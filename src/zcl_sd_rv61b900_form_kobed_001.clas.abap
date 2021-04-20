class ZCL_SD_RV61B900_FORM_KOBED_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RV61B900_FORM_KOBED .

  class-methods CLASS_CONSTRUCTOR .
protected section.
private section.

  types TY_TSMIRS type ZSDT_TSMIRS_VSAR .
  types:
    tt_tsmirs TYPE HASHED TABLE OF ty_tsmirs WITH UNIQUE KEY primary_key COMPONENTS vkorg vtweg vsarttr .

  class-data GT_TSMIRS type TT_TSMIRS .
  constants C_TASIMA type CHAR15 value 'memid_tasima'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_RV61B900_FORM_KOBED_001 IMPLEMENTATION.


METHOD class_constructor.

  IF gt_tsmirs IS INITIAL.
    SELECT *
      FROM zsdt_tsmirs_vsar
      INTO TABLE gt_tsmirs.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_komkbv2> TYPE komkbv2,
                 <lv_subrc>   TYPE sy-subrc.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'KOMKBV2' ). ASSIGN lr_data->* TO <ls_komkbv2>.
  lr_data = co_con->get_vars( 'SUBRC' ).   ASSIGN lr_data->* TO <lv_subrc>.
  "--------->> Anıl CENGİZ 12.02.2020 07:27:53
  "YUR-495
  <lv_subrc> = 0.
  ASSIGN gt_tsmirs[ KEY primary_key COMPONENTS vkorg   = <ls_komkbv2>-vkorg
                                               vtweg   = <ls_komkbv2>-vtweg
                                               vsarttr = <ls_komkbv2>-zvsart ] TO FIELD-SYMBOL(<ls_tsmirs>).
  "--------->> Anıl CENGİZ 22.12.2020 11:38:25
  "YUR-792
*  IF <ls_tsmirs> IS NOT ASSIGNED.
  IF sy-subrc ne 0.
    "---------<<
    <lv_subrc> = 4.
  ENDIF.
  "---------<<
ENDMETHOD.
ENDCLASS.
