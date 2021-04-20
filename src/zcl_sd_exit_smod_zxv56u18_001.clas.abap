class ZCL_SD_EXIT_SMOD_ZXV56U18_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_ZXV56U18 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_ZXV56U18_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <i_fcode>    TYPE fcode,
                 <i_xvttk_wa> TYPE vttkvb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'I_FCODE' ).    ASSIGN lr_data->* TO <i_fcode>.
  lr_data = co_con->get_vars( 'I_XVTTK_WA' ). ASSIGN lr_data->* TO <i_xvttk_wa>.

  CHECK: <i_fcode> EQ zif_sd_exit_smod_zxv56u18~cv_fcode_shpmt_compltn.

  IF <i_xvttk_wa>-tdlnr IS INITIAL.

    DATA(lo_msg) = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '091'
                 id_msgv1 = space ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.

  ENDIF.

ENDMETHOD.
ENDCLASS.
