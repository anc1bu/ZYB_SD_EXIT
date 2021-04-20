*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.01.2021 at 13:25:22
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXC_EXTWG..................................*
DATA:  BEGIN OF STATUS_ZSDT_EXC_EXTWG                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXC_EXTWG                .
CONTROLS: TCTRL_ZSDT_EXC_EXTWG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXC_EXTWG                .
TABLES: ZSDT_EXC_EXTWG                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
