CLASS zcl_sd_mv45afzz_form_rddoc_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_form_rddoc .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_RDDOC_001 IMPLEMENTATION.


  METHOD zif_bc_exit_imp~execute.


*    FIELD-SYMBOLS: <gs_vbak>  TYPE vbak,
*                   <gt_xvbap> TYPE tab_xyvbap,
*                   <gs_t180>  TYPE t180,
*                   <gv_fcode> TYPE char20.
*
*    DATA: lr_data TYPE REF TO data.
*
*    lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
*    lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <gt_xvbap>.
*    lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
*    lr_data = co_con->get_vars( 'FCODE' ).     ASSIGN lr_data->* TO <gv_fcode>.
*
*    CHECK: <gs_t180>-trtyp EQ zif_sd_mv45afzz_form_rddoc~gcv_trtyp_change,
*           <gv_fcode> NE 'LOES',
*           <gs_vbak>-vtweg NE zif_sd_mv45afzz_form_rddoc~gcv_vtweg_exp.
*
*    DATA(lt_enq) = zcl_sd_toolkit=>enqueue_read( 'ATPENQ' ).
*
*    LOOP AT <gt_xvbap> REFERENCE INTO DATA(gr_xvbap)
*      WHERE abgru EQ space
*        AND updkz NE zif_sd_mv45afzz_form_rddoc~gcv_delete
*        AND pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
*
*      "--------->>Anıl CENGİZ 23.54.2020 13:54:07
*      "YUR-775
*      DATA(lts_enq) = VALUE zcl_sd_toolkit=>tts_enq( FOR wa IN lt_enq WHERE ( gtarg+6(18) EQ gr_xvbap->matnr AND gtarg+38(4) EQ gr_xvbap->lgort AND guname NE sy-uname )
*                                                                            ( CORRESPONDING #( wa ) ) ).
*
*      ASSIGN lts_enq[ 1 ] TO FIELD-SYMBOL(<ls_enq>).
*      IF sy-subrc EQ 0.
*        DATA(lo_msg) = cf_reca_message_list=>create( ).
*        lo_msg->add( id_msgty = 'E'
*                     id_msgid = 'ZSD'
*                     id_msgno = '085'
*                     id_msgv1 = gr_xvbap->matnr
*                     id_msgv2 = gr_xvbap->lgort
*                     id_msgv3 = <ls_enq>-guname ).
*      ENDIF.
*      "---------<<
*    ENDLOOP.
*
*    IF lo_msg IS BOUND.
*      RAISE EXCEPTION TYPE zcx_bc_exit_imp
*        EXPORTING
*          messages = lo_msg.
*    ENDIF.


  ENDMETHOD.
ENDCLASS.
