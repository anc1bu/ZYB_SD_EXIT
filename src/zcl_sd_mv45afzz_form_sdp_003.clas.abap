class ZCL_SD_MV45AFZZ_FORM_SDP_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_003 IMPLEMENTATION.


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

  DATA: lt_error    TYPE bapirettab,
        lv_kwmeng   TYPE kwmeng,
        lr_data     TYPE REF TO data,
        lt_xvbap    TYPE tab_xyvbap,
        lt_mtart    TYPE tt_mtart,
        rng_mtart   TYPE RANGE OF mtart,
        lv_decision TYPE abap_bool.

  DATA(lo_msg_list) = cf_reca_message_list=>create( ).

  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.

  "--------->> Anıl CENGİZ 04.04.2020 10:18:59
  "YUR-628
  "YYK ürünlerde palet kalemi olmamalıdır kontrolü.

  IF <ls_t180>-trtyp NE 'A'.
    TRY.
        CHECK: NEW zcl_sd_paletftr_mamulle( )->valid(
                                                 EXPORTING
                                                   iv_auart = <ls_vbak>-auart
                                                   iv_vtweg = <ls_vbak>-vtweg
                                                   iv_kunnr = <ls_vbak>-kunnr ) EQ abap_true.
        lt_xvbap = <lt_xvbap>.
        DELETE lt_xvbap WHERE updkz EQ 'D'.
        ASSIGN lt_xvbap[ pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm ] TO FIELD-SYMBOL(<ls_xvbap>).
        CHECK: <ls_xvbap> IS ASSIGNED. "Palet kalemi varsa.

        SELECT matnr mtart
          FROM mara
          INTO TABLE lt_mtart
          FOR ALL ENTRIES IN lt_xvbap
          WHERE matnr EQ lt_xvbap-matnr.

        LOOP AT lt_xvbap ASSIGNING <ls_xvbap>
          WHERE pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
          LOOP AT lt_mtart ASSIGNING FIELD-SYMBOL(<ls_mtart>)
            WHERE matnr EQ <ls_xvbap>-matnr.
            IF <ls_mtart> NE 'ZYYK'.
              lv_decision = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF sy-subrc EQ 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        CHECK: lv_decision EQ abap_false.

        LOOP AT lt_xvbap ASSIGNING <ls_xvbap>.
          ASSIGN lt_mtart[ matnr = <ls_xvbap>-matnr
                           mtart = 'ZYYK' ] TO <ls_mtart>.
        ENDLOOP.
        IF <ls_mtart> IS ASSIGNED. "ZYYK varsa

          lo_msg_list->add( id_msgty = 'E'
                            id_msgid = 'ZSD'
                            id_msgno = '047' ).

          RAISE EXCEPTION TYPE zcx_sd_paletftr_mamulle
            EXPORTING
              messages = lo_msg_list.

        ENDIF.
      CATCH zcx_sd_paletftr_mamulle INTO DATA(lx_sd_paletftr_mamulle).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_paletftr_mamulle->messages.
    ENDTRY.
  ENDIF.
  "---------<<
ENDMETHOD.
ENDCLASS.
