class ZCL_MM_EXIT_SMOD_MBCF0002_006 definition
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

  constants CV_NAKIL type BWART value '311'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_MBCF0002_006 IMPLEMENTATION.


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

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

  DATA: lv_mtart TYPE mtart.
  "Nakil işlemlerinde..
*  CHECK: iv_mseg-bwart EQ cv_nakil.

  TRY.
      DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                   var = 'USER'
                                                                   val = REF #( sy-uname )
                                                                   surec = 'UY_ARASI_STOK_VIRMAN' ) ) .
      ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

      CHECK: <lv_exc_user> EQ abap_false. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
*------------------------------------------------------------------------------------------------------------------------------
      SELECT SINGLE mtart FROM mara INTO lv_mtart WHERE matnr EQ iv_mseg-matnr.
      IF sy-subrc EQ 0.
        DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                     var = 'MTART'
                                                                     val = REF #( lv_mtart )
                                                                     surec = 'UY_ARASI_STOK_VIRMAN' ) ) .
        ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

        CHECK:<lv_vld_mtart> EQ abap_true. "Geçerli malzeme türleri için aşağıdaki kontrol çalışacaktır.
      ENDIF.
*------------------------------------------------------------------------------------------------------------------------------
      DATA(rr_vld_werks) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                   var = 'WERKS'
                                                                   val = REF #( iv_mseg-werks ) "Kaynak depolar ara depo olmak üezere kontrol çalışacaktır.
                                                                   surec = 'UY_ARASI_STOK_VIRMAN' ) ) .
      ASSIGN rr_vld_werks->* TO FIELD-SYMBOL(<lv_vld_werks>).

      CHECK:<lv_vld_werks> EQ abap_true. "Geçerli ÜY' ler için aşağıdaki kontrol çalışacaktır.
*------------------------------------------------------------------------------------------------------------------------------

      DATA(rr_vld_umwrk) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                   var = 'WERKS'
                                                                   val = REF #( iv_mseg-umwrk ) "Hedef ÜY.
                                                                   surec = 'UY_ARASI_STOK_VIRMAN' ) ) .
      ASSIGN rr_vld_umwrk->* TO FIELD-SYMBOL(<lv_vld_umwrk>).

      CHECK:<lv_vld_umwrk> EQ abap_true. "Geçerli depolar için aşağıdaki kontrol çalışacaktır.
*------------------------------------------------------------------------------------------------------------------------------

      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZMM'
                   id_msgno = '045'
                   id_msgv1 = 'UY_ARASI_STOK_VIRMAN'
                   id_msgv2 = iv_mseg-werks
                   id_msgv3 = iv_mseg-umwrk ).
      RAISE EXCEPTION TYPE zcx_mm_exit
        EXPORTING
          messages = lo_msg.

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
