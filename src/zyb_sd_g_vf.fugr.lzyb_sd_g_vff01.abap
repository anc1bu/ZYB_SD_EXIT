*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_VFF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  JOB_OPEN
*&---------------------------------------------------------------------*
FORM job_open  USING    p_name
               CHANGING p_number
                        ep_retcode.
  CLEAR ep_retcode.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = p_name
      jobclass         = 'A'
    IMPORTING
      jobcount         = p_number
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.
    ep_retcode = sy-subrc.
  ENDIF.
ENDFORM.                    " JOB_OPEN
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_BIL_PROCESS
*&---------------------------------------------------------------------*
FORM submit_bil_process  USING    p_uname
                                  p_name
                                  p_number
                                  p_vbeln
                         CHANGING ep_retcode.

  CLEAR ep_retcode.
  SUBMIT zybsd_r_bil_process
                USER p_uname
                VIA JOB p_name NUMBER p_number
                WITH p_vbeln EQ p_vbeln
                WITH p_job   EQ 'X'
                AND RETURN.

  IF sy-subrc <> 0.
    ep_retcode = sy-subrc.
  ENDIF.
ENDFORM.                    " SUBMIT_BIL_PROCESS
*&---------------------------------------------------------------------*
*&      Form  JOB_CLOSE
*&---------------------------------------------------------------------*
FORM job_close  USING    p_number
                         p_name
                CHANGING ep_released
                         ep_retcode.
  DATA:
    exdate LIKE sy-datum,
    extime LIKE sy-uzeit.

  CLEAR ep_retcode.

  TRY.
      CALL METHOD cl_abap_tstmp=>td_add
        EXPORTING
          date     = sy-datum
          time     = sy-uzeit
          secs     = 5
        IMPORTING
          res_date = exdate
          res_time = extime.
    CATCH cx_parameter_invalid_type .
    CATCH cx_parameter_invalid_range .
  ENDTRY.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = p_number
      jobname              = p_name
*      strtimmed            = 'X'
      sdlstrtdt            = exdate
      sdlstrttm            = extime
    IMPORTING
      job_was_released     = ep_released
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
    ep_retcode = 0.
  ENDIF.
ENDFORM.                    " JOB_CLOSE
*&---------------------------------------------------------------------*
*&      Form  JOBLOG_READ
*&---------------------------------------------------------------------*
FORM joblog_read  USING    p_number
                           p_name
                  CHANGING ep_retcode.
  CLEAR: ep_retcode.

  CALL FUNCTION 'BP_JOBLOG_READ'
    EXPORTING
      jobcount              = p_number
      jobname               = p_name
*     lines                 =
      direction             = 'E' "" From Endding
    TABLES
      joblogtbl             = tb_joblog
    EXCEPTIONS
      cant_read_joblog      = 1
      jobcount_missing      = 2
      joblog_does_not_exist = 3
      joblog_is_empty       = 4
      joblog_name_missing   = 5
      jobname_missing       = 6
      job_does_not_exist    = 7
      OTHERS                = 8.

  IF sy-subrc <> 0.
    ep_retcode = sy-subrc.
  ENDIF.
ENDFORM.                    " JOBLOG_READ
