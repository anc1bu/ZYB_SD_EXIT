class ZCL_SD_MV45AFZZ_FORM_SDP_009 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS cv_aprproc_zf01 TYPE zsdd_apr_process VALUE 'ZF01'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_009 IMPLEMENTATION.


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

  FIELD-SYMBOLS: <lt_xvbap> TYPE tab_xyvbap,
                 <ls_vbak>  TYPE vbak,
                 <ls_yvbak> TYPE vbak,
                 <ls_t180>  TYPE t180,
                 <lt_xkomv> TYPE komv_tab.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'YVBAK' ).     ASSIGN lr_data->* TO <ls_yvbak>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
  lr_data = co_con->get_vars( 'XKOMV' ).     ASSIGN lr_data->* TO <lt_xkomv>.


  CHECK: zcl_sd_mv45afzz_mvtovbak_001=>check_cntrl( co_con ) EQ abap_true.

  NEW zcl_sd_thslt_kntrl( VALUE #( datum = <ls_vbak>-erdat
                                   knuma = <ls_vbak>-zz_knuma_ag
                                   vkorg = <ls_vbak>-vkorg
                                   vtweg = <ls_vbak>-vtweg
                                   brsch = zcl_sd_toolkit=>get_brsch( <ls_vbak>-kunnr )-brsch
                                   kunnr = <ls_vbak>-kunnr
                                   vbtyp = <ls_vbak>-vbtyp ) )->execute( ).

ENDMETHOD.
ENDCLASS.
