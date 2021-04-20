*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.09.2020 at 14:11:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_APR_UNITPRC................................*
DATA:  BEGIN OF STATUS_ZSDT_APR_UNITPRC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_APR_UNITPRC              .
CONTROLS: TCTRL_ZSDT_APR_UNITPRC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_APR_UNITPRC              .
TABLES: ZSDT_APR_UNITPRC               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
