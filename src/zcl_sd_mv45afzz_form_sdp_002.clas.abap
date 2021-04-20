class ZCL_SD_MV45AFZZ_FORM_SDP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  TYPES: BEGIN OF ty_mtart,
           matnr TYPE matnr,
           mtart TYPE mtart,
         END OF ty_mtart,
         tt_mtart TYPE TABLE OF ty_mtart.

  FIELD-SYMBOLS: <lt_xvbap>    TYPE tab_xyvbap,
                 <lv_callbapi> TYPE abap_bool,
                 <ls_vbak>     TYPE vbak,
                 <ls_t180>     TYPE t180.

  DATA: lt_error  TYPE bapirettab,
        lv_kwmeng TYPE kwmeng,
        lr_data   TYPE REF TO data,
        lt_xvbap  TYPE tab_xyvbap,
        lt_mtart  TYPE tt_mtart.

  DATA(lo_msg_list) = cf_reca_message_list=>create( ).

  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.

  "--------->> Anıl CENGİZ 01.08.2018 14:48:36
  " YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
  IF <ls_t180>-trtyp NE 'A'.
    TRY.
        "--------->> Anıl CENGİZ 04.04.2020 09:03:28
        "YUR-628
**    DATA(lb_msg) = NEW zcl_sd_paletftr_mamulle( )->plt_klm_kontrol(
**                                                     EXPORTING
**                                                       is_vbak  = <ls_vbak>
**                                                       it_xvbap = <lt_xvbap> ).
**    IF lb_msg IS NOT INITIAL.
**      APPEND lb_msg TO tb_msg.
**    ENDIF.
*
*    TRY.
*        NEW zcl_sd_paletftr_mamulle( )->plt_klm_kontrol(
*                                          EXPORTING
*                                            is_vbak  = <ls_vbak>
*                                            it_xvbap = <lt_xvbap> ).
*
*      CATCH zcx_sd_paletftr_mamulle INTO DATA(lo_cx_sd_paletftr_mamulle).
*        RAISE EXCEPTION TYPE zcx_bc_exit_imp
*          EXPORTING
*            previous = lo_cx_sd_paletftr_mamulle.
*    ENDTRY.

        "--------->> Anıl CENGİZ 11.08.2020 14:21:21
        "YUR-708
        TRY.
            DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                         var = 'USER'
                                                                         val = REF #( sy-uname )
                                                                         surec = 'YI_PLT_SILME' ) ) .
            ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

          CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
            RAISE EXCEPTION TYPE zcx_bc_exit_imp
              EXPORTING
                messages = lx_sd_exc_vld_cntrl->messages.
        ENDTRY.
        "---------<<


        CHECK: NEW zcl_sd_paletftr_mamulle( )->valid(
                                                 EXPORTING
                                                   iv_auart = <ls_vbak>-auart
                                                   iv_vtweg = <ls_vbak>-vtweg
                                                   iv_kunnr = <ls_vbak>-kunnr ) EQ abap_true,
               "--------->> Anıl CENGİZ 11.08.2020 14:42:29
               "YUR-708
               <lv_exc_user> EQ abap_false. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
               "---------<<
        lt_xvbap = <lt_xvbap>.
        DELETE lt_xvbap WHERE updkz EQ 'D'.
        ASSIGN lt_xvbap[ pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm ] TO FIELD-SYMBOL(<ls_xvbap>).
        CHECK: <ls_xvbap> IS NOT ASSIGNED. "Palet kalemi yok ise.

        SELECT matnr mtart
          FROM mara
          INTO TABLE lt_mtart
          FOR ALL ENTRIES IN lt_xvbap
          WHERE matnr EQ lt_xvbap-matnr.


        LOOP AT lt_xvbap ASSIGNING <ls_xvbap>.
          ASSIGN lt_mtart[ matnr = <ls_xvbap>-matnr
                           mtart = 'ZYYK' ] TO FIELD-SYMBOL(<ls_mtart>).
          ASSIGN lt_mtart[ matnr = <ls_xvbap>-matnr
                           mtart = 'ZPAL' ] TO <ls_mtart>.
        ENDLOOP.
        IF <ls_mtart> IS NOT ASSIGNED. "ZYYK ya da ZPAL yok ise yani seramik var ise.
          lo_msg_list->add( id_msgty = 'E'
                            id_msgid = 'ZSD'
                            id_msgno = '046' ).
          RAISE EXCEPTION TYPE zcx_sd_paletftr_mamulle
            EXPORTING
              messages = lo_msg_list.
          "---------<<
        ENDIF.
      CATCH zcx_sd_paletftr_mamulle INTO DATA(lx_sd_paletftr_mamulle).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_paletftr_mamulle->messages.
    ENDTRY.
    "---------<<
  ENDIF.
  "---------<<

ENDMETHOD.
ENDCLASS.
