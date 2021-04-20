*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.07.2020 at 15:53:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_APR_PRCLST.................................*
DATA:  BEGIN OF STATUS_ZSDT_APR_PRCLST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_APR_PRCLST               .
CONTROLS: TCTRL_ZSDT_APR_PRCLST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_APR_PRCLST               .
TABLES: ZSDT_APR_PRCLST                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
