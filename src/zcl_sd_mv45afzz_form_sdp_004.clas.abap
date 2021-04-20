CLASS zcl_sd_mv45afzz_form_sdp_004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_form_sdp .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS cv_aprproc_zf01 TYPE zsdd_apr_process VALUE 'ZF01'. "#EC NOTEXT

    METHODS check_date_rate
      IMPORTING
        !is_vbak TYPE vbak
        !io_msg  TYPE REF TO if_reca_message_list
      RAISING
        zcx_sd_mv45afzz_form_sdp_004
        zcx_sd_apr .
    METHODS check_sameday
      IMPORTING
        !is_vbak         TYPE vbak
      RETURNING
        VALUE(rv_return) TYPE sy-subrc .
    METHODS check_workflow_active
      IMPORTING
        !is_vbak         TYPE vbak
      RETURNING
        VALUE(rv_return) TYPE sy-subrc .
    METHODS check_zsd053
      IMPORTING
        !it_xvbap TYPE tab_xyvbap
        !it_yvbap TYPE tab_xyvbap
        !io_msg   TYPE REF TO if_reca_message_list
      RAISING
        zcx_sd_mv45afzz_form_sdp_004 .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_004 IMPLEMENTATION.


  METHOD check_date_rate.

    DATA: lv_apr_amount TYPE zsdd_apr_amount.

    DATA(ls_datcnt) = NEW zcl_sd_apr_toolkit( is_vbak = is_vbak )->get_date_controls( ).

    DATA(lv_diff) = sy-datum - is_vbak-erdat.

    DATA(lv_rate) = zcl_sd_apr_toolkit=>get_amount_change_rate( EXPORTING is_vbak = is_vbak iv_wf_amount = lv_apr_amount ).

    IF lv_diff GT ls_datcnt-zdays AND ls_datcnt-zdays GT 0. "gün aşımı
      io_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '050'
                   id_msgv1 = ls_datcnt-zdays
                   id_msgv2 = space
                   id_msgv3 = space
                   id_msgv4 = space ).
      RAISE EXCEPTION TYPE zcx_sd_mv45afzz_form_sdp_004
        EXPORTING
          messages = io_msg.
    ELSEIF lv_rate GT ls_datcnt-zrate AND ls_datcnt-zrate GT 0. "oran aşımı
      io_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '051'
                   id_msgv1 = ls_datcnt-zrate
                   id_msgv2 = space
                   id_msgv3 = space
                   id_msgv4 = space ).
      RAISE EXCEPTION TYPE zcx_sd_mv45afzz_form_sdp_004
        EXPORTING
          messages = io_msg.
    ELSEIF lv_rate LT 0 AND abs( lv_rate ) GT ls_datcnt-zrate AND ls_datcnt-zrate GT 0. "oran düşülmüş
      io_msg->add( id_msgty = 'W'
                   id_msgid = 'ZSD'
                   id_msgno = '052'
                   id_msgv1 = space
                   id_msgv2 = space
                   id_msgv3 = space
                   id_msgv4 = space ).
    ENDIF.


  ENDMETHOD.


  METHOD check_sameday.

    rv_return = 4.

    SELECT SINGLE mandt
      FROM zsdt_apr_statu
      INTO sy-mandt
      WHERE process EQ cv_aprproc_zf01
        AND vbeln   EQ is_vbak-vbeln
        AND action  IN ( 'R', '' ).
    "--------->> Anıl CENGİZ 11.11.2019 15:14:08
    "YUR-502
*  IF sy-subrc <> 0."belge onaylanmış
    IF sy-subrc <> 0 AND "belge onaylanmış
      is_vbak-erdat NE sy-datum. "aynı gün içerisinde ise kontrollere girme.
      "---------<<
      rv_return = 0.
    ENDIF.

  ENDMETHOD.


  METHOD check_workflow_active.
    rv_return = 4.
    SELECT SINGLE mandt
      INTO sy-mandt
      FROM zsdt_apr_wrkflw
      WHERE process EQ cv_aprproc_zf01
        AND vbeln   EQ is_vbak-vbeln
        AND deleted EQ space.
    IF sy-subrc EQ 0. "belge onay iş akışı aktif
      rv_return = 0.
    ENDIF.
  ENDMETHOD.


  METHOD check_zsd053.
    DATA: lv_xkwmeng TYPE kwmeng,
          lv_ykwmeng TYPE kwmeng.

    LOOP AT it_xvbap INTO DATA(ls_vbap).
      ADD ls_vbap-kwmeng TO lv_xkwmeng.
    ENDLOOP.

    LOOP AT it_yvbap INTO ls_vbap.
      ADD ls_vbap-kwmeng TO lv_ykwmeng.
    ENDLOOP.

    IF lv_ykwmeng GT lv_xkwmeng.
      io_msg->add( id_msgty = 'E'
                  id_msgid = 'ZSD'
                  id_msgno = '053'
                  id_msgv1 = space
                  id_msgv2 = space
                  id_msgv3 = space
                  id_msgv4 = space ).
      RAISE EXCEPTION TYPE zcx_sd_mv45afzz_form_sdp_004
        EXPORTING
          messages = io_msg.
    ENDIF.
  ENDMETHOD.


  METHOD zif_bc_exit_imp~execute.

    FIELD-SYMBOLS: <lt_xvbap>    TYPE tab_xyvbap,
                   <lt_yvbap>    TYPE tab_xyvbap,
                   <lv_callbapi> TYPE abap_bool,
                   <ls_vbak>     TYPE vbak,
                   <ls_yvbak>    TYPE vbak,
                   <ls_t180>     TYPE t180,
                   <lt_xkomv>    TYPE komv_tab.

    DATA: lr_data TYPE REF TO data,
          lo_msg  TYPE REF TO if_reca_message_list.

    lo_msg  = cf_reca_message_list=>create( ).
    lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <lt_xvbap>.
    lr_data = co_con->get_vars( 'YVBAP' ).     ASSIGN lr_data->* TO <lt_yvbap>.
    lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
    lr_data = co_con->get_vars( 'YVBAK' ).     ASSIGN lr_data->* TO <ls_yvbak>.
    lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.
    lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
    lr_data = co_con->get_vars( 'XKOMV' ).     ASSIGN lr_data->* TO <lt_xkomv>.


    CHECK: <ls_vbak>-vtweg EQ '10'. "İhracat değilse girmelidir.

    TRY.
        DATA(lo_onay) = NEW zcl_sd_apr_event_create(
                              iv_process   = cv_aprproc_zf01
                              iv_simulate  = abap_true
                              is_vbak      = <ls_vbak>
                              is_ovbak     = <ls_yvbak>
                              it_vbap      = <lt_xvbap>
                              it_komv      = <lt_xkomv>
                              is_t180      = <ls_t180> ).

        CHECK: lo_onay->is_approvable( ) EQ abap_true.
        CASE <ls_t180>-trtyp.
            "VA01yani giriş kipi kontrolü
          WHEN zif_sd_mv45afzz_form_sdp~gcv_trtyp_add.
            "VA02 yani değiştirme kipi kontrolü
          WHEN zif_sd_mv45afzz_form_sdp~gcv_trtyp_change.

            CHECK: check_workflow_active( <ls_vbak> ) EQ 0,
                   check_sameday( <ls_vbak> ) EQ 0.

            check_date_rate(
              EXPORTING
                is_vbak = <ls_vbak>
                io_msg  = lo_msg ).

            check_zsd053(
              EXPORTING
                it_xvbap = <lt_xvbap>
                it_yvbap = <lt_yvbap>
                io_msg   = lo_msg ).
          WHEN OTHERS.
        ENDCASE.
        "Error handling
      CATCH zcx_sd_apr INTO DATA(lx_sd_apr).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_apr->messages.

      CATCH zcx_sd_mv45afzz_form_sdp_004 INTO DATA(lx_sd_mv45afzz_form_sdp_004).
        lo_msg ?= lx_sd_mv45afzz_form_sdp_004->messages.
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
