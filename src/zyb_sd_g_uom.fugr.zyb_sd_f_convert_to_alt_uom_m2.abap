FUNCTION ZYB_SD_F_CONVERT_TO_ALT_UOM_M2.
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
*"     REFERENCE(P_MEINS) TYPE  MEINS
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
        LV_UMREN     LIKE ZYB_T_MD001-UMREN,
        LV_UMREZ     LIKE ZYB_T_MD001-UMREZ,
        LV_KMEINS    LIKE ZYB_T_MD001-MEINS,
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


  DATA: LV_MEINS LIKE MARA-MEINS.
*  SELECT SINGLE MEINS FROM MARA INTO LV_MEINS WHERE MATNR = P_MATNR.
  LV_MEINS = P_MEINS.
* Hesaplamalar
  EP_UOM = LV_MEINS.
  IF PLT_TAM = ''.
    IF P_MVGR2 IS INITIAL.
      EP_ALT_QTY = P_CUR_QTY.
    ELSE.
      CLEAR: LV_UMREN, LV_UMREZ.
      SELECT SINGLE UMREN UMREZ MEINS FROM ZYB_T_MD001 INTO (LV_UMREN, LV_UMREZ, LV_KMEINS)
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
        EP_ALT_QTY = P_CUR_QTY * ( LV_UMREZ / LV_UMREN ).  "adt

        PERFORM MAT_CONV USING P_MATNR EP_ALT_QTY LV_KMEINS LV_MEINS
                      CHANGING EP_UOM_QTY.

* kutudaki miktar dönüşümü için yuvarlama yapılır.

        PERFORM YUVARLAMA CHANGING EP_UOM_QTY.


      ENDIF.

      DATA: LV_AUOM_QTY TYPE MENGE_D.
      CLEAR LV_AUOM_QTY.

      IF NOT P_UOM_QTY IS INITIAL.

        LV_AUOM_QTY = P_UOM_QTY.
        IF LV_UMREN GT 0 AND LV_UMREZ GT 0.

* Kutudaki adet sayısı
          CLEAR LV_KUT_ADT.
          LV_KUT_ADT = ( LV_UMREZ / LV_UMREN ).

* 1 Kutudaki m2
          CLEAR LV_KUT_M2.
          PERFORM MAT_CONV USING P_MATNR LV_KUT_ADT LV_KMEINS LV_MEINS
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

  ENDIF.


ENDFUNCTION.
