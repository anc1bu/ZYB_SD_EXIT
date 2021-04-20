FUNCTION zsd_mm_save_tab_n.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      IT_SD_MD001 STRUCTURE  ZYB_SD_T_MD001
*"      IT_MD001 STRUCTURE  ZYB_T_MD001
*"----------------------------------------------------------------------

  IF it_sd_md001[] IS NOT INITIAL.
    LOOP AT it_sd_md001.
      MODIFY zyb_sd_t_md001 FROM it_sd_md001.
    ENDLOOP.
  ENDIF.

  IF it_md001[] IS NOT INITIAL.
    LOOP AT it_md001.
      MODIFY zyb_t_md001 FROM it_md001.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
