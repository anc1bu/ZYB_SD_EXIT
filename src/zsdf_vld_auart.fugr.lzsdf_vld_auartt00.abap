*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.06.2020 at 16:58:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VLD_AUART..................................*
DATA:  BEGIN OF STATUS_ZSDT_VLD_AUART                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VLD_AUART                .
CONTROLS: TCTRL_ZSDT_VLD_AUART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VLD_AUART                .
TABLES: ZSDT_VLD_AUART                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
