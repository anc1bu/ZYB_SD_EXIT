class ZCL_SD_MV45AFZZ_FORM_RDDOC_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_RDDOC .
  PROTECTED SECTION.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_access_one,
      vkorg      TYPE vkorg,
      vtweg      TYPE vtweg,
      kunnr      TYPE kunnr,
      sipdeg_gun TYPE zzsipdeg_gun,
    END OF ty_access_one .
  TYPES:
    tth_access_one TYPE HASHED TABLE OF ty_access_one WITH UNIQUE KEY vkorg vtweg kunnr .

  TYPES:
    BEGIN OF ty_access_two,
      vkorg      TYPE vkorg,
      vtweg      TYPE vtweg,
      lgort      TYPE lgort_d,
      sipdeg_gun TYPE zzsipdeg_gun,
    END OF ty_access_two .
  TYPES:
    tts_access_two TYPE SORTED TABLE OF ty_access_two WITH NON-UNIQUE KEY sipdeg_gun.

  DATA gt_access_one TYPE tth_access_one .
  DATA gt_access_two TYPE tts_access_two .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_RDDOC_003 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_vbak>  TYPE vbak,
                 <gs_vbkd>  TYPE vbkd,
                 <gt_xvbap> TYPE tab_xyvbap,
                 <gs_t180>  TYPE t180,
                 <gv_fcode> TYPE char20.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'XVBAP' ). ASSIGN lr_data->* TO <gt_xvbap>.
  lr_data = co_con->get_vars( 'VBKD' ).  ASSIGN lr_data->* TO <gs_vbkd>.
  lr_data = co_con->get_vars( 'T180' ).  ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'FCODE' ). ASSIGN lr_data->* TO <gv_fcode>.

  CHECK: <gs_t180>-trtyp EQ zif_sd_mv45afzz_form_rddoc~gcv_trtyp_change,
         <gs_vbak>-vtweg NE zif_sd_mv45afzz_form_rddoc~gcv_vtweg_exp,
         <gs_vbak>-vbtyp NE 'K',
         <gs_vbak>-vbtyp NE 'L',
         sy-batch IS INITIAL,
         sy-binpt IS INITIAL.

  zcl_sd_toolkit=>enqueue_read_akkp( EXPORTING iv_lcnum           = <gs_vbkd>-lcnum
                                               iv_vbeln_va        = <gs_vbkd>-vbeln
                                               iv_same_user_cntrl = abap_true ).

ENDMETHOD.
ENDCLASS.
