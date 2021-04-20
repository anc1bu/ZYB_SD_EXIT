*&---------------------------------------------------------------------*
*&  Include           ZXMDR1U04
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(I_S_GENERAL) TYPE  MDR1P_S_IN_SINGLE_ROUND
*"             REFERENCE(I_S_EINA) TYPE  EINA OPTIONAL
*"             REFERENCE(I_S_EINE) TYPE  EINE OPTIONAL
*"             REFERENCE(I_S_MARC_2) TYPE  MARC OPTIONAL
*"             REFERENCE(I_S_MARC) TYPE  MARC OPTIONAL
*"             REFERENCE(I_S_MVKE) TYPE  MVKE OPTIONAL
*"             REFERENCE(I_S_KNMT) TYPE  KNMT OPTIONAL
*"             REFERENCE(I_S_KNVV) TYPE  KNVV OPTIONAL
*"       TABLES
*"              CH_T_QT_UNITS TYPE  MDR1P_T_OUT_ALLOWED_QT_UNIT
*"                             OPTIONAL
*"              CH_T_ROUND_REASONS TYPE  MDR1P_T_RUNDUNGSGRUND
*"                             OPTIONAL
*"       CHANGING
*"             REFERENCE(CH_S_RESULTS) TYPE  MDR1P_S_OUT_SINGLE_ROUND
*"                             OPTIONAL
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
DATA : lt_msc LIKE TABLE OF rdpr WITH HEADER LINE.
FIELD-SYMBOLS : <fs> TYPE any .
DATA : lv_mvgr1           LIKE vbap-mvgr1,
       lv_mvgr2           LIKE vbap-mvgr2,
       lv_vrkme           LIKE vbap-vrkme,
       lv_vbap            LIKE vbap,
       ls_tvak            TYPE tvak,
       lv_sum             TYPE umren,
       lv_umren           TYPE umren,
       lv_auart           TYPE auart,
       lv_umrez           TYPE umrez,
       lv_pasif           TYPE c,
       lv_fname(32)       VALUE '(SAPMV45A)VBAP', "-MVGR1
       lv_fname3(32)      VALUE '(SAPMV45A)VBAK', "-MVGR1
       lv_fnam2(32)       VALUE '(SAPMV45A)VBAK-AUART',
       ls_fname_ekpo(32)  VALUE '(SAPLMEPO)EKPO',
       lv_fname_bsart(32) VALUE '(SAPLMEPO)EKKO-BSART',
       lv_bsart           TYPE esart,
       ls_ekpo            TYPE ekpo,
       lv_eqty            LIKE ekpo-menge,
       lv_menge           LIKE ekpo-menge,
       lv_tam             TYPE c,
       lv_text(132),
       lv_meins           LIKE mara-meins.
DATA:ls_vbak TYPE vbak.
DATA : lv_qty LIKE  rdpr-bdmng.

CLEAR lv_pasif.
CASE i_s_general-opcode.
  WHEN '1'. " satınalma için
    IF NOT ch_s_results-rdprf IS INITIAL.
      EXIT.
    ENDIF.

    CLEAR lv_bsart.
    UNASSIGN <fs>.
    ASSIGN (lv_fname_bsart) TO <fs>.
    IF sy-subrc = 0.
      lv_bsart = <fs>.
    ENDIF.

    IF  lv_bsart NE 'ZTIC'  AND
        lv_bsart NE 'ZFSN'.

      break ytola.

      EXIT.
    ENDIF.

    CLEAR ls_ekpo.

    UNASSIGN <fs>.
    ASSIGN (ls_fname_ekpo) TO <fs>.
    IF sy-subrc = 0.
      ls_ekpo = <fs>.
    ENDIF.

    lv_mvgr1 = ls_ekpo-zzpal.
    lv_mvgr2 = ls_ekpo-zzkut.

    CLEAR lv_meins.
    SELECT SINGLE meins FROM mara INTO lv_meins
            WHERE matnr = i_s_general-matnr.

    lv_menge = i_s_general-menge.
    lv_tam = 'X'.
    lv_vrkme = 'PAL'.

  WHEN '2' OR '3'. " Satış için
**********************************************************************
    break narslan.
*FIELD-SYMBOLS: <gfs_line>
*ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <gfs_line> TO <fs1>.
    UNASSIGN <fs>.
    ASSIGN (lv_fname3) TO <fs>.
    ls_vbak = <fs>.
    IF ls_vbak-vtweg ne 10.

**********************************************************************
      CLEAR lv_auart.
      UNASSIGN <fs>.
      ASSIGN (lv_fnam2) TO <fs>.
      IF sy-subrc = 0.
        lv_auart = <fs>.
      ENDIF.

* Kontroller
      IF NOT ch_s_results-rdprf IS INITIAL.
        EXIT.
      ENDIF.

      CLEAR ls_tvak.
      SELECT SINGLE * FROM tvak
             INTO ls_tvak
            WHERE auart EQ lv_auart.

      CLEAR: lv_vbap, lv_mvgr1, lv_mvgr2, lv_vrkme.
      UNASSIGN <fs>.
      ASSIGN (lv_fname) TO <fs>.
      IF sy-subrc = 0.
        lv_vbap = <fs>.
        lv_mvgr1 = lv_vbap-mvgr1.
        lv_mvgr2 = lv_vbap-mvgr2.
        lv_vrkme = lv_vbap-vrkme.
      ENDIF.

      SELECT SINGLE meins FROM mara INTO lv_meins
              WHERE matnr = i_s_general-matnr.

      CLEAR: lv_qty.
      lv_qty = i_s_general-menge.

      lv_menge = i_s_general-menge.

      CLEAR: lv_tam, lv_vrkme.
      CASE ls_tvak-kalvg.
        WHEN '3'.
          lv_tam = 'X'.
          lv_vrkme = 'PAL'.
        WHEN  '5'.  lv_vrkme = 'KUT'.   " '4' OR  yıldızlandı. Kısmi palet satışlarında ölçü dönüşümü olmaz. ZSD010 ekranındaki miktarlar bapiye verilir.
        WHEN  OTHERS. lv_pasif = 'X'.
      ENDCASE.
    ELSE.
      lv_pasif = 'X'.
      ENDIF.
ENDCASE.

CHECK lv_pasif IS INITIAL.
CALL FUNCTION 'ZYB_SD_F_CONVERT_TO_ALT_UOM'
  EXPORTING
    plt_tam                  = lv_tam
    p_alt_uom                = lv_vrkme
    p_cur_qty                = lv_menge
    p_matnr                  = i_s_general-matnr
    p_mvgr1                  = lv_mvgr1
    p_mvgr2                  = lv_mvgr2
  IMPORTING
*   ep_alt_qty               = lv_aqty
    ep_uom_qty               = lv_eqty
  EXCEPTIONS
    unit_not_found           = 1
    format_error             = 2
    uom_not_consistent       = 3
    obligatory               = 4
    type_not_consistent      = 5
    not_convertible_material = 6
    not_customize_material   = 7
    empty_palet              = 8
    OTHERS                   = 9.

IF sy-subrc = 0.
  IF i_s_general-opcode NE '1'.
    ch_t_round_reasons-kzgrund = '3'.
  ELSE.
    ch_t_round_reasons-kzgrund = '1'.
  ENDIF.
  ch_s_results-menge = lv_eqty.
  APPEND ch_t_round_reasons.
ELSE.

  IF NOT ( sy-msgid IS INITIAL ).

    IF sy-tcode+0(2) EQ 'VA' OR sy-tcode+0(2) EQ 'ME'.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = sy-msgid
          msgnr               = sy-msgno
          msgv1               = sy-msgv1
          msgv2               = sy-msgv2
          msgv3               = sy-msgv3
          msgv4               = sy-msgv4
        IMPORTING
          message_text_output = lv_text.

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = lv_text.

      MESSAGE lv_text TYPE 'I'.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error.
    ENDIF.
  ELSE.
    MESSAGE e003(rpugen)  WITH '004' 'MD_SINGLE_ROUNDING'
    RAISING error.
  ENDIF.
ENDIF.
