class ZCL_SD_MV45AFZB_FRM_CHKVBP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHKVBP .

  types:
    BEGIN OF ty_kna1,
             kunnr TYPE kunnr,
             ktokd TYPE ktokd,
             brsch TYPE brsch,
           END OF ty_kna1 .
  types:
    tth_kna1 TYPE HASHED TABLE OF ty_kna1 WITH UNIQUE KEY kunnr .
  types:
    BEGIN OF ty_matnr,
        matnr TYPE matnr,
      END OF ty_matnr .
  types:
    tth_matnr TYPE HASHED TABLE OF ty_matnr WITH UNIQUE KEY matnr .

  class-data GT_MATNR type TTH_MATNR .
  class-data GT_KNA1 type TTH_KNA1 .

  class-methods CHECK_MTART_KOSCH
    importing
      !IV_MATNR type MATNR
    returning
      value(RV_RETURN) type SUBRC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHKVBP_002 IMPLEMENTATION.


METHOD check_mtart_kosch.

  DATA: ls_matnr TYPE ty_matnr.

  rv_return = 4.

  ASSIGN gt_matnr[ KEY primary_key COMPONENTS matnr = iv_matnr ] TO FIELD-SYMBOL(<ls_matnr>).
  IF sy-subrc NE 0.
    SELECT SINGLE matnr
      FROM mara
      INTO ls_matnr
      WHERE matnr EQ iv_matnr
        AND mtart EQ zif_sd_mv45afzb_frm_chkvbp~cv_mtart_promosyon  "ZRTM
        AND kosch EQ zif_sd_mv45afzb_frm_chkvbp~cv_kosch_promosyon. "KOTA_PRMSYN
    IF sy-subrc EQ 0.
      INSERT ls_matnr INTO TABLE gt_matnr ASSIGNING <ls_matnr>.
    ENDIF.
  ENDIF.

  IF <ls_matnr> IS ASSIGNED.
    CLEAR: rv_return.
    UNASSIGN: <ls_matnr>.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_vbak>    TYPE vbak,
                 <gs_vbap>    TYPE vbap,
                 <gs_aksvbap> TYPE vbap,
                 <gt_xvbap>   TYPE tab_xyvbap.

  DATA: lr_data TYPE REF TO data,
        ls_kna1 TYPE ty_kna1.

  lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <gt_xvbap>.
  lr_data = co_con->get_vars( 'VBAP' ).  ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( '*VBAP' ). ASSIGN lr_data->* TO <gs_aksvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <gs_vbak>.

  CHECK : check_mtart_kosch( <gs_vbap>-matnr ) EQ 0, "Promosyon kotolama süreci ise.
          <gs_vbap>-abgru EQ space.
  "Mesaj instance yarat.
  DATA(lo_msg) = cf_reca_message_list=>create( ).

  "Ortak Kontroller
  IF <gs_vbak>-auart NE zif_sd_mv45afzb_frm_chkvbp~cv_auart_za11. "Promosyon gönderiminde stş.sip türü ZA11-Plt/Kut.Dışı Nmn.Stş olmalıdır!
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '067'
                 id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_auart_za11 ).
    DATA(lv_hata) = abap_true.
  ENDIF.

  IF <gs_vbap>-lgort NE zif_sd_mv45afzb_frm_chkvbp~cv_lgort_numune. "Promosyon gönderiminde depo yeri 1220-Numune-wm olmalıdır!
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '068'
                 id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_lgort_numune ).
    lv_hata = abap_true.
  ENDIF.

  IF <gs_vbap>-pstyv NE zif_sd_mv45afzb_frm_chkvbp~cv_pstyv_srbst_bdlsz. "Z022-SrbstStk.Bdlsz(0Dgr)
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '071'
                 id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_pstyv_srbst_bdlsz ). "Promosyon gönderiminde kalem tipi Z022 olmalıdır!
    lv_hata = abap_true.
  ENDIF.

  "Dağıtım kanalı bazında kontroller
  CASE <gs_vbak>-vtweg.
    WHEN zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_ic.
      IF <gs_vbak>-vkbur EQ  zif_sd_mv45afzb_frm_chkvbp~cv_vkbur_yi_mrkz. "Satış Büro 1120-Yurtiçi Merkez için sadece 30 dağıtım kanalından gönderim yapılabilir!
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '069'
                     id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_vkbur_yi_mrkz
                     id_msgv2 = zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_dgr ).
        lv_hata = abap_true.
      ENDIF.

    WHEN zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_ihr.



    WHEN zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_dgr.
      IF <gs_vbak>-vkbur EQ  zif_sd_mv45afzb_frm_chkvbp~cv_vkbur_ihr_mrkz. "Satış Büro 1110-Yurtdışı Merkez için sadece 20 dağıtım kanalından gönderim yapılabilir!
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '069'
                     id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_vkbur_ihr_mrkz
                     id_msgv2 = zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_ihr ).
        lv_hata = abap_true.
      ENDIF.

      ASSIGN gt_kna1[ KEY primary_key COMPONENTS kunnr = <gs_vbak>-kunnr ] TO FIELD-SYMBOL(<ls_kna1>).
      IF sy-subrc NE 0.
        SELECT SINGLE kunnr brsch ktokd
          FROM kna1
          INTO ls_kna1
          WHERE kunnr EQ <gs_vbak>-kunnr
            AND ktokd EQ zif_sd_mv45afzb_frm_chkvbp~cv_ktokd_yigi "yurtiçi grup içi
            AND brsch EQ zif_sd_mv45afzb_frm_chkvbp~cv_brsch_ihr_yi. "M900
        IF sy-subrc EQ 0.
          INSERT ls_kna1 INTO TABLE gt_kna1 ASSIGNING <ls_kna1>.
        ENDIF.
      ENDIF.
      IF <ls_kna1> IS ASSIGNED. "Promosyon gönderiminde dağıtım kanalı 20 olmalıdır!
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '070'
                     id_msgv1 = zif_sd_mv45afzb_frm_chkvbp~cv_vtweg_ihr ).
        lv_hata = abap_true.
        UNASSIGN: <ls_kna1>.
      ENDIF.

  ENDCASE.

  CHECK: lv_hata EQ abap_true.
  RAISE EXCEPTION TYPE zcx_bc_exit_imp
    EXPORTING
      messages = lo_msg.
ENDMETHOD.
ENDCLASS.
