*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_ASS_CHRCF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TABLE
*&---------------------------------------------------------------------*
FORM clear_table .
  CLEAR:
    ls_md001,
    gv_matnr,
    gv_plt_tip,
    gv_kut_tip,
    gv_meinh,
    gv_kutu_mik,
    gv_palet_mik,
    gv_kutu_alan,
    gv_palet_alan.
ENDFORM.                    " CLEAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  SET_MEINH
*&---------------------------------------------------------------------*
FORM set_meinh  USING    p_varnam
                CHANGING ep_meinh.
  DATA:
    ls_cabn LIKE cabn,
    ls_chw2 LIKE tchw2,
    p_atinn LIKE cabn-atinn.

  CLEAR: ep_meinh, ls_cabn, ls_chw2, p_atinn.

  PERFORM conversion_exit_atinn_input USING p_varnam
                                   CHANGING p_atinn.
  SELECT SINGLE * FROM cabn
      INTO ls_cabn
     WHERE atinn EQ p_atinn.

  IF NOT ls_cabn-msehi IS INITIAL.
    SELECT SINGLE * FROM tchw2
        INTO ls_chw2
        WHERE msehi EQ ls_cabn-msehi
          AND XUMKQ EQ charx.
    IF sy-subrc = 0.
      ep_meinh = ls_chw2-refme.
    ENDIF.
  ENDIF.
ENDFORM.                    " SET_MEINH
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ATINN_INPUT
*&---------------------------------------------------------------------*
FORM conversion_exit_atinn_input  USING    i_atinn
                                  CHANGING ep_atinn.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = i_atinn
    IMPORTING
      output = ep_atinn.
ENDFORM.                    " CONVERSION_EXIT_ATINN_INPUT
