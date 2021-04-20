*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.05.2015 at 12:57:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_C001...................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_C001                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_C001                 .
CONTROLS: TCTRL_ZYB_SD_T_C001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_C001                 .
TABLES: ZYB_SD_T_C001                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
