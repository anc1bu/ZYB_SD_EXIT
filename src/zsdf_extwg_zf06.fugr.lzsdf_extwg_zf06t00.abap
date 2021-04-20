*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 19.01.2021 at 09:07:04
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXTWG_ZF06.................................*
DATA:  BEGIN OF STATUS_ZSDT_EXTWG_ZF06               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXTWG_ZF06               .
CONTROLS: TCTRL_ZSDT_EXTWG_ZF06
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXTWG_ZF06               .
TABLES: ZSDT_EXTWG_ZF06                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
