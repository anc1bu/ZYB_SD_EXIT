*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_VTWEG_SVKEN
*   generation date: 29.09.2020 at 11:06:00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_VTWEG_SVKEN   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
