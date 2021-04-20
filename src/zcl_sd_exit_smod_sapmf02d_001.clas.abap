class ZCL_SD_EXIT_SMOD_SAPMF02D_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_SAPMF02D .

  types:
    BEGIN OF ty_cust,
             key type ZSDS_CUST_CNTRL_KEY,
             val type ZSDS_CUST_CNTRL_fld,
           END OF ty_cust .
  types:
    tt_cust TYPE HASHED TABLE OF ty_cust WITH UNIQUE KEY PRIMARY_KEY COMPONENTS key .

  class-methods GET_CUST
    importing
      !IS_KEY type ZSDS_CUST_CNTRL_KEY
    returning
      value(RS_CUST) type TY_CUST
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.

  class-data GT_CUST type TT_CUST .

  class-methods GET_STCD2
    importing
      !IV_STCD2 type STCD2
      !IV_KUNNR type KUNNR
    returning
      value(RV_KUNNR) type KUNNR .
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02D_001 IMPLEMENTATION.


METHOD get_cust.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

  ASSIGN gt_cust[ KEY primary_key COMPONENTS key = is_key ] TO FIELD-SYMBOL(<ls_cust>).
  IF sy-subrc NE 0.
    DATA(ls_cust) = zcl_sd_toolkit=>get_cust_cntrl( is_key ).
    IF ls_cust IS INITIAL.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '022'
                   id_msgv1 = is_key-vkorg
                   id_msgv2 = is_key-vtweg
                   id_msgv3 = is_key-ktokd
                   id_msgv4 = is_key-brsch ).
    ELSE.
      INSERT ls_cust INTO TABLE gt_cust ASSIGNING <ls_cust>.
    ENDIF.
  ENDIF.

  IF lo_msg->is_empty( ) NE abap_true.
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.

  rs_cust = <ls_cust>.

ENDMETHOD.


METHOD get_stcd2.

  IF rv_kunnr IS INITIAL. "Static metod olduğu için rv_kunnr session boyunca kalır.
    SELECT SINGLE kunnr
      FROM kna1
      INTO rv_kunnr
      WHERE stcd2 EQ iv_stcd2
        AND kunnr NE iv_kunnr
        AND loevm EQ abap_false.
  ENDIF.

ENDMETHOD.


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

  ASSIGN gt_cust[ KEY primary_key COMPONENTS key = VALUE #( vkorg = <ls_knvv>-vkorg
                                                            vtweg = <ls_knvv>-vtweg
                                                            ktokd = <ls_kna1>-ktokd
                                                            brsch = <ls_kna1>-brsch ) ] TO FIELD-SYMBOL(<ls_cust>).
  IF sy-subrc NE 0.
    DATA(ls_cust) = zcl_sd_toolkit=>get_cust_cntrl( VALUE #(  vkorg = <ls_knvv>-vkorg
                                                              vtweg = <ls_knvv>-vtweg
                                                              ktokd = <ls_kna1>-ktokd
                                                              brsch = <ls_kna1>-brsch  ) ).
    IF ls_cust IS INITIAL.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '022'
                   id_msgv1 = <ls_knvv>-vkorg
                   id_msgv2 = <ls_knvv>-vtweg
                   id_msgv3 = <ls_kna1>-ktokd
                   id_msgv4 = <ls_kna1>-brsch ).
    ELSE.
      INSERT ls_cust INTO TABLE gt_cust ASSIGNING <ls_cust>.
    ENDIF.
  ELSE.
    IF <ls_cust>-val-zvrmukr EQ abap_true. "Vergi Numarası Mükerrerlik Kontrolü
      IF get_stcd2( EXPORTING iv_stcd2 = <ls_kna1>-stcd2
                              iv_kunnr = <ls_kna1>-kunnr ) IS NOT INITIAL.
*          "--------->> Anıl CENGİZ 11.11.2019 10:24:40
*          "YUR-517
*          AND sy-uname NE 'ALPER.SAYAR'.
*          "---------<<
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '034'
                     id_msgv1 = <ls_kna1>-stcd2
                     id_msgv2 = <ls_kna1>-kunnr ).
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
