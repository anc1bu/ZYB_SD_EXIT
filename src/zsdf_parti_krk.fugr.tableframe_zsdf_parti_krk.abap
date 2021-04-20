*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_PARTI_KRK
*   generation date: 07.03.2020 at 09:42:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_PARTI_KRK     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
