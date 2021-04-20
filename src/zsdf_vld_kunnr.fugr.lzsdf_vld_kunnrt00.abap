*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.08.2020 at 13:54:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VLD_KUNNR..................................*
DATA:  BEGIN OF STATUS_ZSDT_VLD_KUNNR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VLD_KUNNR                .
CONTROLS: TCTRL_ZSDT_VLD_KUNNR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VLD_KUNNR                .
TABLES: ZSDT_VLD_KUNNR                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
