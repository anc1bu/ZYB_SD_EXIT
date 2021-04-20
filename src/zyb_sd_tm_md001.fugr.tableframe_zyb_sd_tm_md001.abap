*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZYB_SD_TM_MD001
*   generation date: 26.07.2015 at 01:13:57
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZYB_SD_TM_MD001    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
