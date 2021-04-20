*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.12.2020 at 12:19:27
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMALZEME_11.....................................*
DATA:  BEGIN OF STATUS_ZMALZEME_11                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMALZEME_11                   .
CONTROLS: TCTRL_ZMALZEME_11
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMALZEME_11                   .
TABLES: ZMALZEME_11                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
