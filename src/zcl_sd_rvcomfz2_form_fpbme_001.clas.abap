class ZCL_SD_RVCOMFZ2_FORM_FPBME_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RVCOMFZ2_FORM_FKOMPBME .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_RVCOMFZ2_FORM_FPBME_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_com_mseg> TYPE mseg,
                 <ls_com_pbme> TYPE kompbme.

  DATA(lr_data) = co_con->get_vars( 'COM_MSEG' ). ASSIGN lr_data->* TO <ls_com_mseg>.
       lr_data  = co_con->get_vars( 'COM_PBME' ). ASSIGN lr_data->* TO <ls_com_pbme>.

  <ls_com_pbme>-zzumlgo = <ls_com_mseg>-umlgo.
  <ls_com_pbme>-zzlifnr = <ls_com_mseg>-lifnr.

ENDMETHOD.
ENDCLASS.
