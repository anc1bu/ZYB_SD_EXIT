class ZCL_SD_MV45AFZZ_FORM_SDP_005 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
protected section.
private section.

  constants CV_APRPROC_ZF01 type ZSDD_APR_PROCESS value 'ZF01'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_005 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <lt_xvbap> TYPE tab_xyvbap,
                 <ls_vbak>  TYPE vbak.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <ls_vbak>.

  CHECK: <ls_vbak>-vtweg NE '20',
         <ls_vbak>-auart NE 'ZA02',
         <ls_vbak>-auart NE 'ZA03',
         <ls_vbak>-auart NE 'ZA11',
"--------->> Anıl CENGİZ 02.06.2020 11:23:49
"YUR-662
         NEW zcl_sd_paletftr_mamulle( )->valid(
                                   EXPORTING
                                     iv_auart = <ls_vbak>-auart
                                     iv_vtweg = <ls_vbak>-vtweg
                                     iv_kunnr = <ls_vbak>-kunnr ) EQ abap_true.
  "---------<<

  NEW zcl_sd_mv45afzz_frm_mvflvp_001( )->frm_mvflvp( <lt_xvbap> ).

ENDMETHOD.
ENDCLASS.
