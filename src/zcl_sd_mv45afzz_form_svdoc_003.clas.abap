class ZCL_SD_MV45AFZZ_FORM_SVDOC_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SVDOC .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS cv_aprproc_zf01 TYPE zsdd_apr_process VALUE 'ZF01'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SVDOC_003 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
  "SAVE_PREPARE exitinde hata almıyor ancak daha sonrasında burada hata aldığında siparişi kaydediyor cariden düşmüyor.
*    NEW zcl_sd_mv45afzz_form_sdp_001( )->zif_bc_exit_imp~execute( CHANGING co_con = co_con ).

ENDMETHOD.
ENDCLASS.
