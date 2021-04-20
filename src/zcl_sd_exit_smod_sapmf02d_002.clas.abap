class ZCL_SD_EXIT_SMOD_SAPMF02D_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_SAPMF02D .
protected section.
private section.

  class ZCL_SD_EXIT_SMOD_SAPMF02D_001 definition load .
  class-data GT_CUST type ZCL_SD_EXIT_SMOD_SAPMF02D_001=>TT_CUST .
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02D_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_kna1> TYPE kna1,
                 <ls_knvv> TYPE knvv.

  DATA(lr_data) = co_con->get_vars( 'KNA1' ).  ASSIGN lr_data->* TO <ls_kna1>.
  lr_data  = co_con->get_vars( 'KNVV' ).  ASSIGN lr_data->* TO <ls_knvv>.

  CHECK: <ls_knvv>-vkorg IS NOT INITIAL, "Satış alanı bakımı sırasında kontrol yapılır.
         <ls_knvv>-vtweg IS NOT INITIAL, "Satış alanı bakımı sırasında kontrol yapılır.
         <ls_kna1>-ktokd IS NOT INITIAL, "Hesap grupsuz müşteri açılamaz.
         <ls_kna1>-brsch IS NOT INITIAL. "Müşteri ana verisinde zorunlu alan.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

  IF zcl_sd_exit_smod_sapmf02d_001=>get_cust( VALUE #( vkorg = <ls_knvv>-vkorg
                                                       vtweg = <ls_knvv>-vtweg
                                                       ktokd = <ls_kna1>-ktokd
                                                       brsch = <ls_kna1>-brsch ) )-val-zvruzun EQ abap_true. "Vergi Numarası Uzunluk Kontrolü
    DATA(len) = strlen( <ls_kna1>-stcd2 ).
    IF <ls_kna1>-stkzn EQ 'X'.
      IF len <> 11.
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '023'
                     id_msgv1 = <ls_knvv>-vkorg
                     id_msgv2 = <ls_knvv>-vtweg
                     id_msgv3 = <ls_kna1>-ktokd
                     id_msgv4 = <ls_kna1>-brsch ).
      ENDIF.
    ELSE.
      IF len <> 10.
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '024'
                     id_msgv1 = <ls_knvv>-vkorg
                     id_msgv2 = <ls_knvv>-vtweg
                     id_msgv3 = <ls_kna1>-ktokd
                     id_msgv4 = <ls_kna1>-brsch ).
      ENDIF.
    ENDIF.
  ENDIF.


  IF lo_msg->is_empty( ) NE abap_true.
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.

ENDMETHOD.
ENDCLASS.
