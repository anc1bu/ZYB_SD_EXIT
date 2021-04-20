FUNCTION ZYB_SD_F_UNITCONVERSION.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATNR) TYPE  MATNR
*"     REFERENCE(I_VBELN) TYPE  VBELN_VA
*"     REFERENCE(I_POSNR) TYPE  POSNR_VA
*"     REFERENCE(I_MENGE) TYPE  MENGE_D
*"  EXPORTING
*"     REFERENCE(E_MENGE) TYPE  MENGE_D
*"     REFERENCE(E_MEINS) TYPE  MEINS
*"----------------------------------------------------------------------

  DATA: LS_MARM LIKE MARM,
        LV_MENG TYPE MENGE_D,
        LV_DMEN TYPE MENGE_D,
        LS_VBAP LIKE VBAP,
        LS_01   LIKE ZYB_T_MD001,
        LT_01   LIKE ZYB_T_MD001 OCCURS 0 WITH HEADER LINE.


  "temel ölçü birimi okunur.
  SELECT SINGLE *
                FROM MARM
                INTO LS_MARM
                WHERE MATNR EQ I_MATNR
                AND   UMREZ EQ 1
                AND   UMREN EQ 1.

  CASE LS_MARM-MEINH.
    WHEN 'M2'. "temel ölçü birimi m2 ise

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR            = I_MATNR
          I_IN_ME            = LS_MARM-MEINH
          I_OUT_ME           = 'ST'
          I_MENGE            = I_MENGE
        IMPORTING
         E_MENGE             = LV_MENG
        EXCEPTIONS
         ERROR_IN_APPLICATION       = 1
         ERROR                      = 2
         OTHERS                     = 3.

      SELECT SINGLE VBELN
                    POSNR
                    MVGR1
                    MVGR2
                    FROM VBAP
                    INTO CORRESPONDING FIELDS OF LS_VBAP
                    WHERE VBELN EQ I_VBELN
                    AND   POSNR EQ I_POSNR.

      SELECT *
             FROM ZYB_T_MD001
             INTO TABLE LT_01
             WHERE MATNR EQ I_MATNR
             AND   MVGR2 EQ LS_VBAP-MVGR2.


      READ TABLE LT_01 WITH KEY MVGR2 = LS_VBAP-MVGR2
                                MVGR1 = SPACE.
      IF SY-SUBRC EQ 0.
        CATCH SYSTEM-EXCEPTIONS
          ARITHMETIC_ERRORS = 8
          OTHERS = 4.
          LV_DMEN = ( LT_01-UMREN * LV_MENG ) / LT_01-UMREZ.
          READ TABLE LT_01 WITH KEY MVGR2 = LS_VBAP-MVGR2
                                    MVGR1 = LS_VBAP-MVGR1.
          IF SY-SUBRC EQ 0.
            E_MENGE = ( LT_01-UMREN * LV_DMEN ) / LT_01-UMREZ.
            E_MEINS = LT_01-BKMTP.
          ENDIF.
        ENDCATCH.
      ENDIF.
    WHEN 'ST'. "temel ölçü birimi adet ise

      SELECT SINGLE VBELN
                    POSNR
                    MVGR1
                    MVGR2
                    FROM VBAP
                    INTO CORRESPONDING FIELDS OF LS_VBAP
                    WHERE VBELN EQ I_VBELN
                    AND   POSNR EQ I_POSNR.

      SELECT *
             FROM ZYB_T_MD001
             INTO TABLE LT_01
             WHERE MATNR EQ I_MATNR
             AND   MVGR2 EQ LS_VBAP-MVGR2.


      READ TABLE LT_01 WITH KEY MVGR2 = LS_VBAP-MVGR2
                                MVGR1 = SPACE.
      IF SY-SUBRC EQ 0.
        CATCH SYSTEM-EXCEPTIONS
          ARITHMETIC_ERRORS = 8
          OTHERS = 4.
          LV_DMEN = ( LT_01-UMREN * I_MENGE ) / LT_01-UMREZ.
          READ TABLE LT_01 WITH KEY MVGR2 = LS_VBAP-MVGR2
                                    MVGR1 = LS_VBAP-MVGR1.
          IF SY-SUBRC EQ 0.
            E_MENGE = CEIL( ( LT_01-UMREN * LV_DMEN ) / LT_01-UMREZ ).
            E_MEINS = LT_01-BKMTP.
          ENDIF.
        ENDCATCH.
      ENDIF.

  ENDCASE.







ENDFUNCTION.
