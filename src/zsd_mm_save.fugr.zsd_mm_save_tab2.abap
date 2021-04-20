FUNCTION ZSD_MM_SAVE_TAB2.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  TABLES
*"      T_KALITE STRUCTURE  ZYB_PP_T_KALITE OPTIONAL
*"----------------------------------------------------------------------
  LOOP AT t_kalite.
  MODIFY zyb_pp_t_kalite FROM t_kalite.
  ENDLOOP.
ENDFUNCTION.
