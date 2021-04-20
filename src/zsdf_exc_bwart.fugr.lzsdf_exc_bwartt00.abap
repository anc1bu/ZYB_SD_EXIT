*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.03.2020 at 20:13:25
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXC_BWART..................................*
DATA:  BEGIN OF STATUS_ZSDT_EXC_BWART                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXC_BWART                .
CONTROLS: TCTRL_ZSDT_EXC_BWART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXC_BWART                .
TABLES: ZSDT_EXC_BWART                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
