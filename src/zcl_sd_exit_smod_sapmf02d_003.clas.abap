class ZCL_SD_EXIT_SMOD_SAPMF02D_003 definition
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
  class-methods GET_KKBER_WAERS
    importing
      !IV_KKBER type KKBER
    returning
      value(RV_WAERS) type WAERS .
  class-methods GET_KKBER
    importing
      !IV_KUNNR type KUNNR
      !IV_KKBER type KKBER
    returning
      value(RV_KKBER) type KKBER .
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02D_003 IMPLEMENTATION.


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


METHOD get_kkber.

  IF rv_kkber IS INITIAL. "Static metod olduğu için değişken silinmez.
    SELECT SINGLE kkber
      FROM knkk
      INTO rv_kkber
       WHERE kunnr EQ iv_kunnr
         AND kkber NE iv_kkber. "Girilen değer dışında var mı diye bakılır.
  ENDIF.

ENDMETHOD.


method GET_KKBER_WAERS.

  SELECT SINGLE waers
    FROM t014
    INTO rv_waers
    WHERE kkber EQ iv_kkber.

endmethod.


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
        IF <ls_cust>-val-kkber IS NOT INITIAL. "Kredi kontrolü zorunlu demektir.
          "Kredi kontrol alanı girilmemiş ise hata verdirilir.
          IF <ls_knvv>-kkber IS INITIAL.
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_025
                gv_vkorg = <ls_knvv>-vkorg
                gv_vtweg = <ls_knvv>-vtweg
                gv_ktokd = <ls_kna1>-ktokd
                gv_brsch = <ls_kna1>-brsch.
          ELSEIF <ls_cust>-val-kkber NE <ls_knvv>-kkber. "Uygun kredi kontrol alanı girilmiş mi?
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_027
                gv_kkber = <ls_cust>-val-kkber.
          ELSEIF get_kkber_waers( <ls_knvv>-kkber ) NE <ls_knvv>-waers. "Girilen para birimi ile kredi kontrolü para birimi aynı mı?
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_028
                gv_waers = <ls_knvv>-waers.
          ELSEIF get_kkber( EXPORTING iv_kunnr = <ls_knvv>-kunnr
                                      iv_kkber = <ls_knvv>-kkber ) IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_029
                gv_kunnr = <ls_knvv>-kunnr
                gv_kkber = get_kkber( EXPORTING iv_kunnr = <ls_knvv>-kunnr
                                                iv_kkber = <ls_knvv>-kkber ).
          ENDIF.
        ELSE. "Kredi kontrol alanı girilmemelidir.
          IF <ls_knvv>-kkber IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_sd_cust_cntrl
              EXPORTING
                textid   = zcx_sd_cust_cntrl=>zsd_026
                gv_vkorg = <ls_knvv>-vkorg
                gv_vtweg = <ls_knvv>-vtweg
                gv_ktokd = <ls_kna1>-ktokd
                gv_brsch = <ls_kna1>-brsch.
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
