class ZCL_SD_MV45AFZB_FRM_CHKVBP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHKVBP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHKVBP_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_vbak>    TYPE vbak,
                 <ls_vbap>    TYPE vbap,
                 <ls_aksvbap> TYPE vbap,
                 <lt_xvbap>   TYPE tab_xyvbap.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAP' ).  ASSIGN lr_data->* TO <ls_vbap>.
  lr_data = co_con->get_vars( '*VBAP' ). ASSIGN lr_data->* TO <ls_aksvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <ls_vbak>.

  CHECK: <ls_vbak>-vtweg EQ '20' OR
         ( <ls_vbak>-vtweg EQ '10' AND  <ls_vbak>-vkbur EQ '1120' ) OR
         ( <ls_vbak>-vtweg EQ '30' AND  <ls_vbak>-vkbur EQ '1120' ).


  TRY.
      DATA(rr_vld_auart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                         var = 'AUART'
                                                                         val = REF #( <ls_vbak>-auart )
                                                                         surec = 'IHR_TAM_PLT_NUMNE_DEPO' ) ) .
      ASSIGN rr_vld_auart->* TO FIELD-SYMBOL(<lv_vld_auart>).

    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.
  ENDTRY.

  CHECK: <lv_vld_auart> EQ abap_true. "Geçerli sipariş türleri aşağıdaki kontrol çalışacaktır.

  "Depo yeri değişmediği için yapılmıştır.
  IF <ls_aksvbap>-lgort EQ <ls_vbap>-lgort.
    ASSIGN <lt_xvbap>[ posnr = <ls_vbap>-posnr ] TO FIELD-SYMBOL(<ls_xvbap>).
    <ls_aksvbap>-lgort = <ls_xvbap>-lgort.
  ENDIF.

  TRY.
      DATA(rr_vld_lgort) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                         var = 'LGORT'
                                                                         val = REF #( <ls_vbap>-lgort )
                                                                         surec = 'IHR_TAM_PLT_NUMNE_DEPO' ) ) .
      ASSIGN rr_vld_lgort->* TO FIELD-SYMBOL(<lv_vld_lgort>).

    CATCH zcx_sd_exc_vld_cntrl INTO lx_sd_exc_vld_cntrl.
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.
  ENDTRY.

  CHECK: <lv_vld_lgort> EQ abap_false. "Geçerli depo değil ise hata verdirilir.

  DATA(lo_msg) = cf_reca_message_list=>create( ).
  lo_msg->add( id_msgty = 'E'
               id_msgid = 'ZSD'
               id_msgno = '059'
               id_msgv1 = <ls_vbap>-lgort ).
  RAISE EXCEPTION TYPE zcx_bc_exit_imp
    EXPORTING
      messages = lo_msg.


ENDMETHOD.
ENDCLASS.
