FUNCTION-POOL zyb_sd_g_ass_chrc.            "MESSAGE-ID ..

* INCLUDE LZYB_SD_G_ASS_CHRCD...             " Local class definition

DATA:
  gv_atwrt TYPE atwrt,
  gv_atflv TYPE atflv.

DATA:
  gv_matnr      TYPE matnr,               " Paletteki Malzeme
  gv_plt_tip    TYPE mvgr1,               " Palet Tipi
  gv_kut_tip    TYPE mvgr2,               " Kutu Tipi
  gv_meinh      TYPE meinh,
  gv_kutu_mik   TYPE zyb_sd_e_kutu_mik,   " Kutudaki Miktar
  gv_palet_mik  TYPE zyb_sd_e_palet_mik,  " Paletteki Miktar
  gv_kutu_alan  TYPE zyb_sd_e_kutu_alan,  " Kutudaki Alan
  gv_palet_alan TYPE zyb_sd_e_palet_alan. " Paletteki Alan

DATA:
*"" Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
  ls_md001 LIKE zyb_t_md001,
  ls_query LIKE cuov_01.

CONSTANTS:
  charx(1) TYPE c VALUE 'X'.

DEFINE get_arg.
  CLEAR: gv_atwrt, gv_atflv.
  CALL FUNCTION 'CUOV_GET_FUNCTION_ARGUMENT'
    EXPORTING
      argument      = &1
    IMPORTING
      sym_val       = gv_atwrt
      num_val       = gv_atflv
    TABLES
      query         = query
    EXCEPTIONS
      arg_not_found = 01.

  CASE &2.
    WHEN 'CHAR'. &3 = gv_atwrt.
    WHEN 'NUM'.  &3 = gv_atflv.
  ENDCASE.
END-OF-DEFINITION.
DEFINE set_arg.
  CLEAR: gv_atwrt, gv_atflv.

  CASE &2.
    WHEN 'CHAR'.
      gv_atwrt = &3.
    WHEN 'NUM'.
      gv_atflv = &3.
  ENDCASE.

  CALL FUNCTION 'CUOV_SET_FUNCTION_ARGUMENT'
    EXPORTING
      argument                = &1
      vtype                   = &2
      sym_val                 = gv_atwrt
      num_val                 = gv_atflv
    TABLES
      match                   = match
    EXCEPTIONS
      existing_value_replaced = 01.
END-OF-DEFINITION.
