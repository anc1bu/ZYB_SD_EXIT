*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_VLD_LGORT
*   generation date: 30.06.2020 at 17:52:39
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_VLD_LGORT     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
