*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_FINDOC_EXPC
*   generation date: 20.08.2019 at 18:57:50
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_FINDOC_EXPC   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
