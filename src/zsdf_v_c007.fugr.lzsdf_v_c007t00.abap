*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06.04.2020 at 19:17:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZYB_SD_V_C007...................................*
TABLES: ZYB_SD_V_C007, *ZYB_SD_V_C007. "view work areas
CONTROLS: TCTRL_ZYB_SD_V_C007
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZYB_SD_V_C007. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZYB_SD_V_C007.
* Table for entries selected to show on screen
DATA: BEGIN OF ZYB_SD_V_C007_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZYB_SD_V_C007.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZYB_SD_V_C007_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZYB_SD_V_C007_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZYB_SD_V_C007.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZYB_SD_V_C007_TOTAL.

*.........table declarations:.................................*
TABLES: KNA1                           .
TABLES: T000                           .
TABLES: T001W                          .
TABLES: TVTW                           .
TABLES: TVTWT                          .
TABLES: ZYB_SD_T_C006                  .
TABLES: ZYB_SD_T_C007                  .
