class ZCL_SD_EXIT_SMOD_SAPMF02K_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_SAPMF02K .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_SAPMF02K_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
* Vergi numarası mükerrerlik kontrolü
  DATA: lr_data  TYPE REF TO data,
        lv_lifnr TYPE lifnr.

  FIELD-SYMBOLS: <ls_lfa1> TYPE lfa1.

  lr_data = co_con->get_vars( 'LFA1' ).  ASSIGN lr_data->* TO <ls_lfa1>.

  TRY .
      SELECT SINGLE lifnr
        FROM lfa1
        INTO lv_lifnr
        WHERE stcd2 EQ <ls_lfa1>-stcd2
          AND lifnr NE <ls_lfa1>-lifnr
          AND loevm NE abap_true.
      IF sy-subrc EQ 0 AND
         ( <ls_lfa1>-ktokk EQ 'YIGI' OR <ls_lfa1>-ktokk EQ 'YIGD' OR <ls_lfa1>-ktokk EQ 'PERS' ).
*  OR i_lfa1-ktokk EQ 'ORTK' ) .
*  "--------->> Anıl CENGİZ 21.11.2019 10:48:24
*  "YUR-517
*  AND sy-uname NE 'ALPER.SAYAR'.
*  "---------<<
        RAISE EXCEPTION TYPE zcx_mm_vndr_cntrl
          EXPORTING
            textid   = zcx_mm_vndr_cntrl=>zmm_038
            gv_lifnr = lv_lifnr.
      ENDIF.
    CATCH zcx_mm_vndr_cntrl INTO DATA(lo_cx_mm_vndr_cntrl) .
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          previous = lo_cx_mm_vndr_cntrl.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
