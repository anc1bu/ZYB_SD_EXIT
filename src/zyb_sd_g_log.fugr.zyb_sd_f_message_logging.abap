FUNCTION zyb_sd_f_message_logging.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_LOG_OBJECT) TYPE  BALOBJ_D
*"     REFERENCE(I_LOG_SUBOBJECT) TYPE  BALSUBOBJ OPTIONAL
*"     REFERENCE(I_EXTNUMBER) TYPE  BALNREXT
*"     VALUE(I_REFRESH) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_NEW_LOGNUMBERS) TYPE  BAL_T_LGNM
*"  TABLES
*"      T_LOG_MESSAGE STRUCTURE  SYMSG
*"  EXCEPTIONS
*"      LOG_HEADER_INCONSISTENT
*"      LOGGING_ERROR
*"----------------------------------------------------------------------
* DESCRIPTION: This function module is used insert messages in the
* application log

  DATA:
    rtcode     LIKE sy-subrc,
    ls_message TYPE symsg.

  CLEAR: l_s_log, l_ext_no.

  l_s_log-object    = i_log_object.
  l_s_log-subobject = i_log_subobject.
  l_ext_no          = i_extnumber.
  l_s_log-extnumber = l_ext_no.

* Create the log with header data
  CLEAR rtcode.

  PERFORM log_refresh.

  PERFORM bal_log_create CHANGING rtcode.

  IF rtcode <> 0.
    CASE rtcode.
      WHEN 1.
        RAISE log_header_inconsistent.
      WHEN OTHERS.
        RAISE logging_error.
    ENDCASE.
  ENDIF.
  CHECK rtcode = 0.

* Loop the message table and write the messages into the log
  LOOP AT t_log_message INTO ls_message.
    CLEAR wa_msg.

    PERFORM log_msg_add USING ls_message.
  ENDLOOP.

* save logs in the database
  FREE: it_log_handles.
  IF sy-subrc = 0.
    APPEND l_log_handle TO it_log_handles.

    PERFORM save_log CHANGING rtcode
                              e_new_lognumbers.

    IF rtcode = 0 .
*      IF NOT it_lognm[] IS INITIAL.
*        LOOP AT it_lognm INTO wa_lognm.
*          APPEND wa_lognm TO e_new_lognumbers.
*        ENDLOOP.
*      e_new_lognumbers[] = it_lognm[].
*      ENDIF.
      IF NOT i_refresh IS INITIAL.
        PERFORM log_refresh.
      ENDIF.

    ELSE .
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFUNCTION.
