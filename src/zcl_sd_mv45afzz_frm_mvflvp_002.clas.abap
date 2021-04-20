class ZCL_SD_MV45AFZZ_FRM_MVFLVP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FRM_MVFLVP .

  type-pools ABAP .
  class-methods CHECK_BOART
    importing
      !IV_KNUMA type KNUMA
    returning
      value(RV_RETURN) type ABAP_BOOL .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FRM_MVFLVP_002 IMPLEMENTATION.


METHOD check_boart.
  rv_return = abap_false.
  SELECT SINGLE mandt
    FROM kona
    INTO sy-mandt
    WHERE knuma EQ iv_knuma
      AND boart EQ 'ZY08'. "Bedelsiz kampanya ise
  IF sy-subrc EQ 0.
    rv_return = abap_true.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.
  FIELD-SYMBOLS: <gs_vbap> TYPE vbap,
                 <gs_vbak> TYPE vbak.

  DATA: lr_data  TYPE REF TO data,
        lv_boart TYPE boart.

  lr_data = co_con->get_vars( 'VBAP' ). ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( 'VBAK' ). ASSIGN lr_data->* TO <gs_vbak>.

  IF check_boart( <gs_vbak>-zz_knuma_ag ) EQ abap_true.
    <gs_vbap>-pstyv = 'Z022'.
  ENDIF.
ENDMETHOD.
ENDCLASS.
