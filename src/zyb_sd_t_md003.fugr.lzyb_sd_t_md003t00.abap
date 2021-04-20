*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.02.2018 at 21:12:18
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_MD003..................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_MD003                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_MD003                .
CONTROLS: TCTRL_ZYB_SD_T_MD003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_MD003                .
TABLES: ZYB_SD_T_MD003                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
