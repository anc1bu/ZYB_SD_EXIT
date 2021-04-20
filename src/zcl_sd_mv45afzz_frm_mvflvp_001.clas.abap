"YUR-648 - Palet Kalemi Kontrolü (YUR-648)
class ZCL_SD_MV45AFZZ_FRM_MVFLVP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_SD_MV45AFZZ_FRM_MVFLVP .
  interfaces ZIF_BC_EXIT_IMP .

  methods FRM_MVFLVP
    importing
      !IT_XVBAP type TAB_XYVBAP
    raising
      ZCX_BC_EXIT_IMP .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FRM_MVFLVP_001 IMPLEMENTATION.


METHOD frm_mvflvp.

  TYPES: BEGIN OF ty_mtart,
           matnr TYPE matnr,
           mtart TYPE mtart,
         END OF ty_mtart,
         tt_mtart TYPE HASHED TABLE OF ty_mtart WITH UNIQUE KEY matnr.

  DATA: lt_mtart   TYPE tt_mtart,
        lrng_mtart TYPE RANGE OF mtart.

  lrng_mtart[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZISK' )
                         ( sign = 'I' option = 'EQ' low = 'ZM3P' )
                         ( sign = 'I' option = 'EQ' low = 'ZMDK' )
                         ( sign = 'I' option = 'EQ' low = 'ZMPT' )
                         ( sign = 'I' option = 'EQ' low = 'ZMSG' )
                         ( sign = 'I' option = 'EQ' low = 'ZMYK' )
                         ( sign = 'I' option = 'EQ' low = 'ZTIC' ) ).

  CHECK: it_xvbap IS NOT INITIAL.
*------------------------------------------------------------------------------------------------------------------------------
  SELECT matnr mtart
    FROM mara
    INTO TABLE lt_mtart
    FOR ALL ENTRIES IN it_xvbap
    WHERE matnr EQ it_xvbap-matnr.


  DATA(rv_result) = COND abap_bool( WHEN line_exists( it_xvbap[ pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm ] ) AND
                                         it_xvbap[ pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm ]-pstyv EQ 'D' THEN abap_true
                                    WHEN line_index( it_xvbap[ pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm ] ) EQ 0 THEN abap_true
                                    ELSE abap_false ).

  CHECK: rv_result EQ abap_true.


*------------------------------------------------------------------------------------------------------------------------------
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

  CHECK: <lv_exc_user> EQ abap_false. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
  "---------<<
*------------------------------------------------------------------------------------------------------------------------------

  LOOP AT it_xvbap ASSIGNING FIELD-SYMBOL(<ls_xvbap>)
  WHERE pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
    ASSIGN lt_mtart[ KEY primary_key COMPONENTS matnr = <ls_xvbap>-matnr ] TO FIELD-SYMBOL(<ls_mtart>).
    IF <ls_mtart>-mtart IN lrng_mtart.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '046' ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDLOOP .

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.
  FIELD-SYMBOLS: <lt_xvbap> TYPE tab_xyvbap,
                 <ls_vbak>  TYPE vbak.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <ls_vbak>.

  CHECK: <ls_vbak>-vtweg NE '20',
         <ls_vbak>-auart NE 'ZA02',
         <ls_vbak>-auart NE 'ZA03',
         <ls_vbak>-auart NE 'ZA11',
         "--------->> Anıl CENGİZ 02.06.2020 11:23:49
         "YUR-662
         NEW zcl_sd_paletftr_mamulle( )->valid(
                                   EXPORTING
                                     iv_auart = <ls_vbak>-auart
                                     iv_vtweg = <ls_vbak>-vtweg
                                     iv_kunnr = <ls_vbak>-kunnr ) EQ abap_true.
  "---------<<

  frm_mvflvp( <lt_xvbap> ).

ENDMETHOD.
ENDCLASS.
