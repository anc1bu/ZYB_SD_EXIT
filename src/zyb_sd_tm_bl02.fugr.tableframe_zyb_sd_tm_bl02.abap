*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZYB_SD_TM_BL02
*   generation date: 15.02.2018 at 21:16:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZYB_SD_TM_BL02     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
