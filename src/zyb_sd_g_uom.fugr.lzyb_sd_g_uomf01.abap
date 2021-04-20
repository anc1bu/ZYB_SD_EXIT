*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_UOMF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CONVERT_UNIT_INPUT
*&---------------------------------------------------------------------*
FORM convert_unit_input  CHANGING VALUE(p_val).
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = p_val
    IMPORTING
      output         = p_val
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " CONVERT_UNIT_INPUT
*&---------------------------------------------------------------------*
*&      Form  CONVERT_FLOAT_TO_INTEGER
*&---------------------------------------------------------------------*
FORM convert_float_to_integer  USING VALUE(p_float_val)
                               CHANGING VALUE(p_val).
  CALL FUNCTION 'MURC_ROUND_FLOAT_TO_PACKED'
    EXPORTING
      if_float  = p_float_val
*     IF_SIGNIFICANT_PLACES       = 15
    IMPORTING
      ef_packed = p_val
    EXCEPTIONS
      overflow  = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " CONVERT_FLOAT_TO_INTEGER
*&---------------------------------------------------------------------*
*&      Form  ROUNDING_WITH_RULE
*&---------------------------------------------------------------------*
FORM rounding_with_rule  USING    VALUE(p_rule)
                                  VALUE(p_val)
                         CHANGING VALUE(p_sonuc).
  CALL FUNCTION 'SD_VALUE_ROUND_WITH_RULE'
    EXPORTING
      i_value             = p_val
      i_rrule             = p_rule
    IMPORTING
      e_value             = p_sonuc
    EXCEPTIONS
      rule_not_valid      = 1
      rule_not_applicable = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " ROUNDING_WITH_RULE
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
FORM data_check  USING    p_typ
                          p_matnr
                          p_mvgr1
                          p_mvgr2
                 CHANGING ep_amb.
  DATA: ls_mara LIKE mara.

  CLEAR ls_mara.

  CASE p_typ.
    WHEN gc_typ_plt.
      IF NOT ep_amb IS INITIAL.
        SELECT SINGLE * FROM mara
            INTO ls_mara
           WHERE matnr EQ ep_amb.

        IF ls_mara-matkl NE gc_matkl_plt.
          CLEAR ep_amb.
        ENDIF.
      ENDIF.
      IF ep_amb IS INITIAL AND NOT p_mvgr1 IS INITIAL.
        SELECT SINGLE mvke~matnr FROM mvke
          INNER JOIN mara ON mara~matnr EQ mvke~matnr
          INTO ep_amb
         WHERE mvke~mvgr1 EQ p_mvgr1
           AND mvke~vkorg EQ gc_sanayi
           AND mvke~vtweg EQ gc_diger
" yarımamül fantom malzemesi olduğu için kapatıldı
*           AND mara~mtart EQ gc_mtart_amb
           AND mara~mtart EQ gc_mtart_yrm
           AND mara~matkl EQ gc_matkl_plt.
      ENDIF.
    WHEN gc_typ_kut.
      IF NOT ep_amb IS INITIAL.
        SELECT SINGLE * FROM mara
            INTO ls_mara
           WHERE matnr EQ ep_amb.

        IF ls_mara-matkl NE gc_matkl_kut.
          CLEAR ep_amb.
        ENDIF.
      ENDIF.
      IF ep_amb IS INITIAL AND NOT p_mvgr2 IS INITIAL.
        SELECT SINGLE mvke~matnr FROM mvke
          INNER JOIN mara ON mara~matnr EQ mvke~matnr
          INTO ep_amb
         WHERE mvke~mvgr2 EQ p_mvgr2
           AND mvke~vkorg EQ gc_sanayi
           AND mvke~vtweg EQ gc_diger
" yarımamül fantom malzemesi olduğu için kapatıldı
*           AND mara~mtart EQ gc_mtart_amb
           AND mara~mtart EQ gc_mtart_yrm
           AND mara~matkl EQ gc_matkl_kut.
      ENDIF.
  ENDCASE.
ENDFORM.                    " DATA_CHECK
*&---------------------------------------------------------------------*
*&      Form  MAT_CONV
*&---------------------------------------------------------------------*
FORM mat_conv USING u_matnr u_qty u_meins h_meins
           CHANGING c_qty.
  DATA : lv_umren LIKE marm-umren,
         lv_umrez LIKE marm-umrez,
         lv_menge LIKE ekpo-menge,
         lc_menge LIKE ekpo-menge.
  lv_menge = u_qty.
  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = u_matnr
      i_in_me              = u_meins
      i_out_me             = h_meins
      i_menge              = lv_menge
    IMPORTING
      e_menge              = lc_menge
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING not_convertible_material.
  ELSE.
    c_qty = lc_menge .
  ENDIF.
ENDFORM.                    " MAT_CONV
*&---------------------------------------------------------------------*
*&      Form  ROUNDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM rounding  USING    VALUE(p_tip)
                        p_base
                        p_qty
               CHANGING ep_round.
  DATA: p_typ   TYPE rndtype,
        lv_base TYPE rndbase.
  MOVE p_base TO lv_base.
  CASE p_tip.
    WHEN '+'. p_typ = '2'.
    WHEN '-'. p_typ = '1'.
  ENDCASE.

  CALL FUNCTION 'SD_VALUE_ROUND'
    EXPORTING
      i_value        = p_qty
      i_base         = lv_base
      i_type         = p_typ
    IMPORTING
      e_value        = ep_round
    EXCEPTIONS
      rule_not_valid = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " ROUNDING
*&---------------------------------------------------------------------*
*&      Form  YUVARLAMA
*&---------------------------------------------------------------------*
FORM yuvarlama  CHANGING   p_qty.
  DATA:
    lv_qty           TYPE menge_d,
    lv_ondalik       TYPE menge_d,
    lv_ondalik_c(10) TYPE c,
    lv_base_c(10)    TYPE c.

  CLEAR: lv_ondalik, lv_qty.

*-- Rounding Off
  lv_ondalik = frac( p_qty ).

  CLEAR: lv_ondalik_c, lv_base_c.
  WRITE lv_ondalik TO lv_ondalik_c. CONDENSE lv_ondalik_c.
  WRITE gc_base    TO lv_base_c.    CONDENSE lv_base_c.

  CLEAR lv_qty.
  IF lv_ondalik NE 0.
    IF lv_ondalik_c+4(1) GE lv_base_c+4(1).
      PERFORM rounding USING '+' " Yukarı Yuvarlama tabanı 0,00500
                             gc_base
                             p_qty
                    CHANGING lv_qty.
    ELSE.
      PERFORM rounding USING '-' " Aşağı Yuvarlama tabanı 0,00500
                             gc_base
                             p_qty
                    CHANGING lv_qty.
    ENDIF.
    p_qty = lv_qty.
  ENDIF.
ENDFORM.                    " YUVARLAMA
