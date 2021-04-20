FUNCTION zybsd_f_bil_proc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VBELN) TYPE  VBELN
*"----------------------------------------------------------------------
  FREE: tb_joblog.
  CLEAR: gv_sdlstrttm, gv_released.

  CONCATENATE  'ZF99_' i_vbeln  INTO l_name.

  PERFORM job_open USING l_name CHANGING l_number
                                         cf_retcode.
  IF cf_retcode = 0.
    PERFORM submit_bil_process USING sy-uname
                                     l_name
                                     l_number
                                     i_vbeln
                             CHANGING cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM job_close USING l_number l_name
                   CHANGING gv_released cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM joblog_read USING l_number l_name
                        CHANGING cf_retcode.
  ENDIF.
ENDFUNCTION.
