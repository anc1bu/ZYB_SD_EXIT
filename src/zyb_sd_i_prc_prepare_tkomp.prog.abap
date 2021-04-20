**&---------------------------------------------------------------------*
**&  Include           ZYB_SD_I_PRC_PREPARE_TKOMP
**&---------------------------------------------------------------------*
*DATA:
*  lv_extwg LIKE mara-extwg,
*  lv_herkl TYPE herkl.
*IF t180-trtyp NE 'A'.
*
*  "--------->> Anıl CENGİZ 12.11.2018 19:50:54
*  "YUR-227 Yurtiçi Satışlarında Kampanya İlave İskonto Talebi v.0 -
*  "Programlama
*  NEW zcl_sd_mv45afzz_preptkomp( ir_vbak = REF #( vbak )
*                                 ir_vbap = REF #( vbap )
*                                 ir_vbkd = REF #( vbkd )
*                                 ir_tkomp = REF #( tkomp )
*                                 ir_tkomk = REF #( tkomk )
*                                 is_t180 = t180 )->veri_atama( ).
*  "---------<<
*  CHECK: vbap-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm
*         AND vbak-zz_knuma_ag IS NOT INITIAL
*         "--------->> Anıl CENGİZ 10.08.2020 15:33:46
*         "YUR-706
*         AND zcl_sd_mv45afzz_frm_mvflvp_002=>check_boart( vbak-zz_knuma_ag ) EQ abap_false. "Bedelsiz değil ise aşağıdaki kontrole girer.
*         "---------<<
*
*  DATA: lt_a927pltyp TYPE TABLE OF a927,
*        lt_a910      TYPE TABLE OF a910,
*        ls_a910      TYPE a910,
*        "--------->> Anıl CENGİZ 12.09.2018 11:37:52
*        "YUR-156
*        lt_a931pltyp TYPE TABLE OF a931,
*        ls_a931pltyp TYPE a931,
*        lt_a932pltyp TYPE TABLE OF a932,
*        ls_a932pltyp TYPE a932,
*        lt_a933pltyp TYPE TABLE OF a933,
*        ls_a933pltyp TYPE a933,
*        l_tvak       TYPE tvak,
*        l_kschl      TYPE t6b2f-kschl,
*        l_kobog      TYPE t6b1-kobog,
*        l_boart      TYPE kona-boart,
*        lt_a935      TYPE STANDARD TABLE OF a935,
*        ls_a935      TYPE a935,
*        lt_a934      TYPE STANDARD TABLE OF a934,
*        ls_a934      TYPE a934.
*
*  REFRESH: lt_a927pltyp, lt_a910, lt_a931pltyp, lt_a932pltyp, lt_a933pltyp
*  , lt_a935, lt_a934.
*  CLEAR: ls_a910, ls_a931pltyp, ls_a932pltyp, ls_a933pltyp, l_tvak,
*  l_kschl, l_kobog, l_boart, ls_a935, ls_a934.
*  "---------<<
*
*  SELECT SINGLE * FROM tvak INTO l_tvak WHERE auart = vbak-auart.
*
*  CHECK l_tvak-kalvg = '3' OR
*        l_tvak-kalvg = '4' OR
*        l_tvak-kalvg = '5' OR
*        l_tvak-kalvg = '6'.
*
*  SELECT SINGLE boart FROM kona INTO l_boart WHERE knuma =
*  vbak-zz_knuma_ag.
*  IF sy-subrc <> 0.
*    MESSAGE e023(zsd_va) WITH vbak-zz_knuma_ag.
*  ENDIF.
*  SELECT SINGLE kobog FROM t6b1 INTO l_kobog WHERE boart = l_boart.
*  IF sy-subrc <> 0.
*    MESSAGE e021(zsd_va).
*  ENDIF.
*
*  CASE l_kobog.
*    WHEN 'ZY01'.
*      "--------->> Anıl CENGİZ 12.09.2018 11:35:09
*      "YUR-156
*      "Atıl stok satışı kapsamında yeni eklenen indirim erişim sırası için de
*      "fiyat listesi kontrolü yapılmalıdır.
*      "Depo yeri bakımına göre fiyata bakılır. En önce buna bakılır çünkü bu
*      "koşul hepsini ezer.
*      SELECT zzprsdt pltyp FROM a932
*      INNER JOIN konp ON konp~knumh = a932~knumh
*                      AND konp~kschl = a932~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a932pltyp
*      WHERE a932~kappl EQ 'V'
*      AND a932~kschl EQ 'ZI06'
*      AND a932~knuma_ag EQ vbak-zz_knuma_ag
*      AND a932~vkorg EQ vbak-vkorg
*      AND a932~vtweg EQ vbak-vtweg
*      AND a932~datbi GE vbkd-prsdt
*      AND a932~datab LE vbkd-prsdt
*      AND a932~zzlgort EQ vbap-lgort
*      AND konp~loevm_ko EQ abap_false
*      AND a932~zzprsdt NE '00000000'.
*
*      IF sy-subrc IS INITIAL.
*        "Depo yeri bazında var ise liste fiyatına bakılır.
*        SELECT pltyp FROM a910
*       INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*       INTO CORRESPONDING FIELDS OF TABLE lt_a910
*       FOR ALL ENTRIES IN lt_a932pltyp
*       WHERE a910~kappl EQ 'V'
*       AND a910~kschl EQ 'ZF04'
*       AND a910~vkorg EQ vbak-vkorg
*       AND a910~vtweg EQ vbak-vtweg
*       AND a910~matnr EQ vbap-matnr
*       AND a910~datbi GE vbkd-prsdt
*       AND a910~datab LE vbkd-prsdt
*       AND konp~loevm_ko EQ abap_false
*       AND a910~pltyp EQ lt_a932pltyp-pltyp.
*
*        DESCRIBE TABLE lt_a910.
*        IF sy-tfill EQ 0.
*          "Fiyat bulunamadı
*          MESSAGE e025(zsd_va) WITH vbap-matnr.
*        ELSEIF sy-tfill EQ 1.
*          READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*          tkomp-pltyp_p = ls_a910-pltyp.
*          READ TABLE lt_a932pltyp INTO ls_a932pltyp
*            WITH KEY pltyp = ls_a910-pltyp.
*          tkomp-zzpr932 = ls_a932pltyp-zzprsdt.
*        ELSEIF sy-tfill GT 1.
*          "Geçerli birden fazla fiyat bulunmaktadır.
*          MESSAGE e024(zsd_va) WITH vbap-matnr.
*        ENDIF.
*
*      ELSE. "Depo yeri/fiyatlandırma bazında indirim yok ise
*        "sadece depoyeri tablosu olan A931 ye bakılır.
*
*        SELECT pltyp FROM a931
*    INNER JOIN konp ON konp~knumh = a931~knumh
*                    AND konp~kschl = a931~kschl
*    INTO CORRESPONDING FIELDS OF TABLE lt_a931pltyp
*    WHERE a931~kappl EQ 'V'
*    AND a931~kschl EQ 'ZI06'
*    AND a931~knuma_ag EQ vbak-zz_knuma_ag
*    AND a931~vkorg EQ vbak-vkorg
*    AND a931~vtweg EQ vbak-vtweg
*    AND a931~datbi GE vbkd-prsdt
*    AND a931~datab LE vbkd-prsdt
*    AND a931~zzlgort EQ vbap-lgort
*    AND konp~loevm_ko EQ abap_false.
*
*        IF sy-subrc EQ 0.
*
*          SELECT pltyp FROM a910
*            INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*            INTO CORRESPONDING FIELDS OF TABLE lt_a910
*            FOR ALL ENTRIES IN lt_a931pltyp
*            WHERE a910~kappl EQ 'V'
*            AND a910~kschl EQ 'ZF04'
*            AND a910~vkorg EQ vbak-vkorg
*            AND a910~vtweg EQ vbak-vtweg
*            AND a910~matnr EQ vbap-matnr
*            AND a910~datbi GE vbkd-prsdt
*            AND a910~datab LE vbkd-prsdt
*            AND konp~loevm_ko EQ abap_false
*            AND a910~pltyp EQ lt_a931pltyp-pltyp.
*
*          DESCRIBE TABLE lt_a910.
*          IF sy-tfill EQ 0.
*            "Fiyat bulunamadı
*            MESSAGE e025(zsd_va) WITH vbap-matnr.
*          ELSEIF sy-tfill EQ 1.
*            READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*            tkomp-pltyp_p = ls_a910-pltyp.
*          ELSEIF sy-tfill GT 1.
*            "Geçerli birden fazla fiyat bulunmaktadır.
*            MESSAGE e024(zsd_va) WITH vbap-matnr.
*          ENDIF.
*
*        ELSE.
*          "Depo yeri bazında yok ise Fiyatlandırma/Fİyat listesi
*          "bazında olan A933 tablosuna bakılır.
*          SELECT zzprsdt pltyp FROM a933 INNER JOIN konp
*            ON konp~knumh = a933~knumh
*            AND konp~kschl = a933~kschl
*            INTO CORRESPONDING FIELDS OF TABLE lt_a933pltyp
*            WHERE a933~kappl EQ 'V'
*            AND a933~kschl EQ 'ZI01'
*            AND a933~knuma_ag EQ vbak-zz_knuma_ag
*            AND a933~vkorg EQ vbak-vkorg
*            AND a933~vtweg EQ vbak-vtweg
*            AND a933~datbi GE vbkd-prsdt
*            AND a933~datab LE vbkd-prsdt
*            AND konp~loevm_ko EQ abap_false
*            AND a933~zzprsdt NE '00000000'.
*
*          IF sy-subrc IS INITIAL.
*
*            SELECT pltyp FROM a910
*           INNER JOIN konp ON konp~knumh = a910~knumh
*                           AND konp~kschl = a910~kschl
*           INTO CORRESPONDING FIELDS OF TABLE lt_a910
*           FOR ALL ENTRIES IN lt_a933pltyp
*           WHERE a910~kappl EQ 'V'
*           AND a910~kschl EQ 'ZF04'
*           AND a910~vkorg EQ vbak-vkorg
*           AND a910~vtweg EQ vbak-vtweg
*           AND a910~matnr EQ vbap-matnr
*           AND a910~datbi GE vbkd-prsdt
*           AND a910~datab LE vbkd-prsdt
*           AND konp~loevm_ko EQ abap_false
*           AND a910~pltyp EQ lt_a933pltyp-pltyp.
*
*            DESCRIBE TABLE lt_a910.
*            IF sy-tfill EQ 0.
*              "Fiyat bulunamadı
*              MESSAGE e025(zsd_va) WITH vbap-matnr.
*            ELSEIF sy-tfill EQ 1.
*              READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*              tkomp-pltyp_p = ls_a910-pltyp.
*              READ TABLE lt_a933pltyp INTO ls_a933pltyp
*                WITH KEY pltyp = ls_a910-pltyp.
*              tkomp-zzpr933 = ls_a933pltyp-zzprsdt.
*            ELSEIF sy-tfill GT 1.
*              "Geçerli birden fazla fiyat bulunmaktadır.
*              MESSAGE e024(zsd_va) WITH vbap-matnr.
*            ENDIF.
*          ELSE.
*            "Fiyatlandırma/Fİyat listesi bazında olan A933 tablosunda
*            "yok ise o zaman sadece fiayt listesi olan A927 tablosuna bakılır.
*
*            SELECT pltyp FROM a927 INNER JOIN konp
*      ON konp~knumh = a927~knumh
*      AND konp~kschl = a927~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a927pltyp
*      WHERE a927~kappl EQ 'V'
*      AND a927~kschl EQ 'ZI01'
*      AND a927~knuma_ag EQ vbak-zz_knuma_ag
*      AND a927~vkorg EQ vbak-vkorg
*      AND a927~vtweg EQ vbak-vtweg
*      AND a927~datbi GE vbkd-prsdt
*      AND a927~datab LE vbkd-prsdt
*      AND konp~loevm_ko EQ abap_false.
*            IF sy-subrc EQ 0.
*              SELECT pltyp FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                        AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a927pltyp
*        WHERE a910~kappl EQ 'V'
*        AND a910~kschl EQ 'ZF04'
*        AND a910~vkorg EQ vbak-vkorg
*        AND a910~vtweg EQ vbak-vtweg
*        AND a910~matnr EQ vbap-matnr
*        AND a910~datbi GE vbkd-prsdt
*        AND a910~datab LE vbkd-prsdt
*        AND konp~loevm_ko EQ abap_false
*        AND a910~pltyp EQ lt_a927pltyp-pltyp.
*
*              DESCRIBE TABLE lt_a910.
*              IF sy-tfill EQ 0.
*                "Fiyat bulunamadı
*                MESSAGE e025(zsd_va) WITH vbap-matnr.
*              ELSEIF sy-tfill EQ 1.
*                READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*                tkomp-pltyp_p = ls_a910-pltyp.
*              ELSEIF sy-tfill GT 1.
*                "Geçerli birden fazla fiyat bulunmaktadır.
*                MESSAGE e024(zsd_va) WITH vbap-matnr.
*              ENDIF.
*
*            ELSE.
*              "Fiyat bulunamadı
*              MESSAGE e025(zsd_va) WITH vbap-matnr.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      "---------<<
*      "--------->> Anıl CENGİZ 12.11.2018 16:55:15
*      "YUR-227 Yurtiçi Satışlarında Kampanya İlave İskonto Talebi v.0 -
*      "Programlama
*      "ZI04 ile ilgili atamalar.
*
*      SELECT zzprsdt FROM a935
*        INNER JOIN konp ON konp~knumh = a935~knumh
*                        AND konp~kschl = a935~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a935
*        WHERE a935~kappl EQ 'V'
*         AND a935~kschl EQ 'ZI04'
*        AND a935~knuma_ag EQ tkomp-knuma_ag
*        AND a935~vkorg EQ tkomk-vkorg
*        AND a935~vtweg EQ tkomk-vtweg
**      and a935~ZZPRSDT
*        AND a935~pltyp EQ tkomp-pltyp_p
*        AND a935~prodh3 EQ tkomp-prodh3
*        AND a935~vrkme EQ tkomp-vrkme
*        AND a935~datbi GE tkomk-prsdt
*        AND a935~datab LE tkomk-prsdt
*        AND konp~loevm_ko EQ abap_false.
*      IF sy-subrc EQ 0.
*
*        DESCRIBE TABLE lt_a935.
*
*        IF sy-tfill EQ 1.
*          READ TABLE lt_a935 INTO ls_a935 INDEX 1.
*          tkomp-zzpr935 = ls_a935-zzprsdt.
*        ELSEIF sy-tfill > 1.
*          MESSAGE e134(zyb_sd).
*        ENDIF.
*
*      ENDIF.
*
*      SELECT zzprsdt FROM a934
*        INNER JOIN konp ON konp~knumh = a934~knumh
*                        AND konp~kschl = a934~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a934
*        WHERE a934~kappl EQ 'V'
*        AND a934~kschl EQ 'ZI04'
*        AND a934~knuma_ag EQ tkomp-knuma_ag
*        AND a934~vkorg EQ tkomk-vkorg
*        AND a934~vtweg EQ tkomk-vtweg
**    AND a934~ZZPRSDT eq KOMP-ZZPRSD2
*        AND a934~pltyp EQ tkomp-pltyp_p
*        AND a934~kunag EQ tkomk-kunnr
*        AND a934~datbi GE tkomk-prsdt
*        AND a934~datab LE tkomk-prsdt
*        AND konp~loevm_ko EQ abap_false.
*
*      IF sy-subrc EQ 0.
*
*        DESCRIBE TABLE lt_a934.
*
*        IF sy-tfill EQ 1.
*          READ TABLE lt_a934 INTO ls_a934 INDEX 1.
*          tkomp-zzpr934 = ls_a934-zzprsdt.
*        ELSEIF sy-tfill > 1.
*          MESSAGE e134(zyb_sd).
*        ENDIF.
*
*      ENDIF.
*      "---------<<
*    WHEN 'ZY02'.
*
**      MESSAGE 'BT ye başvurunuz.' TYPE 'E'.
*
*      "--------->> Anıl CENGİZ 12.09.2018 11:35:09
*      "YUR-156
*      "Atıl stok satışı kapsamında yeni eklenen indirim erişim sırası için de
*      "fiyat listesi kontrolü yapılmalıdır.
*      "Depo yeri bakımına göre fiyata bakılır. En önce buna bakılır çünkü bu
*      "koşul hepsini ezer.
*      SELECT zzprsdt pltyp FROM a932
*      INNER JOIN konp ON konp~knumh = a932~knumh
*                      AND konp~kschl = a932~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a932pltyp
*      WHERE a932~kappl EQ 'V'
*      AND a932~kschl EQ 'ZI07'
*      AND a932~knuma_ag EQ vbak-zz_knuma_ag
*      AND a932~vkorg EQ vbak-vkorg
*      AND a932~vtweg EQ vbak-vtweg
*      AND a932~datbi GE vbkd-prsdt
*      AND a932~datab LE vbkd-prsdt
*      AND a932~zzlgort EQ vbap-lgort
*      AND konp~loevm_ko EQ abap_false
*      AND a932~zzprsdt NE '00000000'.
*
*      IF sy-subrc IS INITIAL.
*        "Depo yeri bazında var ise liste fiyatına bakılır.
*        SELECT pltyp FROM a910
*       INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*       INTO CORRESPONDING FIELDS OF TABLE lt_a910
*       FOR ALL ENTRIES IN lt_a932pltyp
*       WHERE a910~kappl EQ 'V'
*       AND a910~kschl EQ 'ZF04'
*       AND a910~vkorg EQ vbak-vkorg
*       AND a910~vtweg EQ vbak-vtweg
*       AND a910~matnr EQ vbap-matnr
*       AND a910~datbi GE vbkd-prsdt
*       AND a910~datab LE vbkd-prsdt
*       AND konp~loevm_ko EQ abap_false
*       AND a910~pltyp EQ lt_a932pltyp-pltyp.
*
*        DESCRIBE TABLE lt_a910.
*        IF sy-tfill EQ 0.
*          "Fiyat bulunamadı
*          MESSAGE e025(zsd_va) WITH vbap-matnr.
*        ELSEIF sy-tfill EQ 1.
*          READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*          tkomp-pltyp_p = ls_a910-pltyp.
*          READ TABLE lt_a932pltyp INTO ls_a932pltyp
*            WITH KEY pltyp = ls_a910-pltyp.
*          tkomp-zzpr932 = ls_a932pltyp-zzprsdt.
*        ELSEIF sy-tfill GT 1.
*          "Geçerli birden fazla fiyat bulunmaktadır.
*          MESSAGE e024(zsd_va) WITH vbap-matnr.
*        ENDIF.
*
*      ELSE. "Depo yeri/fiyatlandırma bazında indirim yok ise
*        "sadece depoyeri tablosu olan A931 ye bakılır.
*
*        SELECT pltyp FROM a931
*    INNER JOIN konp ON konp~knumh = a931~knumh
*                    AND konp~kschl = a931~kschl
*    INTO CORRESPONDING FIELDS OF TABLE lt_a931pltyp
*    WHERE a931~kappl EQ 'V'
*    AND a931~kschl EQ 'ZI07'
*    AND a931~knuma_ag EQ vbak-zz_knuma_ag
*    AND a931~vkorg EQ vbak-vkorg
*    AND a931~vtweg EQ vbak-vtweg
*    AND a931~datbi GE vbkd-prsdt
*    AND a931~datab LE vbkd-prsdt
*    AND a931~zzlgort EQ vbap-lgort
*    AND konp~loevm_ko EQ abap_false.
*
*        IF sy-subrc EQ 0.
*
*          SELECT pltyp FROM a910
*            INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*            INTO CORRESPONDING FIELDS OF TABLE lt_a910
*            FOR ALL ENTRIES IN lt_a931pltyp
*            WHERE a910~kappl EQ 'V'
*            AND a910~kschl EQ 'ZF04'
*            AND a910~vkorg EQ vbak-vkorg
*            AND a910~vtweg EQ vbak-vtweg
*            AND a910~matnr EQ vbap-matnr
*            AND a910~datbi GE vbkd-prsdt
*            AND a910~datab LE vbkd-prsdt
*            AND konp~loevm_ko EQ abap_false
*            AND a910~pltyp EQ lt_a931pltyp-pltyp.
*
*          DESCRIBE TABLE lt_a910.
*          IF sy-tfill EQ 0.
*            "Fiyat bulunamadı
*            MESSAGE e025(zsd_va) WITH vbap-matnr.
*          ELSEIF sy-tfill EQ 1.
*            READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*            tkomp-pltyp_p = ls_a910-pltyp.
*          ELSEIF sy-tfill GT 1.
*            "Geçerli birden fazla fiyat bulunmaktadır.
*            MESSAGE e024(zsd_va) WITH vbap-matnr.
*          ENDIF.
*
*        ELSE.
*          "Depo yeri bazında yok ise Fiyatlandırma/Fİyat listesi
*          "bazında olan A933 tablosuna bakılır.
*          SELECT zzprsdt pltyp FROM a933 INNER JOIN konp
*            ON konp~knumh = a933~knumh
*            AND konp~kschl = a933~kschl
*            INTO CORRESPONDING FIELDS OF TABLE lt_a933pltyp
*            WHERE a933~kappl EQ 'V'
*            AND a933~kschl EQ 'ZI02'
*            AND a933~knuma_ag EQ vbak-zz_knuma_ag
*            AND a933~vkorg EQ vbak-vkorg
*            AND a933~vtweg EQ vbak-vtweg
*            AND a933~datbi GE vbkd-prsdt
*            AND a933~datab LE vbkd-prsdt
*            AND konp~loevm_ko EQ abap_false
*            AND a933~zzprsdt NE '00000000'.
*
*          IF sy-subrc IS INITIAL.
*
*            SELECT pltyp FROM a910
*           INNER JOIN konp ON konp~knumh = a910~knumh
*                           AND konp~kschl = a910~kschl
*           INTO CORRESPONDING FIELDS OF TABLE lt_a910
*           FOR ALL ENTRIES IN lt_a933pltyp
*           WHERE a910~kappl EQ 'V'
*           AND a910~kschl EQ 'ZF04'
*           AND a910~vkorg EQ vbak-vkorg
*           AND a910~vtweg EQ vbak-vtweg
*           AND a910~matnr EQ vbap-matnr
*           AND a910~datbi GE vbkd-prsdt
*           AND a910~datab LE vbkd-prsdt
*           AND konp~loevm_ko EQ abap_false
*           AND a910~pltyp EQ lt_a933pltyp-pltyp.
*
*            DESCRIBE TABLE lt_a910.
*            IF sy-tfill EQ 0.
*              "Fiyat bulunamadı
*              MESSAGE e025(zsd_va) WITH vbap-matnr.
*            ELSEIF sy-tfill EQ 1.
*              READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*              tkomp-pltyp_p = ls_a910-pltyp.
*              READ TABLE lt_a933pltyp INTO ls_a933pltyp
*                WITH KEY pltyp = ls_a910-pltyp.
*              tkomp-zzpr933 = ls_a933pltyp-zzprsdt.
*            ELSEIF sy-tfill GT 1.
*              "Geçerli birden fazla fiyat bulunmaktadır.
*              MESSAGE e024(zsd_va) WITH vbap-matnr.
*            ENDIF.
*          ELSE.
*            "Fiyatlandırma/Fİyat listesi bazında olan A933 tablosunda
*            "yok ise o zaman sadece fiayt listesi olan A927 tablosuna bakılır.
*
*            SELECT pltyp FROM a927 INNER JOIN konp
*      ON konp~knumh = a927~knumh
*      AND konp~kschl = a927~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a927pltyp
*      WHERE a927~kappl EQ 'V'
*      AND a927~kschl EQ 'ZI02'
*      AND a927~knuma_ag EQ vbak-zz_knuma_ag
*      AND a927~vkorg EQ vbak-vkorg
*      AND a927~vtweg EQ vbak-vtweg
*      AND a927~datbi GE vbkd-prsdt
*      AND a927~datab LE vbkd-prsdt
*      AND konp~loevm_ko EQ abap_false.
*            IF sy-subrc EQ 0.
*              SELECT pltyp FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                        AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a927pltyp
*        WHERE a910~kappl EQ 'V'
*        AND a910~kschl EQ 'ZF04'
*        AND a910~vkorg EQ vbak-vkorg
*        AND a910~vtweg EQ vbak-vtweg
*        AND a910~matnr EQ vbap-matnr
*        AND a910~datbi GE vbkd-prsdt
*        AND a910~datab LE vbkd-prsdt
*        AND konp~loevm_ko EQ abap_false
*        AND a910~pltyp EQ lt_a927pltyp-pltyp.
*
*              DESCRIBE TABLE lt_a910.
*              IF sy-tfill EQ 0.
*                "Fiyat bulunamadı
*                MESSAGE e025(zsd_va) WITH vbap-matnr.
*              ELSEIF sy-tfill EQ 1.
*                READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*                tkomp-pltyp_p = ls_a910-pltyp.
*              ELSEIF sy-tfill GT 1.
*                "Geçerli birden fazla fiyat bulunmaktadır.
*                MESSAGE e024(zsd_va) WITH vbap-matnr.
*              ENDIF.
*
*            ELSE.
*              "Fiyat bulunamadı
*              MESSAGE e025(zsd_va) WITH vbap-matnr.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      "---------<<
*
*      "--------->> Anıl CENGİZ 12.11.2018 16:55:15
*      "YUR-227 Yurtiçi Satışlarında Kampanya İlave İskonto Talebi v.0 -
*      "Programlama
*
*      REFRESH: lt_a935, lt_a934.
*      CLEAR: ls_a935, ls_a934.
*
*      "ZI04 ile ilgili atamalar.
*
*      SELECT zzprsdt FROM a935
*        INNER JOIN konp ON konp~knumh = a935~knumh
*                        AND konp~kschl = a935~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a935
*        WHERE a935~kappl EQ 'V'
*         AND a935~kschl EQ 'ZI05'
*        AND a935~knuma_ag EQ tkomp-knuma_ag
*        AND a935~vkorg EQ tkomk-vkorg
*        AND a935~vtweg EQ tkomk-vtweg
**      and a935~ZZPRSDT
*        AND a935~pltyp EQ tkomp-pltyp_p
*        AND a935~prodh3 EQ tkomp-prodh3
*        AND a935~vrkme EQ tkomp-vrkme
*        AND a935~datbi GE tkomk-prsdt
*        AND a935~datab LE tkomk-prsdt
*        AND konp~loevm_ko EQ abap_false.
*      IF sy-subrc EQ 0.
*
*        DESCRIBE TABLE lt_a935.
*
*        IF sy-tfill EQ 1.
*          READ TABLE lt_a935 INTO ls_a935 INDEX 1.
*          tkomp-zzpr935 = ls_a935-zzprsdt.
*        ELSEIF sy-tfill > 1.
*          MESSAGE e134(zyb_sd).
*        ENDIF.
*
*      ENDIF.
*
*      SELECT zzprsdt FROM a934
*        INNER JOIN konp ON konp~knumh = a934~knumh
*                        AND konp~kschl = a934~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a934
*        WHERE a934~kappl EQ 'V'
*        AND a934~kschl EQ 'ZI05'
*        AND a934~knuma_ag EQ tkomp-knuma_ag
*        AND a934~vkorg EQ tkomk-vkorg
*        AND a934~vtweg EQ tkomk-vtweg
**    AND a934~ZZPRSDT eq KOMP-ZZPRSD2
*        AND a934~pltyp EQ tkomp-pltyp_p
*        AND a934~kunag EQ tkomk-kunnr
*        AND a934~datbi GE tkomk-prsdt
*        AND a934~datab LE tkomk-prsdt
*        AND konp~loevm_ko EQ abap_false.
*
*      IF sy-subrc EQ 0.
*
*        DESCRIBE TABLE lt_a934.
*
*        IF sy-tfill EQ 1.
*          READ TABLE lt_a934 INTO ls_a934 INDEX 1.
*          tkomp-zzpr934 = ls_a934-zzprsdt.
*        ELSEIF sy-tfill > 1.
*          MESSAGE e134(zyb_sd).
*        ENDIF.
*
*      ENDIF.
*      "---------<<
*    WHEN OTHERS.
*  ENDCASE.
*
*
*ENDIF.
