*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSDF_CUST_CNTRL
*   generation date: 30.01.2021 at 11:45:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSDF_CUST_CNTRL    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
