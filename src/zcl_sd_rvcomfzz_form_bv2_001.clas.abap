class ZCL_SD_RVCOMFZZ_FORM_BV2_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RVCOMFZZ_FORM_FILLBV2 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_RVCOMFZZ_FORM_BV2_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <com_likp> TYPE likp,
                 <com_kbv2> TYPE komkbv2.

  DATA(lr_data) = co_con->get_vars( 'COM_LIKP' ).   ASSIGN lr_data->* TO <com_likp>.
       lr_data  = co_con->get_vars( 'COM_KBV2' ).   ASSIGN lr_data->* TO <com_kbv2>.

  <com_kbv2>-zvsart = <com_likp>-vsart.

ENDMETHOD.
ENDCLASS.
