*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_CUST_VKBUR
*   generation date: 18.02.2020 at 02:13:39
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_CUST_VKBUR    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
