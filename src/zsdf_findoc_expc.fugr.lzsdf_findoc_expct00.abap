*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 20.08.2019 at 18:57:50
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_FINDOC_EXPC................................*
DATA:  BEGIN OF STATUS_ZSDT_FINDOC_EXPC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_FINDOC_EXPC              .
CONTROLS: TCTRL_ZSDT_FINDOC_EXPC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_FINDOC_EXPC              .
TABLES: ZSDT_FINDOC_EXPC               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
