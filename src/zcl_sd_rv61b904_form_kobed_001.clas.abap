class ZCL_SD_RV61B904_FORM_KOBED_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_RV61B904_FORM_KOBED .
protected section.
private section.

  constants CV_BUKRS type BUKRS value '1000'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_RV61B904_FORM_KOBED_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <ls_kompbme> TYPE kompbme,
                 <lv_subrc>   TYPE sy-subrc.

  DATA: lv_indicator(1),
        lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'KOMPBME' ). ASSIGN lr_data->* TO <ls_kompbme>.
  lr_data = co_con->get_vars( 'SUBRC' ).   ASSIGN lr_data->* TO <lv_subrc>.
  "--------->> Anıl CENGİZ 11.11.2019 11:40:55
  "YUR-515
  "Standartta 173 çıktı koşul rutini atandığı için böyle yapıldı.
  PERFORM kobed_173 IN PROGRAM saplv61b.
  <lv_subrc> = sy-subrc.
  CHECK: sy-subrc EQ 0.

  TRY .
      NEW zcl_mm_iade_irsaliye( )->fill_firma( VALUE #( bwart = <ls_kompbme>-/isistr/ef_bwart
                                                        umlgo = <ls_kompbme>-zzumlgo
                                                        lifnr = <ls_kompbme>-zzlifnr ) ).
    CATCH zcx_mm_iade_irsaliye INTO DATA(lo_cx_mm_iade_irsaliye).
      CASE <ls_kompbme>-/isistr/ef_bwart.
        WHEN '311'.
*          RAISE EXCEPTION TYPE zcx_bc_exit_imp
*            EXPORTING
*              previous = lo_cx_mm_iade_irsaliye.
          RETURN. "Exception a düşer ise depolar arası süreçte bizimle alakalı olmayan bir depoya gittiği anlamına gelir. O yüzden sub-rc 4 atanmaz.
*        WHEN '161' OR '122' OR '541'.
*
        WHEN OTHERS.
          "Exception yaz.
      ENDCASE.
  ENDTRY.

  CASE <ls_kompbme>-/isistr/ef_bwart.
    WHEN '311'.
      <lv_subrc> = 4.
    WHEN '161' OR '122' OR '541'.
      TRY.
          DATA(lv_issue_output) = NEW zcl_sd_rv61b903_form_kobed_001( )->sevk_irs_kntrl( is_params = VALUE #( kappl = 'ME'
                                                                                                              kschl = 'ZIRS' ) ).
          CHECK: lv_issue_output EQ zcl_sd_rv61b903_form_kobed_001=>cv_yok. "Çıktı sürekli türetilecekse aşağıya girmesine gerek yok.
          "31.03.2020 tarihinden sonra karşı taraf e-irsaliye satıcısı değil ise bile e-irsaliye gönderilecek. O yüzden yıldızlandı.
*      CALL FUNCTION '/FORIBA/ED0_F002'
*        EXPORTING
*          i_doc_issue_date = <ls_kompbme>-/isistr/ef_fkdat
*          i_bukrs          = cv_bukrs
**         I_ERP_DOC_NUM    =
**         I_ADD_KEY_VALUES =
**         i_kunnr          =
*          i_lifnr          = <ls_kompbme>-zzlifnr
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
    WHEN OTHERS.
      "Exception yaz.
  ENDCASE.
  "---------<<
ENDMETHOD.
ENDCLASS.
