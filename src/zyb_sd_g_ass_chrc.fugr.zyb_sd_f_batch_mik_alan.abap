FUNCTION zyb_sd_f_batch_mik_alan.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(GLOBALS) LIKE  CUOV_00 STRUCTURE  CUOV_00
*"  TABLES
*"      QUERY STRUCTURE  CUOV_01
*"      MATCH STRUCTURE  CUOV_01
*"  EXCEPTIONS
*"      FAIL
*"      INTERNAL_ERROR
*"----------------------------------------------------------------------
  PERFORM clear_table.
break bbozaci.

  get_arg: 'PALET_MATNR' 'CHAR' gv_matnr.    "Paletteki Malzeme
  get_arg: 'PALET_TIPI'  'CHAR' gv_plt_tip.  "Palet Tipi
  get_arg: 'KUTU_TIPI'   'CHAR' gv_kut_tip.  "Kutu Tipi


  LOOP AT query INTO ls_query WHERE atcio EQ 'O'.
    CLEAR: ls_md001.
    PERFORM set_meinh USING ls_query-varnam CHANGING gv_meinh.

*    SELECT SINGLE * FROM zyb_t_md001
*        INTO ls_md001
*        WHERE matnr EQ gv_matnr
*          AND mvgr1 EQ gv_plt_tip
*          AND mvgr2 EQ gv_kut_tip
*          AND meinh EQ gv_meinh.

    IF NOT ls_md001 IS INITIAL.
      set_arg: ls_query-varnam 'NUM' ls_md001-umrez.
    ENDIF.
  ENDLOOP.





ENDFUNCTION.
