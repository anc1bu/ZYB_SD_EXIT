CLASS zcl_sd_mv45afzz_frm_mvflvp_004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_frm_mvflvp .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FRM_MVFLVP_004 IMPLEMENTATION.


  METHOD zif_bc_exit_imp~execute.
*    FIELD-SYMBOLS: <gs_vbap>      TYPE vbap,
*                   <gs_vbak>      TYPE vbak,
*                   <gs_vbkd>      TYPE vbkd,
*                   <gs_t180>      TYPE t180,
*                   <gv_call_bapi> TYPE abap_bool.
*
*    DATA: lr_data TYPE REF TO data.
*
*    lr_data = co_con->get_vars( 'VBAP' ).      ASSIGN lr_data->* TO <gs_vbap>.
*    lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
*    lr_data = co_con->get_vars( 'VBKD' ).      ASSIGN lr_data->* TO <gs_vbkd>.
*    lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
*    lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <gv_call_bapi>.
*
*    CHECK: <gs_t180>-trtyp EQ zif_sd_mv45afzz_frm_mvflvp~gcv_trtyp_change,
*           <gs_vbak>-vtweg NE zif_sd_mv45afzz_frm_mvflvp~gcv_vtweg_exp,
*           <gs_vbap>-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
*
*    DATA(lt_enq) = zcl_sd_toolkit=>enqueue_read( 'ATPENQ' ).
*
*    DATA(lts_enq) = VALUE zcl_sd_toolkit=>tts_enq( FOR wa IN lt_enq WHERE ( gtarg+6(18) EQ <gs_vbap>-matnr AND gtarg+38(4) EQ <gs_vbap>-lgort AND guname NE sy-uname )
*                                                                      ( CORRESPONDING #( wa ) ) ).
*
*    ASSIGN lts_enq[ 1 ] TO FIELD-SYMBOL(<ls_enq>).
*    IF sy-subrc EQ 0.
*      DATA(lo_msg) = cf_reca_message_list=>create( ).
*      lo_msg->add( id_msgty = 'E'
*                   id_msgid = 'ZSD'
*                   id_msgno = '085'
*                   id_msgv1 = <gs_vbap>-matnr
*                   id_msgv2 = <gs_vbap>-lgort
*                   id_msgv3 = <ls_enq>-guname ).
*    ENDIF.
*
*    IF lo_msg IS BOUND.
*      RAISE EXCEPTION TYPE zcx_bc_exit_imp
*        EXPORTING
*          messages = lo_msg.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
