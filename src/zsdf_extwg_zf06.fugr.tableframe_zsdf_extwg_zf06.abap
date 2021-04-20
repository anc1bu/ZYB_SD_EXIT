*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_EXTWG_ZF06
*   generation date: 19.01.2021 at 09:07:04
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_EXTWG_ZF06    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
