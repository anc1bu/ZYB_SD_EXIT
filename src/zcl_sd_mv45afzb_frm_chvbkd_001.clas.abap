class ZCL_SD_MV45AFZB_FRM_CHVBKD_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHVBKD .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHVBKD_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_vbkd>      TYPE vbkd,
                 <gs_star_vbkd> TYPE vbkd,
                 <gs_vbak>      TYPE vbak,
                 <gs_xvbup>     TYPE vbupvb,
                 <gs_xvbuk>     TYPE vbukvb,
                 <gt_xvbpa>     TYPE tt_vbpavb,
                 <gt_yvbpa>     TYPE tt_vbpavb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBKD' ).    ASSIGN lr_data->* TO <gs_vbkd>.
  lr_data = co_con->get_vars( 'VBAK' ).    ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( '*VBKD' ).   ASSIGN lr_data->* TO <gs_star_vbkd>.
  lr_data = co_con->get_vars( 'XVBUP' ).   ASSIGN lr_data->* TO <gs_xvbup>.
  lr_data = co_con->get_vars( 'XVBUK' ).   ASSIGN lr_data->* TO <gs_xvbuk>.
  lr_data = co_con->get_vars( 'XVBPA[]' ). ASSIGN lr_data->* TO <gt_xvbpa>.
  lr_data = co_con->get_vars( 'YVBPA[]' ). ASSIGN lr_data->* TO <gt_yvbpa>.

  CHECK: zcl_sd_mv45afzz_form_fldmd_004=>check_vtweg( EXPORTING iv_vkorg = <gs_vbak>-vkorg
                                                                iv_vtweg = <gs_vbak>-vtweg ) EQ abap_true. "Dağıtım kanalı

  "Teslimat işlemi başlamış ise "sevk türü" değiştirilemez.
  IF <gs_vbkd>-vsart NE <gs_star_vbkd>-vsart AND
     <gs_vbkd>-posnr NE 000000 AND
     <gs_xvbup>-lfsta NE 'A'.
    DATA(lo_msg) = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '075'
                 id_msgv1 = <gs_star_vbkd>-vsart ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.


  LOOP AT <gt_yvbpa> ASSIGNING FIELD-SYMBOL(<gs_yvbpa>).
    ASSIGN <gt_xvbpa>[ vbeln = <gs_yvbpa>-vbeln
                       posnr = <gs_yvbpa>-posnr
                       parvw = <gs_yvbpa>-parvw ] TO FIELD-SYMBOL(<gs_xvbpa>).
    IF sy-subrc EQ 0.
      "Teslimat işlemi başlamış ise başlık muhattap verileri değiştirilemez.
      IF <gs_yvbpa>-posnr EQ 000000 AND
         <gs_yvbpa>-adrnr NE <gs_xvbpa>-adrnr AND
         <gs_xvbuk>-lfstk NE 'A'.
        lo_msg = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '076'
                     id_msgv1 = <gs_yvbpa>-parvw ).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.
      "O kaleme ait teslimat işlemi başlamış ise kalem muhattap verileri değiştirilemez.
      IF <gs_yvbpa>-posnr NE 000000 AND
         <gs_yvbpa>-adrnr NE <gs_xvbpa>-adrnr AND
         <gs_xvbup>-lfsta NE 'A'.
        lo_msg = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '077'
                     id_msgv1 = <gs_yvbpa>-parvw ).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT <gt_xvbpa> ASSIGNING <gs_xvbpa>
    WHERE updkz EQ 'I'
      AND vbeln IS NOT INITIAL.
    "Teslimat işlemi başlamış ise yeni muhattap verilerisi eklenemez.
    IF <gs_xvbpa>-posnr EQ 000000 AND
       <gs_xvbuk>-lfstk NE 'A'.
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '076'
                   id_msgv1 = <gs_xvbpa>-parvw ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
    "O kaleme ait teslimat işlemi başlamış ise yeni kalem muhattabı eklenemez.
    IF <gs_xvbpa>-posnr NE 000000 AND
       <gs_xvbup>-lfsta NE 'A'.
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '077'
                   id_msgv1 = <gs_xvbpa>-parvw ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
