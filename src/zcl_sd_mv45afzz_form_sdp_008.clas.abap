class ZCL_SD_MV45AFZZ_FORM_SDP_008 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_008 IMPLEMENTATION.


  METHOD zif_bc_exit_imp~execute.

    FIELD-SYMBOLS: <gt_xvbap> TYPE tab_xyvbap,
                   <gs_vbak>  TYPE vbak,
                   <gv_fcode> TYPE char20,
                   <gs_t180>  TYPE t180.

    DATA: lr_data TYPE REF TO data.

    lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <gt_xvbap>.
    lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <gs_vbak>.
    lr_data = co_con->get_vars( 'FCODE' ). ASSIGN lr_data->* TO <gv_fcode>.
    lr_data = co_con->get_vars( 'T180' ).  ASSIGN lr_data->* TO <gs_t180>.

    CHECK: <gv_fcode> NE 'LOES',
           <gs_vbak>-vtweg EQ zif_sd_mv45afzz_form_sdp~gcv_vtweg_dom.

    DATA(lo_risk) = NEW zcl_sd_risk_kontrol( is_vbak  = <gs_vbak>
                                             it_xvbap = <gt_xvbap> ).

    TRY.
        lo_risk->check_risk( ).
      CATCH zcx_sd_risk_kontrol INTO DATA(lx_sd_risk_kontrol).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_risk_kontrol->messages.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
