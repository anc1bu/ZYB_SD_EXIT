*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_EXC_VLD_SUR
*   generation date: 29.06.2020 at 16:27:43
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_EXC_VLD_SUR   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
