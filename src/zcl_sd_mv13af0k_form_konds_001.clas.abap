CLASS zcl_sd_mv13af0k_form_konds_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv13af0k_form_konds .

    TYPES:
      BEGIN OF ty_kotabnr,
        kotabnr TYPE kotabnr,
      END OF ty_kotabnr .
    TYPES:
      tt_kotabnr    TYPE STANDARD TABLE OF ty_kotabnr WITH DEFAULT KEY,
      ttrng_kotabnr TYPE RANGE OF ty_kotabnr.
protected section.
private section.

  types:
    BEGIN OF ty_key_943,
           pltyp   TYPE pltyp,
           zzebat  TYPE zsd_ebat,
           zzlgort TYPE lgort_d,
           vrkme   TYPE vrkme,
           extwg   TYPE extwg,
         END OF ty_key_943 .
  types:
    tt_key_943 TYPE STANDARD TABLE OF ty_key_943 .
  types:
    BEGIN OF ty_key_944,
           pltyp  TYPE pltyp,
           zzebat TYPE zsd_ebat,
           vrkme  TYPE vrkme,
           extwg  TYPE extwg,
         END OF ty_key_944 .
  types:
    tt_key_944 TYPE STANDARD TABLE OF ty_key_944 .
  types:
    BEGIN OF ty_key_942,
           zzlgort TYPE lgort_d,
           pltyp   TYPE pltyp,
           extwg   TYPE extwg,
         END OF ty_key_942 .
  types:
    tt_key_942 TYPE STANDARD TABLE OF ty_key_942 .
  types:
    BEGIN OF ty_key_932,
           zzlgort TYPE lgort_d,
           pltyp   TYPE pltyp,
         END OF ty_key_932 .
  types:
    tt_key_932 TYPE STANDARD TABLE OF ty_key_932 .
  types:
    BEGIN OF ty_key_941,
           pltyp  TYPE pltyp,
           zzseri TYPE zsdd_seri,
           vrkme  TYPE vrkme,
           extwg  TYPE extwg,
         END OF ty_key_941 .
  types:
    tt_key_941 TYPE STANDARD TABLE OF ty_key_941 .
  types:
    BEGIN OF ty_key_935,
           zzseri TYPE zsdd_seri,
           vrkme  TYPE vrkme,
           pltyp  TYPE pltyp,
         END OF ty_key_935 .
  types:
    tt_key_935 TYPE STANDARD TABLE OF ty_key_935 .
  types:
    BEGIN OF ty_key_940,
           pltyp TYPE pltyp,
           kunag TYPE kunag,
           extwg TYPE extwg,
         END OF ty_key_940 .
  types:
    tt_key_940 TYPE STANDARD TABLE OF ty_key_940 .
  types:
    BEGIN OF ty_key_934,
           kunag TYPE kunag,
           pltyp TYPE pltyp,
         END OF ty_key_934 .
  types:
    tt_key_934 TYPE STANDARD TABLE OF ty_key_934 .
  types:
    BEGIN OF ty_key_939,
           pltyp TYPE pltyp,
           extwg TYPE extwg,
         END OF ty_key_939 .
  types:
    tt_key_939 TYPE STANDARD TABLE OF ty_key_939 .
  types:
    BEGIN OF ty_key_933,
           pltyp TYPE pltyp,
         END OF ty_key_933 .
  types:
    tt_key_933 TYPE STANDARD TABLE OF ty_key_933 .
  types:
    BEGIN OF ty_key_949,
           zzebat  TYPE zsd_ebat,
           zzlgort TYPE lgort_d,
           vrkme   TYPE vrkme,
           extwg   TYPE extwg,
         END OF ty_key_949 .
  types:
    tt_key_949 TYPE STANDARD TABLE OF ty_key_949 .
  types:
    BEGIN OF ty_key_950,
           kunnr TYPE kunnr,
           matnr TYPE matnr,
         END OF ty_key_950 .
  types:
    tt_key_950 TYPE STANDARD TABLE OF ty_key_950 .
  types:
    BEGIN OF ty_key_951,
           matnr TYPE matnr,
         END OF ty_key_951 .
  types:
    tt_key_951 TYPE STANDARD TABLE OF ty_key_951 .
  types:
    BEGIN OF ty_key_952,
           pltyp   TYPE pltyp,
           zzlgort TYPE lgort_d,
           zzebat  TYPE zzebat,
           extwg   TYPE extwg,
         END OF ty_key_952 .
  types:
    tt_key_952 TYPE STANDARD TABLE OF ty_key_952 .

  methods EXECUTE
    importing
      value(IT_XVAKE) type COND_VAKEVB_T
      !IT_KONP type COND_KONPDB_T optional
    raising
      ZCX_BC_EXIT_IMP .
ENDCLASS.



CLASS ZCL_SD_MV13AF0K_FORM_KONDS_001 IMPLEMENTATION.


METHOD execute.

  DATA: lr_data        TYPE REF TO data,
        ls_key_943     TYPE ty_key_943,
        ls_key_944     TYPE ty_key_944,
        ls_key_942     TYPE ty_key_942,
        ls_key_932     TYPE ty_key_932,
        ls_key_941     TYPE ty_key_941,
        ls_key_935     TYPE ty_key_935,
        ls_key_940     TYPE ty_key_940,
        ls_key_934     TYPE ty_key_934,
        ls_key_939     TYPE ty_key_939,
        ls_key_933     TYPE ty_key_933,
        ls_key_949     TYPE ty_key_949,
        ls_key_950     TYPE ty_key_950,
        ls_key_951     TYPE ty_key_951,
        ls_key_952     TYPE ty_key_952,
        lt_key_943     TYPE tt_key_943,
        lt_key_944     TYPE tt_key_944,
        lt_key_942     TYPE tt_key_942,
        lt_key_932     TYPE tt_key_932,
        lt_key_941     TYPE tt_key_941,
        lt_key_935     TYPE tt_key_935,
        lt_key_940     TYPE tt_key_940,
        lt_key_934     TYPE tt_key_934,
        lt_key_939     TYPE tt_key_939,
        lt_key_933     TYPE tt_key_933,
        lt_key_949     TYPE tt_key_949,
        lt_key_950     TYPE tt_key_950,
        lt_key_951     TYPE tt_key_951,
        lt_key_952     TYPE tt_key_952,
        ls_a943        TYPE a943,
        lt_a943        TYPE TABLE OF a943,
        ls_a944        TYPE a944,
        lt_a944        TYPE TABLE OF a944,
        ls_a942        TYPE a942,
        lt_a942        TYPE TABLE OF a942,
        ls_a932        TYPE a932,
        lt_a932        TYPE TABLE OF a932,
        ls_a941        TYPE a941,
        lt_a941        TYPE TABLE OF a941,
        ls_a935        TYPE a935,
        lt_a935        TYPE TABLE OF a935,
        ls_a940        TYPE a940,
        lt_a940        TYPE TABLE OF a940,
        ls_a934        TYPE a934,
        lt_a934        TYPE TABLE OF a934,
        ls_a939        TYPE a939,
        lt_a939        TYPE TABLE OF a939,
        ls_a933        TYPE a933,
        lt_a933        TYPE TABLE OF a933,
        ls_a949        TYPE a949,
        lt_a949        TYPE TABLE OF a949,
        ls_a950        TYPE a950,
        lt_a950        TYPE TABLE OF a950,
        ls_a951        TYPE a951,
        lt_a951        TYPE TABLE OF a951,
        ls_a952        TYPE a952,
        lt_a952        TYPE TABLE OF a952,
        lv_pltyp       TYPE pltyp,
        lt_pltyp       TYPE TABLE OF pltyp,
        lv_max_zzprsdt TYPE prsdt.

  CHECK: sy-tcode EQ 'VB21' OR
         sy-tcode EQ 'VB22'.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

  DATA(ltrng_kotabnr) = VALUE ttrng_kotabnr( ( sign = 'I' option = 'EQ' low = '943')
                                             ( sign = 'I' option = 'EQ' low = '944')
                                             ( sign = 'I' option = 'EQ' low = '942')
                                             ( sign = 'I' option = 'EQ' low = '932')
                                             ( sign = 'I' option = 'EQ' low = '941')
                                             ( sign = 'I' option = 'EQ' low = '935')
                                             ( sign = 'I' option = 'EQ' low = '940')
                                             ( sign = 'I' option = 'EQ' low = '934')
                                             ( sign = 'I' option = 'EQ' low = '939')
                                             ( sign = 'I' option = 'EQ' low = '945')
                                             ( sign = 'I' option = 'EQ' low = '948')
                                             ( sign = 'I' option = 'EQ' low = '933')
                                             ( sign = 'I' option = 'EQ' low = '946')
                                             ( sign = 'I' option = 'EQ' low = '947')
                                             ( sign = 'I' option = 'EQ' low = '950')
                                             ( sign = 'I' option = 'EQ' low = '951')
                                             ( sign = 'I' option = 'EQ' low = '949')
                                             ( sign = 'I' option = 'EQ' low = '952') ).

  DELETE it_xvake WHERE kotabnr NOT IN ltrng_kotabnr.

  LOOP AT ltrng_kotabnr REFERENCE INTO DATA(lrrng_kotabnr).
    CASE lrrng_kotabnr->low.
      WHEN '943'.
        DATA(lt_vake) = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING FIELD-SYMBOL(<ls_vake>).
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO FIELD-SYMBOL(<ls_konp>).
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a943.
          ls_a943-knuma_ag  = <ls_vake>-vakey(10).
          ls_a943-vkorg     = <ls_vake>-vakey+10(4).
          ls_a943-vtweg     = <ls_vake>-vakey+14(2).
          ls_a943-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a943-pltyp     = <ls_vake>-vakey+24(2).
          ls_a943-zzebat    = <ls_vake>-vakey+26(30).
          ls_a943-zzlgort   = <ls_vake>-vakey+56(4).
          ls_a943-vrkme     = <ls_vake>-vakey+60(3).
          ls_a943-extwg     = <ls_vake>-vakey+63(18).
          APPEND ls_a943 TO lt_a943.
          MOVE-CORRESPONDING ls_a943 TO ls_key_943.
          COLLECT ls_key_943 INTO lt_key_943.
        ENDLOOP.
        SORT lt_a943 BY pltyp zzebat zzlgort vrkme extwg zzprsdt.
        LOOP AT lt_key_943 ASSIGNING FIELD-SYMBOL(<ls_key_943>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a943 ASSIGNING FIELD-SYMBOL(<ls_a943>)
            WHERE pltyp   EQ <ls_key_943>-pltyp
              AND zzebat  EQ <ls_key_943>-zzebat
              AND zzlgort EQ <ls_key_943>-zzlgort
              AND vrkme   EQ <ls_key_943>-vrkme
              AND extwg   EQ <ls_key_943>-extwg.
            IF <ls_a943>-zzprsdt NE <ls_a943>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_943>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a943>-zzprsdt.
              lv_max_zzprsdt = <ls_a943>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a943 ASSIGNING <ls_a943>
              WHERE pltyp   EQ <ls_key_943>-pltyp
                AND zzebat  EQ <ls_key_943>-zzebat
                AND zzlgort EQ <ls_key_943>-zzlgort
                AND vrkme   EQ <ls_key_943>-vrkme
                AND extwg   EQ <ls_key_943>-extwg
                AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a943>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_943>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '944'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a944.
          ls_a944-knuma_ag  = <ls_vake>-vakey(10).
          ls_a944-vkorg     = <ls_vake>-vakey+10(4).
          ls_a944-vtweg     = <ls_vake>-vakey+14(2).
          ls_a944-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a944-pltyp     = <ls_vake>-vakey+24(2).
          ls_a944-zzebat    = <ls_vake>-vakey+26(30).
          ls_a944-vrkme     = <ls_vake>-vakey+56(3).
          ls_a944-extwg     = <ls_vake>-vakey+59(18).
          APPEND ls_a944 TO lt_a944.
          MOVE-CORRESPONDING ls_a944 TO ls_key_944.
          COLLECT ls_key_944 INTO lt_key_944.
        ENDLOOP.
        SORT lt_a944 BY pltyp zzebat vrkme extwg zzprsdt.
        LOOP AT lt_key_944 ASSIGNING FIELD-SYMBOL(<ls_key_944>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a944 ASSIGNING FIELD-SYMBOL(<ls_a944>)
            WHERE pltyp  EQ <ls_key_944>-pltyp
              AND zzebat EQ <ls_key_944>-zzebat
              AND vrkme  EQ <ls_key_944>-vrkme
              AND extwg  EQ <ls_key_944>-extwg.
            IF <ls_a944>-zzprsdt NE <ls_a944>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_944>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a944>-zzprsdt.
              lv_max_zzprsdt = <ls_a944>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a944 ASSIGNING <ls_a944>
              WHERE pltyp   EQ <ls_key_944>-pltyp
                AND zzebat  EQ <ls_key_944>-zzebat
                AND vrkme   EQ <ls_key_944>-vrkme
                AND extwg   EQ <ls_key_944>-extwg
                AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a944>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_944>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '942'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a942.
          ls_a942-knuma_ag  = <ls_vake>-vakey(10).
          ls_a942-vkorg     = <ls_vake>-vakey+10(4).
          ls_a942-vtweg     = <ls_vake>-vakey+14(2).
          ls_a942-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a942-zzlgort   = <ls_vake>-vakey+24(4).
          ls_a942-pltyp     = <ls_vake>-vakey+28(2).
          ls_a942-extwg     = <ls_vake>-vakey+30(18).
          APPEND ls_a942 TO lt_a942.
          MOVE-CORRESPONDING ls_a942 TO ls_key_942.
          COLLECT ls_key_942 INTO lt_key_942.
        ENDLOOP.
        SORT lt_a942 BY zzlgort pltyp extwg zzprsdt.
        LOOP AT lt_key_942 ASSIGNING FIELD-SYMBOL(<ls_key_942>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a942 ASSIGNING FIELD-SYMBOL(<ls_a942>)
            WHERE zzlgort EQ <ls_key_942>-zzlgort
              AND pltyp   EQ <ls_key_942>-pltyp
              AND extwg   EQ <ls_key_942>-extwg.
            IF <ls_a942>-zzprsdt NE <ls_a942>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_942>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a942>-zzprsdt.
              lv_max_zzprsdt = <ls_a942>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a942 ASSIGNING <ls_a942>
              WHERE zzlgort EQ <ls_key_942>-zzlgort
                AND pltyp   EQ <ls_key_942>-pltyp
                AND extwg   EQ <ls_key_942>-extwg
                AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a942>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_942>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '932'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a932.
          ls_a932-knuma_ag  = <ls_vake>-vakey(10).
          ls_a932-vkorg     = <ls_vake>-vakey+10(4).
          ls_a932-vtweg     = <ls_vake>-vakey+14(2).
          ls_a932-zzlgort   = <ls_vake>-vakey+16(4).
          ls_a932-zzprsdt   = <ls_vake>-vakey+20(8).
          ls_a932-pltyp     = <ls_vake>-vakey+28(2).
          APPEND ls_a932 TO lt_a932.
          MOVE-CORRESPONDING ls_a932 TO ls_key_932.
          COLLECT ls_key_932 INTO lt_key_932.
        ENDLOOP.
        SORT lt_a932 BY zzlgort pltyp zzprsdt.
        LOOP AT lt_key_932 ASSIGNING FIELD-SYMBOL(<ls_key_932>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a932 ASSIGNING FIELD-SYMBOL(<ls_a932>)
            WHERE zzlgort EQ <ls_key_932>-zzlgort
              AND pltyp   EQ <ls_key_932>-pltyp.
            IF <ls_a932>-zzprsdt NE <ls_a932>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_932>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a932>-zzprsdt.
              lv_max_zzprsdt = <ls_a932>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a932 ASSIGNING <ls_a932>
              WHERE zzlgort EQ <ls_key_932>-zzlgort
                AND pltyp   EQ <ls_key_932>-pltyp
                AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a932>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_932>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '941'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a941.

          ls_a941-knuma_ag  = <ls_vake>-vakey(10).
          ls_a941-vkorg     = <ls_vake>-vakey+10(4).
          ls_a941-vtweg     = <ls_vake>-vakey+14(2).
          ls_a941-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a941-pltyp     = <ls_vake>-vakey+24(2).
          ls_a941-zzseri    = <ls_vake>-vakey+26(30).
          ls_a941-vrkme     = <ls_vake>-vakey+56(3).
          ls_a941-extwg     = <ls_vake>-vakey+59(18).
          APPEND ls_a941 TO lt_a941.
          MOVE-CORRESPONDING ls_a941 TO ls_key_941.
          COLLECT ls_key_941 INTO lt_key_941.
        ENDLOOP.
        SORT lt_a941 BY pltyp zzseri vrkme extwg zzprsdt.
        LOOP AT lt_key_941 ASSIGNING FIELD-SYMBOL(<ls_key_941>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a941 ASSIGNING FIELD-SYMBOL(<ls_a941>)
            WHERE pltyp  EQ <ls_key_941>-pltyp
              AND zzseri EQ <ls_key_941>-zzseri
              AND vrkme  EQ <ls_key_941>-vrkme
              AND extwg  EQ <ls_key_941>-extwg.
            IF <ls_a941>-zzprsdt NE <ls_a941>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_941>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a941>-zzprsdt.
              lv_max_zzprsdt = <ls_a941>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a941 ASSIGNING <ls_a941>
            WHERE pltyp   EQ <ls_key_941>-pltyp
              AND zzseri  EQ <ls_key_941>-zzseri
              AND vrkme   EQ <ls_key_941>-vrkme
              AND extwg   EQ <ls_key_941>-extwg
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a941>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_941>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '935'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a935.
          ls_a935-knuma_ag  = <ls_vake>-vakey(10).
          ls_a935-vkorg     = <ls_vake>-vakey+10(4).
          ls_a935-vtweg     = <ls_vake>-vakey+14(2).
          ls_a935-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a935-pltyp     = <ls_vake>-vakey+24(2).
          ls_a935-zzseri    = <ls_vake>-vakey+26(30).
          ls_a935-vrkme     = <ls_vake>-vakey+56(3).
          APPEND ls_a935 TO lt_a935.
          MOVE-CORRESPONDING ls_a935 TO ls_key_935.
          COLLECT ls_key_935 INTO lt_key_935.
        ENDLOOP.
        SORT lt_a935 BY pltyp zzseri vrkme zzprsdt.
        LOOP AT lt_key_935 ASSIGNING FIELD-SYMBOL(<ls_key_935>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a935 ASSIGNING FIELD-SYMBOL(<ls_a935>)
            WHERE pltyp  EQ <ls_key_935>-pltyp
              AND zzseri EQ <ls_key_935>-zzseri
              AND vrkme  EQ <ls_key_935>-vrkme.
            IF <ls_a935>-zzprsdt NE <ls_a935>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_935>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a935>-zzprsdt.
              lv_max_zzprsdt = <ls_a935>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a935 ASSIGNING <ls_a935>
            WHERE pltyp   EQ <ls_key_935>-pltyp
              AND zzseri  EQ <ls_key_935>-zzseri
              AND vrkme   EQ <ls_key_935>-vrkme
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a935>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_935>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '940'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a940.
          ls_a940-knuma_ag  = <ls_vake>-vakey(10).
          ls_a940-vkorg     = <ls_vake>-vakey+10(4).
          ls_a940-vtweg     = <ls_vake>-vakey+14(2).
          ls_a940-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a940-pltyp     = <ls_vake>-vakey+24(2).
          ls_a940-kunag     = <ls_vake>-vakey+26(10).
          ls_a940-extwg     = <ls_vake>-vakey+36(18).
          APPEND ls_a940 TO lt_a940.
          MOVE-CORRESPONDING ls_a940 TO ls_key_940.
          COLLECT ls_key_940 INTO lt_key_940.
        ENDLOOP.
        SORT lt_a940 BY pltyp kunag extwg zzprsdt.
        LOOP AT lt_key_940 ASSIGNING FIELD-SYMBOL(<ls_key_940>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a940 ASSIGNING FIELD-SYMBOL(<ls_a940>)
            WHERE pltyp EQ <ls_key_940>-pltyp
              AND kunag EQ <ls_key_940>-kunag
              AND extwg EQ <ls_key_940>-extwg.
            IF <ls_a940>-zzprsdt NE <ls_a940>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_940>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a940>-zzprsdt.
              lv_max_zzprsdt = <ls_a940>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a940 ASSIGNING <ls_a940>
            WHERE pltyp   EQ <ls_key_940>-pltyp
              AND kunag   EQ <ls_key_940>-kunag
              AND extwg   EQ <ls_key_940>-extwg
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a940>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_940>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '934'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a934.
          ls_a934-knuma_ag  = <ls_vake>-vakey(10).
          ls_a934-vkorg     = <ls_vake>-vakey+10(4).
          ls_a934-vtweg     = <ls_vake>-vakey+14(2).
          ls_a934-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a934-pltyp     = <ls_vake>-vakey+24(2).
          ls_a934-kunag     = <ls_vake>-vakey+26(10).
          APPEND ls_a934 TO lt_a934.
          MOVE-CORRESPONDING ls_a934 TO ls_key_934.
          COLLECT ls_key_934 INTO lt_key_934.
        ENDLOOP.
        SORT lt_a934 BY pltyp kunag zzprsdt.
        LOOP AT lt_key_934 ASSIGNING FIELD-SYMBOL(<ls_key_934>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a934 ASSIGNING FIELD-SYMBOL(<ls_a934>)
            WHERE pltyp EQ <ls_key_934>-pltyp
              AND kunag EQ <ls_key_934>-kunag.
            IF <ls_a934>-zzprsdt NE <ls_a934>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_934>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a934>-zzprsdt.
              lv_max_zzprsdt = <ls_a934>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a934 ASSIGNING <ls_a934>
            WHERE pltyp   EQ <ls_key_934>-pltyp
              AND kunag   EQ <ls_key_934>-kunag
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a934>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_934>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '939' OR '945' OR '948'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a939.
          ls_a939-knuma_ag  = <ls_vake>-vakey(10).
          ls_a939-vkorg     = <ls_vake>-vakey+10(4).
          ls_a939-vtweg     = <ls_vake>-vakey+14(2).
          ls_a939-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a939-pltyp     = <ls_vake>-vakey+24(2).
          ls_a939-extwg     = <ls_vake>-vakey+26(18).
          APPEND ls_a939 TO lt_a939.
          MOVE-CORRESPONDING ls_a939 TO ls_key_939.
          COLLECT ls_key_939 INTO lt_key_939.
        ENDLOOP.
        SORT lt_a939 BY pltyp extwg zzprsdt.
        LOOP AT lt_key_939 ASSIGNING FIELD-SYMBOL(<ls_key_939>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a939 ASSIGNING FIELD-SYMBOL(<ls_a939>)
            WHERE pltyp EQ <ls_key_939>-pltyp
              AND extwg EQ <ls_key_939>-extwg.
            IF <ls_a939>-zzprsdt NE <ls_a939>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_939>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a939>-zzprsdt.
              lv_max_zzprsdt = <ls_a939>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a939 ASSIGNING <ls_a939>
            WHERE pltyp   EQ <ls_key_939>-pltyp
              AND extwg   EQ <ls_key_939>-extwg
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a939>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_939>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '933' OR '946' OR '947'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a933.
          ls_a933-knuma_ag  = <ls_vake>-vakey(10).
          ls_a933-vkorg     = <ls_vake>-vakey+10(4).
          ls_a933-vtweg     = <ls_vake>-vakey+14(2).
          ls_a933-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a933-pltyp     = <ls_vake>-vakey+24(2).
          APPEND ls_a933 TO lt_a933.
          MOVE-CORRESPONDING ls_a933 TO ls_key_933.
          COLLECT ls_key_933 INTO lt_key_933.
        ENDLOOP.
        SORT lt_a933 BY pltyp zzprsdt.
        LOOP AT lt_key_933 ASSIGNING FIELD-SYMBOL(<ls_key_933>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a933 ASSIGNING FIELD-SYMBOL(<ls_a933>)
            WHERE pltyp EQ <ls_key_933>-pltyp.
            IF <ls_a933>-zzprsdt NE <ls_a933>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_933>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a933>-zzprsdt.
              lv_max_zzprsdt = <ls_a933>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a933 ASSIGNING <ls_a933>
            WHERE pltyp   EQ <ls_key_933>-pltyp
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a933>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_933>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        "--------->> Anıl CENGİZ 22.12.2020 16:44:45
        "YUR-796
      WHEN '950'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a950.
          ls_a950-knuma_ag  = <ls_vake>-vakey(10).
          ls_a950-vkorg     = <ls_vake>-vakey+10(4).
          ls_a950-vtweg     = <ls_vake>-vakey+14(2).
          ls_a950-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a950-kunnr     = <ls_vake>-vakey+24(10).
          ls_a950-matnr     = <ls_vake>-vakey+34(18).
          APPEND ls_a950 TO lt_a950.
          MOVE-CORRESPONDING ls_a950 TO ls_key_950.
          COLLECT ls_key_950 INTO lt_key_950.
        ENDLOOP.
        SORT lt_a950 BY kunnr matnr zzprsdt.
        LOOP AT lt_key_950 ASSIGNING FIELD-SYMBOL(<ls_key_950>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a950 ASSIGNING FIELD-SYMBOL(<ls_a950>)
            WHERE kunnr EQ <ls_key_950>-kunnr
              AND matnr EQ <ls_key_950>-matnr.
            IF <ls_a950>-zzprsdt NE <ls_a950>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a950>-zzprsdt.
              lv_max_zzprsdt = <ls_a950>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a950 ASSIGNING <ls_a950>
            WHERE kunnr   EQ <ls_key_950>-kunnr
              AND matnr   EQ <ls_key_950>-matnr
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a950>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '951'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a951.
          ls_a951-knuma_ag  = <ls_vake>-vakey(10).
          ls_a951-vkorg     = <ls_vake>-vakey+10(4).
          ls_a951-vtweg     = <ls_vake>-vakey+14(2).
          ls_a951-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a951-matnr     = <ls_vake>-vakey+24(18).
          APPEND ls_a951 TO lt_a951.
          MOVE-CORRESPONDING ls_a951 TO ls_key_951.
          COLLECT ls_key_951 INTO lt_key_951.
        ENDLOOP.
        SORT lt_a951 BY matnr zzprsdt.
        LOOP AT lt_key_951 ASSIGNING FIELD-SYMBOL(<ls_key_951>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a951 ASSIGNING FIELD-SYMBOL(<ls_a951>)
            WHERE matnr EQ <ls_key_951>-matnr.
            IF <ls_a951>-zzprsdt NE <ls_a951>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a951>-zzprsdt.
              lv_max_zzprsdt = <ls_a951>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a951 ASSIGNING <ls_a951>
            WHERE matnr   EQ <ls_key_951>-matnr
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a951>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '949'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a949.
          ls_a949-knuma_ag  = <ls_vake>-vakey(10).
          ls_a949-vkorg     = <ls_vake>-vakey+10(4).
          ls_a949-vtweg     = <ls_vake>-vakey+14(2).
          ls_a949-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a949-zzebat    = <ls_vake>-vakey+24(30).
          ls_a949-zzlgort   = <ls_vake>-vakey+54(4).
          ls_a949-vrkme     = <ls_vake>-vakey+58(3).
          ls_a949-extwg     = <ls_vake>-vakey+61(18).
          APPEND ls_a949 TO lt_a949.
          MOVE-CORRESPONDING ls_a949 TO ls_key_949.
          COLLECT ls_key_949 INTO lt_key_949.
        ENDLOOP.
        SORT lt_a949 BY zzebat zzlgort vrkme extwg zzprsdt.
        LOOP AT lt_key_949 ASSIGNING FIELD-SYMBOL(<ls_key_949>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a949 ASSIGNING FIELD-SYMBOL(<ls_a949>)
            WHERE zzebat  EQ <ls_key_949>-zzebat
              AND zzlgort EQ <ls_key_949>-zzlgort
              AND vrkme   EQ <ls_key_949>-vrkme
              AND extwg   EQ <ls_key_949>-extwg.
            IF <ls_a949>-zzprsdt NE <ls_a949>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a949>-zzprsdt.
              lv_max_zzprsdt = <ls_a949>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a949 ASSIGNING <ls_a949>
            WHERE zzebat  EQ <ls_key_949>-zzebat
              AND zzlgort EQ <ls_key_949>-zzlgort
              AND vrkme   EQ <ls_key_949>-vrkme
              AND extwg   EQ <ls_key_949>-extwg
              AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a949>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = space ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      WHEN '952'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          ASSIGN it_konp[ knumh = <ls_vake>-knumh
                          loevm_ko = abap_true ] TO <ls_konp>.
          CHECK: sy-subrc NE 0.
          MOVE-CORRESPONDING <ls_vake> TO ls_a952.
          ls_a952-knuma_ag  = <ls_vake>-vakey(10).
          ls_a952-vkorg     = <ls_vake>-vakey+10(4).
          ls_a952-vtweg     = <ls_vake>-vakey+14(2).
          ls_a952-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a952-pltyp     = <ls_vake>-vakey+24(2).
          ls_a952-zzlgort   = <ls_vake>-vakey+26(4).
          ls_a952-zzebat    = <ls_vake>-vakey+30(30).
          ls_a952-extwg     = <ls_vake>-vakey+60(18).
          APPEND ls_a952 TO lt_a952.
          MOVE-CORRESPONDING ls_a952 TO ls_key_952.
          COLLECT ls_key_952 INTO lt_key_952.
        ENDLOOP.
        SORT lt_a952 BY pltyp zzlgort zzebat extwg zzprsdt.
        LOOP AT lt_key_952 ASSIGNING FIELD-SYMBOL(<ls_key_952>).
          CLEAR: lv_max_zzprsdt.
          LOOP AT lt_a952 ASSIGNING FIELD-SYMBOL(<ls_a952>)
            WHERE pltyp   EQ <ls_key_952>-pltyp
              AND zzlgort EQ <ls_key_952>-zzlgort
              AND zzebat  EQ <ls_key_952>-zzebat
              AND extwg   EQ <ls_key_952>-extwg.
            IF <ls_a952>-zzprsdt NE <ls_a952>-datab.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e01
                           id_msgv2 = text-e02
                           id_msgv3 = <ls_key_952>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
            IF lv_max_zzprsdt LT <ls_a952>-zzprsdt.
              lv_max_zzprsdt = <ls_a952>-zzprsdt.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_a952 ASSIGNING <ls_a952>
              WHERE pltyp   EQ <ls_key_952>-pltyp
                AND zzlgort EQ <ls_key_952>-zzlgort
                AND zzebat  EQ <ls_key_952>-zzebat
                AND extwg   EQ <ls_key_952>-extwg
                AND zzprsdt NE lv_max_zzprsdt.
            IF lv_max_zzprsdt LE <ls_a942>-datbi.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'LS'
                           id_msgno = '001'
                           id_msgv1 = text-e03
                           id_msgv2 = text-e04
                           id_msgv3 = <ls_key_952>-pltyp ).
              RAISE EXCEPTION TYPE zcx_bc_exit_imp
                EXPORTING
                  messages = lo_msg.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        "---------<<
    ENDCASE.
  ENDLOOP.

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
