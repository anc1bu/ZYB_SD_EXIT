class ZCL_SD_MV45AFZZ_FORM_FLDMD_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_FLDMD .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_FLDMD_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_vbak>   TYPE vbak,
                 <ls_vbap>   TYPE vbap,
                 <lt_xvbap>  TYPE tab_xyvbap,
                 <ls_t180>   TYPE t180,
                 <ls_screen> TYPE screen.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBAK' ).   ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'VBAP' ).   ASSIGN lr_data->* TO <ls_vbap>.
  lr_data = co_con->get_vars( 'XVBAP' ).  ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'T180' ).   ASSIGN lr_data->* TO <ls_t180>.
  lr_data = co_con->get_vars( 'SCREEN' ). ASSIGN lr_data->* TO <ls_screen>.

  CASE <ls_screen>-name.
    WHEN 'VBAP-ARKTX'.
      screen-input = 0.
  ENDCASE.

ENDMETHOD.
ENDCLASS.
