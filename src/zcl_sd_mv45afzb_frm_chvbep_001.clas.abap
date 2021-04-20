class ZCL_SD_MV45AFZB_FRM_CHVBEP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHVBEP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHVBEP_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  TYPES: BEGIN OF ty_svbep,
           tabix TYPE syst_tabix,
         END OF ty_svbep.

  FIELD-SYMBOLS: <gs_vbep>      TYPE vbep,
                 <gs_star_vbep> TYPE vbep,
                 <gs_svbep>     TYPE ty_svbep,
                 <gs_vbak>      TYPE vbak,
                 <gs_xvbup>     TYPE vbupvb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBEP' ).  ASSIGN lr_data->* TO <gs_vbep>.
  lr_data = co_con->get_vars( '*VBEP' ). ASSIGN lr_data->* TO <gs_star_vbep>.
  lr_data = co_con->get_vars( 'SVBEP' ). ASSIGN lr_data->* TO <gs_svbep>.
  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'XVBUP' ). ASSIGN lr_data->* TO <gs_xvbup>.

  CHECK: zcl_sd_mv45afzz_form_fldmd_004=>check_vtweg( EXPORTING iv_vkorg = <gs_vbak>-vkorg
                                                                iv_vtweg = <gs_vbak>-vtweg ) EQ abap_true, "Dağıtım kanalı
         <gs_xvbup>-lfsta NE 'A'.
  "Teslimat işlemi başlamış ise "İstenen teslim tarihi" değiştirilemez.
  IF ( <gs_vbep>-edatu NE <gs_vbak>-vdatu AND <gs_svbep>-tabix = 0 OR
       <gs_vbep>-edatu NE <gs_star_vbep>-edatu AND <gs_svbep>-tabix > 0 ).

    "--------->> Anıl CENGİZ 15.02.2021 15:41:52
    "YUR-847
*    SELECT SINGLE mandt
*      INTO sy-mandt
*      FROM zsdt_svk_tur_kul
*      WHERE vkorg EQ <gs_vbak>-vkorg
*        AND  vtweg EQ <gs_vbak>-vtweg
*        AND  uname EQ sy-uname.
    TRY.
        DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                          var   = 'USER'
                                                                          val   = REF #( sy-uname )
                                                                          surec = 'YI_SVK_BASLAMA_KNTRL' ) ) .
        ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).
*    IF sy-subrc <> 0.
        IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
          "---------<<
          DATA(lo_msg) = cf_reca_message_list=>create( ).
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD'
                       id_msgno = '075'
                       id_msgv1 = <gs_star_vbep>-edatu ).
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lo_msg.
        ENDIF.

      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.
  ENDIF.

ENDMETHOD.
ENDCLASS.
