*"* use this source file for your ABAP unit test classes
CLASS lct_error_handling DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.

    DATA: cut      TYPE REF TO zcl_sd_mv45afzz_frm_mvflvp_001,
          lo_con   TYPE REF TO zcl_bc_exit_container,
          gt_xvbap TYPE tab_xyvbap,
          lo_msg   TYPE REF TO if_reca_message_list,
          lt_list  TYPE bapirettab.
    METHODS: setup,
      execute
        RETURNING VALUE(rs_message) TYPE recamsg,
      sadece_yyk_varsa FOR TESTING RAISING cx_static_check,
      yyk_ve_seramik_varsa FOR TESTING RAISING cx_static_check,
      sadece_seramik_varsa FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS lct_error_handling IMPLEMENTATION.

  METHOD setup.
    "given
    cut = NEW zcl_sd_mv45afzz_frm_mvflvp_001(  ).
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

  METHOD sadece_yyk_varsa.

    gt_xvbap = VALUE #( ( pstyv = 'Z026' matnr = 'PALET1' updkz = 'D' )
                        ( pstyv = 'Z020' matnr = 'K95002.1' updkz = 'I' ) ).

    lo_con = NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_MV45AFZZ_FRM_MVFLVP'
                                                             vars = VALUE #( ( name = 'XVBAP' value = REF #( gt_xvbap ) ) ) ) ).
    "then
    cl_abap_unit_assert=>assert_initial( execute( ) ). "Satırlarda sadece YYK var ise hata beklenmez.

  ENDMETHOD.

  METHOD yyk_ve_seramik_varsa.

    gt_xvbap = VALUE #( ( pstyv = 'Z026' matnr = 'PALET1'   updkz = 'D' )
                        ( pstyv = 'Z020' matnr = 'K95002.1' updkz = 'I' )
                        ( pstyv = 'Z020' matnr = 'D10509.1' updkz = 'I' ) ).

    lo_con = NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_MV45AFZZ_FRM_MVFLVP'
                                                             vars = VALUE #( ( name = 'XVBAP' value = REF #( gt_xvbap ) ) ) ) ).
    "then
    cl_abap_unit_assert=>assert_not_initial( execute( ) ). "Satırlarda hem YYK hem de seramik var ise hata beklenir.

  ENDMETHOD.

  METHOD sadece_seramik_varsa.

    gt_xvbap = VALUE #( ( pstyv = 'Z026' matnr = 'PALET1'   updkz = 'D' )
                        ( pstyv = 'Z020' matnr = 'D10509.1' updkz = 'I' ) ).

    lo_con = NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_MV45AFZZ_FRM_MVFLVP'
                                                             vars = VALUE #( ( name = 'XVBAP' value = REF #( gt_xvbap ) ) ) ) ).
    "then
    cl_abap_unit_assert=>assert_not_initial( execute( ) ). "Satırlarda sadece seramik var ise hata beklenir.

  ENDMETHOD.

ENDCLASS.
