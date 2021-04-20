*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_ZF99_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PROCESSING
*&---------------------------------------------------------------------*
FORM processing  USING    proc_screen
                 CHANGING cf_retcode.

  DATA:
    l_number         TYPE tbtcjob-jobcount,
    l_name           TYPE tbtcjob-jobname,
    print_parameters TYPE pri_params.

  CLEAR: gv_vbeln.

  IF nast-objky+10 NE space.
    gv_vbeln = nast-objky+16(10).
  ELSE.
    gv_vbeln = nast-objky.
  ENDIF.
* Fatura Bilgileri Devralma
  PERFORM get_data USING gv_vbeln CHANGING cf_retcode.


  CALL FUNCTION 'ZYBSD_F_BIL_PROC'
    STARTING NEW TASK 'TASK'
    DESTINATION 'NONE'
    EXPORTING
      i_vbeln = gv_vbeln.


  IF cf_retcode <> 0.
    PERFORM protocol_update.
  ENDIF.


ENDFORM.                    " PROCESSING
*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--CF_RETCODE  text
*----------------------------------------------------------------------*
FORM get_data USING p_vbeln CHANGING cf_retcode.
  CLEAR: ls_vbrk, lt_vbrp, lt_vbrp[].


  SELECT SINGLE * FROM vbrk INTO ls_vbrk
          WHERE vbeln EQ p_vbeln.

  SELECT * FROM vbrp INTO TABLE lt_vbrp
          WHERE vbeln EQ p_vbeln.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  JOB_OPEN
*&---------------------------------------------------------------------*
FORM job_open  USING name
            CHANGING cf_retcode
                     number TYPE tbtcjob-jobcount.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = name
      jobclass         = 'A'
    IMPORTING
      jobcount         = number
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.
    cf_retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    " JOB_OPEN
*&---------------------------------------------------------------------*
*&      Form  JOB_CLOSE
*&---------------------------------------------------------------------*
FORM job_close USING name number
            CHANGING cf_retcode.
  DATA:
    lv_sdlstrttm   LIKE tbtcjob-sdlstrttm,
    lv_released(1).
  CLEAR: lv_sdlstrttm, lv_released.

  lv_sdlstrttm = sy-uzeit + 3.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = number
      jobname              = name
*     strtimmed            = 'X'
      sdlstrtdt            = sy-datum
      sdlstrttm            = lv_sdlstrttm
    IMPORTING
      job_was_released     = lv_released
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
    cf_retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    " JOB_CLOSE
