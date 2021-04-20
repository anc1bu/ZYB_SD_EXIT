*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_TSMIRS_VSAR
*   generation date: 14.10.2019 at 15:26:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_TSMIRS_VSAR   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
