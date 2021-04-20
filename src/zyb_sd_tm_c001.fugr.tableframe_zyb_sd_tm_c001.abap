*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZYB_SD_TM_C001
*   generation date: 30.05.2015 at 12:57:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZYB_SD_TM_C001     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
