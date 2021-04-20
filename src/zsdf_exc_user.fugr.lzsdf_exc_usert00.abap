*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 02.03.2021 at 09:45:25
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXC_USER...................................*
DATA:  BEGIN OF STATUS_ZSDT_EXC_USER                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXC_USER                 .
CONTROLS: TCTRL_ZSDT_EXC_USER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXC_USER                 .
TABLES: ZSDT_EXC_USER                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
