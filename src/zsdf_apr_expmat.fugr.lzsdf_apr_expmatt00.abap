*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07.11.2019 at 22:20:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_APR_EXPMAT.................................*
DATA:  BEGIN OF STATUS_ZSDT_APR_EXPMAT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_APR_EXPMAT               .
CONTROLS: TCTRL_ZSDT_APR_EXPMAT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_APR_EXPMAT               .
TABLES: ZSDT_APR_EXPMAT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
