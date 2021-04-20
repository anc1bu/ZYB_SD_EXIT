*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.02.2020 at 20:49:19
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_C002...................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_C002                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_C002                 .
CONTROLS: TCTRL_ZYB_SD_T_C002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_C002                 .
TABLES: ZYB_SD_T_C002                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
