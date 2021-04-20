*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.01.2021 at 11:45:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSDT_CUST_CNTRL.................................*
DATA:  BEGIN OF STATUS_ZSDT_CUST_CNTRL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDT_CUST_CNTRL               .
CONTROLS: TCTRL_ZSDT_CUST_CNTRL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSDT_CUST_CNTRL               .
TABLES: ZSDT_CUST_CNTRL                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
