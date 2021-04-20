FUNCTION ZYB_SD_F_CONVERT_TO_ALT_UOM2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_ALT_UOM) TYPE  MARM-MEINH
*"     VALUE(P_CUR_QTY) TYPE  EKPO-MENGE
*"     VALUE(P_MATNR) TYPE  MATNR
*"     VALUE(P_MVGR1) TYPE  MVGR1 OPTIONAL
*"     VALUE(P_MVGR2) TYPE  MVGR2 OPTIONAL
*"     VALUE(P_MATNR_AMB) TYPE  MATNR OPTIONAL
*"     VALUE(P_ROUNDING) TYPE  XFELD OPTIONAL
*"     VALUE(P_RULE) TYPE  RNDRULE DEFAULT '0205'
*"  EXPORTING
*"     REFERENCE(EP_ALT_QTY) TYPE  EKPO-MENGE
*"     REFERENCE(EP_UMREN) TYPE  UMREN
*"     REFERENCE(EP_UMREZ) TYPE  UMREZ
*"  EXCEPTIONS
*"      UNIT_NOT_FOUND
*"      FORMAT_ERROR
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
        lv_matnr_amb TYPE matnr.

  CLEAR : ws_c_mara, ws_c_cf, rt_code, lv_factor, lv_matnr_amb.

  IF  NOT p_mvgr1 IS INITIAL OR NOT p_mvgr2 IS INITIAL  OR
            NOT p_matnr_amb IS INITIAL.
  ELSE.
    MESSAGE e899(fb) WITH 'Parametre Eksik'
                   RAISING format_error.
  ENDIF.
  lv_matnr_amb = p_matnr_amb.

  IF p_rounding EQ 'X' AND p_rule IS INITIAL .
    MESSAGE e899(fb) WITH 'Yuvarlama kuralı girin'
                     RAISING format_error.
  ENDIF.

  SELECT SINGLE * FROM mara
      INTO  ws_c_mara
      WHERE matnr = p_matnr.

  CLEAR lv_typ.
  CASE p_alt_uom.
    WHEN gc_palet_olc.
      lv_typ = gc_typ_plt.
    WHEN gc_kutu_olc.
      lv_typ = gc_typ_kut.
  ENDCASE.

  PERFORM data_check USING lv_typ p_matnr
                           p_mvgr1 p_mvgr2
                  CHANGING lv_matnr_amb.

  CHECK NOT lv_matnr_amb IS INITIAL.

*** sales unit of measure not equal to base unit of measure
  IF p_alt_uom <> ws_c_mara-meins.
    ws_alt_uom = p_alt_uom.

    PERFORM convert_unit_input CHANGING ws_alt_uom.

    CLEAR : wa_base_cf1.       " Conversion Factor for Base unit measure
    SELECT SINGLE
       matnr
       meinh
       umrez     "Numerator for Conversion to Base UnitsMeasure
       umren     "Denominator for conversion to base unitsmeasure
  FROM marm
  INTO CORRESPONDING FIELDS OF wa_base_cf1
  WHERE matnr   EQ p_matnr
   AND meinh    EQ ws_c_mara-meins.

    CLEAR : ws_alt_cf3. " Conversion Factor for Alternate unit measure
    SELECT SINGLE * FROM zyb_t_md001
      INTO  ws_alt_cf3
     WHERE matnr     EQ p_matnr
       AND begda <= sy-datum
       AND endda >= sy-datum.
***       AND matnr_amb EQ lv_matnr_amb
***       AND meinh     EQ ws_alt_uom.

    IF sy-subrc <> 0.
      MESSAGE e899(fb) WITH 'Ölçü birimi tablosunda bulunamadı!'
                         RAISING unit_not_found.
    ELSEIF ws_alt_cf3-umren IS INITIAL OR ws_alt_cf3-umrez IS INITIAL.
      MESSAGE e899(fb) WITH 'Dönüşüm faktörleri bulunamadı!'
                   RAISING unit_not_found.

    ENDIF.

***Calculate the conversion factor
    CLEAR lv_factor.
*    lv_factor =  ( ws_alt_cf3-umrez  / ws_alt_cf3-umren )
*              *  ( wa_base_cf1-umrez / wa_base_cf1-umren ).

    lv_factor =  ( wa_base_cf1-umrez / wa_base_cf1-umren )
              /  ( ws_alt_cf3-umrez  / ws_alt_cf3-umren ).

  ELSE.
    ep_alt_qty = p_cur_qty.
  ENDIF.

  CLEAR: lv_cur_qty, lv_alt_qty.
  MOVE p_cur_qty TO lv_cur_qty.

  lv_alt_qty = lv_cur_qty * lv_factor.

  PERFORM convert_float_to_integer USING lv_alt_qty
                                CHANGING ep_alt_qty.

  IF NOT p_rounding IS INITIAL.
    PERFORM rounding_with_rule USING   p_rule
                                       ep_alt_qty
                              CHANGING ep_alt_qty.
  ENDIF.

  ep_umrez = ws_alt_cf3-umrez.
  ep_umren = ws_alt_cf3-umren.
ENDFUNCTION.
