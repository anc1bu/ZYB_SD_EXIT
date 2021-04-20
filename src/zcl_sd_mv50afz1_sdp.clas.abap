class ZCL_SD_MV50AFZ1_SDP definition
  public
  final
  create public .

public section.

  data GR_XLIPS type ref to DATA .
  data GR_XLIKP type ref to DATA .
  data GR_XVBFA type ref to DATA .
  data GR_V50AGL type ref to DATA .
  data GR_XVBUP type ref to DATA .
  data GR_XVBUK type ref to DATA .
  data GR_YVBFA type ref to DATA .
  data GR_T180 type ref to DATA .
  data GR_LIKP type ref to DATA .

  methods CONSTRUCTOR
    importing
      !IR_XLIPS type ref to DATA
      !IR_XLIKP type ref to DATA
      !IR_XVBFA type ref to DATA
      !IR_V50AGL type ref to DATA
      !IR_XVBUP type ref to DATA
      !IR_XVBUK type ref to DATA
      !IR_YVBFA type ref to DATA
      !IR_T180 type ref to DATA
      !IR_LIKP type ref to DATA .
  methods KONTROLLER .
  methods VERI_ATAMA .
protected section.
private section.

  methods HATA_GOSTER
    importing
      value(IT_RETURN) type BAPIRETTAB .
  methods TASIMA_IRSALIYE .
ENDCLASS.



CLASS ZCL_SD_MV50AFZ1_SDP IMPLEMENTATION.


  METHOD constructor.
    "--------->> Anıl CENGİZ 20.05.2018 13:01:48
    "ZYB_SD_ENH_VL_SDP_CHECK içerisinden çağrılmaktadır.
    "SE20 işlem kodundan enhancement nerde olduğu bakılabilir.
    "---------<<
    gr_xlips = ir_xlips.
    gr_xlikp = ir_xlikp.
    gr_xvbfa = ir_xvbfa .
    gr_yvbfa = ir_yvbfa .
    gr_v50agl = ir_v50agl.
    gr_xvbup = ir_xvbup.
    gr_xvbuk = ir_xvbuk.
    gr_t180 = ir_t180.
    gr_likp = ir_likp.

  ENDMETHOD.


  METHOD hata_goster.
    CHECK it_return IS NOT INITIAL.
*    check sy-calld is not initial.
    CHECK sy-batch IS INITIAL.
    CHECK sy-binpt IS INITIAL.
    CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
    EXPORTING
    it_message = it_return
    EXCEPTIONS
    bal_error  = 1
    OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      DISPLAY LIKE 'E'.
    ELSE.
      "--------->> Anıl CENGİZ 12.08.2018 09:39:10
   " YUR-103 VT02N ekranında "Nakliye Bitiş" yapıldığında "Belgede Hata"
      READ TABLE it_return INTO DATA(ls_return) INDEX 1.
      MESSAGE ID ls_return-id
        TYPE ls_return-type
        NUMBER ls_return-number
        WITH ls_return-message_v1
             ls_return-message_v2
             ls_return-message_v3
             ls_return-message_v4.
*      message e123(zyb_sd).
      "---------<<
    ENDIF.
  ENDMETHOD.


  METHOD kontroller.
    "--------->> Anıl CENGİZ 20.05.2018 12:57:10
    "YUR-28 Palet Satış Ekranı Kontrolleri
    "Faturası var ise teslimat ters kayıt alınamaz.
    DATA: lt_return TYPE bapirettab.
    DATA(lt_rt1) = NEW zcl_sd_palet( ir_xlips  = gr_xlips
                                     ir_xlikp  = gr_xlikp
                                     ir_v50agl = gr_v50agl
                                     )->knt_pltfat( ).
    "---------<<
    "--------->> Anıl CENGİZ 17.10.2018 22:13:03
    "YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
    DATA(lt_rt2) = NEW zcl_sd_paletftr_mamulle(
                                   ir_xlips  = gr_xlips
                                   ir_xlikp  = gr_xlikp
                                   ir_v50agl = gr_v50agl
                                   )->knt_pltfatmamul( ).

    "---------<<

*--------------------------------------------------------------------*
    "Hataları Ekle
*--------------------------------------------------------------------*
    APPEND LINES OF lt_rt1 TO lt_return.
    APPEND LINES OF lt_rt2 TO lt_return.
    SORT lt_return.
    DELETE ADJACENT DUPLICATES FROM lt_return COMPARING ALL FIELDS.
    DELETE lt_return WHERE type EQ 'S'.
*--------------------------------------------------------------------*
    "Hataları Göster
*--------------------------------------------------------------------*
    hata_goster( lt_return ).
  ENDMETHOD.


METHOD tasima_irsaliye.

  FIELD-SYMBOLS: <lt_xlikp> TYPE shp_likp_t,
                 <ls_likp>  TYPE likp.

  ASSIGN gr_likp->* TO <ls_likp>.
  ASSIGN gr_xlikp->* TO <lt_xlikp>.
  ASSIGN <lt_xlikp>[ vbeln = <ls_likp>-vbeln ] TO FIELD-SYMBOL(<ls_xlikp>).

  DATA(lv_vsart) = zcl_sd_tasima_irsaliye=>memory_vsart( ).

  CHECK lv_vsart IS NOT INITIAL.
  <ls_xlikp>-vsart = lv_vsart.


ENDMETHOD.


  METHOD veri_atama.

    "--------->> Anıl CENGİZ 02.08.2018 12:25:13
    "YUR-66  Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
    NEW zcl_sd_paletftr_mamulle( ir_xvbup  = gr_xvbup
                                 ir_xlips  = gr_xlips
                                 ir_xlikp  = gr_xlikp
                                 ir_xvbfa  = gr_xvbfa
                                 ir_yvbfa  = gr_yvbfa
                                 ir_v50agl = gr_v50agl
                                 ir_xvbuk  = gr_xvbuk
                                 ir_t180   = gr_t180
                                     )->atm_pltfatmamul( ).
    "---------<<

    "--------->> Anıl CENGİZ 16.10.2019 15:50:28
    "YUR-495
    tasima_irsaliye( ).
    "---------<<

  ENDMETHOD.
ENDCLASS.
