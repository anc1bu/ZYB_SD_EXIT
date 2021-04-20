class ZCL_SD_LVKMPF0I_FORM_ABS_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_LVKMPF0I_FORM_ABS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_LVKMPF0I_FORM_ABS_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_rlikp> TYPE likp,
                 <gs_xvbkd> TYPE vbkdvb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'RLIKP' ). ASSIGN lr_data->* TO <gs_rlikp>.
  lr_data = co_con->get_vars( 'XVBKD' ). ASSIGN lr_data->* TO <gs_xvbkd>.

  IF <gs_rlikp> IS ASSIGNED AND <gs_rlikp>-lcnum IS NOT INITIAL AND <gs_rlikp>-vbeln NA '$'.
    zcl_sd_toolkit=>enqueue_read_akkp( EXPORTING iv_lcnum = <gs_rlikp>-lcnum
                                                 iv_vbeln_vl = <gs_rlikp>-vbeln
                                                 iv_same_user_cntrl = abap_false ).
    RETURN.
  ENDIF.

  IF <gs_xvbkd> IS ASSIGNED.
    zcl_sd_toolkit=>enqueue_read_akkp( EXPORTING iv_lcnum = <gs_xvbkd>-lcnum
                                                 iv_vbeln_va = <gs_xvbkd>-vbeln   ).
  ENDIF.

ENDMETHOD.
ENDCLASS.
