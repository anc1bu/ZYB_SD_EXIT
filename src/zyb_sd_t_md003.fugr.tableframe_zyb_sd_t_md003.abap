*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZYB_SD_T_MD003
*   generation date: 22.02.2018 at 21:12:18
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZYB_SD_T_MD003     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
