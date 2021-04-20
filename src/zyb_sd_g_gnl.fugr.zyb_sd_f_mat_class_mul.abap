FUNCTION ZYB_SD_F_MAT_CLASS_MUL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      TB_KRK STRUCTURE  ZYB_SD_S_KRK_VAL
*"      ATNAM_RT STRUCTURE  BAPICHARACTRANGETABLE OPTIONAL
*"----------------------------------------------------------------------
  DATA: lt_karak TYPE zyb_sd_s_krk_val OCCURS 0 WITH HEADER LINE.
  DATA : idx LIKE sy-tabix.


  LOOP AT tb_krk.
    tb_krk-objek+0(18)  = tb_krk-matnr.
*    tb_krk-objek+18(10) = tb_krk-charg.
    MODIFY tb_krk.
  ENDLOOP.


  IF tb_krk[] IS NOT INITIAL.
    SELECT cabn~atnam
           cabn~atfor
           ausp~objek
           ausp~atwrt
           ausp~atflv
      FROM ausp
      INNER JOIN cabn ON cabn~atinn EQ ausp~atinn
      INTO CORRESPONDING FIELDS OF TABLE lt_karak
      FOR ALL ENTRIES IN tb_krk
      WHERE ausp~objek      EQ tb_krk-objek
        AND ausp~klart EQ '001'
        AND cabn~atnam IN atnam_rt.
  ENDIF.

  SORT tb_krk STABLE BY matnr.
  LOOP AT lt_karak.
    idx = sy-tabix.
    CLEAR tb_krk.
    READ TABLE tb_krk WITH KEY objek = lt_karak-objek BINARY SEARCH.
    IF sy-subrc = 0.
      lt_karak-matnr = tb_krk-matnr.
*      lt_karak-charg = tb_krk-charg.
      MODIFY lt_karak INDEX idx.
    ENDIF.
  ENDLOOP.

  FREE: tb_krk.
  tb_krk[] = lt_karak[].
ENDFUNCTION.
