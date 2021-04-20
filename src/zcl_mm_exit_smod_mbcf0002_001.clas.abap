class ZCL_MM_EXIT_SMOD_MBCF0002_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EXIT_SMOD_MBCF0002 .

  class-methods ZMB_MIGO_BADI
    importing
      !IV_MSEG type MSEG
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_MBCF0002_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_mseg> TYPE mseg,
                 <ls_mkpf> TYPE mkpf.

  DATA: lr_data   TYPE REF TO data.

  lr_data  = co_con->get_vars( 'I_MSEG'  ). ASSIGN lr_data->* TO <ls_mseg>.
  lr_data  = co_con->get_vars( 'I_MKPF'  ). ASSIGN lr_data->* TO <ls_mkpf>.

*TRY.
  CALL METHOD me->zmb_migo_badi
    EXPORTING
      iv_mseg = <ls_mseg>.
* CATCH zcx_bc_exit_imp .
*ENDTRY.

ENDMETHOD.


METHOD zmb_migo_badi.

  DATA: lv_extwg TYPE extwg,
        lv_ewbez TYPE char20.

  CHECK: iv_mseg-bwart EQ zif_mm_exit_smod_mbcf0002~cv_nakil,
         iv_mseg-werks EQ zif_mm_exit_smod_mbcf0002~cv_werks_delivering.

  "El terminali kullanıcısından gelenler için kontrol çalışmaz. (YUR-606)
  SELECT SINGLE mandt
    FROM zyb_wm_t_users
    INTO sy-mandt
    WHERE username = sy-uname.

  CHECK sy-subrc NE 0. "Tabloda kayıt yok ise el terminali kullanıcısı değildir. Kontrole devam edilir.

  TRY.
      DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                   var = 'USER'
                                                                   val = REF #( sy-uname )
                                                                   surec = 'YI_DEPO_VIRMAN' ) ) .
      ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).
      CHECK: <lv_exc_user> IS INITIAL. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
*------------------------------------------------------------------------------------------------------------------------------
      DATA(rr_vld_lgort) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                   var = 'LGORT'
                                                                   val = REF #( iv_mseg-lgort ) "Nakil işlemlerinde kaynak depolar için kontrol çalışacaktır. UMLGO değil.
                                                                   surec = 'YI_DEPO_VIRMAN' ) ) .
      ASSIGN rr_vld_lgort->* TO FIELD-SYMBOL(<lv_vld_lgort>).
      CHECK:<lv_vld_lgort> IS NOT INITIAL. "Geçerli depolar için aşağıdaki kontrol çalışacaktır.
*------------------------------------------------------------------------------------------------------------------------------
      SELECT SINGLE extwg FROM mara INTO lv_extwg WHERE matnr EQ iv_mseg-matnr.
      IF sy-subrc EQ 0.
        DATA(rr_vld_kalite) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                            var = 'EXTWG'
                                                                            val = REF #( lv_extwg )
                                                                            surec = 'YI_DEPO_VIRMAN' ) ) .
        ASSIGN rr_vld_kalite->* TO FIELD-SYMBOL(<lv_vld_kalite>).
      ENDIF.
      CHECK:<lv_vld_kalite> IS NOT INITIAL. "Nakil işlemlerinde sadece belirli kaliteler için kontrol çalışmalıdır.
      SELECT SINGLE ewbez
        FROM twewt
        INTO lv_ewbez
        WHERE extwg EQ lv_extwg
          AND spras EQ 'T'.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZMM'
                   id_msgno = '018'
                   id_msgv1 = 'YI_DEPO_VIRMAN'
                   id_msgv2 = lv_ewbez
                   id_msgv3 = iv_mseg-lgort ).
      RAISE EXCEPTION TYPE zcx_mm_exit
        EXPORTING
          messages = lo_msg.
*------------------------------------------------------------------------------------------------------------------------------
    CATCH zcx_mm_exit INTO DATA(lx_mm_exit).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_mm_exit->messages.

    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
