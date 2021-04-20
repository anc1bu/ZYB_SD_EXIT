*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 04.01.2021 at 12:47:04
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXC_MTART..................................*
DATA:  BEGIN OF STATUS_ZSDT_EXC_MTART                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXC_MTART                .
CONTROLS: TCTRL_ZSDT_EXC_MTART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXC_MTART                .
TABLES: ZSDT_EXC_MTART                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
