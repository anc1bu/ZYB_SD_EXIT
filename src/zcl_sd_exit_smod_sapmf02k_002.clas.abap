class ZCL_SD_EXIT_SMOD_SAPMF02K_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_SAPMF02K .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02K_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
* Vergi Numarası uzunluk kontrolü
  DATA: lr_data TYPE REF TO data.

  FIELD-SYMBOLS: <ls_lfa1>  TYPE lfa1.

  lr_data = co_con->get_vars( 'LFA1' ).  ASSIGN lr_data->* TO <ls_lfa1>.

  TRY .
      DATA(lv_len) = strlen( <ls_lfa1>-stcd2 ).
      IF <ls_lfa1>-ktokk EQ 'YIGI' OR <ls_lfa1>-ktokk EQ 'YIGD'
                                   OR <ls_lfa1>-ktokk EQ 'PERS' .
*                             OR <ls_lfa1>-ktokk EQ 'ORTK'.
        IF <ls_lfa1>-stkzn EQ abap_true.
          IF lv_len <> 11.
            RAISE EXCEPTION TYPE zcx_mm_vndr_cntrl
              EXPORTING
                textid = zcx_mm_vndr_cntrl=>zmm_036.
          ENDIF.
        ELSE.
          IF lv_len <> 10.
            RAISE EXCEPTION TYPE zcx_mm_vndr_cntrl
              EXPORTING
                textid = zcx_mm_vndr_cntrl=>zmm_037.
          ENDIF.
        ENDIF.
      ENDIF.

    CATCH zcx_mm_vndr_cntrl INTO DATA(lo_cx_mm_vndr_cntrl) .
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          previous = lo_cx_mm_vndr_cntrl.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
