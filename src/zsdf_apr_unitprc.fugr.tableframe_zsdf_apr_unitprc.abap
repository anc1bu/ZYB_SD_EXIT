*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_APR_UNITPRC
*   generation date: 30.09.2020 at 14:11:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_APR_UNITPRC   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
