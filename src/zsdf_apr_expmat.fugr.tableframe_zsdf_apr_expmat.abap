*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_APR_EXPMAT
*   generation date: 07.11.2019 at 22:20:01
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_APR_EXPMAT    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
