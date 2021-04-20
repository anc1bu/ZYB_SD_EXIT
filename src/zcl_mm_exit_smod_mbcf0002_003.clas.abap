class ZCL_MM_EXIT_SMOD_MBCF0002_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EXIT_SMOD_MBCF0002 .

  class-methods ZMB_MIGO_BADI
    importing
      value(IV_MSEG) type MSEG
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.

  constants CV_NAKIL type BWART value '311'. "#EC NOTEXT
  constants CV_MAL_GIRIS type BWART value '101'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_MBCF0002_003 IMPLEMENTATION.


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
  "Nakil işlemlerinde eğer hedef olarak E li stok varsa bu kontrole gir.
*iv_mseg-bwart EQ cv_nakil,
  CHECK: iv_mseg-mat_kdauf IS NOT INITIAL,
         iv_mseg-mat_kdpos IS NOT INITIAL,
         iv_mseg-sobkz EQ 'E',
         iv_mseg-werks EQ zif_mm_exit_smod_mbcf0002~cv_werks_delivering.
  "--------->> Anıl CENGİZ 22.07.2020 17:19:52
  "YUR-692
  IF iv_mseg-bwart EQ cv_mal_giris.
    iv_mseg-umlgo = iv_mseg-lgort.
  ENDIF.
  "---------<<
  TRY.
      DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                   var = 'USER'
                                                                   val = REF #( sy-uname )
                                                                   surec = 'IHR_E_LI_STOK_VIRMAN' ) ) .
      ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

      CHECK: <lv_exc_user> EQ abap_false. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
*------------------------------------------------------------------------------------------------------------------------------
      SELECT SINGLE mtart FROM mara INTO lv_mtart WHERE matnr EQ iv_mseg-matnr.
      IF sy-subrc EQ 0.
        DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                     var = 'MTART'
                                                                     val = REF #( lv_mtart )
                                                                     surec = 'IHR_E_LI_STOK_VIRMAN' ) ) .
        ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

        CHECK:<lv_vld_mtart> EQ abap_true. "Geçerli malzeme türleri için aşağıdaki kontrol çalışacaktır.
      ENDIF.
*------------------------------------------------------------------------------------------------------------------------------
      DATA(rr_vld_lgort) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                   var = 'LGORT'
                                                                   val = REF #( iv_mseg-umlgo )
                                                                   surec = 'IHR_E_LI_STOK_VIRMAN' ) ) .
      ASSIGN rr_vld_lgort->* TO FIELD-SYMBOL(<lv_vld_lgort>).

      CHECK:<lv_vld_lgort> EQ abap_true. "Geçerli depolar için aşağıdaki kontrol çalışacaktır.
*------------------------------------------------------------------------------------------------------------------------------

      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZMM'
                   id_msgno = '039'
                   id_msgv1 = 'IHR_E_LI_STOK_VIRMAN'
                   id_msgv2 = iv_mseg-umlgo ).
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
