FUNCTION zyb_sd_f_condition_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_KAPPL) TYPE  KAPPL
*"     REFERENCE(I_KSCHL) TYPE  KSCHL
*"     REFERENCE(I_KOMK) TYPE  KOMK
*"     REFERENCE(I_KOMP) TYPE  KOMP
*"  EXPORTING
*"     REFERENCE(E_KOTABNR) TYPE  KOTABNR
*"     REFERENCE(E_KONP) TYPE  KONP
*"----------------------------------------------------------------------

  DATA : lv_subrc TYPE sy-subrc.
  DATA : ls_koprt TYPE koprt.
  DATA : lt_condition_records TYPE STANDARD TABLE OF a000.
  DATA : ls_condition_record  TYPE a000.
  DATA : ls_konp   TYPE konp.
  DATA : lt_konp   TYPE TABLE OF konp.
  DATA : lt_scales TYPE TABLE OF condscale.
  DATA : ls_scale  TYPE condscale.
*  DATA : ls_fiyat  TYPE zzersdgens056.
*  DATA : ls_t682i  TYPE t682i.
  DATA: gt_t682i LIKE t682i OCCURS 0 WITH HEADER LINE.

    DEFINE lm_fullen .
    clear : ls_konp,lv_subrc.
    perform konp_fuellen using ls_condition_record-knumh i_kappl
                               &1 gc_yes ls_konp lv_subrc.
    if lv_subrc is initial.
      append ls_konp to lt_konp.
    endif.
  END-OF-DEFINITION.

    PERFORM t685_fuellen USING gc_kvewe
                             i_kappl
                             i_kschl
                             lv_subrc
                             gs_t685.

  PERFORM t682i_fuellen TABLES gt_t682i
                         USING gc_kvewe
                               i_kappl
                               gs_t685-kozgf.
LOOP AT gt_t682i.
CALL FUNCTION 'SD_COND_ACCESS'
  EXPORTING
    application                      = i_kappl
    condition_type                   = i_kschl
    date                             = i_komk-prsdt
    header_comm_area                 = i_komk
    position_comm_area               = i_komp
*   PRESTEP                          = ' '
*   PROTOCOL_DATE                    = ' '
*   PROTOCOL_ACCESS                  = ' '
*   READ_ONLY_ONE_RECORD             = 'X'
    t682i_i                          = gt_t682i
*   T682IA_I                         =
    koprt_i                          = ls_koprt
*   SDPROTHEAD_I                     =
*   CALL_MODUS                       = 'A'
*   READ_ALL_PRESTEP                 = ' '
*   NO_MEM_IMPORT                    = ' '
* IMPORTING
*   CONDITION_IS_PURELY_HEADER       =
*   CONDITION_IS_IN_MEMORY           =
  TABLES
    condition_records                = lt_condition_records
* CHANGING
*   POSITION_COMM_AREA_DYNAMIC       =
*   POSITION_COMM_MULTI_VALUES       =
 EXCEPTIONS
   FIELD_IS_INITIAL                 = 1
   NOT_READ_UNQUALIFIED             = 2
   READ_BUT_NOT_FOUND               = 3
   READ_BUT_BLOCKED                 = 4
   T682Z_MISSING                    = 5
   T681V_MISSING                    = 6
   T681Z_MISSING                    = 7
   MVA_ERROR                        = 8
   OTHERS                           = 9
          .
IF sy-subrc IS INITIAL.
      READ TABLE lt_condition_records INTO ls_condition_record INDEX 1.
      CLEAR : ls_konp,lv_subrc.
      PERFORM konp_fuellen USING ls_condition_record-knumh i_kappl
                                 i_kschl gc_yes e_konp lv_subrc.

ENDIF.
ENDLOOP.
ENDFUNCTION.
