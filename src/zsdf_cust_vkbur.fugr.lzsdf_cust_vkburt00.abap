*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.02.2020 at 02:13:39
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_CUST_VKBUR.................................*
DATA:  BEGIN OF STATUS_ZSDT_CUST_VKBUR               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_CUST_VKBUR               .
CONTROLS: TCTRL_ZSDT_CUST_VKBUR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_CUST_VKBUR               .
TABLES: ZSDT_CUST_VKBUR                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
