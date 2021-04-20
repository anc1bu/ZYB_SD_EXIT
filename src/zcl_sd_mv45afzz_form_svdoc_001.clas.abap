CLASS zcl_sd_mv45afzz_form_svdoc_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_form_svdoc .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS cv_aprproc_zf01 TYPE zsdd_apr_process VALUE 'ZF01'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SVDOC_001 IMPLEMENTATION.


  METHOD zif_bc_exit_imp~execute.

    FIELD-SYMBOLS: <lt_xvbap> TYPE tab_xyvbap,
                   <ls_vbak>  TYPE vbak,
                   <ls_yvbak> TYPE vbak,
                   <ls_t180>  TYPE t180,
                   <lt_xkomv> TYPE komv_tab.

    DATA: lr_data TYPE REF TO data.

    lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <lt_xvbap>.
    lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
    lr_data = co_con->get_vars( 'YVBAK' ).     ASSIGN lr_data->* TO <ls_yvbak>.
    lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
    lr_data = co_con->get_vars( 'XKOMV' ).     ASSIGN lr_data->* TO <lt_xkomv>.

    "--------->> Anıl CENGİZ 07.05.2019 08:05:27
    "YUR-340

    CHECK: <ls_vbak>-vtweg EQ '10'.

    TRY.
        NEW zcl_sd_apr_event_create(
                        iv_process  = cv_aprproc_zf01
                        is_vbak     = <ls_vbak>
                        is_ovbak    = <ls_yvbak>
                        it_vbap     = <lt_xvbap>
                        it_komv     = <lt_xkomv>
                        is_t180     = <ls_t180> )->execute( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

*CLEAR *vbep."V1397 hatası için - YUR-409
*CLEAR xvbep[]."V1397 hatası için - YUR-409
    "---------<<
  ENDMETHOD.
ENDCLASS.
