*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 29.06.2020 at 16:27:44
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_EXC_VLD_SUR................................*
DATA:  BEGIN OF STATUS_ZSDT_EXC_VLD_SUR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_EXC_VLD_SUR              .
CONTROLS: TCTRL_ZSDT_EXC_VLD_SUR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_EXC_VLD_SUR              .
TABLES: ZSDT_EXC_VLD_SUR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
