*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.02.2021 at 12:10:31
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_T_MD002..................................*
DATA:  BEGIN OF STATUS_ZYB_SD_T_MD002                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_SD_T_MD002                .
CONTROLS: TCTRL_ZYB_SD_T_MD002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_SD_T_MD002                .
TABLES: ZYB_SD_T_MD002                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
