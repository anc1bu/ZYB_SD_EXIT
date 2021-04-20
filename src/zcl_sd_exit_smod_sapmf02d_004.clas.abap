class ZCL_SD_EXIT_SMOD_SAPMF02D_004 definition
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

  class-methods GET_DATA .
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02D_004 IMPLEMENTATION.


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
        IF <ls_cust>-val-ktgrd IS INITIAL. "Müşteri Hesap Tayin Grubu mutlaka dolu olmalıdır.
          RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
            EXPORTING
              textid   = zcx_sd_cust_cntrl=>zsd_030
              gv_vkorg = <ls_knvv>-vkorg
              gv_vtweg = <ls_knvv>-vtweg
              gv_ktokd = <ls_kna1>-ktokd
              gv_brsch = <ls_kna1>-brsch.
        ELSE.
          IF <ls_cust>-val-ktgrd NE <ls_knvv>-ktgrd. "Müşteri Hesap Tayin Grubu tablodaki gibi girilmelidir!
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_031
                gv_ktgrd = <ls_cust>-val-ktgrd.
          ENDIF.
        ENDIF.
      ENDIF.

    CATCH zcx_sd_cust_cntrl INTO DATA(lo_cx_sd_cust_cntrl) .
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          previous = lo_cx_sd_cust_cntrl.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
