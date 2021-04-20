FUNCTION zyb_sd_f_medyanagr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_MATNR) TYPE  RANGES_MATNR_TT
*"  TABLES
*"      ET_MED STRUCTURE  ZYB_SD_S_MEDAGR
*"  EXCEPTIONS
*"      NOT_GET_DATA
*"----------------------------------------------------------------------
*  DATA: report_info TYPE REF TO cl_salv_bs_runtime_info.
  FIELD-SYMBOLS: <lt_outtab> TYPE ANY TABLE,
                 <line>      TYPE any,
                 <fs>        TYPE any.

  DATA lo_data TYPE REF TO data.

  DATA: ls_med LIKE LINE OF et_med.
** Medyan ağırlığı hesaplama
  CHECK NOT it_matnr IS  INITIAL.


  " Let know the model
  cl_salv_bs_runtime_info=>set(
*    report_info=>set(
   EXPORTING
     display  = abap_false
     metadata = abap_false
     data     = abap_true
 ).

  SUBMIT zit_mm_parti_medyan_stok WITH so_matnr IN it_matnr
                                  AND RETURN.

  TRY.
      " get data from SALV model
      cl_salv_bs_runtime_info=>get_data_ref(
            IMPORTING
              r_data = lo_data
      ).
      ASSIGN lo_data->* TO <lt_outtab>.
    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE e899(fb) WITH 'Veri Bulunamadı'
         RAISING not_get_data.
  ENDTRY.

  cl_salv_bs_runtime_info=>clear_all( ).

  LOOP AT <lt_outtab> ASSIGNING <line>.
    CLEAR ls_med.
    PERFORM assign_value USING 'MATNR'
                               <line>
                      CHANGING ls_med.

    PERFORM assign_value USING 'MEDKG'
                               <line>
                CHANGING ls_med.

    APPEND ls_med TO et_med.
  ENDLOOP.

ENDFUNCTION.
FORM assign_value USING VALUE(fieldname)
                        line TYPE any
                CHANGING ls_med LIKE zyb_sd_s_medagr.
  FIELD-SYMBOLS: <fs> TYPE any.

  ASSIGN COMPONENT fieldname OF STRUCTURE line TO <fs>.
  IF <fs> IS ASSIGNED.
    CASE fieldname.
      WHEN 'MATNR'.  ls_med-matnr  = <fs>.
      WHEN 'MEDKG'.  ls_med-tartim = <fs>.
    ENDCASE.
  ENDIF.
  UNASSIGN <fs>.
ENDFORM.
