class ZCL_SD_MV45AFZZ_FRM_MVFLVP_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FRM_MVFLVP .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FRM_MVFLVP_003 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
  FIELD-SYMBOLS: <gs_vbap>      TYPE vbap,
                 <gs_vbak>      TYPE vbak,
                 <gs_vbkd>      TYPE vbkd,
                 <gs_t180>      TYPE t180,
                 <gv_call_bapi> TYPE abap_bool.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBAP' ).      ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'VBKD' ).      ASSIGN lr_data->* TO <gs_vbkd>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <gv_call_bapi>.

  CHECK: <gs_vbap>-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm,
         <gs_vbak>-vtweg EQ '10',
         <gs_t180>-trtyp EQ 'V',
         <gv_call_bapi> IS INITIAL.

  <gs_vbkd>-prsdt = sy-datum.

ENDMETHOD.
ENDCLASS.
