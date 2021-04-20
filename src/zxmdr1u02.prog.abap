*&---------------------------------------------------------------------*
*&  Include           ZXMDR1U02
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(I_S_GENERAL) TYPE  MDR1P_S_IN_ALLOWED_QT_UNIT
*"             REFERENCE(I_S_MARA) TYPE  MARA
*"             REFERENCE(I_S_EINA) TYPE  EINA OPTIONAL
*"             REFERENCE(I_S_EINE) TYPE  EINE OPTIONAL
*"             REFERENCE(I_S_MARC) TYPE  MARC OPTIONAL
*"             REFERENCE(I_S_MARC_2) TYPE  MARC OPTIONAL
*"             REFERENCE(I_S_MVKE) TYPE  MVKE OPTIONAL
*"             REFERENCE(I_S_KNMT) TYPE  KNMT OPTIONAL
*"             REFERENCE(I_S_KNVV) TYPE  KNVV OPTIONAL
*"       TABLES
*"              O_T_QT_UNITS TYPE  MDR1P_T_OUT_ALLOWED_QT_UNIT
*"                             OPTIONAL
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
FIELD-SYMBOLS :
   <fs> TYPE any.

DATA :
  ls_vbak      LIKE vbak,
  ls_vbap      LIKE vbap,
  ls_tvak      LIKE tvak,
  lv_fname(32) VALUE '(SAPMV45A)VBAP',
  lv_fnam2(32) VALUE '(SAPMV45A)VBAK'.

CLEAR: ls_vbak, ls_vbap.
*break ytola.
UNASSIGN <fs>.
ASSIGN (lv_fnam2) TO <fs>.
IF sy-subrc = 0.
  ls_vbak = <fs>.
ENDIF.

UNASSIGN <fs>.
ASSIGN (lv_fname) TO <fs>.
IF sy-subrc = 0.
  ls_vbap = <fs>.
ENDIF.


CHECK  i_s_general-appview = '02'.

CLEAR ls_tvak.
SELECT SINGLE * FROM tvak
       INTO ls_tvak
      WHERE auart EQ ls_vbak-auart.
CASE ls_tvak-kalvg.
  WHEN '3' OR '4' OR '5'.
    LOOP AT  o_t_qt_units WHERE flagsiqtunit EQ space
                            AND meinh  NE i_s_mara-meins.

      DELETE o_t_qt_units.
    ENDLOOP.
  WHEN OTHERS.
ENDCASE.
