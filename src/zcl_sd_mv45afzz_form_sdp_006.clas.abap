class ZCL_SD_MV45AFZZ_FORM_SDP_006 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
protected section.
private section.

  types:
    BEGIN OF ty_avlcheck,
      matnr  TYPE matnr,
      lgort  TYPE lgort_d,
      avlqty TYPE mng01,
      kwmeng TYPE kwmeng,
    END OF ty_avlcheck .
  types:
    tth_avlcheck TYPE HASHED TABLE OF ty_avlcheck WITH UNIQUE KEY primary_key COMPONENTS matnr lgort .

  constants GC_MTART_YYK type MTART value 'ZYYK'. "#EC NOTEXT
  constants GC_MTART_ZTIC type MTART value 'ZTIC'. "#EC NOTEXT
  constants CV_DELETE type UPDKZ value 'D'. "#EC NOTEXT
  constants CV_VTWEG_IC type VTWEG value '10'. "#EC NOTEXT
  constants CV_BORCDKNT type VBTYP value 'L'. "#EC NOTEXT
  constants CV_IADESIP type VBTYP value 'H'. "#EC NOTEXT
  constants CV_CREATE type TRTYP value 'H'. "#EC NOTEXT
  constants CV_CHANGE type TRTYP value 'V'. "#EC NOTEXT
  data GT_AVLCHECK type TTH_AVLCHECK .
  constants CV_VTWEG_DIS type VTWEG value '20'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_006 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gt_xvbap>    TYPE tab_xyvbap,
                 <gt_yvbap>    TYPE tab_xyvbap,
                 <gt_xvbep>    TYPE tab_xyvbep,
                 <gv_callbapi> TYPE abap_bool,
                 <gs_vbak>     TYPE vbak,
                 <gs_t180>     TYPE t180,
                 <gv_fcode>    TYPE char20.

  DATA: lt_error  TYPE bapirettab,
        lv_kwmeng TYPE kwmeng,
        lr_data   TYPE REF TO data,
        ls_yvbap  TYPE vbap.

  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <gt_xvbap>.
  lr_data = co_con->get_vars( 'YVBAP' ).     ASSIGN lr_data->* TO <gt_yvbap>.
  lr_data = co_con->get_vars( 'XVBEP' ).     ASSIGN lr_data->* TO <gt_xvbep>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <gv_callbapi>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'FCODE' ).     ASSIGN lr_data->* TO <gv_fcode>.

  CHECK: sy-cprog(6)     NE 'RVKRED',
         <gs_vbak>-vbtyp NE cv_borcdknt, "Borç dekont talebi değilse.
         <gs_vbak>-vbtyp NE cv_iadesip,
         <gv_fcode> NE 'LOES'.

  LOOP AT <gt_xvbap> REFERENCE INTO DATA(gr_xvbap)
    WHERE abgru EQ space
      AND updkz NE cv_delete
      AND pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.

    CHECK: zcl_sd_mv45afzb_frm_chkvbp_002=>check_mtart_kosch( gr_xvbap->matnr ) EQ 0. "Promosyon kotolama süreci ise.

    IF gr_xvbap->kwmeng NE gr_xvbap->kbmeng.
      DATA(lv_hata) = abap_true.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD_VA'
                   id_msgno = '019'
                   id_msgv1 = gr_xvbap->vbeln
                   id_msgv2 = gr_xvbap->posnr
                   id_msgv3 = gr_xvbap->matnr ).
    ENDIF.

  ENDLOOP.

  CHECK: lv_hata EQ abap_true.
  RAISE EXCEPTION TYPE zcx_bc_exit_imp
    EXPORTING
      messages = lo_msg.

ENDMETHOD.
ENDCLASS.
