class ZCL_SD_MV45AFZZ_FORM_TKOMP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
protected section.
private section.

  types:
    BEGIN OF ty_pltyp,
           pltyp TYPE pltyp,
         END OF ty_pltyp .
  types:
    trng_pltyp TYPE RANGE OF ty_pltyp .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_TKOMP_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
"YUR-773 maddesi ile ZCL_SD_MV45AFZZ_FORM_TKOMP_003 sınıfının içerisine alındı. Bu sınıf yedekleme amacıyla tutuldu.
*  FIELD-SYMBOLS: <gs_tkomp> TYPE komp,
*                 <gs_tkomk> TYPE komk,
*                 <gs_t180>  TYPE t180.
*
*  DATA: lr_data  TYPE REF TO data.
*
*  lr_data = co_con->get_vars( 'TKOMP' ). ASSIGN lr_data->* TO <gs_tkomp>.
*  lr_data = co_con->get_vars( 'TKOMK' ). ASSIGN lr_data->* TO <gs_tkomk>.
*  lr_data = co_con->get_vars( 'T180' ).  ASSIGN lr_data->* TO <gs_t180>.
*
*  CHECK: <gs_t180>-trtyp NE 'A',
*         <gs_tkomp>-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm,
*         <gs_tkomp>-knuma_ag IS NOT INITIAL,
*         "--------->> Anıl CENGİZ 10.08.2020 15:33:46
*         "YUR-706
*         zcl_sd_mv45afzz_frm_mvflvp_002=>check_boart( <gs_tkomp>-knuma_ag ) EQ abap_false. "Bedelsiz değil ise aşağıdaki kontrole girer.
*  "---------<<
*  DATA: lt_a910      TYPE TABLE OF a910,
*        ls_a910      TYPE a910,
*        lt_a932pltyp TYPE TABLE OF a932,
*        ls_a932pltyp TYPE a932,
*        lt_a933pltyp TYPE TABLE OF a933,
*        ls_a933pltyp TYPE a933,
*        lt_a946pltyp TYPE TABLE OF a946,
*        ls_a946pltyp TYPE a946,
*        lt_a934pltyp TYPE TABLE OF a934,
*        ls_a934pltyp TYPE a934,
*        lt_a935pltyp TYPE TABLE OF a935,
*        ls_a935pltyp TYPE a935,
*        lt_a939pltyp TYPE TABLE OF a939,
*        ls_a939pltyp TYPE a939,
*        lt_a945pltyp TYPE TABLE OF a945,
*        ls_a945pltyp TYPE a945,
*        lt_a940pltyp TYPE TABLE OF a940,
*        ls_a940pltyp TYPE a940,
*        lt_a941pltyp TYPE TABLE OF a941,
*        ls_a941pltyp TYPE a941,
*        lt_a942pltyp TYPE TABLE OF a942,
*        ls_a942pltyp TYPE a942,
*        lt_a943pltyp TYPE TABLE OF a943,
*        ls_a943pltyp TYPE a943,
*        lt_a944pltyp TYPE TABLE OF a944,
*        ls_a944pltyp TYPE a944,
*        l_tvak       TYPE tvak,
*        l_kschl      TYPE t6b2f-kschl,
*        l_kobog      TYPE t6b1-kobog,
*        l_boart      TYPE kona-boart,
*        rng_kschl    TYPE RANGE OF kschl.
*
*  SELECT SINGLE * FROM tvak INTO l_tvak WHERE auart = <gs_tkomk>-auart.
*
*  CHECK: l_tvak-kalvg = '3' OR
*         l_tvak-kalvg = '4' OR
*         l_tvak-kalvg = '5' OR
*         l_tvak-kalvg = '6'.
*
*  SELECT SINGLE boart FROM kona INTO l_boart WHERE knuma = <gs_tkomp>-knuma_ag.
*  IF sy-subrc <> 0.
*    MESSAGE e023(zsd_va) WITH <gs_tkomp>-knuma_ag.
*  ENDIF.
*  SELECT SINGLE kobog FROM t6b1 INTO l_kobog WHERE boart = l_boart.
*  IF sy-subrc <> 0.
*    MESSAGE e021(zsd_va).
*  ENDIF.
*  "--------->> Anıl CENGİZ 30.11.2020 14:08:42
*  "YUR-773
**  CASE l_kobog.
**    WHEN 'ZY01'.
*      rng_kschl = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZI08' high = space )
*                           ( sign = 'I' option = 'EQ' low = 'ZI06' high = space )
*                           ( sign = 'I' option = 'EQ' low = 'ZI04' high = space )
*                           ( sign = 'I' option = 'EQ' low = 'ZI01' high = space )
*                           ( sign = 'I' option = 'EQ' low = 'ZI02' high = space )  ).
**    WHEN 'ZY02'.
**      rng_kschl = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZI09' high = space )
**                           ( sign = 'I' option = 'EQ' low = 'ZI07' high = space )
**                           ( sign = 'I' option = 'EQ' low = 'ZI05' high = space )
**                           ( sign = 'I' option = 'EQ' low = 'ZI02' high = space )  ).
**    WHEN OTHERS.
**  ENDCASE.
*  "--------->> Sırayla bakılır ZI01
*  LOOP AT rng_kschl REFERENCE INTO DATA(lr_rng_kschl).
*    SELECT zzprsdt pltyp
*      FROM a939
*      INNER JOIN konp ON konp~knumh = a939~knumh
*                     AND konp~kschl = a939~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a939pltyp
*      WHERE a939~kappl    EQ 'V'
**        AND a939~kschl    IN rng_kschl "'ZI01'
*        AND a939~kschl    EQ lr_rng_kschl->low "'ZI01'
*        AND a939~knuma_ag EQ <gs_tkomp>-knuma_ag
*        AND a939~vkorg    EQ <gs_tkomk>-vkorg
*        AND a939~vtweg    EQ <gs_tkomk>-vtweg
*        AND a939~zzprsdt  NE '00000000'
*        AND a939~extwg    EQ <gs_tkomp>-extwg
*        AND a939~datbi    GE <gs_tkomk>-prsdt
*        AND a939~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    IF sy-subrc EQ 0.
*      SELECT pltyp
*        FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a939pltyp
*        WHERE a910~kappl    EQ 'V'
*          AND a910~kschl    EQ 'ZF04'
*          AND a910~vkorg    EQ <gs_tkomk>-vkorg
*          AND a910~vtweg    EQ <gs_tkomk>-vtweg
*          AND a910~pltyp    EQ lt_a939pltyp-pltyp
*          AND a910~matnr    EQ <gs_tkomp>-pmatn
*          AND a910~datbi    GE <gs_tkomk>-prsdt
*          AND a910~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      DESCRIBE TABLE lt_a910.
*      IF sy-tfill EQ 0.
*        "Fiyat bulunamadı
*        MESSAGE e025(zsd_va) WITH <gs_tkomp>-matnr.
*      ELSEIF sy-tfill EQ 1.
*        READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*        <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*        READ TABLE lt_a939pltyp INTO ls_a939pltyp
*          WITH KEY pltyp = ls_a910-pltyp.
*        <gs_tkomp>-zzpr939 = ls_a939pltyp-zzprsdt.
*      ELSEIF sy-tfill GT 1.
*        "Geçerli birden fazla fiyat bulunmaktadır.
*        MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*      ENDIF.
*    ELSE.
*      SELECT zzprsdt pltyp
*        FROM a933
*        INNER JOIN konp ON konp~knumh = a933~knumh
*                       AND konp~kschl = a933~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a933pltyp
*        WHERE a933~kappl    EQ 'V'
**          AND a933~kschl    IN rng_kschl "'ZI01'
*          AND a933~kschl    EQ lr_rng_kschl->low "'ZI01'
*          AND a933~knuma_ag EQ <gs_tkomp>-knuma_ag
*          AND a933~vkorg    EQ <gs_tkomk>-vkorg
*          AND a933~vtweg    EQ <gs_tkomk>-vtweg
*          AND a933~zzprsdt  NE '00000000'
*          AND a933~datbi    GE <gs_tkomk>-prsdt
*          AND a933~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      IF sy-subrc IS INITIAL.
*        SELECT pltyp
*          FROM a910
*          INNER JOIN konp ON konp~knumh = a910~knumh
*                         AND konp~kschl = a910~kschl
*          INTO CORRESPONDING FIELDS OF TABLE lt_a910
*          FOR ALL ENTRIES IN lt_a933pltyp
*          WHERE a910~kappl    EQ 'V'
*            AND a910~kschl    EQ 'ZF04'
*            AND a910~vkorg    EQ <gs_tkomk>-vkorg
*            AND a910~vtweg    EQ <gs_tkomk>-vtweg
*            AND a910~pltyp    EQ lt_a933pltyp-pltyp
*            AND a910~matnr    EQ <gs_tkomp>-pmatn
*            AND a910~datbi    GE <gs_tkomk>-prsdt
*            AND a910~datab    LE <gs_tkomk>-prsdt
*            AND konp~loevm_ko EQ abap_false.
*        DESCRIBE TABLE lt_a910.
*        IF sy-tfill EQ 0.
*          "Fiyat bulunamadı
*          MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*        ELSEIF sy-tfill EQ 1.
*          READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*          <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*          READ TABLE lt_a933pltyp INTO ls_a933pltyp
*            WITH KEY pltyp = ls_a910-pltyp.
*          <gs_tkomp>-zzpr933 = ls_a933pltyp-zzprsdt.
*        ELSEIF sy-tfill GT 1.
*          "Geçerli birden fazla fiyat bulunmaktadır.
*          MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*
*    SELECT zzprsdt pltyp
*      FROM a945
*      INNER JOIN konp ON konp~knumh = a945~knumh
*                     AND konp~kschl = a945~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a945pltyp
*      WHERE a945~kappl    EQ 'V'
**        AND a945~kschl    IN rng_kschl "'ZI01'
*        AND a945~kschl    EQ lr_rng_kschl->low "'ZI01'
*        AND a945~knuma_ag EQ <gs_tkomp>-knuma_ag
*        AND a945~vkorg    EQ <gs_tkomk>-vkorg
*        AND a945~vtweg    EQ <gs_tkomk>-vtweg
*        AND a945~zzprsdt  NE '00000000'
*        AND a945~extwg    EQ <gs_tkomp>-extwg
*        AND a945~datbi    GE <gs_tkomk>-prsdt
*        AND a945~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    IF sy-subrc EQ 0.
*      SELECT pltyp
*        FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a945pltyp
*        WHERE a910~kappl    EQ 'V'
*          AND a910~kschl    EQ 'ZF04'
*          AND a910~vkorg    EQ <gs_tkomk>-vkorg
*          AND a910~vtweg    EQ <gs_tkomk>-vtweg
*          AND a910~pltyp    EQ lt_a945pltyp-pltyp
*          AND a910~matnr    EQ <gs_tkomp>-pmatn
*          AND a910~datbi    GE <gs_tkomk>-prsdt
*          AND a910~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      DESCRIBE TABLE lt_a910.
*      IF sy-tfill EQ 0.
*        "Fiyat bulunamadı
*        MESSAGE e025(zsd_va) WITH <gs_tkomp>-matnr.
*      ELSEIF sy-tfill EQ 1.
*        READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*        <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*        READ TABLE lt_a945pltyp INTO ls_a945pltyp
*          WITH KEY pltyp = ls_a910-pltyp.
*        <gs_tkomp>-zzpr945 = ls_a945pltyp-zzprsdt.
*      ELSEIF sy-tfill GT 1.
*        "Geçerli birden fazla fiyat bulunmaktadır.
*        MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*      ENDIF.
*    ELSE.
*      SELECT zzprsdt pltyp
*        FROM a946
*        INNER JOIN konp ON konp~knumh = a946~knumh
*                       AND konp~kschl = a946~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a946pltyp
*        WHERE a946~kappl    EQ 'V'
**          AND a946~kschl    IN rng_kschl "'ZI01'
*          AND a946~kschl    EQ lr_rng_kschl->low "'ZI01'
*          AND a946~knuma_ag EQ <gs_tkomp>-knuma_ag
*          AND a946~vkorg    EQ <gs_tkomk>-vkorg
*          AND a946~vtweg    EQ <gs_tkomk>-vtweg
*          AND a946~zzprsdt  NE '00000000'
*          AND a946~datbi    GE <gs_tkomk>-prsdt
*          AND a946~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      IF sy-subrc IS INITIAL.
*        SELECT pltyp
*          FROM a910
*          INNER JOIN konp ON konp~knumh = a910~knumh
*                         AND konp~kschl = a910~kschl
*          INTO CORRESPONDING FIELDS OF TABLE lt_a910
*          FOR ALL ENTRIES IN lt_a946pltyp
*          WHERE a910~kappl    EQ 'V'
*            AND a910~kschl    EQ 'ZF04'
*            AND a910~vkorg    EQ <gs_tkomk>-vkorg
*            AND a910~vtweg    EQ <gs_tkomk>-vtweg
*            AND a910~pltyp    EQ lt_a946pltyp-pltyp
*            AND a910~matnr    EQ <gs_tkomp>-pmatn
*            AND a910~datbi    GE <gs_tkomk>-prsdt
*            AND a910~datab    LE <gs_tkomk>-prsdt
*            AND konp~loevm_ko EQ abap_false.
*        DESCRIBE TABLE lt_a910.
*        IF sy-tfill EQ 0.
*          "Fiyat bulunamadı
*          MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*        ELSEIF sy-tfill EQ 1.
*          READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*          <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*          READ TABLE lt_a946pltyp INTO ls_a946pltyp
*            WITH KEY pltyp = ls_a910-pltyp.
*          <gs_tkomp>-zzpr946 = ls_a946pltyp-zzprsdt.
*        ELSEIF sy-tfill GT 1.
*          "Geçerli birden fazla fiyat bulunmaktadır.
*          MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*  "---------<< ZI01
*  "--------->> Sırayla bakılır ZI04
*  SELECT zzprsdt pltyp
*    FROM a941
*    INNER JOIN konp ON konp~knumh = a941~knumh
*                   AND konp~kschl = a941~kschl
*    INTO CORRESPONDING FIELDS OF TABLE lt_a941pltyp
*    WHERE a941~kappl    EQ 'V'
*      AND a941~kschl    IN rng_kschl "'ZI04'
*      AND a941~knuma_ag EQ <gs_tkomp>-knuma_ag
*      AND a941~vkorg    EQ <gs_tkomk>-vkorg
*      AND a941~vtweg    EQ <gs_tkomk>-vtweg
*      AND a941~zzprsdt  NE '00000000'
*      AND a941~zzseri   EQ <gs_tkomp>-zzseri
*      AND a941~vrkme    EQ <gs_tkomp>-vrkme
*      AND a941~extwg    EQ <gs_tkomp>-extwg
*      AND a941~datbi    GE <gs_tkomk>-prsdt
*      AND a941~datab    LE <gs_tkomk>-prsdt
*      AND konp~loevm_ko EQ abap_false.
*  IF sy-subrc EQ 0.
*    SELECT pltyp
*      FROM a910
*      INNER JOIN konp ON konp~knumh = a910~knumh
*                     AND konp~kschl = a910~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a910
*      FOR ALL ENTRIES IN lt_a941pltyp
*      WHERE a910~kappl    EQ 'V'
*        AND a910~kschl    EQ 'ZF04'
*        AND a910~vkorg    EQ <gs_tkomk>-vkorg
*        AND a910~vtweg    EQ <gs_tkomk>-vtweg
*        AND a910~pltyp    EQ lt_a941pltyp-pltyp
*        AND a910~matnr    EQ <gs_tkomp>-pmatn
*        AND a910~datbi    GE <gs_tkomk>-prsdt
*        AND a910~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    DESCRIBE TABLE lt_a910.
*    IF sy-tfill EQ 0.
*      "Fiyat bulunamadı
*      MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*    ELSEIF sy-tfill EQ 1.
*      READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*      <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*      READ TABLE lt_a941pltyp INTO ls_a941pltyp
*        WITH KEY pltyp = ls_a910-pltyp.
*      <gs_tkomp>-zzpr941 = ls_a941pltyp-zzprsdt.
*    ELSEIF sy-tfill GT 1.
*      "Geçerli birden fazla fiyat bulunmaktadır.
*      MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*    ENDIF.
*  ELSE.
*    SELECT zzprsdt pltyp
*      FROM a935
*      INNER JOIN konp ON konp~knumh = a935~knumh
*                     AND konp~kschl = a935~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a935pltyp
*      WHERE a935~kappl    EQ 'V'
*        AND a935~kschl    IN rng_kschl "'ZI04''
*        AND a935~knuma_ag EQ <gs_tkomp>-knuma_ag
*        AND a935~vkorg    EQ <gs_tkomk>-vkorg
*        AND a935~vtweg    EQ <gs_tkomk>-vtweg
*        AND a935~zzprsdt  NE '00000000'
*        AND a935~zzseri   EQ <gs_tkomp>-zzseri
*        AND a935~vrkme    EQ <gs_tkomp>-vrkme
*        AND a935~datbi    GE <gs_tkomk>-prsdt
*        AND a935~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    IF sy-subrc EQ 0.
*      SELECT pltyp
*        FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a935pltyp
*        WHERE a910~kappl    EQ 'V'
*          AND a910~kschl    EQ 'ZF04'
*          AND a910~vkorg    EQ <gs_tkomk>-vkorg
*          AND a910~vtweg    EQ <gs_tkomk>-vtweg
*          AND a910~pltyp    EQ lt_a935pltyp-pltyp
*          AND a910~matnr    EQ <gs_tkomp>-pmatn
*          AND a910~datbi    GE <gs_tkomk>-prsdt
*          AND a910~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      DESCRIBE TABLE lt_a910.
*      IF sy-tfill EQ 0.
*        "Fiyat bulunamadı
*        MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*      ELSEIF sy-tfill EQ 1.
*        READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*        <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*        READ TABLE lt_a935pltyp INTO ls_a935pltyp
*          WITH KEY pltyp = ls_a910-pltyp.
*        <gs_tkomp>-zzpr935 = ls_a935pltyp-zzprsdt.
*      ELSEIF sy-tfill GT 1.
*        "Geçerli birden fazla fiyat bulunmaktadır.
*        MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*      ENDIF.
*    ELSE.
*      SELECT zzprsdt pltyp
*        FROM a940
*        INNER JOIN konp ON konp~knumh = a940~knumh
*                       AND konp~kschl = a940~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a940pltyp
*        WHERE a940~kappl    EQ 'V'
*          AND a940~kschl    IN rng_kschl "'ZI04'
*          AND a940~knuma_ag EQ <gs_tkomp>-knuma_ag
*          AND a940~vkorg    EQ <gs_tkomk>-vkorg
*          AND a940~vtweg    EQ <gs_tkomk>-vtweg
*          AND a940~zzprsdt  NE '00000000'
*          AND a940~kunag    EQ <gs_tkomk>-kunnr
*          AND a940~extwg    EQ <gs_tkomp>-extwg
*          AND a940~datbi    GE <gs_tkomk>-prsdt
*          AND a940~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      IF sy-subrc EQ 0.
*        SELECT pltyp
*          FROM a910
*          INNER JOIN konp ON konp~knumh = a910~knumh
*                         AND konp~kschl = a910~kschl
*          INTO CORRESPONDING FIELDS OF TABLE lt_a910
*          FOR ALL ENTRIES IN lt_a940pltyp
*          WHERE a910~kappl    EQ 'V'
*            AND a910~kschl    EQ 'ZF04'
*            AND a910~vkorg    EQ <gs_tkomk>-vkorg
*            AND a910~vtweg    EQ <gs_tkomk>-vtweg
*            AND a910~pltyp    EQ lt_a940pltyp-pltyp
*            AND a910~matnr    EQ <gs_tkomp>-pmatn
*            AND a910~datbi    GE <gs_tkomk>-prsdt
*            AND a910~datab    LE <gs_tkomk>-prsdt
*            AND konp~loevm_ko EQ abap_false.
*        DESCRIBE TABLE lt_a910.
*        IF sy-tfill EQ 0.
*          "Fiyat bulunamadı
*          MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*        ELSEIF sy-tfill EQ 1.
*          READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*          <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*          READ TABLE lt_a940pltyp INTO ls_a940pltyp
*            WITH KEY pltyp = ls_a910-pltyp.
*          <gs_tkomp>-zzpr940 = ls_a940pltyp-zzprsdt.
*        ELSEIF sy-tfill GT 1.
*          "Geçerli birden fazla fiyat bulunmaktadır.
*          MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*        ENDIF.
*      ELSE.
*        SELECT zzprsdt pltyp
*          FROM a934
*          INNER JOIN konp ON konp~knumh = a934~knumh
*                         AND konp~kschl = a934~kschl
*          INTO CORRESPONDING FIELDS OF TABLE lt_a934pltyp
*          WHERE a934~kappl    EQ 'V'
*            AND a934~kschl    IN rng_kschl "'ZI04'
*            AND a934~knuma_ag EQ <gs_tkomp>-knuma_ag
*            AND a934~vkorg    EQ <gs_tkomk>-vkorg
*            AND a934~vtweg    EQ <gs_tkomk>-vtweg
*            AND a934~zzprsdt  NE '00000000'
*            AND a934~kunag    EQ <gs_tkomk>-kunnr
*            AND a934~datbi    GE <gs_tkomk>-prsdt
*            AND a934~datab    LE <gs_tkomk>-prsdt
*            AND konp~loevm_ko EQ abap_false.
*        IF sy-subrc EQ 0.
*          SELECT pltyp
*            FROM a910
*            INNER JOIN konp ON konp~knumh = a910~knumh
*                           AND konp~kschl = a910~kschl
*            INTO CORRESPONDING FIELDS OF TABLE lt_a910
*            FOR ALL ENTRIES IN lt_a934pltyp
*            WHERE a910~kappl    EQ 'V'
*              AND a910~kschl    EQ 'ZF04'
*              AND a910~vkorg    EQ <gs_tkomk>-vkorg
*              AND a910~vtweg    EQ <gs_tkomk>-vtweg
*              AND a910~pltyp    EQ lt_a934pltyp-pltyp
*              AND a910~matnr    EQ <gs_tkomp>-pmatn
*              AND a910~datbi    GE <gs_tkomk>-prsdt
*              AND a910~datab    LE <gs_tkomk>-prsdt
*              AND konp~loevm_ko EQ abap_false.
*          DESCRIBE TABLE lt_a910.
*          IF sy-tfill EQ 0.
*            "Fiyat bulunamadı
*            MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*          ELSEIF sy-tfill EQ 1.
*            READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*            <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*            READ TABLE lt_a934pltyp INTO ls_a934pltyp
*              WITH KEY pltyp = ls_a910-pltyp.
*            <gs_tkomp>-zzpr934 = ls_a934pltyp-zzprsdt.
*          ELSEIF sy-tfill GT 1.
*            "Geçerli birden fazla fiyat bulunmaktadır.
*            MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  "---------<< ZI04
*  "--------->> Sırayla bakılır ZI06
*  SELECT zzprsdt pltyp
*    FROM a942
*    INNER JOIN konp ON konp~knumh = a942~knumh
*                   AND konp~kschl = a942~kschl
*    INTO CORRESPONDING FIELDS OF TABLE lt_a942pltyp
*    WHERE a942~kappl    EQ 'V'
*      AND a942~kschl    IN rng_kschl "'ZI06'
*      AND a942~knuma_ag EQ <gs_tkomp>-knuma_ag
*      AND a942~vkorg    EQ <gs_tkomk>-vkorg
*      AND a942~vtweg    EQ <gs_tkomk>-vtweg
*      AND a942~zzprsdt  NE '00000000'
*      AND a942~zzlgort  EQ <gs_tkomp>-zzlgort
*      AND a942~extwg    EQ <gs_tkomp>-extwg
*      AND a942~datbi    GE <gs_tkomk>-prsdt
*      AND a942~datab    LE <gs_tkomk>-prsdt
*      AND konp~loevm_ko EQ abap_false.
*  IF sy-subrc IS INITIAL.
*    SELECT pltyp
*      FROM a910
*      INNER JOIN konp ON konp~knumh = a910~knumh
*                     AND konp~kschl = a910~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a910
*      FOR ALL ENTRIES IN lt_a942pltyp
*      WHERE a910~kappl    EQ 'V'
*        AND a910~kschl    EQ 'ZF04'
*        AND a910~vkorg    EQ <gs_tkomk>-vkorg
*        AND a910~vtweg    EQ <gs_tkomk>-vtweg
*        AND a910~pltyp    EQ lt_a942pltyp-pltyp
*        AND a910~matnr    EQ <gs_tkomp>-pmatn
*        AND a910~datbi    GE <gs_tkomk>-prsdt
*        AND a910~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    DESCRIBE TABLE lt_a910.
*    IF sy-tfill EQ 0.
*      "Fiyat bulunamadı
*      MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*    ELSEIF sy-tfill EQ 1.
*      READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*      <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*      READ TABLE lt_a942pltyp INTO ls_a942pltyp
*        WITH KEY pltyp = ls_a910-pltyp.
*      <gs_tkomp>-zzpr942 = ls_a942pltyp-zzprsdt.
*    ELSEIF sy-tfill GT 1.
*      "Geçerli birden fazla fiyat bulunmaktadır.
*      MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*    ENDIF.
*  ELSE.
*    SELECT zzprsdt pltyp
*      FROM a932
*      INNER JOIN konp ON konp~knumh = a932~knumh
*                     AND konp~kschl = a932~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a932pltyp
*      WHERE a932~kappl    EQ 'V'
*        AND a932~kschl    IN rng_kschl "'ZI06'
*        AND a932~knuma_ag EQ <gs_tkomp>-knuma_ag
*        AND a932~vkorg    EQ <gs_tkomk>-vkorg
*        AND a932~vtweg    EQ <gs_tkomk>-vtweg
*        AND a932~zzlgort  EQ <gs_tkomp>-zzlgort
*        AND a932~zzprsdt  NE '00000000'
*        AND a932~datbi    GE <gs_tkomk>-prsdt
*        AND a932~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    IF sy-subrc IS INITIAL.
*      SELECT pltyp
*        FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a932pltyp
*        WHERE a910~kappl    EQ 'V'
*          AND a910~kschl    EQ 'ZF04'
*          AND a910~vkorg    EQ <gs_tkomk>-vkorg
*          AND a910~vtweg    EQ <gs_tkomk>-vtweg
*          AND a910~pltyp    EQ lt_a932pltyp-pltyp
*          AND a910~matnr    EQ <gs_tkomp>-pmatn
*          AND a910~datbi    GE <gs_tkomk>-prsdt
*          AND a910~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      DESCRIBE TABLE lt_a910.
*      IF sy-tfill EQ 0.
*        "Fiyat bulunamadı
*        MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*      ELSEIF sy-tfill EQ 1.
*        READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*        <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*        READ TABLE lt_a932pltyp INTO ls_a932pltyp
*          WITH KEY pltyp = ls_a910-pltyp.
*        <gs_tkomp>-zzpr932 = ls_a932pltyp-zzprsdt.
*      ELSEIF sy-tfill GT 1.
*        "Geçerli birden fazla fiyat bulunmaktadır.
*        MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*  "---------<< ZI06
*
*  "--------->> Sırayla bakılır ZI08
*  SELECT zzprsdt pltyp
*    FROM a943
*    INNER JOIN konp ON konp~knumh = a943~knumh
*                   AND konp~kschl = a943~kschl
*    INTO CORRESPONDING FIELDS OF TABLE lt_a943pltyp
*    WHERE a943~kappl    EQ 'V'
*      AND a943~kschl    IN rng_kschl "'ZI08'
*      AND a943~knuma_ag EQ <gs_tkomp>-knuma_ag
*      AND a943~vkorg    EQ <gs_tkomk>-vkorg
*      AND a943~vtweg    EQ <gs_tkomk>-vtweg
*      AND a943~zzprsdt  NE '00000000'
*      AND a943~zzebat   EQ <gs_tkomp>-zzebat
*      AND a943~zzlgort  EQ <gs_tkomp>-zzlgort
*      AND a943~vrkme    EQ <gs_tkomp>-vrkme
*      AND a943~extwg    EQ <gs_tkomp>-extwg
*      AND a943~datbi    GE <gs_tkomk>-prsdt
*      AND a943~datab    LE <gs_tkomk>-prsdt
*      AND konp~loevm_ko EQ abap_false.
*  IF sy-subrc EQ 0.
*    SELECT pltyp
*      FROM a910
*      INNER JOIN konp ON konp~knumh = a910~knumh
*                     AND konp~kschl = a910~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a910
*      FOR ALL ENTRIES IN lt_a943pltyp
*      WHERE a910~kappl    EQ 'V'
*        AND a910~kschl    EQ 'ZF04'
*        AND a910~vkorg    EQ <gs_tkomk>-vkorg
*        AND a910~vtweg    EQ <gs_tkomk>-vtweg
*        AND a910~pltyp    EQ lt_a943pltyp-pltyp
*        AND a910~matnr    EQ <gs_tkomp>-pmatn
*        AND a910~datbi    GE <gs_tkomk>-prsdt
*        AND a910~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    DESCRIBE TABLE lt_a910.
*    IF sy-tfill EQ 0.
*      "Fiyat bulunamadı
*      MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*    ELSEIF sy-tfill EQ 1.
*      READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*      <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*      READ TABLE lt_a943pltyp INTO ls_a943pltyp
*        WITH KEY pltyp = ls_a910-pltyp.
*      <gs_tkomp>-zzpr943 = ls_a943pltyp-zzprsdt.
*    ELSEIF sy-tfill GT 1.
*      "Geçerli birden fazla fiyat bulunmaktadır.
*      MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*    ENDIF.
*  ELSE.
*    SELECT zzprsdt pltyp
*      FROM a944
*      INNER JOIN konp ON konp~knumh = a944~knumh
*                     AND konp~kschl = a944~kschl
*      INTO CORRESPONDING FIELDS OF TABLE lt_a944pltyp
*      WHERE a944~kappl    EQ 'V'
*        AND a944~kschl    IN rng_kschl "'ZI08'
*        AND a944~knuma_ag EQ <gs_tkomp>-knuma_ag
*        AND a944~vkorg    EQ <gs_tkomk>-vkorg
*        AND a944~vtweg    EQ <gs_tkomk>-vtweg
*        AND a944~zzprsdt  NE '00000000'
*        AND a944~zzebat   EQ <gs_tkomp>-zzebat
*        AND a944~vrkme    EQ <gs_tkomp>-vrkme
*        AND a944~extwg    EQ <gs_tkomp>-extwg
*        AND a944~datbi    GE <gs_tkomk>-prsdt
*        AND a944~datab    LE <gs_tkomk>-prsdt
*        AND konp~loevm_ko EQ abap_false.
*    IF sy-subrc EQ 0.
*      SELECT pltyp
*        FROM a910
*        INNER JOIN konp ON konp~knumh = a910~knumh
*                       AND konp~kschl = a910~kschl
*        INTO CORRESPONDING FIELDS OF TABLE lt_a910
*        FOR ALL ENTRIES IN lt_a944pltyp
*        WHERE a910~kappl    EQ 'V'
*          AND a910~kschl    EQ 'ZF04'
*          AND a910~vkorg    EQ <gs_tkomk>-vkorg
*          AND a910~vtweg    EQ <gs_tkomk>-vtweg
*          AND a910~pltyp    EQ lt_a944pltyp-pltyp
*          AND a910~matnr    EQ <gs_tkomp>-pmatn
*          AND a910~datbi    GE <gs_tkomk>-prsdt
*          AND a910~datab    LE <gs_tkomk>-prsdt
*          AND konp~loevm_ko EQ abap_false.
*      DESCRIBE TABLE lt_a910.
*      IF sy-tfill EQ 0.
*        "Fiyat bulunamadı
*        MESSAGE e025(zsd_va) WITH <gs_tkomp>-pmatn.
*      ELSEIF sy-tfill EQ 1.
*        READ TABLE lt_a910 INTO ls_a910 INDEX 1.
*        <gs_tkomp>-pltyp_p = ls_a910-pltyp.
*        READ TABLE lt_a944pltyp INTO ls_a944pltyp
*          WITH KEY pltyp = ls_a910-pltyp.
*        <gs_tkomp>-zzpr944 = ls_a944pltyp-zzprsdt.
*      ELSEIF sy-tfill GT 1.
*        "Geçerli birden fazla fiyat bulunmaktadır.
*        MESSAGE e024(zsd_va) WITH <gs_tkomp>-pmatn.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*  "---------<< ZI08
ENDMETHOD.
ENDCLASS.
