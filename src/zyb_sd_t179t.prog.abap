*&---------------------------------------------------------------------*
*& Report  ZYB_SD_T179T
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zyb_sd_t179t_top                        .    " global Data

* INCLUDE ZYB_SD_T179T_O01                        .  " PBO-Modules
* INCLUDE ZYB_SD_T179T_I01                        .  " PAI-Modules
 INCLUDE zyb_sd_t179t_f01                        .  " FORM-Routines

 TABLES: t179t.
 DATA: it_t179t TYPE TABLE OF t179t,
       ls_t179t TYPE t179t.
PARAMETERS: p_vtext TYPE vtext.

INITIALIZATION.
SELECT * FROM t179t INTO CORRESPONDING FIELDS OF TABLE it_t179t.

  break anilc.
  LOOP AT it_t179t INTO ls_t179t WHERE vtext IS INITIAL.
    UPDATE t179t SET vtext = 'X'
                 WHERE spras = ls_t179t-spras
                 AND prodh = ls_t179t-prodh.
    ENDLOOP.
