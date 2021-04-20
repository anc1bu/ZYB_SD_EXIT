class ZCL_SD_MV13AF0K_FORM_KONDS_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV13AF0K_FORM_KONDS .

  class-methods EXECUTE
    importing
      !IT_XVAKE type COND_VAKEVB_T
      !IT_KONP type COND_KONPDB_T optional
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.

  types:
    BEGIN OF ty_extwg,
           matnr TYPE matnr,
           mtart type mtart,
           extwg TYPE extwg,
         END OF ty_extwg .
  types:
    tth_extwg TYPE HASHED TABLE OF ty_extwg WITH UNIQUE KEY matnr .

  class-data GT_EXTWG type TTH_EXTWG .
ENDCLASS.



CLASS ZCL_SD_MV13AF0K_FORM_KONDS_002 IMPLEMENTATION.


METHOD execute.

  DATA: ls_extwg   TYPE ty_extwg.

  CHECK: sy-tcode EQ 'ZSD007' OR
         sy-tcode EQ 'VK11' OR
         sy-tcode EQ 'VK12'.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

  DATA(lt_kotabnr) = VALUE zcl_sd_mv13af0k_form_konds_001=>tt_kotabnr( ( kotabnr = '910')
                                                                       ( kotabnr = '004') ).

  TRY.
      LOOP AT lt_kotabnr INTO DATA(lv_kotabnr).
        DATA(lt_vake) = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lv_kotabnr AND
                                                                        updkz NE '' AND
                                                                        kschl EQ 'ZF04' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake REFERENCE INTO DATA(lr_vake).

          ASSIGN it_konp[ knumh = lr_vake->knumh
                          loevm_ko = abap_true ] TO FIELD-SYMBOL(<is_konp>).
          CHECK: sy-subrc NE 0.

          CASE lr_vake->kotabnr.
            WHEN '910'.
              DATA(lv_matnr) = lr_vake->vakey+8(18).
            WHEN '004'.
              lv_matnr = lr_vake->vakey+6(18).
          ENDCASE.

          CHECK: lv_matnr NE zcl_sd_paletftr_mamulle=>cv_pltmlzno.

          ASSIGN gt_extwg[ KEY primary_key COMPONENTS matnr = lv_matnr ] TO FIELD-SYMBOL(<gs_extwg>).
          IF sy-subrc NE 0.
            SELECT SINGLE matnr mtart extwg
              FROM mara
              INTO ls_extwg
              WHERE matnr EQ lv_matnr.
            IF sy-subrc EQ 0.
              INSERT ls_extwg INTO TABLE gt_extwg ASSIGNING <gs_extwg>.
            ELSE.
              RETURN.
            ENDIF.
          ENDIF.

          DATA(rr_vld_extwg) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                             var   = 'EXTWG'
                                                                             val   = REF #( <gs_extwg>-extwg )
                                                                             surec = 'YI_ZF04_GRIS' ) ) .
          ASSIGN rr_vld_extwg->* TO FIELD-SYMBOL(<lv_vld_extwg>).

          IF <lv_vld_extwg> NE abap_true. "Geçerli kalite değil ise.
            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZSD'
                         id_msgno = '088'
                         id_msgv1 = zcl_sd_toolkit=>get_extwg( ls_extwg-matnr )-extwg
                         id_msgv2 = |ZF04|
                         id_msgv3 = space
                         id_msgv4 = space ). "& kalite için & fiyatı giremezsiniz!

          ENDIF.

          DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                             var   = 'MTART'
                                                                             val   = REF #( <gs_extwg>-mtart )
                                                                             surec = 'YI_ZF04_GRIS' ) ) .
          ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

          IF <lv_vld_mtart> NE abap_true. "Geçerli malzeme türü değil ise.
            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZSD'
                         id_msgno = '089'
                         id_msgv1 = <gs_extwg>-mtart
                         id_msgv2 = |ZF04|
                         id_msgv3 = space
                         id_msgv4 = space ). "& malzeme türü için & fiyatı giremezsiniz!

          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF lo_msg->has_messages_of_msgty( 'E' ) EQ abap_true .
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.
    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.

  ENDTRY.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gt_xvake> TYPE cond_vakevb_t,
                 <lt_konp>  TYPE cond_konpdb_t.

  DATA: lr_data TYPE REF TO data,
        lt_konp TYPE cond_konpdb_t.

  lr_data = co_con->get_vars( 'XVAKE[]' ). ASSIGN lr_data->* TO <gt_xvake>.

  ASSIGN ('(SAPMV13A)XKONP[]') TO <lt_konp>.
  IF sy-subrc EQ 0.
    lt_konp = <lt_konp>.
  ENDIF.

  execute( EXPORTING it_xvake = <gt_xvake>
                     it_konp = lt_konp ).

ENDMETHOD.
ENDCLASS.
