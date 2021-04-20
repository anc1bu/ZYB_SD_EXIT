class ZCL_SD_MV50AFZ1_FORM_SDP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV50AFZ1_FORM_SDP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV50AFZ1_FORM_SDP_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  DATA: lr_data TYPE REF TO data.

  FIELD-SYMBOLS: <lt_xlips>  TYPE shp_lips_t,
                 <ls_v50agl> TYPE v50agl.

  lr_data = co_con->get_vars( 'XLIPS' ).  ASSIGN lr_data->* TO <lt_xlips>.
  lr_data = co_con->get_vars( 'V50AGL' ). ASSIGN lr_data->* TO <ls_v50agl>.

  CHECK: <ls_v50agl>-warenausgang EQ abap_true. "Mal çıkışı sırasında

  DATA(lo_msg) = cf_reca_message_list=>create( ).

  LOOP AT <lt_xlips> ASSIGNING FIELD-SYMBOL(<ls_xlips>)
    WHERE pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm
    AND ( vtweg EQ '10' OR vtweg EQ '30' ).
    IF <ls_xlips>-lfimg EQ 0.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '056'
                   id_msgv1 = <ls_xlips>-posnr ).
    ENDIF.
  ENDLOOP.

  lo_msg->get_list_as_bapiret( IMPORTING et_list = DATA(lt_list) ).
  IF lt_list IS NOT INITIAL.
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.

ENDMETHOD.
ENDCLASS.
