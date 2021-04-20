*"* use this source file for your ABAP unit test classes
CLASS lct_manuel_fyt_giris_kntrl DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: cut      TYPE REF TO zcl_sd_rv61afzb_form_bwend_001,
          lo_con   TYPE REF TO zcl_bc_exit_container,
          lo_msg   TYPE REF TO if_reca_message_list,
          lt_list  TYPE bapirettab,
          gt_xkomv TYPE zcl_sd_rv61afzb_form_bwend_001=>tt_xkomv,
          gs_komp  TYPE komp,
          gs_komk  TYPE komk.

    METHODS: setup,
      execute
        RETURNING VALUE(rs_message) TYPE recamsg,
      malzeme_turu_kontrolu FOR TESTING RAISING cx_static_check,
      malzeme_turu_kontrolu_negatif FOR TESTING RAISING cx_static_check,
      ihracat_degilse FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS lct_manuel_fyt_giris_kntrl IMPLEMENTATION.

  METHOD setup.
    "given
    cut = NEW zcl_sd_rv61afzb_form_bwend_001(  ).
  ENDMETHOD.

  METHOD execute.
    "when
    TRY.
        cut->zif_bc_exit_imp~execute( CHANGING co_con = lo_con ) .
      CATCH zcx_bc_exit_imp INTO DATA(lx_bc_exit_imp).
        "then
        lo_msg ?= lx_bc_exit_imp->messages.
        lo_msg->get_first_message( IMPORTING es_message = rs_message ).
    ENDTRY.
  ENDMETHOD.
*-------------------------------------------------------------------
  METHOD malzeme_turu_kontrolu. "check_mtart
    "ZSDT_VLD_MTART tablosunda "Yurtiçi Manuel Fiyat İşlemleri" kolonunda ZYYK malzeme türü tıklı olmalıdır.
    gt_xkomv = VALUE #( ( kschl = 'ZF01' kinak = '' ) ).
    gs_komp  = VALUE #( mtart = 'ZYYK' ).
    "--------->> Anıl CENGİZ 7 May 2020 09:49:59
    "YUR-654
    gs_komk = VALUE #( vtweg = '10' ).
    "---------<<
    lo_con = NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_RV61AFZB_FORM_BWRTNEND'
                                                             vars = VALUE #( ( name = 'XKOMV' value = REF #( gt_xkomv ) )
                                                                             ( name = 'KOMP'  value = REF #( gs_komp ) )
                                                                             ( name = 'KOMK'  value = REF #( gs_komk ) ) ) ) ).
    "then
    cl_abap_unit_assert=>assert_not_initial( execute( ) ). "Malzeme türü tablosu dolu ise hata beklenir.

  ENDMETHOD.
*-------------------------------------------------------------------
  METHOD malzeme_turu_kontrolu_negatif. "check_mtart
    "ZSDT_VLD_MTART tablosunda "Yurtiçi Manuel Fiyat İşlemleri" kolonunda hiç bir malzeme türü tıklı değildir. Kısacası malzeme türü yoktur.
    gt_xkomv = VALUE #( ( kschl = 'ZF01' kinak = '' ) ).
    gs_komp  = VALUE #( mtart = ' ' ).

    lo_con = NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_RV61AFZB_FORM_BWRTNEND'
                                                             vars = VALUE #( ( name = 'XKOMV' value = REF #( gt_xkomv ) )
                                                                             ( name = 'KOMP'  value = REF #( gs_komp ) )
                                                                             ( name = 'KOMK'  value = REF #( gs_komk ) ) ) ) ).
    "then
    cl_abap_unit_assert=>assert_initial( execute( ) ). "Malzeme türü tablosu dolu ise hata beklenmez.

  ENDMETHOD.
*-------------------------------------------------------------------
  "YUR-654
  METHOD ihracat_degilse.



  ENDMETHOD.
*-------------------------------------------------------------------
ENDCLASS.
