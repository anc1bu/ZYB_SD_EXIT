class ZCL_SD_RV50C900_FORM_KOPRN_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RV50C900_FORM_KOPRN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_RV50C900_FORM_KOPRN_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_likp>  TYPE likp,
                 <gs_lipsd> TYPE lipsd,
                 <gs_cvbak> TYPE vbak,
                 <gs_cvbap> TYPE vbapvb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'LIKP' ).  ASSIGN lr_data->* TO <gs_likp>.
  lr_data = co_con->get_vars( 'LIPSD' ). ASSIGN lr_data->* TO <gs_lipsd>.
  lr_data = co_con->get_vars( 'CVBAK' ). ASSIGN lr_data->* TO <gs_cvbak>.
  lr_data = co_con->get_vars( 'CVBAP' ). ASSIGN lr_data->* TO <gs_cvbap>.

ENDMETHOD.
ENDCLASS.
