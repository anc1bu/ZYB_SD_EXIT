*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 02.03.2021 at 09:47:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VLD_MTART..................................*
DATA:  BEGIN OF STATUS_ZSDT_VLD_MTART                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VLD_MTART                .
CONTROLS: TCTRL_ZSDT_VLD_MTART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VLD_MTART                .
TABLES: ZSDT_VLD_MTART                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
