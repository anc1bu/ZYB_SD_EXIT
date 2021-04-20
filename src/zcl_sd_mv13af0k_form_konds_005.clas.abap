class ZCL_SD_MV13AF0K_FORM_KONDS_005 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV13AF0K_FORM_KONDS .

  class-methods CLASS_CONSTRUCTOR .
  class-methods EXECUTE
    importing
      value(IT_XVAKE) type COND_VAKEVB_T
      !IT_KONP type COND_KONPDB_T optional
    raising
      ZCX_BC_EXIT_IMP .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_a950,
             knuma_ag TYPE knuma_ag,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             zzprsdt  TYPE prsdt,
             kunnr    TYPE kunnr_v,
             matnr    TYPE matnr,
             kfrst    TYPE kfrst,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a950 .
  types:
    tt_a950 TYPE STANDARD TABLE OF ty_a950 .
  types:
    BEGIN OF ty_a951,
             knuma_ag TYPE knuma_ag,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             zzprsdt  TYPE prsdt,
             matnr    TYPE matnr,
             kfrst    TYPE kfrst,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a951 .
  types:
    tt_a951 TYPE STANDARD TABLE OF ty_a951 .
  types:
    BEGIN OF ty_a908,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             kunnr    TYPE kunnr_v,
             matnr    TYPE matnr,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a908 .
  types:
    tt_a908 TYPE STANDARD TABLE OF ty_a908 .
  types:
    BEGIN OF ty_a936,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             zzlgort  TYPE lgort_d,
             matnr    TYPE matnr,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a936 .
  types:
    tt_a936 TYPE STANDARD TABLE OF ty_a936 .
  types:
    BEGIN OF ty_a909,
             vkorg    TYPE vkorg,
             vtweg    TYPE vtweg,
             matnr    TYPE matnr,
             datab    TYPE datab,
             datbi    TYPE datbi,
             loevm_ko TYPE loevm_ko,
           END OF ty_a909 .
  types:
    tt_a909     TYPE STANDARD TABLE OF ty_a909 .
  types:
    ttrng_matnr TYPE RANGE OF matnr .
  types:
    BEGIN OF ty_knumh,
             knumh    TYPE knumh,
             loevm_ko TYPE loevm_ko,
           END OF ty_knumh .
  types:
    tt_knumh TYPE TABLE OF ty_knumh .
  types TY_EXTWG_ZF06 type ZSDT_EXTWG_ZF06 .
  types:
    tt_extwg_zf06 type STANDARD TABLE OF ty_extwg_zf06 .

  class-data GT_EXTWG_ZF06 type TT_EXTWG_ZF06 .
ENDCLASS.



CLASS ZCL_SD_MV13AF0K_FORM_KONDS_005 IMPLEMENTATION.


METHOD class_constructor.

  SELECT *
    FROM zsdt_extwg_zf06
    INTO TABLE gt_extwg_zf06.

ENDMETHOD.


METHOD execute.

  DATA: lr_data      TYPE REF TO data,
        ls_a950      TYPE ty_a950,
        lt_a950      TYPE tt_a950,
        ls_a951      TYPE ty_a951,
        lt_a951      TYPE tt_a951,
        ls_a908      TYPE ty_a908,
        lt_a908      TYPE tt_a908,
        ls_a936      TYPE ty_a936,
        lt_a936      TYPE tt_a936,
        ls_a909      TYPE ty_a909,
        lt_a909      TYPE tt_a909,
        lv_matnr     TYPE matnr,
        lv_kalite(1),
        ltrng_matnr  TYPE ttrng_matnr,
        lt_msg       TYPE re_t_msg,
        lt_knumh     TYPE tt_knumh.

  CHECK: sy-tcode EQ 'VK11' OR
         sy-tcode EQ 'VK12' OR
         sy-tcode EQ 'VB21' OR
         sy-tcode EQ 'VB22' OR
         sy-tcode EQ 'ZSD007'.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

*10	950	Tic.prom./Müşteri/Malzeme
*MANDT  MANDT CLNT  3 0 Üst birim
*KAPPL  KAPPL CHAR  2 0 Uygulama
*KSCHL  KSCHA CHAR  4 0 Koşul türü
*KNUMA_AG KNUMA_AG  CHAR  10  0 Ticari promosyon
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZPRSDT  PRSDT DATS  8 0 Fiyatlandırma ve döviz kuruna ilişkin tarih
*KUNNR  KUNNR_V CHAR  10  0 Müşteri numarası
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*KFRST  KFRST CHAR  1 0 Onay durumu
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*20	951	Tic.prom./Malzeme
*MANDT  MANDT CLNT  3 0 Üst birim
*KAPPL  KAPPL CHAR  2 0 Uygulama
*KSCHL  KSCHA CHAR  4 0 Koşul türü
*KNUMA_AG KNUMA_AG  CHAR  10  0 Ticari promosyon
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZPRSDT  PRSDT DATS  8 0 Fiyatlandırma ve döviz kuruna ilişkin tarih
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*KFRST  KFRST CHAR  1 0 Onay durumu
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*30	949	Tic.prom./Ebat/Depo/SÖB/Kalite

*40	908	Müşteri/Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*KUNNR  KUNNR_V CHAR  10  0 Müşteri numarası
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*50	936	Depo yeri/Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZLGORT  LGORT_D CHAR  4 0 Depo yeri
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*60	909	Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*  LOOP AT it_xvake REFERENCE INTO DATA(ir_vake).
*    COLLECT ir_vake->kotabnr INTO lt_kotabnr.
*  ENDLOOP.

  DATA(ltrng_kotabnr) = VALUE zcl_sd_mv13af0k_form_konds_001=>ttrng_kotabnr( ( sign = 'I' option = 'EQ' low = '950')
                                                                             ( sign = 'I' option = 'EQ' low = '951')
                                                                             ( sign = 'I' option = 'EQ' low = '949')
                                                                             ( sign = 'I' option = 'EQ' low = '908')
                                                                             ( sign = 'I' option = 'EQ' low = '936')
                                                                             ( sign = 'I' option = 'EQ' low = '909') ).
  DELETE it_xvake WHERE kotabnr NOT IN ltrng_kotabnr.

  LOOP AT ltrng_kotabnr REFERENCE INTO DATA(lrrng_kotabnr).
    CASE lrrng_kotabnr->low.
      WHEN '950'.
        DATA(lt_vake) = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                        kschl   EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING FIELD-SYMBOL(<ls_vake>).
          IF <ls_vake>-knumh IS NOT INITIAL.
            ASSIGN it_konp[ knumh = <ls_vake>-knumh
                            loevm_ko = space ] TO FIELD-SYMBOL(<is_konp>).
            CHECK: sy-subrc EQ 0.
          ENDIF.
          MOVE-CORRESPONDING <ls_vake> TO ls_a950.
          ls_a950-knuma_ag  = <ls_vake>-vakey(10).
          ls_a950-vkorg     = <ls_vake>-vakey+10(4).
          ls_a950-vtweg     = <ls_vake>-vakey+14(2).
*            ls_a950-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a950-kunnr     = <ls_vake>-vakey+24(10).
          ls_a950-matnr     = <ls_vake>-vakey+34(18).
          ls_a950-kfrst     = <ls_vake>-vakey+52(1).
          ls_a950-datbi     = <ls_vake>-datbi.
          ls_a950-datab     = <ls_vake>-datab.

          SPLIT ls_a950-matnr AT '.' INTO lv_matnr lv_kalite.
          "--------->> Anıl CENGİZ 08.02.2021 15:25:58
          "YUR-840
*          lv_matnr = |{ lv_matnr }*|.
*          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a950-matnr )
*                                 ( sign = 'I' option = 'CP' low = lv_matnr ) ).
          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a950-matnr ) ).

          LOOP AT gt_extwg_zf06 REFERENCE INTO DATA(gr_extwg_zf06)
            WHERE fytkalite EQ lv_kalite.
            DATA(lv_matnr1) = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr1 ) TO ltrng_matnr.
          ENDLOOP.
          IF sy-subrc EQ 4.
            EXIT.
          ENDIF.
          "---------<<
          SELECT a950~knuma_ag a950~vkorg a950~vtweg a950~zzprsdt a950~kunnr
                 a950~matnr a950~kfrst MAX( a950~datbi ) AS datbi MAX( a950~datab ) AS datab
                 konp~loevm_ko
            FROM a950
            INNER JOIN konp ON a950~knumh EQ konp~knumh
            INTO CORRESPONDING FIELDS OF TABLE lt_a950
            WHERE a950~kappl    EQ 'V'
              AND a950~kschl    EQ 'ZF06'
              AND a950~knuma_ag EQ ls_a950-knuma_ag
              AND a950~vkorg    EQ ls_a950-vkorg
              AND a950~vtweg    EQ ls_a950-vtweg
*                AND a950~zzprsdt  EQ ls_a950-zzprsdt
              AND a950~kunnr    EQ ls_a950-kunnr
              AND a950~matnr    IN ltrng_matnr
              AND a950~kfrst    EQ ls_a950-kfrst
              GROUP BY a950~knuma_ag a950~vkorg a950~vtweg a950~zzprsdt a950~kunnr a950~matnr a950~kfrst konp~loevm_ko.

          LOOP AT lt_vake ASSIGNING FIELD-SYMBOL(<ls_vake2>).
            CHECK: <ls_vake2>-vakey+34(18) NE ls_a950-matnr .
            LOOP AT lt_a950 REFERENCE INTO DATA(lr_a950)
              WHERE knuma_ag EQ <ls_vake2>-vakey(10)
                AND vkorg    EQ <ls_vake2>-vakey+10(4)
                AND vtweg    EQ <ls_vake2>-vakey+14(2)
                AND zzprsdt  EQ <ls_vake2>-vakey+16(8)
                AND kunnr    EQ <ls_vake2>-vakey+24(10)
                AND matnr    EQ <ls_vake2>-vakey+34(18)
                AND kfrst    EQ <ls_vake2>-vakey+52(1).
              DATA(lv_tabix) = sy-tabix.
              DATA(lv_key) = |{ lr_a950->knuma_ag }{ lr_a950->vkorg }{ lr_a950->vtweg }{ lr_a950->zzprsdt }{ lr_a950->kunnr }{ lr_a950->matnr }{ lr_a950->kfrst }|.
              ASSIGN lt_vake[ vakey = lv_key ] TO FIELD-SYMBOL(<ls_vake1>).
              IF sy-subrc EQ 0.
                IF <ls_vake1>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    lr_a950->datab = <ls_vake1>-datab.
                    lr_a950->datbi = <ls_vake1>-datbi.
                  ELSE.
                    DELETE lt_a950 INDEX lv_tabix.
                  ENDIF.
                ELSE.
                  lr_a950->datab = <ls_vake1>-datab.
                  lr_a950->datbi = <ls_vake1>-datbi.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF <ls_vake2>-knumh IS NOT INITIAL.
                ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                  APPEND VALUE #( knuma_ag = <ls_vake2>-vakey(10)
                                  vkorg    = <ls_vake2>-vakey+10(4)
                                  vtweg    = <ls_vake2>-vakey+14(2)
                                  zzprsdt  = <ls_vake2>-vakey+16(8)
                                  kunnr    = <ls_vake2>-vakey+24(10)
                                  matnr    = <ls_vake2>-vakey+34(18)
                                  kfrst    = <ls_vake2>-vakey+52(1)
                                  datab    = <ls_vake2>-datab
                                  datbi    = <ls_vake2>-datbi ) TO lt_a950.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          DELETE lt_a950 WHERE matnr NOT IN ltrng_matnr.
          IF lt_a950 IS NOT INITIAL.
            LOOP AT lt_a950 REFERENCE INTO lr_a950
              WHERE knuma_ag EQ ls_a950-knuma_ag
                AND vkorg    EQ ls_a950-vkorg
                AND vtweg    EQ ls_a950-vtweg
*                  AND zzprsdt  EQ ls_a950-zzprsdt
                AND kunnr    EQ ls_a950-kunnr
                AND kfrst    EQ ls_a950-kfrst
                AND datab    GT ls_a950-datab
                AND datab    GT ls_a950-datbi.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT lt_a950 REFERENCE INTO lr_a950
                WHERE knuma_ag EQ ls_a950-knuma_ag
                  AND vkorg    EQ ls_a950-vkorg
                  AND vtweg    EQ ls_a950-vtweg
*                    AND zzprsdt  EQ ls_a950-zzprsdt
                  AND kunnr    EQ ls_a950-kunnr
                  AND kfrst    EQ ls_a950-kfrst
                  AND datbi    LT ls_a950-datab
                  AND datbi    LT ls_a950-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                APPEND VALUE #( msgty = 'E'
                  msgid = 'ZSD'
                  msgno = '092'
                  msgv1 = ls_a950-knuma_ag
                  msgv2 = ls_a950-matnr
                  msgv3 = lt_a950[ 1 ]-matnr
                  msgv4 = 'ZF06' ) TO lt_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN '951'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                  kschl   EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          IF <ls_vake>-knumh IS NOT INITIAL.
            ASSIGN it_konp[ knumh = <ls_vake>-knumh
                            loevm_ko = space ] TO <is_konp>.
            CHECK: sy-subrc EQ 0.
          ENDIF.
          MOVE-CORRESPONDING <ls_vake> TO ls_a951.
          ls_a951-knuma_ag  = <ls_vake>-vakey(10).
          ls_a951-vkorg     = <ls_vake>-vakey+10(4).
          ls_a951-vtweg     = <ls_vake>-vakey+14(2).
*          ls_a951-zzprsdt   = <ls_vake>-vakey+16(8).
          ls_a951-matnr     = <ls_vake>-vakey+24(18).
          ls_a951-kfrst     = <ls_vake>-vakey+42(1).
          ls_a951-datab     = <ls_vake>-datab.
          ls_a951-datbi     = <ls_vake>-datbi.

          SPLIT ls_a951-matnr AT '.' INTO lv_matnr lv_kalite.
          "--------->> Anıl CENGİZ 08.02.2021 15:25:58
          "YUR-840
*          lv_matnr = |{ lv_matnr }*|.
*          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a951-matnr )
*                                 ( sign = 'I' option = 'CP' low = lv_matnr ) ).
          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a951-matnr ) ).

          LOOP AT gt_extwg_zf06 REFERENCE INTO gr_extwg_zf06
            WHERE fytkalite EQ lv_kalite.
            lv_matnr1 = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr1 ) TO ltrng_matnr.
          ENDLOOP.
          IF sy-subrc EQ 4.
            EXIT.
          ENDIF.
          "---------<<
          SELECT a951~knuma_ag a951~vkorg a951~vtweg a951~zzprsdt a951~matnr
                 a951~kfrst MAX( a951~datbi ) AS datbi MAX( a951~datab ) AS datab konp~loevm_ko
            FROM a951
            INNER JOIN konp ON a951~knumh EQ konp~knumh
            INTO CORRESPONDING FIELDS OF TABLE lt_a951
            WHERE a951~kappl    EQ 'V'
              AND a951~kschl    EQ 'ZF06'
              AND a951~knuma_ag EQ ls_a951-knuma_ag
              AND a951~vkorg    EQ ls_a951-vkorg
              AND a951~vtweg    EQ ls_a951-vtweg
*                AND a951~zzprsdt  EQ ls_a951-zzprsdt
              AND a951~matnr    IN ltrng_matnr
              AND a951~kfrst    EQ ls_a951-kfrst
              GROUP BY a951~knuma_ag a951~vkorg a951~vtweg a951~zzprsdt a951~matnr a951~kfrst konp~loevm_ko.

          LOOP AT lt_vake ASSIGNING <ls_vake2>.
            CHECK: <ls_vake2>-vakey+24(18) NE ls_a951-matnr .
            LOOP AT lt_a951 REFERENCE INTO DATA(lr_a951)
              WHERE knuma_ag EQ <ls_vake2>-vakey(10)
                AND vkorg    EQ <ls_vake2>-vakey+10(4)
                AND vtweg    EQ <ls_vake2>-vakey+14(2)
                AND zzprsdt  EQ <ls_vake2>-vakey+16(8)
                AND matnr    EQ <ls_vake2>-vakey+24(18)
                AND kfrst    EQ <ls_vake2>-vakey+42(1).
              lv_tabix = sy-tabix.
              lv_key = |{ lr_a951->knuma_ag }{ lr_a951->vkorg }{ lr_a951->vtweg }{ lr_a951->zzprsdt }{ lr_a951->matnr }{ lr_a951->kfrst }|.
*              lv_key = |{ lr_a951->knuma_ag }{ lr_a951->vkorg }{ lr_a951->vtweg }{ lr_a951->matnr }{ lr_a951->kfrst }|.
              ASSIGN lt_vake[ vakey = lv_key ] TO <ls_vake1>.
              IF sy-subrc EQ 0.
                IF <ls_vake1>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    lr_a951->datab = <ls_vake1>-datab.
                    lr_a951->datbi = <ls_vake1>-datbi.
                  ELSE.
                    DELETE lt_a951 INDEX lv_tabix.
                  ENDIF.
                ELSE.
                  lr_a951->datab = <ls_vake1>-datab.
                  lr_a951->datbi = <ls_vake1>-datbi.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF <ls_vake2>-knumh IS NOT INITIAL.
                ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                  APPEND VALUE #( knuma_ag = <ls_vake2>-vakey(10)
                                  vkorg    = <ls_vake2>-vakey+10(4)
                                  vtweg    = <ls_vake2>-vakey+14(2)
                                  zzprsdt  = <ls_vake2>-vakey+16(8)
                                  matnr    = <ls_vake2>-vakey+24(18)
                                  kfrst    = <ls_vake2>-vakey+42(1)
                                  datab    = <ls_vake2>-datab
                                  datbi    = <ls_vake2>-datbi ) TO lt_a951.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          DELETE lt_a951 WHERE matnr NOT IN ltrng_matnr.
          IF lt_a951 IS NOT INITIAL.
            LOOP AT lt_a951 REFERENCE INTO lr_a951
              WHERE knuma_ag EQ ls_a951-knuma_ag
                AND vkorg    EQ ls_a951-vkorg
                AND vtweg    EQ ls_a951-vtweg
*                  AND zzprsdt  EQ ls_a951-zzprsdt
                AND kfrst    EQ ls_a951-kfrst
                AND datab    GT ls_a951-datab
                AND datab    GT ls_a951-datbi.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT lt_a951 REFERENCE INTO lr_a951
                WHERE knuma_ag EQ ls_a951-knuma_ag
                  AND vkorg    EQ ls_a951-vkorg
                  AND vtweg    EQ ls_a951-vtweg
*                    AND zzprsdt  EQ ls_a951-zzprsdt
                  AND kfrst    EQ ls_a951-kfrst
                  AND datbi    LT ls_a951-datab
                  AND datbi    LT ls_a951-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                APPEND VALUE #( msgty = 'E'
                  msgid = 'ZSD'
                  msgno = '092'
                  msgv1 = ls_a951-knuma_ag
                  msgv2 = ls_a951-matnr
                  msgv3 = lt_a951[ 1 ]-matnr
                  msgv4 = 'ZF06' ) TO lt_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN '908'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                  kschl   EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          IF <ls_vake>-knumh IS NOT INITIAL.
            ASSIGN it_konp[ knumh = <ls_vake>-knumh
                            loevm_ko = space ] TO <is_konp>.
            CHECK: sy-subrc EQ 0.
          ENDIF.
          MOVE-CORRESPONDING <ls_vake> TO ls_a908.
          ls_a908-vkorg     = <ls_vake>-vakey(4).
          ls_a908-vtweg     = <ls_vake>-vakey+4(2).
          ls_a908-kunnr     = <ls_vake>-vakey+6(10).
          ls_a908-matnr     = <ls_vake>-vakey+16(18).
          ls_a908-datab     = <ls_vake>-datab.
          ls_a908-datbi     = <ls_vake>-datbi.

          SPLIT ls_a908-matnr AT '.' INTO lv_matnr lv_kalite.
          "--------->> Anıl CENGİZ 08.02.2021 15:25:58
          "YUR-840
*          lv_matnr = |{ lv_matnr }*|.
*          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a908-matnr )
*                                 ( sign = 'I' option = 'CP' low = lv_matnr ) ).

          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a908-matnr ) ).

          LOOP AT gt_extwg_zf06 REFERENCE INTO gr_extwg_zf06
            WHERE fytkalite EQ lv_kalite.
            lv_matnr1 = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr1 ) TO ltrng_matnr.
          ENDLOOP.
          IF sy-subrc EQ 4.
            EXIT.
          ENDIF.
          "---------<<
          SELECT a908~vkorg a908~vtweg a908~kunnr a908~matnr
                 MAX( a908~datbi ) AS datbi MAX( a908~datab ) AS datab
                 konp~loevm_ko
            FROM a908
            INNER JOIN konp ON a908~knumh EQ konp~knumh
            INTO CORRESPONDING FIELDS OF TABLE lt_a908
            WHERE a908~kappl    EQ 'V'
              AND a908~kschl    EQ 'ZF06'
              AND a908~vkorg    EQ ls_a908-vkorg
              AND a908~vtweg    EQ ls_a908-vtweg
              AND a908~kunnr    EQ ls_a908-kunnr
              AND a908~matnr    IN ltrng_matnr
              GROUP BY a908~vkorg a908~vtweg a908~kunnr a908~matnr konp~loevm_ko.

          LOOP AT lt_vake ASSIGNING <ls_vake2>.
            CHECK: <ls_vake2>-vakey+16(18) NE ls_a908-matnr .
            LOOP AT lt_a908 REFERENCE INTO DATA(lr_a908)
              WHERE vkorg    EQ <ls_vake2>-vakey(4)
                AND vtweg    EQ <ls_vake2>-vakey+4(2)
                AND kunnr    EQ <ls_vake2>-vakey+6(10)
                AND matnr    EQ <ls_vake2>-vakey+16(18).
              lv_tabix = sy-tabix.
              lv_key = |{ lr_a908->vkorg }{ lr_a908->vtweg }{ lr_a908->kunnr }{ lr_a908->matnr }|.
              ASSIGN lt_vake[ vakey = lv_key ] TO <ls_vake1>.
              IF sy-subrc EQ 0.
                IF <ls_vake1>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    lr_a908->datab = <ls_vake1>-datab.
                    lr_a908->datbi = <ls_vake1>-datbi.
                  ELSE.
                    DELETE lt_a908 INDEX lv_tabix.
                  ENDIF.
                ELSE.
                  lr_a908->datab = <ls_vake1>-datab.
                  lr_a908->datbi = <ls_vake1>-datbi.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF <ls_vake2>-knumh IS NOT INITIAL.
                ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                  APPEND VALUE #( vkorg    = <ls_vake2>-vakey(4)
                                  vtweg    = <ls_vake2>-vakey+4(2)
                                  kunnr    = <ls_vake2>-vakey+6(10)
                                  matnr    = <ls_vake2>-vakey+16(18)
                                  datab    = <ls_vake2>-datab
                                  datbi    = <ls_vake2>-datbi ) TO lt_a908.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          DELETE lt_a908 WHERE matnr NOT IN ltrng_matnr.
          IF lt_a908 IS NOT INITIAL.
            LOOP AT lt_a908 REFERENCE INTO lr_a908
              WHERE vkorg EQ ls_a908-vkorg
                AND vtweg EQ ls_a908-vtweg
                AND kunnr EQ ls_a908-kunnr
                AND datab GT ls_a908-datab
                AND datab GT ls_a908-datbi.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT lt_a908 REFERENCE INTO lr_a908
                WHERE vkorg EQ ls_a908-vkorg
                  AND vtweg EQ ls_a908-vtweg
                  AND kunnr EQ ls_a908-kunnr
                  AND datbi LT ls_a908-datab
                  AND datbi LT ls_a908-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                APPEND VALUE #( msgty = 'E'
                  msgid = 'ZSD'
                  msgno = '092'
                  msgv1 = ls_a908-kunnr
                  msgv2 = ls_a908-matnr
                  msgv3 = lt_a908[ 1 ]-matnr
                  msgv4 = 'ZF06' ) TO lt_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN '936'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                  kschl   EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          IF <ls_vake>-knumh IS NOT INITIAL.
            ASSIGN it_konp[ knumh = <ls_vake>-knumh
                            loevm_ko = space ] TO <is_konp>.
            CHECK: sy-subrc EQ 0.
          ENDIF.
          MOVE-CORRESPONDING <ls_vake> TO ls_a936.
          ls_a936-vkorg  = <ls_vake>-vakey(4).
          ls_a936-vtweg  = <ls_vake>-vakey+4(2).
          ls_a936-zzlgort = <ls_vake>-vakey+6(4).
          ls_a936-matnr  = <ls_vake>-vakey+10(18).
          ls_a936-datab  = <ls_vake>-datab.
          ls_a936-datbi  = <ls_vake>-datbi.

          SPLIT ls_a936-matnr AT '.' INTO lv_matnr lv_kalite.
          "--------->> Anıl CENGİZ 08.02.2021 15:25:58
          "YUR-840
*          lv_matnr = |{ lv_matnr }*|.
*          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a936-matnr )
*                                 ( sign = 'I' option = 'CP' low = lv_matnr ) ).

          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a936-matnr ) ).

          LOOP AT gt_extwg_zf06 REFERENCE INTO gr_extwg_zf06
            WHERE fytkalite EQ lv_kalite.
            lv_matnr1 = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr1 ) TO ltrng_matnr.
          ENDLOOP.
          IF sy-subrc EQ 4.
            EXIT.
          ENDIF.
          "---------<<
          SELECT a936~vkorg a936~vtweg a936~zzlgort a936~matnr
                 MAX( a936~datbi ) AS datbi MAX( a936~datab ) AS datab konp~loevm_ko
            FROM a936
            INNER JOIN konp ON a936~knumh EQ konp~knumh
            INTO CORRESPONDING FIELDS OF TABLE lt_a936
            WHERE a936~kappl    EQ 'V'
              AND a936~kschl    EQ 'ZF06'
              AND a936~vkorg    EQ ls_a936-vkorg
              AND a936~vtweg    EQ ls_a936-vtweg
              AND a936~zzlgort  EQ ls_a936-zzlgort
              AND a936~matnr    IN ltrng_matnr
              GROUP BY a936~vkorg a936~vtweg a936~zzlgort a936~matnr konp~loevm_ko.

          LOOP AT lt_vake ASSIGNING <ls_vake2>.
            CHECK: <ls_vake2>-vakey+10(18) NE ls_a936-matnr .
            LOOP AT lt_a936 REFERENCE INTO DATA(lr_a936)
              WHERE vkorg   EQ <ls_vake2>-vakey(4)
                AND vtweg   EQ <ls_vake2>-vakey+4(2)
                AND zzlgort EQ <ls_vake2>-vakey+6(4)
                AND matnr   EQ <ls_vake2>-vakey+10(18).
              lv_tabix = sy-tabix.
              lv_key = |{ lr_a936->vkorg }{ lr_a936->vtweg }{ lr_a936->zzlgort }{ lr_a936->matnr }|.
              ASSIGN lt_vake[ vakey = lv_key ] TO <ls_vake1>.
              IF sy-subrc EQ 0.
                IF <ls_vake1>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    lr_a936->datab = <ls_vake1>-datab.
                    lr_a936->datbi = <ls_vake1>-datbi.
                  ELSE.
                    DELETE lt_a936 INDEX lv_tabix.
                  ENDIF.
                ELSE.
                  lr_a936->datab = <ls_vake1>-datab.
                  lr_a936->datbi = <ls_vake1>-datbi.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF <ls_vake2>-knumh IS NOT INITIAL.
                ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                  APPEND VALUE #( vkorg    = <ls_vake2>-vakey(4)
                                  vtweg    = <ls_vake2>-vakey+4(2)
                                  zzlgort  = <ls_vake2>-vakey+6(4)
                                  matnr    = <ls_vake2>-vakey+10(18)
                                  datab    = <ls_vake2>-datab
                                  datbi    = <ls_vake2>-datbi ) TO lt_a936.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          DELETE lt_a936 WHERE matnr NOT IN ltrng_matnr.
          IF lt_a936 IS NOT INITIAL.
            LOOP AT lt_a936 REFERENCE INTO lr_a936
              WHERE vkorg   EQ ls_a936-vkorg
                AND vtweg   EQ ls_a936-vtweg
                AND zzlgort EQ ls_a936-zzlgort
                AND datab   GT ls_a936-datab
                AND datab   GT ls_a936-datbi.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT lt_a936 REFERENCE INTO lr_a936
                WHERE vkorg EQ ls_a936-vkorg
                  AND vtweg EQ ls_a936-vtweg
                  AND zzlgort EQ ls_a936-zzlgort
                  AND datbi LT ls_a936-datab
                  AND datbi LT ls_a936-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                APPEND VALUE #( msgty = 'E'
                  msgid = 'ZSD'
                  msgno = '092'
                  msgv1 = ls_a936-zzlgort
                  msgv2 = ls_a936-matnr
                  msgv3 = lt_a936[ 1 ]-matnr
                  msgv4 = 'ZF06' ) TO lt_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN '909'.
        lt_vake = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lrrng_kotabnr->low AND
                                                                  kschl   EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake ASSIGNING <ls_vake>.
          IF <ls_vake>-knumh IS NOT INITIAL.
            ASSIGN it_konp[ knumh = <ls_vake>-knumh
                            loevm_ko = space ] TO <is_konp>.
            CHECK: sy-subrc EQ 0.
          ENDIF.
          MOVE-CORRESPONDING <ls_vake> TO ls_a909.
          ls_a909-vkorg  = <ls_vake>-vakey(4).
          ls_a909-vtweg  = <ls_vake>-vakey+4(2).
          ls_a909-matnr  = <ls_vake>-vakey+6(18).
          ls_a909-datab  = <ls_vake>-datab.
          ls_a909-datbi  = <ls_vake>-datbi.

          SPLIT ls_a909-matnr AT '.' INTO lv_matnr lv_kalite.
          "--------->> Anıl CENGİZ 08.02.2021 15:25:58
          "YUR-840
*          lv_matnr = |{ lv_matnr }*|.
*          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a909-matnr )
*                                 ( sign = 'I' option = 'CP' low = lv_matnr ) ).

          ltrng_matnr = VALUE #( ( sign = 'E' option = 'EQ' low = ls_a909-matnr ) ).

          LOOP AT gt_extwg_zf06 REFERENCE INTO gr_extwg_zf06
            WHERE fytkalite EQ lv_kalite.
            lv_matnr1 = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
            APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_matnr1 ) TO ltrng_matnr.
          ENDLOOP.
          IF sy-subrc EQ 4.
            EXIT.
          ENDIF.
          "---------<<
          SELECT a909~vkorg a909~vtweg a909~matnr
                 MAX( a909~datbi ) AS datbi MAX( a909~datab ) AS datab konp~loevm_ko
            FROM a909
            INNER JOIN konp ON a909~knumh EQ konp~knumh
            INTO CORRESPONDING FIELDS OF TABLE lt_a909
            WHERE a909~kappl    EQ 'V'
              AND a909~kschl    EQ 'ZF06'
              AND a909~vkorg    EQ ls_a909-vkorg
              AND a909~vtweg    EQ ls_a909-vtweg
              AND a909~matnr    IN ltrng_matnr
              GROUP BY a909~vkorg a909~vtweg a909~matnr konp~loevm_ko.

          LOOP AT lt_vake ASSIGNING <ls_vake2>.
            CHECK: <ls_vake2>-vakey+6(18) NE ls_a909-matnr .
            LOOP AT lt_a909 REFERENCE INTO DATA(lr_a909)
              WHERE vkorg   EQ <ls_vake2>-vakey(4)
                AND vtweg   EQ <ls_vake2>-vakey+4(2)
                AND matnr   EQ <ls_vake2>-vakey+6(18).
              lv_tabix = sy-tabix.
              lv_key = |{ lr_a909->vkorg }{ lr_a909->vtweg }{ lr_a909->matnr }|.
              ASSIGN lt_vake[ vakey = lv_key ] TO <ls_vake1>.
              IF sy-subrc EQ 0.
                IF <ls_vake1>-knumh IS NOT INITIAL.
                  ASSIGN it_konp[ knumh = <ls_vake1>-knumh ] TO <is_konp>.
                  IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                    lr_a909->datab = <ls_vake1>-datab.
                    lr_a909->datbi = <ls_vake1>-datbi.
                  ELSE.
                    DELETE lt_a909 INDEX lv_tabix.
                  ENDIF.
                ELSE.
                  lr_a909->datab = <ls_vake1>-datab.
                  lr_a909->datbi = <ls_vake1>-datbi.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF <ls_vake2>-knumh IS NOT INITIAL.
                ASSIGN it_konp[ knumh = <ls_vake2>-knumh ] TO <is_konp>.
                IF sy-subrc EQ 0 AND <is_konp>-loevm_ko NE abap_true.
                  APPEND VALUE #( vkorg    = <ls_vake2>-vakey(4)
                                  vtweg    = <ls_vake2>-vakey+4(2)
                                  matnr    = <ls_vake2>-vakey+6(18)
                                  datab    = <ls_vake2>-datab
                                  datbi    = <ls_vake2>-datbi ) TO lt_a909.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          DELETE lt_a909 WHERE matnr NOT IN ltrng_matnr.
          IF lt_a909 IS NOT INITIAL.
            LOOP AT lt_a909 REFERENCE INTO lr_a909
              WHERE vkorg   EQ ls_a909-vkorg
                AND vtweg   EQ ls_a909-vtweg
                AND datab   GT ls_a909-datab
                AND datab   GT ls_a909-datbi.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT lt_a909 REFERENCE INTO lr_a909
                WHERE vkorg EQ ls_a909-vkorg
                  AND vtweg EQ ls_a909-vtweg
                  AND datbi LT ls_a909-datab
                  AND datbi LT ls_a909-datbi.
                EXIT.
              ENDLOOP.
              IF sy-subrc NE 0.
                APPEND VALUE #( msgty = 'E'
                  msgid = 'ZSD'
                  msgno = '092'
                  msgv1 = ls_a909-matnr
                  msgv2 = lt_a909[ 1 ]-matnr
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


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

  FIELD-SYMBOLS: <gt_xvake> TYPE cond_vakevb_t,
                 <gt_xkonp> TYPE cond_konpdb_t.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVAKE[]' ). ASSIGN lr_data->* TO <gt_xvake>.
  lr_data = co_con->get_vars( 'XKONP[]' ). ASSIGN lr_data->* TO <gt_xkonp>.

  execute( EXPORTING it_xvake = <gt_xvake>
                     it_konp = <gt_xkonp> ).

ENDMETHOD.
ENDCLASS.
