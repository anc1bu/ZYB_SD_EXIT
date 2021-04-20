class ZCL_SD_MV45AFZZ_FORM_FLDMD_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_FLDMD .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_FLDMD_002 IMPLEMENTATION.


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

  "--------->> Anıl CENGİZ 21.06.2019 13:31:41
  "YUR-414
  zcl_sd_apr_order_process=>is_delivered_and_modifiable( EXPORTING is_vbak = <ls_vbak>
                                                                   is_vbap = <ls_vbap>
                                                          CHANGING cs_screen = <ls_screen> ).
  "---------<<


ENDMETHOD.
ENDCLASS.
