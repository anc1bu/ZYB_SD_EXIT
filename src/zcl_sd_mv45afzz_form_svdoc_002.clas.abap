class ZCL_SD_MV45AFZZ_FORM_SVDOC_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SVDOC .
protected section.
private section.

  constants CV_APRPROC_ZF01 type ZSDD_APR_PROCESS value 'ZF01'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SVDOC_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <lt_xvbup>    TYPE tab_xyvbup.

  DATA: lr_data    TYPE REF TO data.

  lr_data    = co_con->get_vars( 'XVBUP' ).     ASSIGN lr_data->* TO <lt_xvbup>.
  "--------->> Anıl CENGİZ 29.05.2019 18:00:17
  "YUR-380
  CHECK: sy-cprog(6) NE 'RVKRED'.
  LOOP AT <lt_xvbup> ASSIGNING FIELD-SYMBOL(<ls_xvbup>)
     WHERE updkz NE 'D'
     AND cmppi EQ 'B'. " Kredi kontrolü işlem tamam değil
    IF <ls_xvbup>-absta NE 'C'.   " Red gerekçesi yoksa
      MESSAGE e020(zsd_va)
         WITH <ls_xvbup>-vbeln <ls_xvbup>-posnr.
    ENDIF.
  ENDLOOP.
  "---------<<
ENDMETHOD.
ENDCLASS.
