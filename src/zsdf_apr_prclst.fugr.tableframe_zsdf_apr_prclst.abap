*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_APR_PRCLST
*   generation date: 28.07.2020 at 15:53:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_APR_PRCLST    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
