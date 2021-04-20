class ZCL_SD_MV45AFZZ_FIELDMOD definition
  public
  final
  create public .

public section.

  data GS_VBAK type VBAK read-only .
  data GS_SCREEN type SCREEN .
  data GT_XVBAP type TAB_XYVBAP read-only .
  data GS_VBAP type VBAP read-only .
  constants CV_YURTICI type VTWEG value '10'. "#EC NOTEXT
  constants CV_YURDISI type VTWEG value '20'. "#EC NOTEXT
  data GS_T180 type T180 .
  constants C_TRTYP_CREATE type TRTYP value 'H'. "#EC NOTEXT
  constants C_TRTYP_CHANGE type TRTYP value 'V'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      value(IS_VBAK) type VBAK optional
      value(IS_VBAP) type VBAP optional
      value(IT_XVBAP) type TAB_XYVBAP optional
      value(IS_SCREEN) type SCREEN optional
      value(IS_T180) type T180 optional .
  methods FIELD_MOD
    exporting
      value(ES_SCREEN) type SCREEN .
protected section.
private section.

  methods YUR_9_FIELD_MOD .
  methods YUR_116_FIELD_MOD .
  methods YUR_307_FIELD_MOD .
  methods YUR_340_FIELD_MOD .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FIELDMOD IMPLEMENTATION.


  METHOD constructor.
    gs_vbak = is_vbak.
    gs_vbap = is_vbap.
    gt_xvbap = it_xvbap.
    gs_screen = is_screen.
    gs_t180 = is_t180.

  ENDMETHOD.


  METHOD field_mod.
    "--------->> Anıl CENGİZ 28.09.2020 08:58:06
    "YUR-739
***acengiz --> YUR-9  Planlanan Siparişte Değişiklik Yapılmasının Engel
*    yur_9_field_mod( ).
***acengiz <-- YUR-9  Planlanan Siparişte Değişiklik Yapılmasının Engel
    "---------<<

    "--->>>MOZDOGAN 25.07.2018 11:21:59
    " YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi

    NEW zcl_sd_paletftr_mamulle( ir_xvbap = REF #( gt_xvbap[] )
                                 is_vbap = gs_vbap
                                 ir_t180 = REF #( gs_t180 ) )->alan_kapatma(
                                  CHANGING cs_screen = gs_screen ).
    "---<<<<<

    "--------->> Anıl CENGİZ 31.12.2020 12:24:18
    "YUR-773
    "Refactoring kapsamında ZCL_SD_MV45AFZZ_FORM_FLDMD_005 içerisine taşındı
    "--------->> Anıl CENGİZ 16.08.2018 12:01:38
    "YUR-116 Yurtiçi Satışlarında "Ödeme Garanti Şeması"
    "ve "Fiyatlandırma Tarihi" Alanları Kapatılmalı
*    yur_116_field_mod( ).
    "---------<<
    "---------<<
    "--------->> Anıl CENGİZ 06.03.2019 14:03:44
    "YUR-328
    "-->> commented by mehmet sertkaya 24.06.2019 16:46:28
    "yur-421
*          yur_307_field_mod( ).
    "-----------------------------<
    "---------<<

*--------------------------------------------------------------------*
    "Ekran Atamasını Yap
*--------------------------------------------------------------------*
    es_screen = gs_screen.

  ENDMETHOD.


  METHOD yur_116_field_mod.
    "ZCL_SD_MV45AFZZ_FORM_FLDMD_005 içerisine taşındı.
*    CASE gs_screen-name.
*      WHEN 'VBKD-ABSSC' OR 'VBKD-PRSDT' OR 'VBKD-LCNUM'.
*        IF gs_vbak-vtweg = cv_yurtici.
*          gs_screen-input = 0.
*          MODIFY SCREEN.
*        ENDIF.
*      WHEN OTHERS.
*    ENDCASE.

  ENDMETHOD.


  METHOD yur_307_field_mod.

*    DATA: lv_day_diff   TYPE zsdt_sip_deg_knt-svktur_gun,
*          lv_svktur_gun TYPE zsdt_sip_deg_knt-svktur_gun.
*
*    CHECK gs_vbak-erdat > '20190219'.
*
*    CASE gs_screen-name.
*
*      WHEN 'VBKD-VSART'.
*
*        IF gs_vbap-posnr IS INITIAL.
*
*         "--------->> add by mehmet sertkaya 24.06.2019 09:47:32
*         if gs_t180-trtyp = c_trtyp_create.
*          gs_screen-input = 1.
*         else.
*         "-----------------------------<<
*          gs_screen-input = 0.
*         endif.
*          MODIFY SCREEN.
*
*
*        ELSE.
*
*          IF gs_t180-trtyp = c_trtyp_change AND sy-batch EQ abap_false.
*            "--------->> Anıl CENGİZ 22.02.2019 07:00:44
*            "YUR-328 Bayi sevk(termin) gün sayısı bakım kontrol tablosu
*            "Erişim sırası 1
*            SELECT SINGLE svktur_gun
*              INTO lv_svktur_gun
*              FROM zsdt_sip_deg_knt
*              WHERE vkorg EQ gs_vbak-vkorg
*                AND vtweg EQ gs_vbak-vtweg
*                AND kunnr EQ gs_vbak-kunnr.
*            IF sy-subrc NE 0.
*              "---------<<
*              "Erişim sırası 2
*              SELECT SINGLE svktur_gun
*                INTO lv_svktur_gun
*                FROM zsdt_sip_deg_knt
*                WHERE vkorg EQ gs_vbak-vkorg
*                  AND vtweg EQ gs_vbak-vtweg
*                  AND lgort EQ gs_vbap-lgort.
*              IF sy-subrc EQ 0.
*                lv_day_diff = sy-datum - gs_vbak-erdat.
*              ENDIF.
*            ELSE.
*              lv_day_diff = sy-datum - gs_vbak-erdat.
*            ENDIF.
*
*            IF lv_day_diff GT lv_svktur_gun AND lv_svktur_gun NE 0.
*              SELECT SINGLE mandt ##WRITE_OK
*                INTO sy-mandt
*                FROM zsdt_svk_tur_kul
*                WHERE vkorg EQ gs_vbak-vkorg
*                 AND  vtweg EQ gs_vbak-vtweg
*                 AND  uname EQ sy-uname.
*              IF sy-subrc <> 0.
*                gs_screen-input = 0.
*                MODIFY SCREEN.
*              ENDIF.
*            ENDIF.
*
*          ENDIF.
*        ENDIF.
*
*      WHEN OTHERS.
*    ENDCASE.

  ENDMETHOD.


  method yur_340_field_mod.

*
*    case gs_screen-name.
*
*      when 'VBKD-VSART'.
*
*        if gs_vbap-posnr is initial.
*
*          gs_screen-input = 0.
*          modify screen.
*
*        endif.
*    endcase.


  endmethod.


METHOD yur_9_field_mod.
  "--------->> Anıl CENGİZ 28.09.2020 11:16:26
  "YUR-739
*    DATA : ls_yb_t_englle TYPE zsd_yb_t_englle,
*           ls_vbfa        TYPE vbfa.
*
*    SELECT SINGLE * FROM zsd_yb_t_englle INTO ls_yb_t_englle
*      WHERE vkorg EQ gs_vbak-vkorg
*      AND vtweg EQ gs_vbak-vtweg.
*    IF sy-subrc IS INITIAL. "sadece yurtiçi siparişleri için
*
*      CLEAR ls_vbfa.
*      SELECT SINGLE * FROM vbfa INTO ls_vbfa
*        WHERE vbelv = gs_vbak-vbeln
*        AND vbtyp_n = 'J'.
*      IF ls_vbfa-vbeln IS NOT INITIAL.
*
*        CASE gs_screen-name.
*          WHEN 'VBKD-VSART'   OR 'RV45A-ETDAT' OR
*               'RV45A-KETDAT' OR 'VBKD-BSTKD' OR
*               'KUWEV-KUNNR'.
*            gs_screen-input = 0.
*            MODIFY SCREEN.
*          WHEN OTHERS.
*        ENDCASE.
*
*      ENDIF.
*
*    ENDIF.
  "---------<<
ENDMETHOD.
ENDCLASS.
