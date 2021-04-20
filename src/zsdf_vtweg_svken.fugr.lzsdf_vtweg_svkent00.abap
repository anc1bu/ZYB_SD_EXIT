*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.09.2020 at 11:06:00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_VTWEG_SVKEN................................*
DATA:  BEGIN OF STATUS_ZSDT_VTWEG_SVKEN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_VTWEG_SVKEN              .
CONTROLS: TCTRL_ZSDT_VTWEG_SVKEN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_VTWEG_SVKEN              .
TABLES: ZSDT_VTWEG_SVKEN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
