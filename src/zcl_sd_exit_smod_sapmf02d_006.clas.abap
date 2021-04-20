class ZCL_SD_EXIT_SMOD_SAPMF02D_006 definition
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
protected section.
private section.

  types:
    BEGIN OF ty_vkbur,
           key TYPE zsds_cust_vkbur_key,
         END OF ty_vkbur .
  types:
    tt_vkbur TYPE HASHED TABLE OF ty_vkbur WITH UNIQUE KEY primary_key COMPONENTS key .

  class-data GT_CUST type TT_CUST .
  class-data GT_VKBUR type TT_VKBUR .

  class-methods GET_DATA .
  class-methods CHECK_VKBUR
    importing
      !IS_KEY type ZSDS_CUST_VKBUR_KEY
    raising
      ZCX_SD_CUST_CNTRL .
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02D_006 IMPLEMENTATION.


METHOD CHECK_VKBUR.

  DATA: ls_vkbur TYPE zsdt_cust_vkbur.

  ASSIGN gt_vkbur[ KEY primary_key COMPONENTS key = is_key ] TO FIELD-SYMBOL(<ls_vkbur>).
  IF <ls_vkbur> IS NOT ASSIGNED.
    SELECT SINGLE *
      FROM zsdt_cust_vkbur
      INTO ls_vkbur
      WHERE vkorg EQ is_key-vkorg
        AND vtweg EQ is_key-vtweg
        AND ktokd EQ is_key-ktokd
        AND brsch EQ is_key-brsch
        AND vkbur EQ is_key-vkbur.
    IF sy-subrc EQ 0.
      INSERT VALUE #( key = CORRESPONDING #( ls_vkbur ) ) INTO TABLE gt_vkbur ASSIGNING <ls_vkbur>.
    ELSE.
      RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
        EXPORTING
          textid = zcx_sd_cust_cntrl=>zsd_035.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD GET_DATA.

  DATA: lt_cust TYPE STANDARD TABLE OF zsdt_cust_cntrl.

  SELECT *
    FROM zsdt_cust_cntrl
    INTO TABLE lt_cust.

  LOOP AT lt_cust ASSIGNING FIELD-SYMBOL(<ls_cust>).
    INSERT VALUE #( key = CORRESPONDING #( <ls_cust> )
                    val = CORRESPONDING #( <ls_cust> ) ) INTO TABLE gt_cust.

  ENDLOOP.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_kna1> TYPE kna1,
                 <ls_knvv> TYPE knvv.

  get_data( ).

  DATA(lr_data) = co_con->get_vars( 'KNA1' ).  ASSIGN lr_data->* TO <ls_kna1>.
       lr_data  = co_con->get_vars( 'KNVV' ).  ASSIGN lr_data->* TO <ls_knvv>.

  CHECK: <ls_knvv>-vkorg IS NOT INITIAL, "Satış alanı bakımı sırasında kontrol yapılır.
         <ls_knvv>-vtweg IS NOT INITIAL, "Satış alanı bakımı sırasında kontrol yapılır.
         <ls_kna1>-ktokd IS NOT INITIAL, "Hesap grupsuz müşteri açılamaz.
         <ls_kna1>-brsch IS NOT INITIAL. "Müşteri ana verisinde zorunlu alan.

  ASSIGN gt_cust[ KEY primary_key COMPONENTS key = VALUE #( vkorg = <ls_knvv>-vkorg
                                                            vtweg = <ls_knvv>-vtweg
                                                            ktokd = <ls_kna1>-ktokd
                                                            brsch = <ls_kna1>-brsch ) ] TO FIELD-SYMBOL(<ls_cust>).
  TRY.
      IF <ls_cust> IS NOT ASSIGNED.
        RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
          EXPORTING
            textid   = zcx_sd_cust_cntrl=>zsd_022
            gv_vkorg = <ls_knvv>-vkorg
            gv_vtweg = <ls_knvv>-vtweg
            gv_ktokd = <ls_kna1>-ktokd
            gv_brsch = <ls_kna1>-brsch.
      ELSE.
        IF <ls_cust>-val-zvkbur EQ abap_true. "Satış bürosu kontrolü yapılacak.
          check_vkbur( VALUE #( vkorg = <ls_knvv>-vkorg
                                vtweg = <ls_knvv>-vtweg
                                ktokd = <ls_kna1>-ktokd
                                brsch = <ls_kna1>-brsch
                                vkbur = <ls_knvv>-vkbur ) ).
        ENDIF.
      ENDIF.

    CATCH zcx_sd_cust_cntrl INTO DATA(lo_cx_sd_cust_cntrl) .
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          previous = lo_cx_sd_cust_cntrl.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
