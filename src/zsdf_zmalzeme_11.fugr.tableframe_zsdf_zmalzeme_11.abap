*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_ZMALZEME_11
*   generation date: 29.12.2020 at 12:19:27
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_ZMALZEME_11   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
