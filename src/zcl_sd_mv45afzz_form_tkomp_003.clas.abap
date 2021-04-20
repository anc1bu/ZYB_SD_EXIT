class ZCL_SD_MV45AFZZ_FORM_TKOMP_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_TKOMP .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_pltyp,
      pltyp TYPE pltyp,
    END OF ty_pltyp .
  types:
    trng_pltyp  TYPE RANGE OF ty_pltyp .
  types:
    ttrng_matnr   TYPE RANGE OF matnr .
  types TY_EXTWG_ZF06 type ZSDT_EXTWG_ZF06 .
  types:
    tt_extwg_zf06 TYPE STANDARD TABLE OF ty_extwg_zf06 .

  class-data GT_EXTWG_ZF06 type TT_EXTWG_ZF06 .

  type-pools ABAP .
  class-methods CHECK_EXTWG_ZF06
    importing
      !IV_MATNR type MATNR
    returning
      value(RV_RETURN) type ABAP_BOOL .
  methods CHECK_ZF06
    importing
      !IS_TKOMK type KOMK
      !IV_MATNR_TO_BE_CHECKED type MATNR optional
      !IV_EXTWG_TO_BE_CHECKED type EXTWG optional
    changing
      !CS_TKOMP type KOMP
      !CS_VBAP type VBAP
      !CTRNG_MATNR type TTRNG_MATNR
    returning
      value(RV_RETURN) type ABAP_BOOL
    raising
      ZCX_BC_EXIT_IMP .
  methods FIND_ZF04
    importing
      !IS_TKOMK type KOMK
    changing
      !CS_TKOMP type KOMP
      !CS_VBAP type VBAP .
  methods FIND_ZF06
    importing
      !IS_TKOMK type KOMK
      !IV_RETURN type ABAP_BOOL
    changing
      !CS_TKOMP type KOMP
      !CS_VBAP type VBAP
      !CTRNG_MATNR type TTRNG_MATNR optional
    raising
      ZCX_BC_EXIT_IMP .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_TKOMP_003 IMPLEMENTATION.


METHOD check_extwg_zf06.

  DATA: ls_extwg_zf06 TYPE ty_extwg_zf06.

  SPLIT iv_matnr AT '.' INTO DATA(lv_matnr) DATA(lv_kalite).

  ASSIGN gt_extwg_zf06[ fytkalite = lv_kalite ] TO FIELD-SYMBOL(<gs_extwg_zf06>).
  IF sy-subrc NE 0.
    SELECT *
      FROM zsdt_extwg_zf06
      APPENDING TABLE gt_extwg_zf06
      WHERE fytkalite EQ lv_kalite.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.
  ELSE.
    rv_return = abap_true.
  ENDIF.

ENDMETHOD.


METHOD check_zf06.

  IF iv_extwg_to_be_checked IS INITIAL.
    DATA(ls_extwg_to_be_checked) = zcl_sd_toolkit=>get_extwg( iv_matnr_to_be_checked ).
  ELSE.
    ls_extwg_to_be_checked-extwg = iv_extwg_to_be_checked.
  ENDIF.

  DATA(ls_extwg_entered_material) = zcl_sd_toolkit=>get_extwg( cs_vbap-matnr ).

  CHECK: ls_extwg_to_be_checked-extwg IS NOT INITIAL AND ls_extwg_entered_material-extwg IS NOT INITIAL,
         ls_extwg_to_be_checked-extwg NE ls_extwg_entered_material-extwg.
  SELECT SINGLE mandt
    FROM zsdt_extwg_zf06
    INTO sy-mandt
    WHERE fytkalite EQ ls_extwg_to_be_checked-extwg
      AND gecerlikalite EQ ls_extwg_entered_material-extwg.
  IF sy-subrc EQ 0.
    rv_return = abap_false.
  ELSE.
    rv_return = abap_true.
    APPEND VALUE #( sign = 'E' option = 'EQ' low = iv_matnr_to_be_checked ) TO ctrng_matnr.
  ENDIF.

ENDMETHOD.


METHOD find_zf04.

  DATA: lt_a910      TYPE TABLE OF a910,
        lt_a933pltyp TYPE TABLE OF a933,
        lt_a934pltyp TYPE TABLE OF a934,
        lt_a935pltyp TYPE TABLE OF a935,
        lt_a940pltyp TYPE TABLE OF a940,
        lt_a942pltyp TYPE TABLE OF a942,
        lt_a944pltyp TYPE TABLE OF a944,
        lt_a945pltyp TYPE TABLE OF a945,
        lt_a948pltyp TYPE TABLE OF a948,
        lt_a952pltyp TYPE TABLE OF a952,
        ltrng_matnr  TYPE ttrng_matnr.

  "--------->>Anıl CENGİZ 12.05.2021 09:05:52
  "YUR-808
  SPLIT cs_tkomp-matnr AT '.' INTO DATA(lv_matnr) DATA(lv_kalite).
  APPEND VALUE #( sign   = 'I'
                  option = 'CP'
                  low    = |{ lv_matnr }*| ) TO ltrng_matnr.
  "---------<<

  "--------->> Anıl CENGİZ 30.11.2020 14:08:42
  "YUR-773
  "--------->> Sırayla bakılır. ZI01 Dönem İskontosu(%)  933
  SELECT zzprsdt pltyp
          FROM a933
          INNER JOIN konp ON konp~knumh = a933~knumh
                         AND konp~kschl = a933~kschl
          INTO CORRESPONDING FIELDS OF TABLE lt_a933pltyp
          WHERE a933~kappl    EQ 'V'
            AND a933~kschl    EQ 'ZI01'
            AND a933~knuma_ag EQ cs_tkomp-knuma_ag
            AND a933~vkorg    EQ is_tkomk-vkorg
            AND a933~vtweg    EQ is_tkomk-vtweg
            AND a933~zzprsdt  NE '00000000'
            AND a933~datbi    GE is_tkomk-prsdt
            AND a933~datab    LE is_tkomk-prsdt
            AND konp~loevm_ko EQ abap_false.
  IF sy-subrc IS INITIAL.
    SELECT pltyp matnr
      FROM a910
      INNER JOIN konp ON konp~knumh = a910~knumh
                     AND konp~kschl = a910~kschl
      INTO CORRESPONDING FIELDS OF TABLE lt_a910
      FOR ALL ENTRIES IN lt_a933pltyp
      WHERE a910~kappl    EQ 'V'
        AND a910~kschl    EQ 'ZF04'
        AND a910~vkorg    EQ is_tkomk-vkorg
        AND a910~vtweg    EQ is_tkomk-vtweg
        AND a910~pltyp    EQ lt_a933pltyp-pltyp
        AND a910~matnr    IN ltrng_matnr
        AND a910~datbi    GE is_tkomk-prsdt
        AND a910~datab    LE is_tkomk-prsdt
        AND konp~loevm_ko EQ abap_false.
    DESCRIBE TABLE lt_a910.
    IF sy-tfill EQ 1.
      DATA(lv_valid_pltyp) = lt_a910[ 1 ]-pltyp.
      cs_tkomp-pltyp_p = lv_valid_pltyp.
      cs_tkomp-zzpr933 = lt_a933pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
      cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
    ELSEIF sy-tfill GT 1.
      "Geçerli birden fazla fiyat bulunmaktadır.
      MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
    ENDIF.
  ENDIF.
  "---------<< ZI01

  "--------->> Sırayla bakılır. ZI10  Kalite İskontosu(%) 948
  SELECT zzprsdt pltyp
    FROM a948
    INNER JOIN konp ON konp~knumh = a948~knumh
                   AND konp~kschl = a948~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a948pltyp
    WHERE a948~kappl    EQ 'V'
      AND a948~kschl    EQ 'ZI10'
      AND a948~knuma_ag EQ cs_tkomp-knuma_ag
      AND a948~vkorg    EQ is_tkomk-vkorg
      AND a948~vtweg    EQ is_tkomk-vtweg
      AND a948~zzprsdt  NE '00000000'
      AND a948~extwg    EQ cs_tkomp-extwg
      AND a948~datbi    GE is_tkomk-prsdt
      AND a948~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  IF sy-subrc IS INITIAL.
    IF lv_valid_pltyp IS NOT INITIAL.
      DELETE lt_a948pltyp WHERE pltyp NE lv_valid_pltyp.
    ENDIF.
    IF lt_a948pltyp IS NOT INITIAL.
      SELECT pltyp matnr
        FROM a910
        INNER JOIN konp ON konp~knumh = a910~knumh
                       AND konp~kschl = a910~kschl
        INTO CORRESPONDING FIELDS OF TABLE lt_a910
        FOR ALL ENTRIES IN lt_a948pltyp
        WHERE a910~kappl    EQ 'V'
          AND a910~kschl    EQ 'ZF04'
          AND a910~vkorg    EQ is_tkomk-vkorg
          AND a910~vtweg    EQ is_tkomk-vtweg
          AND a910~pltyp    EQ lt_a948pltyp-pltyp
          AND a910~matnr    IN ltrng_matnr
          AND a910~datbi    GE is_tkomk-prsdt
          AND a910~datab    LE is_tkomk-prsdt
          AND konp~loevm_ko EQ abap_false.
      DESCRIBE TABLE lt_a910.
      IF sy-tfill EQ 1.
        lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
        cs_tkomp-zzpr948 = lt_a948pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
        cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
      ELSEIF sy-tfill GT 1.
        "Geçerli birden fazla fiyat bulunmaktadır.
        MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
      ENDIF.
    ENDIF.
  ENDIF.
  "---------<< ZI10

  "--------->> Sırayla bakılır *ZI08  Ürün İskontosu(%) 935
*                               ZI08  Ürün İskontosu(%) 944
  SELECT zzprsdt pltyp
    FROM a935
    INNER JOIN konp ON konp~knumh = a935~knumh
                   AND konp~kschl = a935~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a935pltyp
    WHERE a935~kappl    EQ 'V'
      AND a935~kschl    EQ 'ZI08'
      AND a935~knuma_ag EQ cs_tkomp-knuma_ag
      AND a935~vkorg    EQ is_tkomk-vkorg
      AND a935~vtweg    EQ is_tkomk-vtweg
      AND a935~zzprsdt  NE '00000000'
      AND a935~zzseri   EQ cs_tkomp-zzseri
      AND a935~vrkme    EQ cs_tkomp-vrkme
      AND a935~datbi    GE is_tkomk-prsdt
      AND a935~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  IF sy-subrc EQ 0.
    IF lv_valid_pltyp IS NOT INITIAL.
      DELETE lt_a935pltyp WHERE pltyp NE lv_valid_pltyp.
    ENDIF.
    IF lt_a935pltyp IS NOT INITIAL.
      SELECT pltyp matnr
        FROM a910
        INNER JOIN konp ON konp~knumh = a910~knumh
                       AND konp~kschl = a910~kschl
        INTO CORRESPONDING FIELDS OF TABLE lt_a910
        FOR ALL ENTRIES IN lt_a935pltyp
        WHERE a910~kappl    EQ 'V'
          AND a910~kschl    EQ 'ZF04'
          AND a910~vkorg    EQ is_tkomk-vkorg
          AND a910~vtweg    EQ is_tkomk-vtweg
          AND a910~pltyp    EQ lt_a935pltyp-pltyp
          AND a910~matnr    IN ltrng_matnr
          AND a910~datbi    GE is_tkomk-prsdt
          AND a910~datab    LE is_tkomk-prsdt
          AND konp~loevm_ko EQ abap_false.
      DESCRIBE TABLE lt_a910.
      IF sy-tfill EQ 1.
        lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
        cs_tkomp-zzpr935 = lt_a935pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
        cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
      ELSEIF sy-tfill GT 1.
        "Geçerli birden fazla fiyat bulunmaktadır.
        MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT zzprsdt pltyp
      FROM a944
      INNER JOIN konp ON konp~knumh = a944~knumh
                     AND konp~kschl = a944~kschl
      INTO CORRESPONDING FIELDS OF TABLE lt_a944pltyp
      WHERE a944~kappl    EQ 'V'
        AND a944~kschl    EQ 'ZI08'
        AND a944~knuma_ag EQ cs_tkomp-knuma_ag
        AND a944~vkorg    EQ is_tkomk-vkorg
        AND a944~vtweg    EQ is_tkomk-vtweg
        AND a944~zzprsdt  NE '00000000'
        AND a944~zzebat   EQ cs_tkomp-zzebat
        AND a944~vrkme    EQ cs_tkomp-vrkme
        AND a944~extwg    EQ cs_tkomp-extwg
        AND a944~datbi    GE is_tkomk-prsdt
        AND a944~datab    LE is_tkomk-prsdt
        AND konp~loevm_ko EQ abap_false.
    IF sy-subrc EQ 0.
      IF lv_valid_pltyp IS NOT INITIAL.
        DELETE lt_a944pltyp WHERE pltyp NE lv_valid_pltyp.
      ENDIF.
      IF lt_a944pltyp IS NOT INITIAL.
        SELECT pltyp matnr
          FROM a910
          INNER JOIN konp ON konp~knumh = a910~knumh
                         AND konp~kschl = a910~kschl
          INTO CORRESPONDING FIELDS OF TABLE lt_a910
          FOR ALL ENTRIES IN lt_a944pltyp
          WHERE a910~kappl    EQ 'V'
            AND a910~kschl    EQ 'ZF04'
            AND a910~vkorg    EQ is_tkomk-vkorg
            AND a910~vtweg    EQ is_tkomk-vtweg
            AND a910~pltyp    EQ lt_a944pltyp-pltyp
            AND a910~matnr    IN ltrng_matnr
            AND a910~datbi    GE is_tkomk-prsdt
            AND a910~datab    LE is_tkomk-prsdt
            AND konp~loevm_ko EQ abap_false.
        DESCRIBE TABLE lt_a910.
        IF sy-tfill EQ 1.
          lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
          cs_tkomp-zzpr944 = lt_a944pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
          cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
        ELSEIF sy-tfill GT 1.
          "Geçerli birden fazla fiyat bulunmaktadır.
          MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  "---------<< ZI08

  "--------->> Sırayla bakılır ZI06	Depo İskontosu(%)	952
*                             "ZI06	Depo İskontosu(%)	942
  SELECT zzprsdt pltyp
    FROM a952
    INNER JOIN konp ON konp~knumh = a952~knumh
                   AND konp~kschl = a952~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a952pltyp
    WHERE a952~kappl    EQ 'V'
      AND a952~kschl    EQ 'ZI06'
      AND a952~knuma_ag EQ cs_tkomp-knuma_ag
      AND a952~vkorg    EQ is_tkomk-vkorg
      AND a952~vtweg    EQ is_tkomk-vtweg
      AND a952~zzprsdt  NE '00000000'
      AND a952~zzlgort  EQ cs_tkomp-zzlgort
      AND a952~zzebat   EQ cs_tkomp-zzebat
      AND a952~extwg    EQ cs_tkomp-extwg
      AND a952~datbi    GE is_tkomk-prsdt
      AND a952~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  IF sy-subrc IS INITIAL.
    IF lv_valid_pltyp IS NOT INITIAL.
      DELETE lt_a952pltyp WHERE pltyp NE lv_valid_pltyp.
    ENDIF.
    IF lt_a952pltyp IS NOT INITIAL.
      SELECT pltyp matnr
        FROM a910
        INNER JOIN konp ON konp~knumh = a910~knumh
                       AND konp~kschl = a910~kschl
        INTO CORRESPONDING FIELDS OF TABLE lt_a910
        FOR ALL ENTRIES IN lt_a952pltyp
        WHERE a910~kappl    EQ 'V'
          AND a910~kschl    EQ 'ZF04'
          AND a910~vkorg    EQ is_tkomk-vkorg
          AND a910~vtweg    EQ is_tkomk-vtweg
          AND a910~pltyp    EQ lt_a952pltyp-pltyp
         "--------->>Anıl CENGİZ 12.11.2021 09:11:42
         "YUR-808
*            AND a910~matnr    EQ cs_tkomp-matnr
          AND a910~matnr    IN ltrng_matnr
          "---------<<
          AND a910~datbi    GE is_tkomk-prsdt
          AND a910~datab    LE is_tkomk-prsdt
          AND konp~loevm_ko EQ abap_false.
      DESCRIBE TABLE lt_a910.
      IF sy-tfill EQ 1.
        lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
        cs_tkomp-zzpr952 = lt_a952pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
        cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
      ELSEIF sy-tfill GT 1.
        "Geçerli birden fazla fiyat bulunmaktadır.
        MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT zzprsdt pltyp
      FROM a942
      INNER JOIN konp ON konp~knumh = a942~knumh
                     AND konp~kschl = a942~kschl
      INTO CORRESPONDING FIELDS OF TABLE lt_a942pltyp
      WHERE a942~kappl    EQ 'V'
        AND a942~kschl    EQ 'ZI06'
        AND a942~knuma_ag EQ cs_tkomp-knuma_ag
        AND a942~vkorg    EQ is_tkomk-vkorg
        AND a942~vtweg    EQ is_tkomk-vtweg
        AND a942~zzprsdt  NE '00000000'
        AND a942~zzlgort  EQ cs_tkomp-zzlgort
        AND a942~extwg    EQ cs_tkomp-extwg
        AND a942~datbi    GE is_tkomk-prsdt
        AND a942~datab    LE is_tkomk-prsdt
        AND konp~loevm_ko EQ abap_false.
    IF sy-subrc IS INITIAL.
      IF lv_valid_pltyp IS NOT INITIAL.
        DELETE lt_a942pltyp WHERE pltyp NE lv_valid_pltyp.
      ENDIF.
      IF lt_a942pltyp IS NOT INITIAL.
        SELECT pltyp matnr
          FROM a910
          INNER JOIN konp ON konp~knumh = a910~knumh
                         AND konp~kschl = a910~kschl
          INTO CORRESPONDING FIELDS OF TABLE lt_a910
          FOR ALL ENTRIES IN lt_a942pltyp
          WHERE a910~kappl    EQ 'V'
            AND a910~kschl    EQ 'ZF04'
            AND a910~vkorg    EQ is_tkomk-vkorg
            AND a910~vtweg    EQ is_tkomk-vtweg
            AND a910~pltyp    EQ lt_a942pltyp-pltyp
            AND a910~matnr    IN ltrng_matnr
            AND a910~datbi    GE is_tkomk-prsdt
            AND a910~datab    LE is_tkomk-prsdt
            AND konp~loevm_ko EQ abap_false.
        DESCRIBE TABLE lt_a910.
        IF sy-tfill EQ 1.
          lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
          cs_tkomp-zzpr942 = lt_a942pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
          cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
        ELSEIF sy-tfill GT 1.
          "Geçerli birden fazla fiyat bulunmaktadır.
          MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  "---------<< ZI06

  "--------->> Sırayla bakılır *ZI04  Bayi İskontosu(%) 940
*                               ZI04  Bayi İskontosu(%) 934
  SELECT zzprsdt pltyp
    FROM a940
    INNER JOIN konp ON konp~knumh = a940~knumh
                   AND konp~kschl = a940~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a940pltyp
    WHERE a940~kappl    EQ 'V'
      AND a940~kschl    EQ 'ZI04'
      AND a940~knuma_ag EQ cs_tkomp-knuma_ag
      AND a940~vkorg    EQ is_tkomk-vkorg
      AND a940~vtweg    EQ is_tkomk-vtweg
      AND a940~zzprsdt  NE '00000000'
      AND a940~kunag    EQ is_tkomk-kunnr
      AND a940~extwg    EQ cs_tkomp-extwg
      AND a940~datbi    GE is_tkomk-prsdt
      AND a940~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  IF sy-subrc EQ 0.
    IF lv_valid_pltyp IS NOT INITIAL.
      DELETE lt_a940pltyp WHERE pltyp NE lv_valid_pltyp.
    ENDIF.
    IF lt_a940pltyp IS NOT INITIAL.
      SELECT pltyp matnr
        FROM a910
        INNER JOIN konp ON konp~knumh = a910~knumh
                       AND konp~kschl = a910~kschl
        INTO CORRESPONDING FIELDS OF TABLE lt_a910
        FOR ALL ENTRIES IN lt_a940pltyp
        WHERE a910~kappl    EQ 'V'
          AND a910~kschl    EQ 'ZF04'
          AND a910~vkorg    EQ is_tkomk-vkorg
          AND a910~vtweg    EQ is_tkomk-vtweg
          AND a910~pltyp    EQ lt_a940pltyp-pltyp
          AND a910~matnr    IN ltrng_matnr
          AND a910~datbi    GE is_tkomk-prsdt
          AND a910~datab    LE is_tkomk-prsdt
          AND konp~loevm_ko EQ abap_false.
      DESCRIBE TABLE lt_a910.
      IF sy-tfill EQ 1.
        lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
        cs_tkomp-zzpr940 = lt_a940pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
        cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
      ELSEIF sy-tfill GT 1.
        "Geçerli birden fazla fiyat bulunmaktadır.
        MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT zzprsdt pltyp
      FROM a934
      INNER JOIN konp ON konp~knumh = a934~knumh
                     AND konp~kschl = a934~kschl
      INTO CORRESPONDING FIELDS OF TABLE lt_a934pltyp
      WHERE a934~kappl    EQ 'V'
        AND a934~kschl    EQ 'ZI04'
        AND a934~knuma_ag EQ cs_tkomp-knuma_ag
        AND a934~vkorg    EQ is_tkomk-vkorg
        AND a934~vtweg    EQ is_tkomk-vtweg
        AND a934~zzprsdt  NE '00000000'
        AND a934~kunag    EQ is_tkomk-kunnr
        AND a934~datbi    GE is_tkomk-prsdt
        AND a934~datab    LE is_tkomk-prsdt
        AND konp~loevm_ko EQ abap_false.
    IF sy-subrc EQ 0.
      IF lv_valid_pltyp IS NOT INITIAL.
        DELETE lt_a934pltyp WHERE pltyp NE lv_valid_pltyp.
      ENDIF.
      IF lt_a934pltyp IS NOT INITIAL.
        SELECT pltyp matnr
          FROM a910
          INNER JOIN konp ON konp~knumh = a910~knumh
                         AND konp~kschl = a910~kschl
          INTO CORRESPONDING FIELDS OF TABLE lt_a910
          FOR ALL ENTRIES IN lt_a934pltyp
          WHERE a910~kappl    EQ 'V'
            AND a910~kschl    EQ 'ZF04'
            AND a910~vkorg    EQ is_tkomk-vkorg
            AND a910~vtweg    EQ is_tkomk-vtweg
            AND a910~pltyp    EQ lt_a934pltyp-pltyp
            AND a910~matnr    IN ltrng_matnr
            AND a910~datbi    GE is_tkomk-prsdt
            AND a910~datab    LE is_tkomk-prsdt
            AND konp~loevm_ko EQ abap_false.
        DESCRIBE TABLE lt_a910.
        IF sy-tfill EQ 1.
          lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
          cs_tkomp-zzpr934 = lt_a934pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
          cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
        ELSEIF sy-tfill GT 1.
          "Geçerli birden fazla fiyat bulunmaktadır.
          MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  "---------<< ZI04

  "--------->> Sırayla bakılır. *ZI02 Birim Başına İskonto  945
  SELECT zzprsdt pltyp
     FROM a945
     INNER JOIN konp ON konp~knumh = a945~knumh
                    AND konp~kschl = a945~kschl
     INTO CORRESPONDING FIELDS OF TABLE lt_a945pltyp
     WHERE a945~kappl    EQ 'V'
       AND a945~kschl    EQ 'ZI02'
       AND a945~knuma_ag EQ cs_tkomp-knuma_ag
       AND a945~vkorg    EQ is_tkomk-vkorg
       AND a945~vtweg    EQ is_tkomk-vtweg
       AND a945~zzprsdt  NE '00000000'
       AND a945~extwg    EQ cs_tkomp-extwg
       AND a945~datbi    GE is_tkomk-prsdt
       AND a945~datab    LE is_tkomk-prsdt
       AND konp~loevm_ko EQ abap_false.
  IF sy-subrc IS INITIAL.
    IF lv_valid_pltyp IS NOT INITIAL.
      DELETE lt_a945pltyp WHERE pltyp NE lv_valid_pltyp.
    ENDIF.
    IF lt_a945pltyp IS NOT INITIAL.
      SELECT pltyp matnr
        FROM a910
        INNER JOIN konp ON konp~knumh = a910~knumh
                       AND konp~kschl = a910~kschl
        INTO CORRESPONDING FIELDS OF TABLE lt_a910
        FOR ALL ENTRIES IN lt_a945pltyp
        WHERE a910~kappl    EQ 'V'
          AND a910~kschl    EQ 'ZF04'
          AND a910~vkorg    EQ is_tkomk-vkorg
          AND a910~vtweg    EQ is_tkomk-vtweg
          AND a910~pltyp    EQ lt_a945pltyp-pltyp
          AND a910~matnr    IN ltrng_matnr
          AND a910~datbi    GE is_tkomk-prsdt
          AND a910~datab    LE is_tkomk-prsdt
          AND konp~loevm_ko EQ abap_false.
      DESCRIBE TABLE lt_a910.
      IF sy-tfill EQ 1.
        lv_valid_pltyp = cs_tkomp-pltyp_p = lt_a910[ 1 ]-pltyp.
        cs_tkomp-zzpr945 = lt_a945pltyp[ pltyp = lv_valid_pltyp ]-zzprsdt.
        cs_vbap-zzpmatn = cs_tkomp-matnr = lt_a910[ 1 ]-matnr.
      ELSEIF sy-tfill GT 1.
        "Geçerli birden fazla fiyat bulunmaktadır.
        MESSAGE e024(zsd_va) WITH cs_tkomp-matnr.
      ENDIF.
    ENDIF.
  ENDIF.
  "---------<< ZI02
  "--------->>Anıl CENGİZ 12.18.2021 16:18:22
  "YUR-808
  IF cs_vbap-zzpmatn IS INITIAL.
    "Fiyat bulunamadı
    MESSAGE e025(zsd_va) WITH cs_tkomp-matnr.
  ENDIF.
  "---------<<
ENDMETHOD.


METHOD find_zf06.
  "--------->> Sırayla bakılır  ZF06  Pzlma.Prmsyn.Fiyatı 950 Müşteri/Malzeme
*                               ZF06  Pzlma.Prmsyn.Fiyatı 951 Malzeme
*                               ZF06  Pzlma.Prmsyn.Fiyatı 949 Ebat/Depo yeri/Satış Ölçü Birimi/Kalite
*                               ZF06  Pzlma.Prmsyn.Fiyatı 908	Müşteri/Malzeme
*                               ZF06  Pzlma.Prmsyn.Fiyatı 936	Depo yeri/Malzeme
*                               ZF06  Pzlma.Prmsyn.Fiyatı 909	Malzeme
  DATA: lt_a950    TYPE TABLE OF a950,
        lt_a951    TYPE TABLE OF a951,
        lt_a949    TYPE TABLE OF a949,
        lt_a908    TYPE TABLE OF a908,
        lt_a936    TYPE TABLE OF a936,
        lt_a909    TYPE TABLE OF a909,
        lv_zzpmatn TYPE pmatn.
  "--------->> Anıl CENGİZ 08.02.2021 17:05:17
  "YUR-840
*  CHECK: check_extwg_zf06( cs_tkomp-pmatn ) EQ abap_true.
  check_extwg_zf06( cs_tkomp-pmatn ).
  SPLIT cs_tkomp-pmatn AT '.' INTO DATA(lv_matnr) DATA(lv_kalite).
  "---------<<

  "--------->>Anıl CENGİZ 12.05.2021 09:05:52
  "YUR-808
  IF iv_return EQ abap_false.
    "--------->> Anıl CENGİZ 08.02.2021 17:20:32
    "YUR-840
*    SPLIT cs_tkomp-pmatn AT '.' INTO DATA(lv_matnr) DATA(lv_kalite).
*    APPEND VALUE #( sign   = 'I'
*                    option = 'CP'
*                    low    = |{ lv_matnr }*| ) TO ctrng_matnr.

    ctrng_matnr = VALUE #( ( sign = 'I' option = 'EQ' low = cs_tkomp-pmatn ) ).
    LOOP AT gt_extwg_zf06 REFERENCE INTO DATA(gr_extwg_zf06)
      WHERE fytkalite EQ lv_kalite.
      DATA(lv_matnr1) = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
      APPEND VALUE #( sign   = 'I'
                      option = 'EQ'
                      low    = lv_matnr1 ) TO ctrng_matnr.
    ENDLOOP.
    "---------<<
  ELSE.
    "--------->> Anıl CENGİZ 08.02.2021 17:28:49
    "YUR-840
*    DELETE ctrng_matnr WHERE sign EQ 'I'
*                         AND option EQ 'CP'.
    LOOP AT gt_extwg_zf06 REFERENCE INTO gr_extwg_zf06
      WHERE fytkalite EQ lv_kalite.
      lv_matnr1 = |{ lv_matnr }.{ gr_extwg_zf06->gecerlikalite }|.
      DELETE ctrng_matnr WHERE sign   EQ 'I'
                           AND option EQ 'EQ'
                           AND low    EQ lv_matnr1.
    ENDLOOP.
    "---------<<
    IF sy-subrc EQ 0.
      APPEND VALUE #( sign   = 'I'
                      option = 'EQ'
                      low    = cs_vbap-matnr ) TO ctrng_matnr.
    ELSE.
      APPEND VALUE #( sign   = 'I'
                      option = 'EQ'
                      low    = cs_tkomp-pmatn ) TO ctrng_matnr.
    ENDIF.
  ENDIF.
  "---------<<
  SELECT zzprsdt matnr
    FROM a950
    INNER JOIN konp ON konp~knumh = a950~knumh
                   AND konp~kschl = a950~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a950
    WHERE a950~kappl    EQ 'V'
      AND a950~kschl    EQ 'ZF06'
      AND a950~knuma_ag EQ cs_tkomp-knuma_ag
      AND a950~vkorg    EQ is_tkomk-vkorg
      AND a950~vtweg    EQ is_tkomk-vtweg
      AND a950~zzprsdt  NE '00000000'
      AND a950~kunnr    EQ is_tkomk-kunnr
      AND a950~matnr    IN ctrng_matnr
      AND a950~datbi    GE is_tkomk-prsdt
      AND a950~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  DESCRIBE TABLE lt_a950.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_matnr_to_be_checked = lt_a950[ 1 ]-matnr
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_tkomp-zzpr950 = lt_a950[ 1 ]-zzprsdt.
      cs_vbap-zzpmatn = lv_zzpmatn = cs_tkomp-pmatn = lt_a950[ 1 ]-matnr.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

  CHECK: lv_zzpmatn IS INITIAL.
  SELECT zzprsdt matnr
    FROM a951
    INNER JOIN konp ON konp~knumh = a951~knumh
                   AND konp~kschl = a951~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a951
    WHERE a951~kappl    EQ 'V'
      AND a951~kschl    EQ 'ZF06'
      AND a951~knuma_ag EQ cs_tkomp-knuma_ag
      AND a951~vkorg    EQ is_tkomk-vkorg
      AND a951~vtweg    EQ is_tkomk-vtweg
      AND a951~zzprsdt  NE '00000000'
      AND a951~matnr    IN ctrng_matnr
      AND a951~datbi    GE is_tkomk-prsdt
      AND a951~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  DESCRIBE TABLE lt_a951.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_matnr_to_be_checked = lt_a951[ 1 ]-matnr
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_tkomp-zzpr951 = lt_a951[ 1 ]-zzprsdt.
      cs_vbap-zzpmatn = lv_zzpmatn = cs_tkomp-pmatn = lt_a951[ 1 ]-matnr.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

  CHECK: lv_zzpmatn IS INITIAL.
  SELECT zzprsdt extwg
    FROM a949
    INNER JOIN konp ON konp~knumh = a949~knumh
                   AND konp~kschl = a949~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a949
    WHERE a949~kappl    EQ 'V'
      AND a949~kschl    EQ 'ZF06'
      AND a949~knuma_ag EQ cs_tkomp-knuma_ag
      AND a949~vkorg    EQ is_tkomk-vkorg
      AND a949~vtweg    EQ is_tkomk-vtweg
      AND a949~zzprsdt  NE '00000000'
      AND a949~zzebat   EQ cs_tkomp-zzebat
      AND a949~zzlgort  EQ cs_tkomp-zzlgort
      AND a949~vrkme    EQ cs_tkomp-vrkme
      AND a949~extwg    EQ cs_tkomp-extwg
      AND a949~datbi    GE is_tkomk-prsdt
      AND a949~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_extwg_to_be_checked = lt_a949[ 1 ]-extwg
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_tkomp-zzpr949 = lt_a949[ 1 ]-zzprsdt.
      cs_vbap-zzextwg  = cs_tkomp-extwg = lt_a949[ 1 ]-extwg.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

  CHECK: cs_vbap-zzextwg IS INITIAL.
  SELECT matnr
    FROM a908
    INNER JOIN konp ON konp~knumh = a908~knumh
                   AND konp~kschl = a908~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a908
    WHERE a908~kappl    EQ 'V'
      AND a908~kschl    EQ 'ZF06'
      AND a908~vkorg    EQ is_tkomk-vkorg
      AND a908~vtweg    EQ is_tkomk-vtweg
      AND a908~kunnr    EQ is_tkomk-kunnr
      AND a908~matnr    IN ctrng_matnr
      AND a908~datbi    GE is_tkomk-prsdt
      AND a908~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  DESCRIBE TABLE lt_a908.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_matnr_to_be_checked = lt_a908[ 1 ]-matnr
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_vbap-zzpmatn = lv_zzpmatn = cs_tkomp-pmatn = lt_a908[ 1 ]-matnr.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

  CHECK: lv_zzpmatn IS INITIAL.
  SELECT matnr
    FROM a936
    INNER JOIN konp ON konp~knumh = a936~knumh
                   AND konp~kschl = a936~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a936
    WHERE a936~kappl    EQ 'V'
      AND a936~kschl    EQ 'ZF06'
      AND a936~vkorg    EQ is_tkomk-vkorg
      AND a936~vtweg    EQ is_tkomk-vtweg
      AND a936~zzlgort  EQ cs_tkomp-zzlgort
      AND a936~matnr    IN ctrng_matnr
      AND a936~datbi    GE is_tkomk-prsdt
      AND a936~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  DESCRIBE TABLE lt_a936.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_matnr_to_be_checked = lt_a936[ 1 ]-matnr
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_vbap-zzpmatn = lv_zzpmatn = cs_tkomp-pmatn = lt_a936[ 1 ]-matnr.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

  CHECK: lv_zzpmatn IS INITIAL.
  SELECT matnr
    FROM a909
    INNER JOIN konp ON konp~knumh = a909~knumh
                   AND konp~kschl = a909~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_a909
    WHERE a909~kappl    EQ 'V'
      AND a909~kschl    EQ 'ZF06'
      AND a909~vkorg    EQ is_tkomk-vkorg
      AND a909~vtweg    EQ is_tkomk-vtweg
      AND a909~matnr    IN ctrng_matnr
      AND a909~datbi    GE is_tkomk-prsdt
      AND a909~datab    LE is_tkomk-prsdt
      AND konp~loevm_ko EQ abap_false.
  DESCRIBE TABLE lt_a909.
  IF sy-tfill EQ 1.
    IF check_zf06( EXPORTING is_tkomk               = is_tkomk
                             iv_matnr_to_be_checked = lt_a909[ 1 ]-matnr
                    CHANGING cs_tkomp               = cs_tkomp
                             cs_vbap                = cs_vbap
                             ctrng_matnr            = ctrng_matnr ) EQ abap_false.
      cs_vbap-zzpmatn = lv_zzpmatn = cs_tkomp-pmatn = lt_a909[ 1 ]-matnr.
    ELSE.
      find_zf06( EXPORTING is_tkomk    = is_tkomk
                           iv_return   = abap_true
                 CHANGING  cs_tkomp    = cs_tkomp
                           cs_vbap     = cs_vbap
                           ctrng_matnr = ctrng_matnr ).
    ENDIF.
  ELSEIF sy-tfill GT 1.
    "Geçerli birden fazla fiyat bulunmaktadır.
    MESSAGE e024(zsd_va) WITH cs_tkomp-pmatn.
  ENDIF.

*  IF cs_vbap-zzpmatn IS INITIAL.
*    "Fiyat bulunamadı
*    MESSAGE e025(zsd_va) WITH cs_tkomp-pmatn.
*  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_tkomp> TYPE komp,
                 <gs_tkomk> TYPE komk,
                 <gs_t180>  TYPE t180,
                 <gs_vbap>  TYPE vbap.

  DATA: lr_data     TYPE REF TO data,
        l_tvak      TYPE tvak,
        l_kschl     TYPE t6b2f-kschl,
        l_kobog     TYPE t6b1-kobog,
        l_boart     TYPE kona-boart,
        ltrng_matnr TYPE ttrng_matnr.

  lr_data = co_con->get_vars( 'TKOMP' ). ASSIGN lr_data->* TO <gs_tkomp>.
  lr_data = co_con->get_vars( 'TKOMK' ). ASSIGN lr_data->* TO <gs_tkomk>.
  lr_data = co_con->get_vars( 'T180' ).  ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'VBAP' ).  ASSIGN lr_data->* TO <gs_vbap>.

  CHECK: <gs_t180>-trtyp NE 'A',
         <gs_tkomp>-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm,
         <gs_tkomp>-knuma_ag IS NOT INITIAL,
         "--------->> Anıl CENGİZ 10.08.2020 15:33:46
         "YUR-706
         zcl_sd_mv45afzz_frm_mvflvp_002=>check_boart( <gs_tkomp>-knuma_ag ) EQ abap_false. "Bedelsiz değil ise aşağıdaki kontrole girer.
  "---------<<
  SELECT SINGLE * FROM tvak INTO l_tvak WHERE auart = <gs_tkomk>-auart.

  CHECK: l_tvak-kalvg = '3' OR
         l_tvak-kalvg = '4' OR
         l_tvak-kalvg = '5' OR
         l_tvak-kalvg = '6'.

  SELECT SINGLE boart FROM kona INTO l_boart WHERE knuma = <gs_tkomp>-knuma_ag.
  IF sy-subrc <> 0.
    MESSAGE e023(zsd_va) WITH <gs_tkomp>-knuma_ag.
  ENDIF.
  SELECT SINGLE kobog FROM t6b1 INTO l_kobog WHERE boart = l_boart.
  IF sy-subrc <> 0.
    MESSAGE e021(zsd_va).
  ENDIF.
  "--------->> Anıl CENGİZ 22.12.2020 16:05:28
  "YUR-796
  find_zf04( EXPORTING is_tkomk    = <gs_tkomk>
             CHANGING  cs_tkomp    = <gs_tkomp>
                       cs_vbap     = <gs_vbap> ).
  "---------<<
  "--------->>Anıl CENGİZ 12.05.2021 09:05:52
  "YUR-808
  find_zf06( EXPORTING is_tkomk    = <gs_tkomk>
                       iv_return   = abap_false
             CHANGING  cs_tkomp    = <gs_tkomp>
                       cs_vbap     = <gs_vbap> ).
  "---------<<
ENDMETHOD.
ENDCLASS.
