*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.04.2016 at 13:51:43
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_T_MD001.....................................*
DATA:  BEGIN OF STATUS_ZYB_T_MD001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZYB_T_MD001                   .
CONTROLS: TCTRL_ZYB_T_MD001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZYB_T_MD001                   .
TABLES: ZYB_T_MD001                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
