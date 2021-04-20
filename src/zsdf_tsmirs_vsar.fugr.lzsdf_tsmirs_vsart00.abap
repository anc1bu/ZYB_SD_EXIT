*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 14.10.2019 at 15:26:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_TSMIRS_VSAR................................*
DATA:  BEGIN OF STATUS_ZSDT_TSMIRS_VSAR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_TSMIRS_VSAR              .
CONTROLS: TCTRL_ZSDT_TSMIRS_VSAR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_TSMIRS_VSAR              .
TABLES: ZSDT_TSMIRS_VSAR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
