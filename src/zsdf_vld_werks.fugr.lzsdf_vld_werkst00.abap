*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 02.03.2021 at 10:32:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VLD_WERKS..................................*
DATA:  BEGIN OF STATUS_ZSDT_VLD_WERKS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VLD_WERKS                .
CONTROLS: TCTRL_ZSDT_VLD_WERKS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VLD_WERKS                .
TABLES: ZSDT_VLD_WERKS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
