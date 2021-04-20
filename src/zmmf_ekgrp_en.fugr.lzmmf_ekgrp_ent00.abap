*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.03.2021 at 16:59:13
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMMT_EKGRP_EN...................................*
DATA:  BEGIN OF STATUS_ZMMT_EKGRP_EN                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMT_EKGRP_EN                 .
CONTROLS: TCTRL_ZMMT_EKGRP_EN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMMT_EKGRP_EN                 .
TABLES: ZMMT_EKGRP_EN                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
