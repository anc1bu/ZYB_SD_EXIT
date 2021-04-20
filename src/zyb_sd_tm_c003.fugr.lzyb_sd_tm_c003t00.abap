*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06.03.2019 at 11:48:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_C003...................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_C003                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_C003                 .
CONTROLS: TCTRL_ZYB_SD_T_C003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_C003                 .
TABLES: ZYB_SD_T_C003                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
