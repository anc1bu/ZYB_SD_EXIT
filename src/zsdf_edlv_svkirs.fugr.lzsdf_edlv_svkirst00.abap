*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 27.07.2020 at 16:26:30
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EDLV_SVKIRS................................*
DATA:  BEGIN OF STATUS_ZSDT_EDLV_SVKIRS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EDLV_SVKIRS              .
CONTROLS: TCTRL_ZSDT_EDLV_SVKIRS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EDLV_SVKIRS              .
TABLES: ZSDT_EDLV_SVKIRS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
