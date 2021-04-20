FUNCTION zyb_sd_f_urtmik.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VBELN) TYPE  VBELN_VA
*"     VALUE(I_POSNR) TYPE  POSNR_VA
*"  EXPORTING
*"     REFERENCE(E_SIPMIK) TYPE  MENGE_D
*"     REFERENCE(E_TESMIK) TYPE  MENGE_D
*"     REFERENCE(E_URTBKL) TYPE  MENGE_D
*"     REFERENCE(E_MEINS) TYPE  MEINS
*"  EXCEPTIONS
*"      VBELN_NOT_FOUND
*"      POSNR_NOT_FOUND
*"----------------------------------------------------------------------
  DATA: ls_vbuk  LIKE vbuk,
        ls_vbup  LIKE vbup,
        lv_stk   TYPE labst,
        lv_tsmik TYPE LFIMG.

  DATA: ls_ordview LIKE order_view,
        lt_ordkey  LIKE sales_key OCCURS 0 WITH HEADER LINE,
        lt_orditm  LIKE bapisdit  OCCURS 0 WITH HEADER LINE.

  CLEAR: ls_vbuk, ls_vbup.

  SELECT SINGLE * FROM vbuk
      INTO ls_vbuk
     WHERE vbeln EQ i_vbeln.

  IF sy-subrc <> 0.
    MESSAGE e899(fb) WITH 'Sipariş numarası mevcut değil'
          RAISING vbeln_not_found.
  ENDIF.

  SELECT SINGLE * FROM vbup
        INTO ls_vbup
       WHERE vbeln EQ i_vbeln
         AND posnr EQ i_posnr.

  IF sy-subrc <> 0.
    MESSAGE e899(fb) WITH 'Sipariş numarasına ait kalem'
                          ' no mevcut değil'
                    RAISING posnr_not_found.
  ENDIF.

  CLEAR: ls_ordview, lt_ordkey, lt_ordkey[], lt_orditm[], lt_orditm.
  ls_ordview-item = 'X'.
  lt_ordkey-vbeln = i_vbeln.
  APPEND lt_ordkey.

  CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
    EXPORTING
      i_bapi_view     = ls_ordview
    TABLES
      sales_documents = lt_ordkey
      order_items_out = lt_orditm.

*  DELETE  lt_orditm WHERE doc_number NE i_vbeln
*                      AND itm_number NE i_posnr.


*  READ TABLE lt_orditm INDEX 1.
  READ TABLE lt_orditm with key doc_number = i_vbeln
                                itm_number = i_posnr.

  IF sy-subrc = 0.
* stok miktarı
    CLEAR lv_stk.
    SELECT SUM( kalab ) FROM mska
          INTO lv_stk
         WHERE vbeln EQ lt_orditm-doc_number
           AND posnr EQ lt_orditm-itm_number
           AND matnr EQ lt_orditm-material
           AND kalab GT 0.

    IF lv_stk GT 0 AND lt_orditm-sales_unit NE lt_orditm-base_uom.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr  = lt_orditm-material
          i_in_me  = lt_orditm-base_uom
          i_out_me = lt_orditm-sales_unit
          i_menge  = lv_stk
        IMPORTING
          e_menge  = lv_stk.
    ENDIF.
  ENDIF.


  DATA: ls_dlv_cnt LIKE bapidlvbuffercontrol,
        r_vgbel    LIKE bapidlv_range_vgbel OCCURS 0 WITH HEADER LINE,
        r_wbstk    LIKE bapidlv_range_wbstk OCCURS 0 WITH HEADER LINE,
        lt_itmdlv  LIKE bapidlvitem         OCCURS 0 WITH HEADER LINE.


  CLEAR: ls_dlv_cnt, r_wbstk, r_wbstk[], r_vgbel, r_vgbel[], lt_itmdlv.

  ls_dlv_cnt-item = 'X'.

  r_wbstk-sign = 'I'.
  r_wbstk-option = 'EQ'.
  r_wbstk-overall_status_goods_movem_low = 'C'.
  APPEND r_wbstk.

  r_vgbel-sign        = 'I'.
  r_vgbel-option      = 'EQ'.
  r_vgbel-ref_doc_low = i_vbeln.
  APPEND r_vgbel.

  CALL FUNCTION 'BAPI_DELIVERY_GETLIST'
    EXPORTING
      is_dlv_data_control = ls_dlv_cnt
    TABLES
      it_vgbel            = r_vgbel
      it_wbstk            = r_wbstk
      et_delivery_item    = lt_itmdlv.

  CLEAR lv_tsmik.
  LOOP AT lt_itmdlv WHERE vgbel EQ i_vbeln
                      AND vgpos EQ i_posnr.
    lv_tsmik = lv_tsmik + lt_itmdlv-lfimg.
  ENDLOOP.

* Sonuçlar
  e_sipmik = lt_orditm-req_qty.
  e_tesmik = lv_tsmik.
  e_urtbkl = lt_orditm-req_qty - ( lv_tsmik + lv_stk ).
  e_meins  = lt_orditm-sales_unit.
ENDFUNCTION.
