*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07.03.2020 at 09:42:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_PARTI_KRK..................................*
DATA:  BEGIN OF STATUS_ZSDT_PARTI_KRK                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_PARTI_KRK                .
CONTROLS: TCTRL_ZSDT_PARTI_KRK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_PARTI_KRK                .
TABLES: ZSDT_PARTI_KRK                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
