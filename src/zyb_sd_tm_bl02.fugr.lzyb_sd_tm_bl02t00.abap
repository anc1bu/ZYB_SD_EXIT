*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.02.2018 at 21:17:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_BL02...................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_BL02                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_BL02                 .
CONTROLS: TCTRL_ZYB_SD_T_BL02
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_BL02                 .
TABLES: ZYB_SD_T_BL02                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
