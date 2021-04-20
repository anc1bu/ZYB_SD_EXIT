class ZCL_SD_MV13AF0K_FORM_KONDS_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV13AF0K_FORM_KONDS .

  class-methods EXECUTE
    importing
      value(IT_XVAKE) type COND_VAKEVB_T
      !IT_KONP type COND_KONPDB_T optional
    raising
      ZCX_BC_EXIT_IMP .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_a910,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             pltyp    TYPE pltyp,
             matnr    TYPE matnr,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a910,
           tt_a910 TYPE STANDARD TABLE OF ty_a910,
           BEGIN OF ty_a004,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             matnr    TYPE matnr,
             datab    TYPE datab,
             datbi    TYPE datbi,
             knumh    TYPE knumh,
             loevm_ko TYPE loevm_ko,
           END OF ty_a004,
           tt_a004     TYPE STANDARD TABLE OF ty_a004,
           ttrng_matnr TYPE RANGE OF matnr,
           BEGIN OF ty_knumh,
             knumh    TYPE knumh,
             loevm_ko TYPE loevm_ko,
           END OF ty_knumh,
           tt_knumh TYPE TABLE OF ty_knumh.
ENDCLASS.



CLASS ZCL_SD_MV13AF0K_FORM_KONDS_003 IMPLEMENTATION.


  METHOD execute.

    DATA: lr_data      TYPE REF TO data,
          ls_a910      TYPE ty_a910,
          lt_a910      TYPE tt_a910,
          ls_a004      TYPE ty_a004,
          lt_a004      TYPE tt_a004,
          lv_matnr     TYPE matnr,
          lv_kalite(1),
          ltrng_matnr  TYPE ttrng_matnr,
          lt_msg       TYPE re_t_msg,
          lt_knumh     TYPE tt_knumh.

    DATA(lo_msg) = cf_reca_message_list=>create( ).

    CHECK: sy-tcode EQ 'VK11' OR
           sy-tcode EQ 'VK12' OR
           sy-tcode EQ 'ZSD007'.

*    LOOP AT it_xvake REFERENCE INTO DATA(ir_vake).
*      COLLECT ir_vake->kotabnr INTO lt_kotabnr.
*    ENDLOOP.

    DATA(ltrng_kotabnr) = VALUE zcl_sd_mv13af0k_form_konds_001=>ttrng_kotabnr( ( sign = 'I' option = 'EQ' low = '910')
                                                                               ( sign = 'I' option = 'EQ' low = '004') ).

    DELETE it_xvake WHERE kotabnr NOT IN ltrng_kotabnr.

    LOOP AT ltrng_kotabnr REFERENCE INTO DATA(lrrng_kotabnr).
      CASE lrrng_kotabnr->low.
        WHEN '910'.
          DATA(lt_vake) = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                          kschl   EQ 'ZF04' ) ( CORRESPONDING #( wa ) ) ).
          LOOP AT lt_vake ASSIGNING FIELD-SYMBOL(<ls_vake>).
            IF <ls_vake>-knumh IS NOT INITIAL.
              ASSIGN it_konp[ knumh = <ls_vake>-knumh
                              loevm_ko = space ] TO FIELD-SYMBOL(<is_konp>).
              CHECK: sy-subrc EQ 0.
            ENDIF.
            MOVE-CORRESPONDING <ls_vake> TO ls_a910.
            ls_a910-vkorg     = <ls_vake>-vakey(4).
            ls_a910-vtweg     = <ls_vake>-vakey+4(2).
            ls_a910-pltyp     = <ls_vake>-vakey+6(2).
            ls_a910-matnr     = <ls_vake>-vakey+8(18).
            ls_a910-datab     = <ls_vake>-datab.
            ls_a910-datbi     = <ls_vake>-datbi.

            SPLIT ls_a910-matnr AT '.' INTO lv_matnr lv_kalite.
            lv_matnr = |{ lv_matnr }*|.
            ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a910-matnr )
                                   ( sign = 'I' option = 'CP' low = lv_matnr ) ).

            SELECT a910~vkorg a910~vtweg a910~pltyp
                   a910~matnr MAX( a910~datab ) AS datab MAX( a910~datbi ) AS datbi
                   konp~loevm_ko
              FROM a910
              INNER JOIN konp ON a910~knumh EQ konp~knumh
              INTO CORRESPONDING FIELDS OF TABLE lt_a910
              WHERE a910~kappl EQ 'V'
                AND a910~kschl EQ 'ZF04'
                AND a910~vkorg EQ ls_a910-vkorg
                AND a910~vtweg EQ ls_a910-vtweg
                AND a910~pltyp EQ ls_a910-pltyp
                AND a910~matnr IN ltrng_matnr
                GROUP BY a910~vkorg a910~vtweg a910~pltyp a910~matnr konp~loevm_ko.

            LOOP AT lt_vake ASSIGNING FIELD-SYMBOL(<ls_vake2>).
              CHECK: <ls_vake2>-vakey+8(18) NE ls_a910-matnr .
              LOOP AT lt_a910 REFERENCE INTO DATA(lr_a910)
                WHERE vkorg EQ <ls_vake2>-vakey(4)
                  AND vtweg EQ <ls_vake2>-vakey+4(2)
                  AND pltyp EQ <ls_vake2>-vakey+6(2)
                  AND matnr EQ <ls_vake2>-vakey+8(18).
                DATA(lv_tabix) = sy-tabix.
                DATA(lv_key) = |{ lr_a910->vkorg }{ lr_a910->vtweg }{ lr_a910->pltyp }{ lr_a910->matnr }|.
                ASSIGN lt_vake[ vakey = lv_key ] TO FIELD-SYMBOL(<ls_vake1>).
                IF sy-subrc EQ 0.
                  IF <ls_vake1>-knumh IS NOT INITIAL.
                    ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                    IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                      lr_a910->datab = <ls_vake1>-datab.
                      lr_a910->datbi = <ls_vake1>-datbi.
                    ELSE.
                      DELETE lt_a910 INDEX lv_tabix.
                    ENDIF.
                  ELSE.
                    lr_a910->datab = <ls_vake1>-datab.
                    lr_a910->datbi = <ls_vake1>-datbi.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              IF sy-subrc NE 0.
                IF <ls_vake2>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    APPEND VALUE #( vkorg = <ls_vake2>-vakey(4)
                                    vtweg = <ls_vake2>-vakey+4(2)
                                    pltyp = <ls_vake2>-vakey+6(2)
                                    matnr = <ls_vake2>-vakey+8(18)
                                    datab = <ls_vake2>-datab
                                    datbi = <ls_vake2>-datbi ) TO lt_a910.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.

            DELETE lt_a910 WHERE matnr NOT IN ltrng_matnr.
            IF lt_a910 IS NOT INITIAL.
              LOOP AT lt_a910 REFERENCE INTO lr_a910
                WHERE vkorg EQ ls_a910-vkorg
                  AND vtweg EQ ls_a910-vtweg
                  AND pltyp EQ ls_a910-pltyp
                  AND datab GT ls_a910-datab
                  AND datab GT ls_a910-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                LOOP AT lt_a910 REFERENCE INTO lr_a910
                  WHERE vkorg EQ ls_a910-vkorg
                    AND vtweg EQ ls_a910-vtweg
                    AND pltyp EQ ls_a910-pltyp
                    AND datbi LT ls_a910-datab
                    AND datbi LT ls_a910-datbi.
                  EXIT.
                ENDLOOP.
                IF sy-subrc NE 0.
                  APPEND VALUE #( msgty = 'E'
                    msgid = 'ZSD'
                    msgno = '092'
                    msgv1 = ls_a910-pltyp
                    msgv2 = ls_a910-matnr
                    msgv3 = lt_a910[ 1 ]-matnr
                    msgv4 = 'ZF04' ) TO lt_msg.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        WHEN '004'.
          lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                    kschl   EQ 'ZF04' ) ( CORRESPONDING #( wa ) ) ).
          LOOP AT lt_vake ASSIGNING <ls_vake>.
            IF <ls_vake>-knumh IS NOT INITIAL.
              ASSIGN it_konp[ knumh = <ls_vake>-knumh
                              loevm_ko = space ] TO <is_konp>.
              CHECK: sy-subrc EQ 0.
            ENDIF.
            MOVE-CORRESPONDING <ls_vake> TO ls_a004.
            ls_a004-vkorg     = <ls_vake>-vakey(4).
            ls_a004-vtweg     = <ls_vake>-vakey+4(2).
            ls_a004-matnr     = <ls_vake>-vakey+6(18).
            ls_a004-datab     = <ls_vake>-datab.
            ls_a004-datbi     = <ls_vake>-datbi.

            SPLIT ls_a004-matnr AT '.' INTO lv_matnr lv_kalite.
            lv_matnr = |{ lv_matnr }*|.
            ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a004-matnr )
                                   ( sign = 'I' option = 'CP' low = lv_matnr ) ).

            SELECT vkorg vtweg matnr
                   datab datbi knumh
              FROM a004
              INTO CORRESPONDING FIELDS OF TABLE lt_a004
              WHERE a004~kappl EQ 'V'
                AND a004~kschl EQ 'ZF04'
                AND a004~vkorg EQ ls_a004-vkorg
                AND a004~vtweg EQ ls_a004-vtweg
                AND a004~matnr IN ltrng_matnr.
            IF lt_a004 IS NOT INITIAL.
              SELECT knumh loevm_ko
                FROM konp
                INTO CORRESPONDING FIELDS OF TABLE lt_knumh
                FOR ALL ENTRIES IN lt_a004
                WHERE knumh EQ lt_a004-knumh.
            ENDIF.

            LOOP AT lt_a004 ASSIGNING FIELD-SYMBOL(<ls_a004>).
              ASSIGN lt_knumh[ knumh = <ls_a004>-knumh ] TO FIELD-SYMBOL(<ls_knumh>).
              CHECK: sy-subrc EQ 0.
              <ls_a004>-loevm_ko = <ls_knumh>-loevm_ko.
            ENDLOOP.

            LOOP AT lt_vake ASSIGNING <ls_vake2>.
              CHECK: <ls_vake2>-vakey+6(18) NE ls_a004-matnr.
              LOOP AT lt_a004 REFERENCE INTO DATA(lr_a004)
                WHERE vkorg EQ <ls_vake2>-vakey(4)
                  AND vtweg EQ <ls_vake2>-vakey+4(2)
                  AND matnr EQ <ls_vake2>-vakey+6(18).
                lv_tabix = sy-tabix.
                lv_key = |{ lr_a004->vkorg }{ lr_a004->vtweg }{ lr_a004->matnr }|.
                ASSIGN lt_vake[ vakey = lv_key ] TO <ls_vake1>.
                IF sy-subrc EQ 0.
                  IF <ls_vake1>-knumh IS NOT INITIAL.
                    ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                    IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                      lr_a004->datab = <ls_vake1>-datab.
                      lr_a004->datbi = <ls_vake1>-datbi.
                    ELSE.
                      DELETE lt_a004 INDEX lv_tabix.
                    ENDIF.
                  ELSE.
                    lr_a004->datab = <ls_vake1>-datab.
                    lr_a004->datbi = <ls_vake1>-datbi.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              IF sy-subrc NE 0.
                IF <ls_vake2>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    APPEND VALUE #( vkorg = <ls_vake2>-vakey(4)
                                    vtweg = <ls_vake2>-vakey+4(2)
                                    matnr = <ls_vake2>-vakey+6(18)
                                    datab = <ls_vake2>-datab
                                    datbi = <ls_vake2>-datbi ) TO lt_a004.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
            DELETE lt_a004 WHERE matnr NOT IN ltrng_matnr.
            IF lt_a004 IS NOT INITIAL.
              LOOP AT lt_a004 REFERENCE INTO lr_a004
                WHERE vkorg EQ ls_a004-vkorg
                  AND vtweg EQ ls_a004-vtweg
                  AND datab GT ls_a004-datab
                  AND datab GT ls_a004-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                LOOP AT lt_a004 REFERENCE INTO lr_a004
                  WHERE vkorg EQ ls_a004-vkorg
                    AND vtweg EQ ls_a004-vtweg
                    AND datbi LT ls_a004-datab
                    AND datbi LT ls_a004-datbi.
                  EXIT.
                ENDLOOP.
                IF sy-subrc NE 0.
                  APPEND VALUE #( msgty = 'E'
                    msgid = 'ZSD'
                    msgno = '092'
                    msgv1 = space
                    msgv2 = ls_a004-matnr
                    msgv3 = lt_a004[ 1 ]-matnr
                    msgv4 = 'ZF06' ) TO lt_msg.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.

    SORT lt_msg.
    DELETE ADJACENT DUPLICATES FROM lt_msg COMPARING ALL FIELDS.
    LOOP AT lt_msg REFERENCE INTO DATA(lr_msg).
      lo_msg->add( id_msgty = lr_msg->msgty
                   id_msgid = lr_msg->msgid
                   id_msgno = lr_msg->msgno
                   id_msgv1 = lr_msg->msgv1
                   id_msgv2 = lr_msg->msgv2
                   id_msgv3 = lr_msg->msgv3
                   id_msgv4 = lr_msg->msgv4 ).
    ENDLOOP.

    IF lo_msg->is_empty( ) NE abap_true.
      REFRESH: lt_msg.
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.

  ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gt_xvake> TYPE cond_vakevb_t,
                 <gt_xkonp> TYPE cond_konpdb_t.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVAKE[]' ). ASSIGN lr_data->* TO <gt_xvake>.
  lr_data = co_con->get_vars( 'XKONP[]' ). ASSIGN lr_data->* TO <gt_xkonp>.

  execute( EXPORTING it_xvake = <gt_xvake>
                     it_konp = <gt_xkonp> ).

ENDMETHOD.
ENDCLASS.
