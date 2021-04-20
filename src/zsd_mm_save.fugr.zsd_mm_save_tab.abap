FUNCTION zsd_mm_save_tab.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_SD_MD001) TYPE  ZYB_SD_T_MD001 OPTIONAL
*"  TABLES
*"      IT_MD001 STRUCTURE  ZYB_T_MD001
*"----------------------------------------------------------------------

  IF is_sd_md001 IS NOT INITIAL.
    MODIFY zyb_sd_t_md001 FROM is_sd_md001.
  ENDIF.

  IF it_md001[] IS NOT INITIAL.
    LOOP AT it_md001.
      MODIFY zyb_t_md001 FROM it_md001.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
