FUNCTION zyb_sd_f_convert_to_alt_uom.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PLT_TAM) TYPE  XFELD OPTIONAL
*"     VALUE(P_ALT_UOM) TYPE  MARM-MEINH
*"     VALUE(P_CUR_QTY) TYPE  EKPO-MENGE OPTIONAL
*"     VALUE(P_UOM_QTY) TYPE  MENGE_D OPTIONAL
*"     VALUE(P_MATNR) TYPE  MATNR
*"     VALUE(P_MVGR1) TYPE  MVGR1 OPTIONAL
*"     VALUE(P_MVGR2) TYPE  MVGR2 OPTIONAL
*"     VALUE(P_DATUM) TYPE  DATUM OPTIONAL
*"  EXPORTING
*"     VALUE(EP_ALT_QTY) TYPE  EKPO-MENGE
*"     VALUE(EP_UOM_QTY) TYPE  EKPO-MENGE
*"     VALUE(EP_UOM) TYPE  MEINS
*"  EXCEPTIONS
*"      UNIT_NOT_FOUND
*"      FORMAT_ERROR
*"      UOM_NOT_CONSISTENT
*"      OBLIGATORY
*"      TYPE_NOT_CONSISTENT
*"      NOT_CONVERTIBLE_MATERIAL
*"      NOT_CUSTOMIZE_MATERIAL
*"      EMPTY_PALET
*"----------------------------------------------------------------------
*& Temel ölçü biriminden miktarı
*& palet ve kutu ölçü birimlerine dönüştürür.
*& 0205 kuralı bir üst tam sayıya yuvarlar. Diğer yuvarlama kuralları
*& için TVFRDRX tablosuna bakılabilir.
*"----------------------------------------------------------------------
  DATA: lv_factor  TYPE  f,
        lv_cur_qty TYPE  f,
        lv_alt_qty TYPE  f.

  DATA: lv_typ(1)    TYPE c,
        lv_pal       TYPE i,
        ls_kut       LIKE zyb_t_md001,
        ls_pal       LIKE zyb_t_md001,
        lv_matnr_amb TYPE matnr.
  DATA : lt_marm LIKE TABLE OF marm WITH HEADER LINE,
         lt_msc  LIKE TABLE OF rdpr WITH HEADER LINE.

  DATA: lv_kut_say TYPE menge_d,
        lv_kut_adt TYPE menge_d,
        lv_kut_m2  TYPE menge_d,
        lv_pal_m2  TYPE menge_d,
        lv_qty     TYPE menge_d.

  CLEAR : lt_msc[], lt_msc, lt_marm[], lt_marm, lv_pal, ws_c_mara,
          ws_c_cf, rt_code, lv_factor, lv_matnr_amb.

  SELECT * FROM marm INTO TABLE lt_marm WHERE matnr = p_matnr.
  LOOP AT lt_marm.
    lt_marm-brgew = lt_marm-umrez / lt_marm-umren.
    MODIFY lt_marm INDEX sy-tabix.
  ENDLOOP.
  SORT lt_marm BY brgew.
  READ TABLE lt_marm WITH KEY meinh = 'PAL'.
  IF sy-subrc = 0.
    lv_pal = sy-tabix.
  ENDIF.
  IF p_datum IS INITIAL OR p_datum = '00000000'.
    p_datum = sy-datum.
  ENDIF.
* Kontroller
  IF NOT p_cur_qty IS INITIAL AND NOT p_uom_qty IS INITIAL.
    MESSAGE e899(fb)
        WITH 'Palet/Kutu miktarı veya m2/adt miktarından biri girilebilir'
        RAISING obligatory.
  ELSEIF  p_cur_qty IS INITIAL AND p_uom_qty IS INITIAL.
    MESSAGE e899(fb)
        WITH 'Palet/Kutu miktarı veya m2/adt miktarı eksik'
        RAISING obligatory.
  ENDIF.


  SELECT SINGLE * FROM mara WHERE matnr = p_matnr.
  IF plt_tam = 'X'.
    IF p_alt_uom NE mara-meins AND p_alt_uom NE 'PAL'.
      MESSAGE e899(fb) WITH 'Tam palette ÖB, temel ölçü birimi yada PAL olmalıdır' mara-meins p_matnr
                       RAISING uom_not_consistent.
      CHECK 1 = 2.
    ENDIF.
    IF p_mvgr1 IS INITIAL OR p_mvgr2 IS INITIAL.
      MESSAGE e899(fb) WITH 'Tam palette palet ve kutu tipi boş olmamalıdır' p_matnr
                       RAISING obligatory.
    ENDIF.
*    IF p_alt_uom NE 'PAL'.
*      MESSAGE e899(fb) WITH 'Tam palette ÖB Palet olmalıdır.'
*                       RAISING obligatory.
*    ENDIF.
  ELSE.
    IF p_mvgr1 IS NOT INITIAL.
      MESSAGE e899(fb) WITH 'Yarım palet çevrimlerinde, palet tipi girilemez.' p_matnr
                     RAISING empty_palet.
    ENDIF.
    READ TABLE lt_marm WITH KEY meinh = p_alt_uom.
    IF sy-tabix >= lv_pal AND lv_pal <> 0.
      MESSAGE e899(fb) WITH 'Yarım palette PAL ve üstü ölçü birimi kullanılamaz' p_matnr
                     RAISING uom_not_consistent.
      CHECK 1 = 2.
    ENDIF.
    IF p_mvgr2 IS INITIAL AND p_alt_uom NE 'ST'. "mara-meins.
      MESSAGE e899(fb) WITH 'Yarım palette kutu boş ise ÖB, adet olmalıdır' p_matnr
                            mara-meins
                    RAISING uom_not_consistent.
    ENDIF.
  ENDIF.
  IF p_alt_uom NE mara-meins AND p_alt_uom NE 'PAL' AND p_alt_uom NE 'KUT'
  AND plt_tam = 'X'.
    MESSAGE e899(fb) WITH 'İstenen ÖB uygun değildir.' p_matnr
                  RAISING uom_not_consistent.
  ENDIF.


  IF p_mvgr1 IS NOT INITIAL.
    CLEAR tvm1.
    SELECT SINGLE * FROM tvm1 WHERE mvgr1 = p_mvgr1.
    IF sy-subrc NE 0.
      MESSAGE e899(fb) WITH 'Girilen Palet tipi yanlış' p_matnr
                      RAISING type_not_consistent.
    ENDIF.
  ENDIF.
  IF p_mvgr2 IS NOT INITIAL.
    CLEAR tvm2.
    SELECT SINGLE * FROM tvm2 WHERE mvgr2 = p_mvgr2.
    IF sy-subrc NE 0.
      MESSAGE e899(fb) WITH 'Girilen Kutu tipi yanlış' p_matnr
                      RAISING type_not_consistent.
    ENDIF.
  ENDIF.

* Hesaplamalar
  ep_uom = mara-meins.
  IF plt_tam = ''.
    IF p_mvgr2 IS INITIAL.
      ep_alt_qty = p_cur_qty.
* palet ve kutu dönüşümleri malzeme anaverisine tanımlandığı için yıldızlanmıştır.
*      PERFORM mat_conv USING p_matnr p_cur_qty p_alt_uom mara-meins
*                    CHANGING ep_uom_qty.
*      CHECK 1 = 2.
    ELSE.
      CLEAR ls_kut.
      SELECT SINGLE * FROM zyb_t_md001 INTO ls_kut
              WHERE bkmtp = p_alt_uom "'KUT'
                AND matnr = p_matnr
                AND mvgr1 = ''
                AND mvgr2 = p_mvgr2
                AND begda <= p_datum
                AND endda >= p_datum.
      IF sy-subrc NE 0.
        MESSAGE e899(fb) WITH 'Bu malzemenin kutu tipinde bakımı yok' p_matnr p_mvgr2
                    RAISING not_customize_material.
        CHECK 1 = 2.
      ENDIF.

      IF NOT p_cur_qty IS INITIAL.
        ep_alt_qty = p_cur_qty * ( ls_kut-umrez / ls_kut-umren ).  "adt
*      PERFORM mat_conv USING p_matnr p_cur_qty ls_kut-meins p_alt_uom
*                    CHANGING p_cur_qty.

*-----> Aşağıdaki kutu m2 hesaplaması 1 kutuya göre çalışması için kapatıldı
*        PERFORM mat_conv USING p_matnr ep_alt_qty ls_kut-meins mara-meins
*                      CHANGING ep_uom_qty.
*------<---------

* 1 kutu m2 si hesaplanır yuvarlama yapılır.
* ardından girilen miktar ile kutunun m2 hesaplama yapılır
        DATA: lv_kutm2  TYPE menge_d,
              lv_kutadt TYPE menge_d.
        CLEAR lv_kutm2.
        lv_kutadt = ( ls_kut-umrez / ls_kut-umren ).  "adt
        PERFORM mat_conv USING p_matnr lv_kutadt ls_kut-meins mara-meins
                      CHANGING lv_kutm2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.

        PERFORM yuvarlama CHANGING lv_kutm2.
        ep_uom_qty = lv_kutm2 * p_cur_qty.
*        DATA: lv_qty TYPE menge_d.
*        CLEAR lv_qty.
*    CLEAR lv_ondalik.
*
*        IF sy-subrc = 0.
**-- Rounding Off
*          lv_ondalik = frac( ep_uom_qty ).
*        ENDIF.
*
*        DATA: lv_ondalik_c(10) TYPE c,
*              gc_base_c(10)    TYPE c.
*
*        CLEAR: lv_ondalik_c, gc_base_c.
*        WRITE lv_ondalik TO lv_ondalik_c. CONDENSE lv_ondalik_c.
*        WRITE gc_base    TO gc_base_c.    CONDENSE gc_base_c.
*
*        CLEAR lv_qty.
*        IF lv_ondalik NE 0.
*          IF lv_ondalik_c+4(1) GE gc_base_c+4(1).
*            PERFORM rounding USING '+' " Yukarı Yuvarlama tabanı 0,00500
*                                   gc_base
*                                   ep_uom_qty
*                          CHANGING lv_qty.
*          ELSE.
*            PERFORM rounding USING '-' " Aşağı Yuvarlama tabanı 0,00500
*                                   gc_base
*                                   ep_uom_qty
*                          CHANGING lv_qty.
*          ENDIF.
*          ep_uom_qty = lv_qty.
*        ENDIF.
      ENDIF.

      DATA: lv_auom_qty TYPE menge_d.
      CLEAR lv_auom_qty.

      IF NOT p_uom_qty IS INITIAL.
* malzeme anaverisinde kutu dönüşümleri verildiği için kapatıldı.
*        IF ls_kut-meins NE mara-meins.
*          PERFORM mat_conv USING p_matnr p_uom_qty mara-meins ls_kut-meins
*                        CHANGING lv_auom_qty.
*        ELSE.
*          lv_auom_qty = p_uom_qty.
*        ENDIF.
        lv_auom_qty = p_uom_qty.
        IF ls_kut-umren GT 0 AND ls_kut-umrez GT 0.

* Kutudaki adet sayısı
          CLEAR lv_kut_adt.
          lv_kut_adt = ( ls_kut-umrez / ls_kut-umren ).

* 1 Kutudaki m2
          CLEAR lv_kut_m2.
          PERFORM mat_conv USING p_matnr lv_kut_adt ls_kut-meins mara-meins
                        CHANGING lv_kut_m2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.
          CLEAR lv_qty.
          PERFORM yuvarlama CHANGING lv_kut_m2.
          lv_qty = lv_kut_m2.
          IF lv_qty GT 0.
            ep_alt_qty = lv_auom_qty / lv_qty.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
* palet bilgileri
    CLEAR ls_pal.
    SELECT SINGLE * FROM zyb_t_md001 INTO ls_pal
          WHERE bkmtp = 'PAL'
            AND matnr = p_matnr
            AND mvgr1 = p_mvgr1
            AND mvgr2 = p_mvgr2
            AND begda <= p_datum
            AND endda >= p_datum.
    IF sy-subrc NE 0.
      MESSAGE e899(fb) WITH 'Bu malzemenin palet tipinde bakımı yok' p_matnr p_mvgr1 p_mvgr2
                  RAISING not_customize_material.
    ENDIF.

* kutu bilgileri
    CLEAR ls_kut.
    SELECT SINGLE * FROM zyb_t_md001 INTO ls_kut
              WHERE bkmtp = ls_pal-meins "'KUT'
                AND matnr = p_matnr
                AND mvgr1 = '' "p_mvgr1
                AND mvgr2 = p_mvgr2
                AND begda <= p_datum
                AND endda >= p_datum.
    IF sy-subrc NE 0.
      MESSAGE e899(fb) WITH 'Bu malzemenin kutu tipinde bakımı yok' p_matnr p_mvgr2
                  RAISING not_customize_material.
      CHECK 1 = 2.
    ENDIF.

    IF p_alt_uom = mara-meins.
      ep_alt_qty = ( ls_kut-umrez / ls_kut-umren ) * ( ls_pal-umrez / ls_pal-umren ) .
      PERFORM mat_conv USING p_matnr ep_alt_qty ls_kut-meins mara-meins
                    CHANGING ep_uom_qty.

      lt_msc-werks = '1000'.
      lt_msc-bdmng = 0.
      lt_msc-vormg = ep_uom_qty.
      APPEND lt_msc.
      CALL FUNCTION 'ZCHECK_ROUNDING_PROFILE'
        EXPORTING
          plant             = '1000'
          profile           = 'YUV'
          quantity_in       = p_cur_qty
        IMPORTING
          quantity_out      = ep_uom_qty
        TABLES
          irdpr             = lt_msc
        EXCEPTIONS
          profile_not_found = 1
          OTHERS            = 2.
      IF sy-subrc NE 0.
        MESSAGE e899(fb) WITH 'Yuvarlama hatası'
                     RAISING format_error.
      ENDIF.
      CLEAR ep_alt_qty.
    ELSE.

      IF NOT p_cur_qty IS INITIAL.

* Paletteki Kutu Sayısı
        CLEAR: lv_kut_say.
        lv_kut_say = p_cur_qty * ( ls_pal-umrez / ls_pal-umren ).

* Kutudaki adet sayısı
        CLEAR lv_kut_adt.
        IF ls_kut-umren gt 0.
        lv_kut_adt = ( ls_kut-umrez / ls_kut-umren ).
        ENDIF.


* 1 Kutudaki m2
        CLEAR lv_kut_m2.
        PERFORM mat_conv USING p_matnr lv_kut_adt ls_kut-meins mara-meins
                      CHANGING lv_kut_m2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.

        PERFORM yuvarlama CHANGING lv_kut_m2.
        lv_qty = lv_kut_m2.

*        CLEAR lv_ondalik.
*
*        IF sy-subrc = 0.
**-- Rounding Off
*          lv_ondalik = frac( lv_kut_m2 ).
*        ENDIF.
*
*        CLEAR: lv_ondalik_c, gc_base_c.
*        WRITE lv_ondalik TO lv_ondalik_c. CONDENSE lv_ondalik_c.
*        WRITE gc_base    TO gc_base_c.    CONDENSE gc_base_c.
*
*
*        CLEAR lv_qty.
*        IF lv_ondalik NE 0.
*          IF lv_ondalik_c+4(1) GE gc_base_c+4(1).
*            PERFORM rounding USING '+' " Yukarı Yuvarlama tabanı 0,00500
*                                   gc_base
*                                   lv_kut_m2
*                          CHANGING lv_qty.
*          ELSE.
*            PERFORM rounding USING '-' " Aşağı Yuvarlama tabanı 0,00500
*                                   gc_base
*                                   lv_kut_m2
*                          CHANGING lv_qty.
*          ENDIF.
*        ELSE.
*          lv_qty = lv_kut_m2.
*        ENDIF.

* Paletteki m2
        ep_uom_qty = lv_qty * lv_kut_say.
        IF ls_kut-umren gt 0 AND ls_pal-umrez gt 0.
        ep_alt_qty = p_cur_qty * ( ls_kut-umrez / ls_kut-umren ) * ( ls_pal-umrez / ls_pal-umren ) .
        ENDIF.
*    PERFORM mat_conv USING p_matnr p_cur_qty ls_kut-meins p_alt_uom
*                  CHANGING p_cur_qty.
*        PERFORM mat_conv USING p_matnr ep_alt_qty ls_kut-meins mara-meins
*                      CHANGING ep_uom_qty.
      ENDIF.

      IF NOT p_uom_qty IS INITIAL.
        IF ls_kut-umrez GT 0 AND
           ls_kut-umren GT 0 AND
           ls_pal-umrez GT 0 AND
           ls_pal-umren GT 0.

* Paletteki Kutu Sayısı
          CLEAR: lv_kut_say.
          lv_kut_say = 1 * ( ls_pal-umrez / ls_pal-umren ).

* Kutudaki adet sayısı
          CLEAR lv_kut_adt.
          lv_kut_adt = ( ls_kut-umrez / ls_kut-umren ).

* 1 Kutudaki m2
          CLEAR lv_kut_m2.
          PERFORM mat_conv USING p_matnr lv_kut_adt ls_kut-meins mara-meins
                        CHANGING lv_kut_m2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.
          CLEAR lv_qty.
          PERFORM yuvarlama CHANGING lv_kut_m2.
          lv_qty = lv_kut_m2.

* 1 Paletteki m2
          lv_pal_m2 = lv_qty * lv_kut_say.

          ep_alt_qty = p_uom_qty / lv_pal_m2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

** bir adet için dönüşüm ile birden fazla dönüşümde yuvarlama farkı oluşuyor
*    PERFORM rounding_with_rule  USING  '0200'
*                             CHANGING ep_uom_qty.
ENDFUNCTION.
