FUNCTION ZYB_SD_F_CONVERT_TO_ALT_UOM_MM.
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
  DATA: LV_FACTOR  TYPE  F,
        LV_CUR_QTY TYPE  F,
        LV_ALT_QTY TYPE  F.

  DATA: LV_TYP(1)    TYPE C,
        LV_PAL       TYPE I,
        LS_KUT       LIKE ZYB_T_MD001,
        LS_PAL       LIKE ZYB_T_MD001,
        LV_MATNR_AMB TYPE MATNR.
  DATA:   LT_MSC  LIKE TABLE OF RDPR WITH HEADER LINE.

  DATA: LV_KUT_SAY TYPE MENGE_D,
        LV_KUT_ADT TYPE MENGE_D,
        LV_KUT_M2  TYPE MENGE_D,
        LV_PAL_M2  TYPE MENGE_D,
        LV_QTY     TYPE MENGE_D.

  CLEAR : LT_MSC[], LT_MSC, LV_PAL, WS_C_MARA,
          WS_C_CF, RT_CODE, LV_FACTOR, LV_MATNR_AMB.




*  SELECT SINGLE MEINS FROM MARA INTO EP_UOM WHERE MATNR = P_MATNR.
*
*  CLEAR LS_KUT.
*  SELECT SINGLE * FROM ZYB_T_MD001 INTO LS_KUT
*          WHERE BKMTP = P_ALT_UOM "'KUT'
*            AND MATNR = P_MATNR
*            AND MVGR1 = ''
*            AND MVGR2 = P_MVGR2
*            AND BEGDA <= SY-DATUM
*            AND ENDDA >= SY-DATUM.
*  IF SY-SUBRC NE 0.
*    MESSAGE E899(FB) WITH 'Bu malzemenin kutu tipinde bakımı yok'
*                RAISING NOT_CUSTOMIZE_MATERIAL.
*    CHECK 1 = 2.
*  ENDIF.
*
*  IF NOT P_CUR_QTY IS INITIAL.
*    EP_ALT_QTY = P_CUR_QTY * ( LS_KUT-UMREZ / LS_KUT-UMREN ).  "adt
**      PERFORM mat_conv USING p_matnr p_cur_qty ls_kut-meins p_alt_uom
**                    CHANGING p_cur_qty.
*    PERFORM MAT_CONV USING P_MATNR EP_ALT_QTY LS_KUT-MEINS EP_UOM
*                  CHANGING EP_UOM_QTY.
*
** kutudaki miktar dönüşümü için yuvarlama yapılır.
*
*    PERFORM YUVARLAMA CHANGING EP_UOM_QTY.
*
*
*  ENDIF.
  DATA: LV_MEINS LIKE MARA-MEINS.
  SELECT SINGLE MEINS FROM MARA INTO LV_MEINS WHERE MATNR = P_MATNR.
* Hesaplamalar
  EP_UOM = LV_MEINS.
  IF PLT_TAM = ''.
    IF P_MVGR2 IS INITIAL.
      EP_ALT_QTY = P_CUR_QTY.
    ELSE.
      CLEAR LS_KUT.
      SELECT SINGLE * FROM ZYB_T_MD001 INTO LS_KUT
              WHERE BKMTP = P_ALT_UOM "'KUT'
                AND MATNR = P_MATNR
                AND MVGR1 = ''
                AND MVGR2 = P_MVGR2
                AND BEGDA <= SY-DATUM
                AND ENDDA >= SY-DATUM.
      IF SY-SUBRC NE 0.
        MESSAGE E899(FB) WITH 'Bu malzemenin kutu tipinde bakımı yok'
                    RAISING NOT_CUSTOMIZE_MATERIAL.
        CHECK 1 = 2.
      ENDIF.

      IF NOT P_CUR_QTY IS INITIAL.
        EP_ALT_QTY = P_CUR_QTY * ( LS_KUT-UMREZ / LS_KUT-UMREN ).  "adt

        PERFORM MAT_CONV USING P_MATNR EP_ALT_QTY LS_KUT-MEINS lv_meins
                      CHANGING EP_UOM_QTY.

* kutudaki miktar dönüşümü için yuvarlama yapılır.

        PERFORM YUVARLAMA CHANGING EP_UOM_QTY.


      ENDIF.

      DATA: LV_AUOM_QTY TYPE MENGE_D.
      CLEAR LV_AUOM_QTY.

      IF NOT P_UOM_QTY IS INITIAL.

        LV_AUOM_QTY = P_UOM_QTY.
        IF LS_KUT-UMREN GT 0 AND LS_KUT-UMREZ GT 0.

* Kutudaki adet sayısı
          CLEAR LV_KUT_ADT.
          LV_KUT_ADT = ( LS_KUT-UMREZ / LS_KUT-UMREN ).

* 1 Kutudaki m2
          CLEAR LV_KUT_M2.
          PERFORM MAT_CONV USING P_MATNR LV_KUT_ADT LS_KUT-MEINS lv_meins
                        CHANGING LV_KUT_M2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.
          CLEAR LV_QTY.
          PERFORM YUVARLAMA CHANGING LV_KUT_M2.
          LV_QTY = LV_KUT_M2.
          IF LV_QTY GT 0.
            EP_ALT_QTY = LV_AUOM_QTY / LV_QTY.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
* palet bilgileri
    CLEAR LS_PAL.
    SELECT SINGLE * FROM ZYB_T_MD001 INTO LS_PAL
          WHERE BKMTP = 'PAL'
            AND MATNR = P_MATNR
            AND MVGR1 = P_MVGR1
            AND MVGR2 = P_MVGR2
            AND BEGDA <= SY-DATUM
            AND ENDDA >= SY-DATUM.
    IF SY-SUBRC NE 0.
      MESSAGE E899(FB) WITH 'Bu malzemenin palet tipinde bakımı yok'
                  RAISING NOT_CUSTOMIZE_MATERIAL.
    ENDIF.

* kutu bilgileri
    CLEAR LS_KUT.
    SELECT SINGLE * FROM ZYB_T_MD001 INTO LS_KUT
              WHERE BKMTP = LS_PAL-MEINS "'KUT'
                AND MATNR = P_MATNR
                AND MVGR1 = '' "p_mvgr1
                AND MVGR2 = P_MVGR2
                AND BEGDA <= SY-DATUM
                AND ENDDA >= SY-DATUM.
    IF SY-SUBRC NE 0.
      MESSAGE E899(FB) WITH 'Bu malzemenin kutu tipinde bakımı yok'
                  RAISING NOT_CUSTOMIZE_MATERIAL.
      CHECK 1 = 2.
    ENDIF.

    IF P_ALT_UOM = lv_meins.
      EP_ALT_QTY = ( LS_KUT-UMREZ / LS_KUT-UMREN ) * ( LS_PAL-UMREZ / LS_PAL-UMREN ) .
      PERFORM MAT_CONV USING P_MATNR EP_ALT_QTY LS_KUT-MEINS lv_meins
                    CHANGING EP_UOM_QTY.

      LT_MSC-WERKS = '1000'.
      LT_MSC-BDMNG = 0.
      LT_MSC-VORMG = EP_UOM_QTY.
      APPEND LT_MSC.
      CALL FUNCTION 'ZCHECK_ROUNDING_PROFILE'
        EXPORTING
          PLANT             = '1000'
          PROFILE           = 'YUV'
          QUANTITY_IN       = P_CUR_QTY
        IMPORTING
          QUANTITY_OUT      = EP_UOM_QTY
        TABLES
          IRDPR             = LT_MSC
        EXCEPTIONS
          PROFILE_NOT_FOUND = 1
          OTHERS            = 2.
      IF SY-SUBRC NE 0.
        MESSAGE E899(FB) WITH 'Yuvarlama hatası'
                     RAISING FORMAT_ERROR.
      ENDIF.
      CLEAR EP_ALT_QTY.
    ELSE.

      IF NOT P_CUR_QTY IS INITIAL.

* Paletteki Kutu Sayısı
        CLEAR: LV_KUT_SAY.
        LV_KUT_SAY = P_CUR_QTY * ( LS_PAL-UMREZ / LS_PAL-UMREN ).

* Kutudaki adet sayısı
        CLEAR LV_KUT_ADT.
        LV_KUT_ADT = ( LS_KUT-UMREZ / LS_KUT-UMREN ).

* 1 Kutudaki m2
        CLEAR LV_KUT_M2.
        PERFORM MAT_CONV USING P_MATNR LV_KUT_ADT LS_KUT-MEINS lv_meins
                      CHANGING LV_KUT_M2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.

        PERFORM YUVARLAMA CHANGING LV_KUT_M2.
        LV_QTY = LV_KUT_M2.


* Paletteki m2
        EP_UOM_QTY = LV_QTY * LV_KUT_SAY.
        EP_ALT_QTY = P_CUR_QTY * ( LS_KUT-UMREZ / LS_KUT-UMREN ) * ( LS_PAL-UMREZ / LS_PAL-UMREN ) .

      ENDIF.

      IF NOT P_UOM_QTY IS INITIAL.
        IF LS_KUT-UMREZ GT 0 AND
           LS_KUT-UMREN GT 0 AND
           LS_PAL-UMREZ GT 0 AND
           LS_PAL-UMREN GT 0.

* Paletteki Kutu Sayısı
          CLEAR: LV_KUT_SAY.
          LV_KUT_SAY = 1 * ( LS_PAL-UMREZ / LS_PAL-UMREN ).

* Kutudaki adet sayısı
          CLEAR LV_KUT_ADT.
          LV_KUT_ADT = ( LS_KUT-UMREZ / LS_KUT-UMREN ).

* 1 Kutudaki m2
          CLEAR LV_KUT_M2.
          PERFORM MAT_CONV USING P_MATNR LV_KUT_ADT LS_KUT-MEINS lv_meins
                        CHANGING LV_KUT_M2.

* kutudaki miktar dönüşümü için yuvarlama yapılır.
          CLEAR LV_QTY.
          PERFORM YUVARLAMA CHANGING LV_KUT_M2.
          LV_QTY = LV_KUT_M2.

* 1 Paletteki m2
          LV_PAL_M2 = LV_QTY * LV_KUT_SAY.

          EP_ALT_QTY = P_UOM_QTY / LV_PAL_M2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

** bir adet için dönüşüm ile birden fazla dönüşümde yuvarlama farkı oluşuyor
*    PERFORM rounding_with_rule  USING  '0200'
*                             CHANGING ep_uom_qty.

ENDFUNCTION.
