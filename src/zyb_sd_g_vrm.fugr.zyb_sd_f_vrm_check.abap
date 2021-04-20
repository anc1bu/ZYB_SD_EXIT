FUNCTION zyb_sd_f_vrm_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(USER_EXIT) TYPE  XFELD DEFAULT ' '
*"     VALUE(VRM_CHECK) TYPE  ZYB_SD_TY_VRM_CHECK
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA:
    lv_sobkz TYPE sobkz.
  CLEAR: lv_sobkz, wa_check.
  FREE:
    tb_msg, tb_check.
    CLEAR:
    gv_islem, gv_txt, gs_batch.

  tb_check = vrm_check.

  PERFORM get_global_data.

  LOOP AT tb_check INTO wa_check.
    CLEAR: gv_islem, lv_sobkz.

    PERFORM set_tip USING wa_check
                  CHANGING gv_islem
                           lv_sobkz.

    CHECK NOT gv_islem IS INITIAL.

    CASE gv_islem.
      WHEN gc_tip_grs.
        IF lv_sobkz EQ gc_sobkz_e.
          PERFORM mal_giris_dis USING wa_check.

          PERFORM karakteristik_kontrol USING gc_tip_grs
                                              wa_check.
        ENDIF.
      WHEN gc_tip_icvir.

        PERFORM ic_virman_check USING wa_check.
        PERFORM karakteristik_kontrol USING gc_tip_icvir
                                            wa_check.
      WHEN gc_tip_disvir.

        PERFORM dis_virman_check USING wa_check.
        PERFORM karakteristik_kontrol USING gc_tip_disvir
                                            wa_check.
    ENDCASE.
  ENDLOOP.
  return[] = tb_msg[].
ENDFUNCTION.
