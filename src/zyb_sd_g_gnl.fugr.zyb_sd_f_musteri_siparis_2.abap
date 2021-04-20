FUNCTION zyb_sd_f_musteri_siparis_2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_KUN1D) TYPE  ZKUNNR_RANGE_TT OPTIONAL
*"     VALUE(IS_VTWEG) TYPE  ZVTWEG_RANGE_TT OPTIONAL
*"     VALUE(IS_KUNNR) TYPE  ZKUNNR_RANGE_TT OPTIONAL
*"     VALUE(IP_KUNNAM) TYPE  NAME1_GP OPTIONAL
*"     VALUE(IS_KUNWE) TYPE  ZKUNWE_RANGE_TT OPTIONAL
*"     VALUE(IS_VBELN) TYPE  ZVBELN_RANGE_TT OPTIONAL
*"     VALUE(IS_POSNR) TYPE  ZPOSNR_RANGE_TT OPTIONAL
*"     VALUE(IS_AUART) TYPE  ZAUART_RANGE_TT OPTIONAL
*"     VALUE(IS_VKBUR) TYPE  ZVKBUR_RANGE_TT OPTIONAL
*"     VALUE(IS_LFSTA) TYPE  ZLFSTA_RANGE_TT OPTIONAL
*"     VALUE(IS_LGORT) TYPE  ZLGORT_RANGE_TT OPTIONAL
*"     VALUE(IS_AUDAT) TYPE  ZAUDAT_RANGE_TT OPTIONAL
*"     VALUE(IS_LDDAT) TYPE  ZLDDAT_RANGE_TT OPTIONAL
*"     VALUE(IS_MATNR) TYPE  ZMATNR_RANGE_TT OPTIONAL
*"     VALUE(IP_MAKTX) TYPE  MAKTX OPTIONAL
*"     VALUE(IS_OZKOD) TYPE  ZOZKOD_RANGE_TT OPTIONAL
*"     VALUE(IS_BSTKD) TYPE  ZBSTKD_RANGE_TT OPTIONAL
*"     VALUE(IS_BSTDK) TYPE  ZBSTDK_RANGE_TT OPTIONAL
*"     VALUE(IS_LAND1) TYPE  ZLAND1_RANGE_TT OPTIONAL
*"     VALUE(IS_ERNAM) TYPE  ZERNAM_RANGE_TT OPTIONAL
*"     VALUE(IS_MATKL) TYPE  ZMATKL_RANGE_TT OPTIONAL
*"     VALUE(IS_VSART) TYPE  ZVSART_RANGE_TT OPTIONAL
*"     VALUE(IP_IC) TYPE  CHAR1 OPTIONAL
*"     VALUE(IP_DIS) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(E_EXPORT) TYPE  ZYB_SD_MUSSIP_TT
*"----------------------------------------------------------------------

  "DATA TANIMLAMALARI
  "------------------------------------------------------------------------
  TABLES : vbpa, vbak, vbap,vbup, vbkd, zyb_sd_t_md001, lips, likp, knvh,
  afpo, kna1.
  DATA : ip_datab	 TYPE d.
  DATA : lt_rettab LIKE TABLE OF ddshretval WITH HEADER LINE.
  DATA : BEGIN OF lt_kun1d OCCURS 0,
           hkunnr LIKE knvh-hkunnr,
           name1  LIKE kna1-name1,
         END OF lt_kun1d.
  DATA : BEGIN OF msc OCCURS 0,
           mark,
           kun1d     LIKE vbpa-kunnr,
           nam1d     LIKE kna1-name1,
           kunnr     LIKE kna1-kunnr,
           name1     LIKE kna1-name1,
           kunwe     LIKE vbpa-kunnr,
           namwe     LIKE kna1-name1,
           vbeln     LIKE vbak-vbeln,
           posnr     LIKE vbap-posnr,
           matnr     LIKE vbap-matnr,
           maktx     LIKE makt-maktx,
           matkl     LIKE vbap-matkl,
           ozelkod   LIKE zyb_sd_t_md001-ozelkod,
           ozelad    LIKE zyb_sd_t_md001-ozelad,
           auart     LIKE vbak-auart,
           bezei     LIKE tvakt-bezei,
           audat     LIKE vbak-audat,
           bstkd     LIKE vbkd-bstkd,
           bstdk     LIKE vbkd-bstdk,
           vsart     LIKE vbkd-vsart,
           ernam     LIKE vbak-ernam,
           faksp     LIKE vbap-faksp,
           vtext     LIKE tvfst-vtext,
           wmeng     LIKE vbep-wmeng, ""
           kwmeng    LIKE vbap-kwmeng,
           vrkme     LIKE vbap-vrkme,
           kalab     LIKE mska-kalab,
           menge     LIKE zyb_sd_s_bloke-menge,
           fark      LIKE mska-kalab,
           ackmk     LIKE mseg-menge,
           lfimg     LIKE lips-lfimg,
           netpr     LIKE vbap-netpr,
           kpein     LIKE vbap-kpein,
           kmein     LIKE vbap-kmein,
           netwr     LIKE vbap-netwr,
           waerk     LIKE vbak-waerk,
           lfsta     LIKE vbup-lfsta,
           sttxt(32),
           wadat_ist LIKE likp-wadat_ist,
           abgru     LIKE vbap-abgru,
           beze2     LIKE tvagt-bezei,
           augru     LIKE vbak-augru,
           beze3     LIKE tvaut-bezei,
           prsdt     LIKE vbkd-prsdt,
           mvgr1     LIKE vbap-mvgr1,
           beze4     LIKE tvm1t-bezei,
           mvgr2     LIKE vbap-mvgr2,
           beze5     LIKE tvm2t-bezei,
           mvgr3     LIKE vbap-mvgr3,
           beze6     LIKE tvm3t-bezei,
           mvgr4     LIKE vbap-mvgr4,
           beze7     LIKE tvm4t-bezei,
           vtweg     LIKE vbak-vtweg,
           vkorg     LIKE vbak-vkorg,
           vkorgtxt  TYPE vtxtk,
           vkbur     LIKE vbak-vkbur,
           vkburtxt  TYPE bezei20,
           vstel     TYPE vstel,
           vsteltxt  TYPE bezei30,
           werks     TYPE werks_d,
           werkstxt  TYPE name1,
           plnmik    TYPE menge_d,
           lddat     TYPE lddat,
           vbeln_vl  TYPE vbeln_vl,
           posnr_vl  TYPE posnr_vl,
         END OF msc.

  DATA: tb_data     LIKE TABLE OF msc,
        ls_data     LIKE LINE OF msc,
        lt_data_tmp LIKE TABLE OF msc,
        ls_data_tmp LIKE LINE OF msc.

*--> bbozaci 28.09.2015
*  DATA : BEGIN OF lt_ozkod OCCURS 0,
*      	zyb_sd_t_md001-ozelkod,
*         END OF lt_ozkod.
*--< bbozaci 28.09.2015
  DATA:
    lt_ozkod LIKE zyb_sd_t_md001 OCCURS 0 WITH HEADER LINE,
    lt_tvkot LIKE tvkot OCCURS 0 WITH HEADER LINE,
    lt_tvkbt LIKE tvkbt OCCURS 0 WITH HEADER LINE,
    lt_tvstt LIKE tvstt OCCURS 0 WITH HEADER LINE,
    lt_t001w LIKE t001w OCCURS 0 WITH HEADER LINE,
    lt_tvakt LIKE tvakt OCCURS 0 WITH HEADER LINE,
    lt_tvfst LIKE tvfst OCCURS 0 WITH HEADER LINE,
    lt_vbpa  LIKE vbpa  OCCURS 0 WITH HEADER LINE,
    lt_adrc  LIKE adrc  OCCURS 0 WITH HEADER LINE,
    lt_lips  LIKE lips  OCCURS 0 WITH HEADER LINE.

  DATA : ls_export LIKE LINE OF e_export.

  RANGES :         s_kunnr FOR vbak-kunnr,
                   s_kunwe FOR vbpa-kunnr,
                   s_kun1d FOR vbpa-kunnr,
                   s_vtweg FOR vbak-vtweg,
                   s_vbeln FOR vbak-vbeln,
                   s_posnr FOR vbap-posnr,
                   s_auart FOR vbak-auart,
                   s_vkbur FOR vbak-vkbur,
                   s_lfsta FOR vbup-lfsta,
                   s_lgort FOR vbap-lgort,
                   s_audat FOR vbak-audat,
                   s_lddat FOR zyb_sd_t_shp02-lddat,
                   s_matnr FOR vbap-matnr,
                   s_ozkod FOR zyb_sd_t_md001-ozelkod,
                   s_matkl FOR vbap-matkl,
                   s_bstkd FOR vbkd-bstkd,
                   s_bstdk FOR vbkd-bstdk,
                   s_land1 FOR kna1-land1,
                   s_vsart FOR vbkd-vsart,
                   s_ernam FOR vbak-ernam,
                   r_vtweg FOR vbak-vtweg.

  DATA : r_audat  LIKE LINE OF is_audat.
  DATA : r_audat1 LIKE LINE OF s_audat,
         r_lddat  LIKE LINE OF is_lddat,
         r_lddat1 LIKE LINE OF s_lddat.

  DATA : lt_kna1 LIKE TABLE OF kna1 WITH HEADER LINE.
  DATA : lv_tbx TYPE i.
  break bbozaci.
  s_kunnr[] = is_kunnr[].
  s_kun1d[] = is_kun1d[].
  s_kunwe[] = is_kunwe[].
  s_vbeln[] = is_vbeln[].
  s_posnr[] = is_posnr[].
  s_auart[] = is_auart[].
  s_vkbur[] = is_vkbur[].
  s_lfsta[] = is_lfsta[].
  s_lgort[] = is_lgort[].
*  S_AUDAT[] = IS_AUDAT[].
  s_matnr[] = is_matnr[].
  s_ozkod[] = is_ozkod[].
  s_bstkd[] = is_bstkd[].
  s_bstdk[] = is_bstdk[].
  s_land1[] = is_land1[].
  s_ernam[] = is_ernam[].
  s_matkl[] = is_matkl[].
  s_vsart[] = is_vsart[].
  s_vtweg[] = is_vtweg[].
  ip_datab  = sy-datum.

  IF NOT ip_kunnam IS INITIAL.
    CONCATENATE '%'ip_kunnam'%' INTO ip_kunnam.
    SELECT kunnr
           name1 FROM kna1
        INTO TABLE lt_kna1
        WHERE name1 LIKE ip_kunnam.
    LOOP AT lt_kna1.
      CLEAR s_kunnr.
      s_kunnr-sign   = 'I'.
      s_kunnr-option = 'EQ'.
      s_kunnr-low    = lt_kna1-kunnr.
      APPEND s_kunnr.
    ENDLOOP.
  ENDIF.

  CLEAR : s_audat[].
  LOOP AT is_audat INTO r_audat.
    IF r_audat-low IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = r_audat-low
        IMPORTING
          date_internal = r_audat-low.
    ENDIF.
    IF r_audat-high IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = r_audat-high
        IMPORTING
          date_internal = r_audat-high.
    ENDIF.
    CLEAR r_audat1.
    r_audat1-sign   = r_audat-sign.
    r_audat1-option = r_audat-option.
    r_audat1-low    = r_audat-low(8).
    r_audat1-high   = r_audat-high(8).
    APPEND r_audat1 TO s_audat.
  ENDLOOP.

  CLEAR s_lddat[].
  LOOP AT is_lddat INTO r_lddat.
    IF r_lddat-low IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = r_lddat-low
        IMPORTING
          date_internal = r_lddat-low.
    ENDIF.
    IF r_lddat-high IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = r_lddat-high
        IMPORTING
          date_internal = r_lddat-high.
    ENDIF.
    CLEAR r_lddat1.
    r_lddat1-sign   = r_lddat-sign.
    r_lddat1-option = r_lddat-option.
    r_lddat1-low    = r_lddat-low(8).
    r_lddat1-high   = r_lddat-high(8).
    APPEND r_lddat1 TO s_lddat.
  ENDLOOP.

**--> bbozaci 28.09.2015
*  SELECT * FROM zyb_sd_t_md001 .
*    lt_ozkod-ozelkod = zyb_sd_t_md001-ozelkod.
*    COLLECT lt_ozkod.
*  ENDSELECT.
**--< bbozaci 28.09.2015


  IF s_land1 IS NOT INITIAL.
    s_kunnr-sign = 'I'. s_kunnr-option = 'EQ'.
    SELECT * FROM kna1 WHERE land1 IN s_land1.
      s_kunnr-low = kna1-kunnr.
      APPEND s_kunnr.
    ENDSELECT.
  ENDIF.

  IF is_kun1d IS NOT INITIAL AND ip_dis IS NOT INITIAL.
    SELECT SINGLE * FROM knvh WHERE hityp = 'A'
                                AND vkorg = '1100'
                                AND vtweg = '20'
                                AND spart = '00'
                                AND hkunnr IN is_kun1d
                                AND datab <= ip_datab
                                AND datbi >= ip_datab.
    IF sy-subrc NE 0.
      MESSAGE i071(zyb_sd).
      CHECK 1 = 2.
    ENDIF.
  ENDIF.

  CLEAR: r_vtweg, r_vtweg[].
  IF NOT ip_ic IS INITIAL.
    r_vtweg-sign   = 'I'.
    r_vtweg-option = 'EQ'.
    r_vtweg-low    = '10'.
    APPEND r_vtweg. CLEAR r_vtweg-low.
    r_vtweg-low = '30'.
    APPEND r_vtweg. CLEAR r_vtweg.
  ENDIF.

  IF ip_ic EQ 'X'.
    IF ip_maktx IS INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE msc
        FROM vbak
      INNER JOIN vbap ON vbak~vbeln = vbap~vbeln
      INNER JOIN vbup ON vbup~vbeln = vbap~vbeln
                     AND vbup~posnr = vbap~posnr
       WHERE vbak~vbeln IN s_vbeln
         AND vbap~posnr IN s_posnr
         AND vbap~lgort IN s_lgort
         AND vbak~vkbur IN s_vkbur
         AND vbak~auart IN s_auart
         AND vbak~audat IN s_audat
         AND vbak~kunnr IN s_kunnr
         AND vbap~matnr IN s_matnr
         AND vbap~matkl IN s_matkl
         AND vbak~ernam IN s_ernam
         AND vbak~vtweg IN r_vtweg
         AND vbup~lfsta IN s_lfsta.
    ELSE.
      CONCATENATE '%'ip_maktx'%' INTO ip_maktx.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE msc
        FROM vbak
      INNER JOIN vbap ON vbak~vbeln = vbap~vbeln
      INNER JOIN makt ON makt~matnr = vbap~matnr
      INNER JOIN vbup ON vbup~vbeln = vbap~vbeln
                     AND vbup~posnr = vbap~posnr
       WHERE vbak~vbeln IN s_vbeln
         AND vbap~posnr IN s_posnr
         AND vbap~lgort IN s_lgort
         AND vbak~vkbur IN s_vkbur
         AND vbak~auart IN s_auart
         AND vbak~audat IN s_audat
         AND vbak~kunnr IN s_kunnr
         AND vbap~matnr IN s_matnr
         AND vbap~matkl IN s_matkl
         AND makt~maktx LIKE ip_maktx
         AND makt~spras EQ sy-langu
         AND vbak~ernam IN s_ernam
         AND vbak~vtweg IN r_vtweg
         AND vbup~lfsta IN s_lfsta.
    ENDIF.
  ENDIF.

  CLEAR: r_vtweg, r_vtweg[].
  IF NOT ip_dis IS INITIAL.
    r_vtweg-sign   = 'I'.
    r_vtweg-option = 'EQ'.
    r_vtweg-low    = '20'.
    APPEND r_vtweg. CLEAR r_vtweg-low.
  ENDIF.

  FREE: tb_data.
  IF ip_dis EQ 'X'.
    IF ip_maktx IS INITIAL.
      SELECT vbak~kunnr
             vbap~vbeln
             vbap~posnr
             vbap~matnr
             makt~maktx
             vbap~matkl
             vbak~auart
             vbak~audat
             vbak~ernam
             vbap~faksp
             vbap~kwmeng
             vbap~vrkme
             vbap~netpr
             vbap~kpein
             vbap~kmein
             vbap~netwr
             vbak~waerk
             vbap~mvgr1
             vbap~mvgr2
             vbap~mvgr3
             vbap~mvgr4
             vbak~vtweg
             vbak~vkorg
             vbak~vkbur
             vbap~vstel
             vbap~werks
             vbup~lfsta
             shp02~tesmik AS plnmik
             shp02~lddat
             shp02~vbeln_vl
             shp02~posnr_vl
         INTO CORRESPONDING FIELDS OF TABLE tb_data
        FROM vbak
      INNER JOIN vbap ON vbak~vbeln = vbap~vbeln
      INNER JOIN vbup ON vbup~vbeln = vbap~vbeln
                     AND vbup~posnr = vbap~posnr
      INNER JOIN zyb_sd_t_shp02 AS shp02 ON shp02~vbeln EQ vbap~vbeln
                                        AND shp02~posnr EQ vbap~posnr
      INNER JOIN makt ON makt~matnr = vbap~matnr
       WHERE vbak~vbeln  IN s_vbeln
         AND vbap~posnr  IN s_posnr
         AND vbap~lgort  IN s_lgort
         AND vbak~vkbur  IN s_vkbur
         AND vbak~auart  IN s_auart
         AND vbak~audat  IN s_audat
         AND vbak~kunnr  IN s_kunnr
         AND vbap~matnr  IN s_matnr
         AND vbap~matkl  IN s_matkl
         AND vbak~ernam  IN s_ernam
         AND vbak~vtweg  IN r_vtweg
         AND shp02~loekz EQ space
         AND shp02~durum IN ('C', 'D')
         AND shp02~lddat IN s_lddat
         AND makt~spras  EQ sy-langu
         AND vbup~lfsta IN s_lfsta.
    ELSE.
      CONCATENATE '%'ip_maktx'%' INTO ip_maktx.
      SELECT vbak~kunnr
             vbap~vbeln
             vbap~posnr
             vbap~matnr
             makt~maktx
             vbap~matkl
             vbak~auart
             vbak~audat
             vbak~ernam
             vbap~faksp
             vbap~kwmeng
             vbap~vrkme
             vbap~netpr
             vbap~kpein
             vbap~kmein
             vbap~netwr
             vbak~waerk
             vbap~mvgr1
             vbap~mvgr2
             vbap~mvgr3
             vbap~mvgr4
             vbak~vtweg
             vbak~vkorg
             vbak~vkbur
             vbap~vstel
             vbap~werks
             vbup~lfsta
             shp02~tesmik AS plnmik
             shp02~lddat
             shp02~vbeln_vl
             shp02~posnr_vl
        INTO CORRESPONDING FIELDS OF TABLE tb_data
        FROM vbak
      INNER JOIN vbap ON vbak~vbeln = vbap~vbeln
      INNER JOIN vbup ON vbup~vbeln = vbap~vbeln
                     AND vbup~posnr = vbap~posnr
      INNER JOIN makt ON makt~matnr = vbap~matnr
      INNER JOIN zyb_sd_t_shp02 AS shp02 ON shp02~vbeln EQ vbap~vbeln
                                        AND shp02~posnr EQ vbap~posnr
       WHERE vbak~vbeln  IN s_vbeln
         AND vbap~posnr  IN s_posnr
         AND vbap~lgort  IN s_lgort
         AND vbak~vkbur  IN s_vkbur
         AND vbak~auart  IN s_auart
         AND vbak~audat  IN s_audat
         AND vbak~kunnr  IN s_kunnr
         AND vbap~matnr  IN s_matnr
         AND vbap~matkl  IN s_matkl
         AND makt~maktx  LIKE ip_maktx
         AND makt~spras  EQ sy-langu
         AND vbak~ernam  IN s_ernam
         AND vbak~vtweg  IN r_vtweg
         AND shp02~loekz EQ space
         AND shp02~durum IN ('C', 'D')
         AND shp02~lddat IN s_lddat
         AND vbup~lfsta  IN s_lfsta.
    ENDIF.

    FREE: lt_lips.
    IF NOT tb_data[] IS INITIAL.
      SELECT * FROM lips
          INNER JOIN vbup ON vbup~vbeln EQ lips~vbeln
          INTO CORRESPONDING FIELDS OF TABLE lt_lips
         FOR ALL ENTRIES IN tb_data
          WHERE lips~vbeln EQ tb_data-vbeln_vl
            AND lips~lfimg GT 0
            AND vbup~kosta NE 'C'.
    ENDIF.

    lt_data_tmp[] = tb_data[].
    SORT tb_data BY vbeln posnr lddat.
    DELETE ADJACENT DUPLICATES FROM tb_data
                          COMPARING vbeln posnr lddat.

    LOOP AT tb_data INTO ls_data.
      CLEAR: msc, lt_lips, ls_data-vbeln_vl, ls_data-posnr_vl,
             ls_data-plnmik.

      LOOP AT lt_data_tmp  INTO ls_data_tmp
                          WHERE vbeln = ls_data-vbeln
                            AND posnr = ls_data-posnr
                            AND lddat = ls_data-lddat.
        IF NOT ls_data_tmp-vbeln_vl IS INITIAL.
          READ TABLE lt_lips WITH KEY vbeln = ls_data_tmp-vbeln_vl
                                      posnr = ls_data_tmp-posnr_vl.
          IF sy-subrc <> 0.
            DELETE lt_data_tmp.
            CONTINUE.
          ENDIF.
        ENDIF.
        ls_data-plnmik = ls_data-plnmik + ls_data_tmp-plnmik.
      ENDLOOP.

      MOVE-CORRESPONDING ls_data TO msc.
      APPEND msc.
    ENDLOOP.
  ENDIF.

**--> bbozaci  28.09.2015
  IF NOT msc[] IS INITIAL.
    FREE: lt_ozkod.
    SELECT * FROM zyb_sd_t_md001
        INTO TABLE lt_ozkod
       FOR ALL ENTRIES IN msc
         WHERE vtweg = msc-vtweg
           AND kunnr = msc-kunnr
           AND matnr = msc-matnr
           AND mvgr2 = msc-mvgr2.

    FREE: lt_tvkot.
    SELECT * FROM tvkot
         INTO TABLE lt_tvkot
       FOR ALL ENTRIES IN msc
         WHERE vkorg EQ msc-vkorg
           AND spras EQ sy-langu.

    FREE: lt_tvkbt.
    SELECT * FROM tvkbt
         INTO TABLE lt_tvkbt
        FOR ALL ENTRIES IN msc
         WHERE vkbur EQ msc-vkbur
           AND spras EQ sy-langu.

    FREE: lt_tvstt.
    SELECT * FROM tvstt
           INTO TABLE lt_tvstt
         FOR ALL ENTRIES IN msc
          WHERE vstel EQ msc-vstel
            AND spras EQ sy-langu.

    FREE: lt_t001w.
    SELECT * FROM t001w
           INTO TABLE lt_t001w
       FOR ALL ENTRIES IN msc
          WHERE werks EQ msc-werks.

    FREE: lt_tvakt.
    SELECT * FROM tvakt
        INTO TABLE lt_tvakt
       FOR ALL ENTRIES IN msc
          WHERE auart EQ msc-auart
            AND spras EQ sy-langu.

    FREE: lt_tvfst.
    SELECT * FROM tvfst
            INTO TABLE lt_tvfst
        FOR ALL ENTRIES IN msc
            WHERE faksp EQ msc-faksp
              AND spras EQ sy-langu.

    FREE: lt_vbpa[].
    SELECT * FROM vbpa
    INTO TABLE lt_vbpa
    FOR ALL ENTRIES IN msc
    WHERE vbeln EQ msc-vbeln
      AND posnr EQ '000000'
      AND parvw IN ('1D', 'WE', 'AG').

    SORT lt_vbpa BY vbeln parvw.

    IF NOT lt_vbpa[] IS INITIAL.
      FREE: lt_adrc.
      SELECT * FROM adrc
           INTO TABLE lt_adrc
         FOR ALL ENTRIES IN lt_vbpa
           WHERE addrnumber EQ lt_vbpa-adrnr.

      SORT lt_adrc BY addrnumber.
    ENDIF.
  ENDIF.
**--< bbozaci 28.09.2015

  SELECT * FROM kna1 INTO TABLE lt_kna1.

  SORT lt_kna1 BY kunnr.
  DATA : lt_blk LIKE TABLE OF zyb_sd_s_bloke WITH HEADER LINE,
         lt_key LIKE TABLE OF zyb_sd_s_sdkey WITH HEADER LINE.

* düzeltmeye buradan başlanacak.
  LOOP AT msc.
    lv_tbx = sy-tabix.


* Müşteri Hiyerarşisi 1
    CLEAR lt_vbpa.
    READ TABLE lt_vbpa WITH KEY vbeln = msc-vbeln
                                parvw = '1D'.
    IF sy-subrc = 0.
      msc-kun1d  = lt_vbpa-kunnr.

      CLEAR lt_adrc.
      READ TABLE lt_adrc WITH KEY addrnumber = lt_vbpa-adrnr.
      IF sy-subrc = 0.
        msc-nam1d = lt_adrc-name1.
      ENDIF.
    ENDIF.

    IF is_kun1d IS NOT INITIAL AND msc-kun1d NOT IN is_kun1d AND
       msc-kunnr NOT IN is_kun1d.
      DELETE msc INDEX lv_tbx.
      CONTINUE.
    ENDIF.

* Malı Teslim Alan
    CLEAR lt_vbpa.
    READ TABLE lt_vbpa WITH KEY vbeln = msc-vbeln
                                parvw = 'WE'.
    IF sy-subrc = 0.
      msc-kunwe  = lt_vbpa-kunnr.

      CLEAR lt_adrc.
      READ TABLE lt_adrc WITH KEY addrnumber = lt_vbpa-adrnr.
      IF sy-subrc = 0.
        msc-namwe = lt_adrc-name1.
      ENDIF.
    ENDIF.

    IF msc-kunwe NOT IN s_kunwe.
      DELETE msc INDEX lv_tbx.
      CONTINUE.
    ENDIF.


    SELECT SINGLE * FROM vbkd WHERE vbeln = msc-vbeln
    AND posnr = msc-posnr.
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM vbkd WHERE vbeln = msc-vbeln
      AND posnr = '000000'.
    ENDIF.

    IF sy-subrc = 0.
      msc-bstkd = vbkd-bstkd.
      msc-bstdk = vbkd-bstdk.
      msc-vsart = vbkd-vsart.
      msc-prsdt = vbkd-prsdt.
    ENDIF.

    IF msc-bstkd NOT IN s_bstkd.
      DELETE msc INDEX lv_tbx.
      CONTINUE.
    ENDIF.

    IF msc-bstdk NOT IN s_bstdk.
      DELETE msc INDEX lv_tbx.
      CONTINUE.
    ENDIF.

  IF msc-vtweg EQ '20'.
    CLEAR lt_ozkod.
    READ TABLE lt_ozkod WITH KEY vtweg = msc-vtweg
                                 kunnr = msc-kunnr
                                 matnr = msc-matnr
                                 mvgr2 = msc-mvgr2.
    IF sy-subrc = 0.
      msc-ozelkod = lt_ozkod-ozelkod.
      msc-ozelad  = lt_ozkod-ozelad.
    ENDIF.
  ENDIF.

    IF msc-ozelkod NOT IN s_ozkod.
      DELETE msc INDEX lv_tbx.
      CONTINUE.
    ENDIF.


    CLEAR lt_tvkot.
    READ TABLE lt_tvkot WITH KEY vkorg = msc-vkorg.
    IF sy-subrc = 0.
      msc-vkorgtxt = lt_tvkot-vtext.
    ENDIF.

    CLEAR lt_tvkbt.
    READ TABLE lt_tvkbt WITH KEY vkbur = msc-vkbur.
    IF sy-subrc = 0.
      msc-vkburtxt = lt_tvkbt-bezei.
    ENDIF.

    CLEAR lt_tvstt.
    READ TABLE lt_tvstt WITH KEY vstel = msc-vstel.
    IF sy-subrc = 0.
      msc-vsteltxt = lt_tvstt-vtext.
    ENDIF.

    CLEAR lt_t001w.
    READ TABLE lt_t001w WITH KEY werks = msc-werks.
    IF sy-subrc = 0.
      msc-werkstxt = lt_t001w-name1.
    ENDIF.

    CLEAR lt_tvakt.
    READ TABLE lt_tvakt WITH KEY auart = msc-auart.
      IF sy-subrc = 0.
        msc-bezei = lt_tvakt-bezei.
      ENDIF.

      CLEAR lt_tvfst.
      READ TABLE lt_tvfst WITH KEY faksp = msc-faksp.
      IF sy-subrc = 0.
        msc-vtext = lt_tvfst-vtext.
      ENDIF.

    CLEAR lt_kna1.
    READ TABLE lt_kna1 WITH KEY kunnr = msc-kunnr BINARY SEARCH.
    IF sy-subrc = 0.
      msc-name1 = lt_kna1-name1.
    ENDIF.

    IF msc-maktx IS INITIAL.
      SELECT SINGLE maktx FROM makt INTO msc-maktx
              WHERE matnr = msc-matnr
                AND spras = sy-langu.
    ENDIF.



    SELECT SINGLE wmeng FROM vbep INTO msc-wmeng
            WHERE vbeln = msc-vbeln
              AND posnr = msc-posnr.


    SELECT SUM( kalab ) FROM mska INTO msc-kalab
     WHERE vbeln = msc-vbeln
       AND posnr = msc-posnr.

    CLEAR : lt_blk[], lt_key[].
    lt_key-vbeln = msc-vbeln.
    lt_key-posnr = msc-posnr.
    APPEND lt_key. CLEAR lt_key.

"YUR-134
*    CALL FUNCTION 'ZYB_SD_F_BLOKE_STOK'
    CALL FUNCTION 'ZYB_SD_F_BLOKE_STOK_N'
      TABLES
        bloke_tab  = lt_blk
        sd_key_tab = lt_key.

    LOOP AT lt_blk ."WHERE vbeln_vf NE ''.
      ADD lt_blk-menge TO msc-menge.
    ENDLOOP.
    msc-fark = msc-kalab - msc-menge.
**        ackmk

    CASE msc-lfsta.
      WHEN 'A'.
        msc-sttxt = 'Teslimatı yapılmadı.'.
      WHEN 'B'.
        msc-sttxt = 'Kısmen teslimat yapıldı.'.
      WHEN 'C'.
        msc-sttxt = 'Tamamen teslim edildi.'.
      WHEN ''.
        msc-sttxt = 'İlişkili değil.'.
    ENDCASE.

    SELECT * FROM lips WHERE vgbel = msc-vbeln
                         AND vgpos = msc-posnr.
      SELECT SINGLE * FROM likp WHERE vbeln = lips-vbeln.
      IF sy-subrc = 0.
        IF msc-wadat_ist < likp-wadat_ist.
          msc-wadat_ist = likp-wadat_ist.
        ENDIF.
      ENDIF.
    ENDSELECT.

    SELECT SINGLE SUM( lips~lfimg ) INTO msc-lfimg
      FROM lips
      INNER JOIN vbuk ON lips~vbeln EQ vbuk~vbeln
      WHERE lips~vgbel EQ msc-vbeln
        AND lips~vgpos EQ msc-posnr
        AND vbuk~wbstk EQ 'C'.

    SELECT SINGLE bezei FROM tvagt INTO msc-beze2
            WHERE abgru = msc-abgru
    AND spras = sy-langu.
    SELECT SINGLE bezei FROM tvaut INTO msc-beze3
            WHERE augru = msc-augru
    AND spras = sy-langu.
    SELECT SINGLE bezei FROM tvm1t INTO msc-beze4
            WHERE mvgr1 = msc-mvgr1
    AND spras = sy-langu.
    SELECT SINGLE bezei FROM tvm2t INTO msc-beze5
            WHERE mvgr2 = msc-mvgr2
    AND spras = sy-langu.
    SELECT SINGLE bezei FROM tvm3t INTO msc-beze6
        WHERE mvgr3 = msc-mvgr3
    AND spras = sy-langu.
    SELECT SINGLE bezei FROM tvm4t INTO msc-beze7
            WHERE mvgr4 = msc-mvgr4
    AND spras = sy-langu.
    SELECT SINGLE * FROM afpo WHERE kdauf = msc-vbeln
                                AND kdpos = msc-posnr.
    IF sy-subrc = 0.
      msc-ackmk = afpo-psmng - afpo-wemng.
    ENDIF.

    MODIFY msc INDEX lv_tbx.
    IF msc IN s_vsart.
      MOVE-CORRESPONDING msc TO ls_export.
      APPEND ls_export TO e_export.
    ENDIF.
  ENDLOOP.
  IF msc[] IS INITIAL.
    MESSAGE i017(zyb_sd).
  ENDIF.
ENDFUNCTION.
