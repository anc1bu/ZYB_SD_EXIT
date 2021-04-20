class ZCL_SD_MV45AFZZ_FORM_FLDMD_004 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_FLDMD .

  types:
    BEGIN OF ty_svken,
             vkorg TYPE vkorg,
             vtweg TYPE vtweg,
           END OF ty_svken .
  types:
    tth_svken TYPE HASHED TABLE OF ty_svken WITH UNIQUE KEY vkorg vtweg .

  class-data GT_SVKEN type TTH_SVKEN .

  class-methods CLASS_CONSTRUCTOR .
  type-pools ABAP .
  class-methods CHECK_VTWEG
    importing
      !IV_VKORG type VKORG
      !IV_VTWEG type VTWEG
    returning
      value(RV_RETURN) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_FLDMD_004 IMPLEMENTATION.


METHOD check_vtweg.

  DATA: ls_svken TYPE ty_svken.

  rv_return = abap_false.

  ASSIGN gt_svken[ KEY primary_key COMPONENTS vkorg = iv_vkorg
                                              vtweg = iv_vtweg ] TO FIELD-SYMBOL(<gs_svken>).
  IF sy-subrc EQ 0.
    rv_return = abap_true.
  ENDIF.
ENDMETHOD.


METHOD class_constructor.

  IF gt_svken[] IS INITIAL.
    SELECT vkorg vtweg
      FROM zsdt_vtweg_svken
      INTO CORRESPONDING FIELDS OF TABLE gt_svken.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_screen> TYPE screen,
                 <gs_sy>     TYPE syst,
                 <gs_t180>   TYPE t180,
                 <gs_vbak>   TYPE vbak,
                 <gs_xvbuk>  TYPE vbukvb.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'SCREEN' ). ASSIGN lr_data->* TO <gs_screen>.
  lr_data = co_con->get_vars( 'SY' ).     ASSIGN lr_data->* TO <gs_sy>.
  lr_data = co_con->get_vars( 'T180' ).   ASSIGN lr_data->* TO <gs_t180>.
  lr_data = co_con->get_vars( 'VBAK' ).   ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'XVBUK' ).  ASSIGN lr_data->* TO <gs_xvbuk>.

  CHECK: <gs_t180>-trtyp EQ zif_sd_mv45afzz_form_fldmd~cv_trtyp_change, "Değiştirme kipinde ise
         ( <gs_sy>-dynnr EQ '4302' OR "Başlık ekranı ise kapat.
           <gs_sy>-dynnr EQ '4440' OR "Genel bakış ekranı ise kapat.
           <gs_sy>-dynnr EQ '4021' OR "Genel bakış ekranı ise kapat.
           <gs_sy>-dynnr EQ '4351' OR "Başlık ekranı ise kapat.
           <gs_sy>-dynnr EQ '4701' ) , "İlk giriş ekranı ise kapat.
         check_vtweg( EXPORTING iv_vkorg = <gs_vbak>-vkorg
                                iv_vtweg = <gs_vbak>-vtweg ) EQ abap_true, "Dağıtım kanalı
         <gs_xvbuk>-lfstk NE 'A',
         "--------->> Anıl CENGİZ 19.10.2020 16:27:33
         "YUR-754
         <gs_vbak>-vbtyp EQ zif_sd_mv45afzz_form_fldmd~cv_vbtyp_siparis.
  "---------<<
  CASE <gs_screen>-name.
    WHEN 'VBKD-VSART'.   "Sevk Türü
      screen-input = 0.
    WHEN 'RV45A-KETDAT'. "Belgenin istenen teslimat tarihi
      screen-input = 0.
    WHEN 'RV45A-KPRGBZ'. " İstenen teslimat tarihinin tipi
      screen-input = 0.
    WHEN 'KUWEV-KUNNR'.  "Malı teslim alan muhattabını.
      screen-input = 0.
    WHEN 'VBKD-BSTDK'.   "Müşteri SAS No.
      screen-input = 0.
    WHEN 'VBKD-BSTKD'.   "Müşteri SAS Tarihi.
      screen-input = 0.
  ENDCASE.

ENDMETHOD.
ENDCLASS.
