CLASS zcl_sd_mv45afzz_form_fldmd_005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_form_fldmd .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sd_mv45afzz_form_fldmd_005 IMPLEMENTATION.


  METHOD zif_bc_exit_imp~execute.

    FIELD-SYMBOLS: <ls_vbak>   TYPE vbak,
                   <ls_vbap>   TYPE vbap,
                   <lt_xvbap>  TYPE tab_xyvbap,
                   <ls_t180>   TYPE t180,
                   <ls_screen> TYPE screen.

    DATA: lr_data TYPE REF TO data.

    lr_data = co_con->get_vars( 'VBAK' ).   ASSIGN lr_data->* TO <ls_vbak>.
    lr_data = co_con->get_vars( 'VBAP' ).   ASSIGN lr_data->* TO <ls_vbap>.
    lr_data = co_con->get_vars( 'XVBAP' ).  ASSIGN lr_data->* TO <lt_xvbap>.
    lr_data = co_con->get_vars( 'T180' ).   ASSIGN lr_data->* TO <ls_t180>.
    lr_data = co_con->get_vars( 'SCREEN' ). ASSIGN lr_data->* TO <ls_screen>.


    TRY.
        DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                     var = 'USER'
                                                                     val = REF #( sy-uname )
                                                                     surec = 'YI_FYTTRH_IZIN' ) ) .
        ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

        CHECK: <lv_exc_user> EQ abap_false, "istisna kullanıcısı ise aşağıdaki kontrole girmez.
               <ls_vbak>-vtweg EQ zif_sd_mv45afzz_form_fldmd~cv_vtweg_icpiyasa.

        CASE <ls_screen>-name.
          WHEN 'VBKD-ABSSC' OR 'VBKD-PRSDT' OR 'VBKD-LCNUM'.
            screen-input = 0.
        ENDCASE.

      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
