*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.06.2020 at 17:52:39
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VLD_LGORT..................................*
DATA:  BEGIN OF STATUS_ZSDT_VLD_LGORT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VLD_LGORT                .
CONTROLS: TCTRL_ZSDT_VLD_LGORT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VLD_LGORT                .
TABLES: ZSDT_VLD_LGORT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
