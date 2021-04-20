*&---------------------------------------------------------------------*
*& Report  ZYBSD_R_ZF99
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zybsd_r_zf99.

INCLUDE rlb_invoice_data_declare.
INCLUDE messdata.      "for XNAST to be available
* Tanımlamalar
INCLUDE zybsd_i_zf99_def.
*Form
INCLUDE zybsd_i_zf99_frm.

*---------------------------------------------------------------------*
*       FORM ENTRY
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  DATA: lf_retcode TYPE sy-subrc.
  CLEAR retcode.
  xscreen = us_screen.
  break bbozaci.
  PERFORM processing USING us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                    "ENTRY
FORM output_time USING dat LIKE nast-vsdat
                       ura LIKE nast-vsura
                       urb LIKE nast-vsurb.
  IF      xnast-kschl = 'ZF99'
  AND     xnast-nacha = '1'.           "when printing
    dat = sy-datum.
    ura = sy-uzeit + '000003'.
    urb = ura + '000003'.
  ENDIF.
ENDFORM.
