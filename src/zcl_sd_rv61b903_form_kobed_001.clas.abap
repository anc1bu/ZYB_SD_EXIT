class ZCL_SD_RV61B903_FORM_KOBED_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RV61B903_FORM_KOBED .

  types:
    BEGIN OF ty_params.
          INCLUDE TYPE komkbv2.
  TYPES:  kappl TYPE sna_kappl,
          kschl TYPE sna_kschl,
          END OF ty_params .

  constants CV_YOK type ZSDD_SVKIRS_OUTPUT value 'Y'. "#EC NOTEXT

  methods SEVK_IRS_KNTRL
    importing
      !IS_PARAMS type TY_PARAMS
    returning
      value(RV_ISSUE_OUTPUT) type ZSDD_SVKIRS_OUTPUT
    raising
      ZCX_SD_RV61B903_FORM_KOBED .
protected section.
private section.

  constants CV_BUKRS type BUKRS value '1000'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_RV61B903_FORM_KOBED_001 IMPLEMENTATION.


METHOD sevk_irs_kntrl.

  IF is_params-kappl IS NOT INITIAL AND
     is_params-kschl IS NOT INITIAL.
    SELECT SINGLE issue_output
      FROM zsdt_edlv_svkirs
      INTO rv_issue_output
      WHERE kappl EQ is_params-kappl
        AND kschl EQ is_params-kschl
        AND vkorg EQ is_params-vkorg
        AND vtweg EQ is_params-vtweg.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_sd_rv61b903_form_kobed
        EXPORTING
          textid = zcx_sd_rv61b903_form_kobed=>zsd_045
          kappl  = is_params-kappl
          kschl  = is_params-kschl.
    ENDIF.
  ELSE.
    RAISE EXCEPTION TYPE zcx_sd_rv61b903_form_kobed
      EXPORTING
        textid = zcx_sd_rv61b903_form_kobed=>zsd_048.
  ENDIF.
ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_komkbv2> TYPE komkbv2,
                 <lv_subrc>   TYPE sy-subrc.

  DATA: lv_indicator(1),
        lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'KOMKBV2' ). ASSIGN lr_data->* TO <ls_komkbv2>.
  lr_data = co_con->get_vars( 'SUBRC' ).   ASSIGN lr_data->* TO <lv_subrc>.

  "--------->> Anıl CENGİZ 11.11.2019 11:40:55
  "YUR-515
  <lv_subrc> = 0.
  TRY .
      DATA(lv_issue_output) = sevk_irs_kntrl( is_params = VALUE #( kappl = 'V2'
                                                                   kschl = 'ZL01'
                                                                   vkorg = <ls_komkbv2>-vkorg
                                                                   vtweg = <ls_komkbv2>-vtweg ) ).

      CHECK: lv_issue_output EQ cv_yok. "Çıktı sürekli türetilecekse aşağıya girmesine gerek yok.

      "31.03.2020 tarihinden sonra karşı taraf e-irsaliye müşterisi değil ise bile e-irsaliye gönderilecek. O yüzden yıldızlandı.
*      CALL FUNCTION '/FORIBA/ED0_F002'
*        EXPORTING
*          i_doc_issue_date = <ls_komkbv2>-/isistr/ef_fkdat
*          i_bukrs          = cv_bukrs
**         I_ERP_DOC_NUM    =
**         I_ADD_KEY_VALUES =
*          i_kunnr          = <ls_komkbv2>-kunag
**         I_LIFNR          =
*        IMPORTING
*          e_rcl_indicator  = lv_indicator.
*      IF lv_indicator EQ abap_true.
      <lv_subrc> = 4.
*      ENDIF.

    CATCH zcx_sd_rv61b903_form_kobed INTO DATA(lo_cx_sd_rv61b903_form_kobed) .
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          previous = lo_cx_sd_rv61b903_form_kobed.
  ENDTRY.
  "---------<<


ENDMETHOD.
ENDCLASS.
