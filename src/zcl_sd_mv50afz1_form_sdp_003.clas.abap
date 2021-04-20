class ZCL_SD_MV50AFZ1_FORM_SDP_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV50AFZ1_FORM_SDP .

  class-methods CLASS_CONSTRUCTOR .
protected section.
private section.

  types:
    BEGIN OF ty_pstyv,
      pstyv TYPE pstyv,
    END OF ty_pstyv .
  types:
    tt_pstyv TYPE STANDARD TABLE OF ty_pstyv WITH DEFAULT KEY .

  class-data GT_PSTYV_FKREL type TT_PSTYV .
ENDCLASS.



CLASS ZCL_SD_MV50AFZ1_FORM_SDP_003 IMPLEMENTATION.


method CLASS_CONSTRUCTOR.

  IF gt_pstyv_fkrel IS INITIAL.
    SELECT pstyv
      FROM tvap
      INTO TABLE gt_pstyv_fkrel
      WHERE fkrel NE space.
  ENDIF.

endmethod.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gt_xlips>  TYPE shp_lips_t,
                 <gt_xvbup>  TYPE tab_xyvbup,
                 <gt_xvbuk>  TYPE shp_vl10_vbuk_t,
                 <gs_v50agl> TYPE v50agl.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XLIPS' ).  ASSIGN lr_data->* TO <gt_xlips>.
  lr_data = co_con->get_vars( 'XVBUP' ).  ASSIGN lr_data->* TO <gt_xvbup>.
  lr_data = co_con->get_vars( 'XVBUK' ).  ASSIGN lr_data->* TO <gt_xvbuk>.
  lr_data = co_con->get_vars( 'V50AGL' ). ASSIGN lr_data->* TO <gs_v50agl>.

  CHECK: <gs_v50agl>-warenausgang EQ abap_true. "Mal çıkışı sırasında

  DATA(lt_rng_pstyv) = VALUE  rjksd_pstyv_range_tab( FOR wa IN <gt_xlips> WHERE ( pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm ) ( sign = 'I' option = 'EQ' low = wa-pstyv ) ).
  DATA(lt_pstyv_fkrel) = VALUE tt_pstyv( FOR wa1 IN gt_pstyv_fkrel WHERE ( pstyv IN lt_rng_pstyv ) ( pstyv = wa1-pstyv ) ).
  IF lt_pstyv_fkrel IS INITIAL.

    LOOP AT <gt_xlips> ASSIGNING FIELD-SYMBOL(<gs_xlips>)
      WHERE pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.

      ASSIGN <gt_xvbup>[ vbeln = <gs_xlips>-vbeln
                         posnr = <gs_xlips>-posnr ] TO FIELD-SYMBOL(<gs_xvbup>).
      IF sy-subrc EQ 0.
        IF <gs_xvbup>-updkz NE 'I'.
          <gs_xvbup>-updkz = 'U'.
        ENDIF.
        CLEAR: <gs_xvbup>-fksta.
        <gs_xvbup>-gbsta = 'C'.
        CLEAR: <gs_xlips>-fkrel.
      ENDIF.
      "Bütün kalemler faturalama ilişkili değil ise VBUK tablosu ona göre güncellenir.
      DATA(lt_vbup_fksta_1) = VALUE tab_xyvbup( FOR wa2 IN <gt_xvbup> WHERE ( fksta IS NOT INITIAL ) ( CORRESPONDING #( wa2 ) ) ).
      IF lt_vbup_fksta_1 IS INITIAL.
        ASSIGN <gt_xvbuk>[ vbeln = <gs_xlips>-vbeln ] TO FIELD-SYMBOL(<gs_xvbuk>).
        IF sy-subrc EQ 0.
          CLEAR: <gs_xvbuk>-fkstk.
          <gs_xvbuk>-gbstk = 'C'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.
ENDCLASS.
