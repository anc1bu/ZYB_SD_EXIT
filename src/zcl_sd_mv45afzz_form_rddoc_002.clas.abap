class ZCL_SD_MV45AFZZ_FORM_RDDOC_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_RDDOC .
  PROTECTED SECTION.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_access_one,
      vkorg      TYPE vkorg,
      vtweg      TYPE vtweg,
      kunnr      TYPE kunnr,
      sipdeg_gun TYPE zzsipdeg_gun,
    END OF ty_access_one .
  TYPES:
    tth_access_one TYPE HASHED TABLE OF ty_access_one WITH UNIQUE KEY vkorg vtweg kunnr .

  TYPES:
    BEGIN OF ty_access_two,
      vkorg      TYPE vkorg,
      vtweg      TYPE vtweg,
      lgort      TYPE lgort_d,
      sipdeg_gun TYPE zzsipdeg_gun,
    END OF ty_access_two .
  TYPES:
    tts_access_two TYPE SORTED TABLE OF ty_access_two WITH NON-UNIQUE KEY sipdeg_gun.

  DATA gt_access_one TYPE tth_access_one .
  DATA gt_access_two TYPE tts_access_two .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_RDDOC_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_vbak>  TYPE vbak,
                 <gt_xvbap> TYPE tab_xyvbap,
                 <gs_t180>  TYPE t180,
                 <gv_fcode> TYPE char20.

  DATA: lr_data        TYPE REF TO data,
        ls_access_one  TYPE ty_access_one,
        lv_fark_gun    TYPE i,
        lv_lgort_count TYPE i,
        lv_sipdeg_gun  TYPE i.

  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <gt_xvbap>.
  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'FCODE' ).     ASSIGN lr_data->* TO <gv_fcode>.

  CHECK: <gs_t180>-trtyp EQ zif_sd_mv45afzz_form_rddoc~gcv_trtyp_change,
         <gs_vbak>-vtweg NE zif_sd_mv45afzz_form_rddoc~gcv_vtweg_exp,
         <gs_vbak>-vbtyp NE 'K',
         <gs_vbak>-vbtyp NE 'L',
         sy-batch IS INITIAL,
         sy-binpt IS INITIAL.

  TRY.
      DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                   var = 'USER'
                                                                   val = REF #( sy-uname )
                                                                   surec = 'YI_SIPDEG_GUN' ) ) .
      ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).
      CHECK: <lv_exc_user> IS INITIAL. "istisna kullanıcısı ise aşağıdaki kontrole girmez.

    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.
  ENDTRY.
  "Access 1
  DATA(lo_msg) = cf_reca_message_list=>create( ).

  ASSIGN gt_access_one[ KEY primary_key COMPONENTS vkorg = <gs_vbak>-vkorg
                                                   vtweg = <gs_vbak>-vtweg
                                                   kunnr = <gs_vbak>-kunnr ] TO FIELD-SYMBOL(<gs_access_one>).
  IF sy-subrc NE 0.
    SELECT SINGLE vkorg vtweg kunnr sipdeg_gun
      FROM zsdt_sip_deg_knt
      INTO ls_access_one
      WHERE vkorg EQ <gs_vbak>-vkorg
        AND vtweg EQ <gs_vbak>-vtweg
        AND kunnr EQ <gs_vbak>-kunnr.
    IF sy-subrc EQ 0.
      INSERT ls_access_one INTO TABLE gt_access_one ASSIGNING <gs_access_one>.
    ENDIF.
  ENDIF.

  IF <gs_access_one> IS ASSIGNED AND <gs_access_one>-sipdeg_gun IS NOT INITIAL.
    lv_sipdeg_gun = <gs_access_one>-sipdeg_gun - 1.
    lv_fark_gun =  sy-datum - <gs_vbak>-erdat.
    IF lv_fark_gun GT lv_sipdeg_gun.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '087'
                   id_msgv1 = <gs_vbak>-erdat
                   id_msgv2 = CONV #( <gs_access_one>-sipdeg_gun ) ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
    RETURN.
    "--------->> Anıl CENGİZ 06.01.2021 11:29:40
    "YUR-811
  ELSEIF <gs_access_one> IS ASSIGNED AND <gs_access_one>-sipdeg_gun IS INITIAL..
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '087'
                 id_msgv1 = <gs_vbak>-erdat
                 id_msgv2 = CONV #( <gs_access_one>-sipdeg_gun ) ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
    "---------<<
  ENDIF.

  "Access 2
  DATA(lt_rng_lgort) = VALUE range_t_lgort_d( FOR wa IN <gt_xvbap> WHERE ( lgort IS NOT INITIAL ) ( sign = 'I' option = 'EQ' low = wa-lgort ) ).
  DESCRIBE TABLE lt_rng_lgort.
  lv_lgort_count = sy-tfill.
  DATA(lt_access_two) = VALUE tts_access_two( FOR wa1 IN gt_access_two WHERE ( vkorg EQ <gs_vbak>-vkorg AND vtweg EQ <gs_vbak>-vtweg AND lgort IN lt_rng_lgort ) ( CORRESPONDING #( wa1 ) ) ).
  DESCRIBE TABLE lt_access_two.
  IF sy-tfill NE lv_lgort_count.
    SELECT vkorg vtweg lgort sipdeg_gun
      FROM zsdt_sip_deg_knt
      APPENDING TABLE gt_access_two
      WHERE vkorg EQ <gs_vbak>-vkorg
        AND vtweg EQ <gs_vbak>-vtweg
        AND lgort IN lt_rng_lgort.
    DELETE ADJACENT DUPLICATES FROM gt_access_two COMPARING ALL FIELDS.
  ENDIF.

  CHECK: gt_access_two IS NOT INITIAL.

  DATA(lv_access_two) = VALUE zzsipdeg_gun( gt_access_two[ 1 ]-sipdeg_gun ).

  IF lv_access_two IS NOT INITIAL.
    lv_sipdeg_gun = lv_access_two - 1.
    lv_fark_gun =  sy-datum - <gs_vbak>-erdat.
    IF lv_fark_gun GT lv_sipdeg_gun.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '087'
                   id_msgv1 = <gs_vbak>-erdat
                   id_msgv2 = CONV #( lv_access_two ) ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
    RETURN.
    "--------->> Anıl CENGİZ 06.01.2021 11:29:40
    "YUR-811
  ELSE.
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '087'
                 id_msgv1 = <gs_vbak>-erdat
                 id_msgv2 = CONV #( lv_access_two ) ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
    "---------<<
  ENDIF.

ENDMETHOD.
ENDCLASS.
