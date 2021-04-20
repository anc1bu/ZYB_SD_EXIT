class ZCL_SD_MV50AFZ1_FORM_SDP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV50AFZ1_FORM_SDP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV50AFZ1_FORM_SDP_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  DATA: lr_data TYPE REF TO data.

  FIELD-SYMBOLS: <lt_xlips>  TYPE shp_lips_t,
                 <ls_v50agl> TYPE v50agl.

  lr_data = co_con->get_vars( 'XLIPS' ).  ASSIGN lr_data->* TO <lt_xlips>.
  lr_data = co_con->get_vars( 'V50AGL' ). ASSIGN lr_data->* TO <ls_v50agl>.

  CHECK: <ls_v50agl>-warenausgang EQ abap_true. "Mal çıkışı sırasında

  LOOP AT <lt_xlips> TRANSPORTING NO FIELDS
    WHERE mtart NE 'ZYYK'
      AND pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
    EXIT.
  ENDLOOP.
  CHECK: sy-subrc NE 0.

  LOOP AT <lt_xlips> ASSIGNING FIELD-SYMBOL(<ls_xlips_vgbel>)
  WHERE vgbel IS NOT INITIAL.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    LOOP AT <lt_xlips> ASSIGNING FIELD-SYMBOL(<ls_xlips>)
      WHERE pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.
      IF <ls_xlips> IS ASSIGNED.
        <ls_xlips>-vgbel = <ls_xlips_vgbel>-vgbel.
        <ls_xlips>-updkz = 'U'.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.
ENDCLASS.
