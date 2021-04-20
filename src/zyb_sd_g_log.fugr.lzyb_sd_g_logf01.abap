*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_LOGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BAL_LOG_CREATE
*&---------------------------------------------------------------------*
FORM bal_log_create CHANGING retcode.
  CLEAR: retcode, l_log_handle.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = l_s_log
    IMPORTING
      e_log_handle            = l_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    retcode = sy-subrc.
  ENDIF.
ENDFORM.                    " BAL_LOG_CREATE
*&---------------------------------------------------------------------*
*&      Form  LOG_MSG_ADD
*&---------------------------------------------------------------------*
FORM log_msg_add USING ls_msg LIKE symsg.
  DATA:  i_probclass TYPE bal_s_msg-probclass.
  CLEAR: wa_msg_handle, gv_msg_was_logged,
         gv_msg_was_displayed, i_probclass.

* entry check
  CHECK ls_msg-msgno NE 0.
  CHECK ls_msg-msgid NE space.

* define data of message for Application Log
  wa_msg-msgty = ls_msg-msgty.
  wa_msg-msgid = ls_msg-msgid.
  wa_msg-msgno = ls_msg-msgno.
  wa_msg-msgv1 = ls_msg-msgv1.
  wa_msg-msgv2 = ls_msg-msgv2.
  wa_msg-msgv3 = ls_msg-msgv3.
  wa_msg-msgv4 = ls_msg-msgv4.

  CASE ls_msg-msgty.
    WHEN msgty_x.
      i_probclass = probclass_very_high.
    WHEN msgty_a.
      i_probclass = probclass_very_high.
    WHEN msgty_e.
      i_probclass = probclass_high.
    WHEN msgty_w.
      i_probclass = probclass_medium.
    WHEN msgty_i.
      i_probclass = probclass_low.
    WHEN msgty_s.
      i_probclass = probclass_low.
    WHEN msgty_none.
      i_probclass = probclass_none.
  ENDCASE.

  wa_msg-probclass = i_probclass.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle        = l_log_handle
      i_s_msg             = wa_msg
    IMPORTING
      e_s_msg_handle      = wa_msg_handle
      e_msg_was_logged    = gv_msg_was_logged
      e_msg_was_displayed = gv_msg_was_displayed
    EXCEPTIONS
      log_not_found       = 1
      msg_inconsistent    = 2
      log_is_full         = 3
      OTHERS              = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " LOG_MSG_ADD
*&---------------------------------------------------------------------*
*&      Form  SAVE_LOG
*&---------------------------------------------------------------------*
FORM save_log CHANGING retcode
                       lt_lognm TYPE bal_t_lgnm.
  CLEAR retcode.
*  CLEAR: it_lognm, it_lognm[].
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
*     I_CLIENT         = SY-MANDT
*     I_IN_UPDATE_TASK = ' '
*     I_SAVE_ALL       = ' '
      i_t_log_handle   = it_log_handles
    IMPORTING
      e_new_lognumbers = lt_lognm
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    retcode = sy-subrc.
  ENDIF.
ENDFORM.                    " SAVE_LOG
*&---------------------------------------------------------------------*
*&      Form  LOG_REFRESH
*&---------------------------------------------------------------------*
FORM log_refresh .
* Clear protocol in memory...
      CALL FUNCTION 'BAL_LOG_REFRESH'
        EXPORTING
          i_log_handle = l_log_handle
        EXCEPTIONS
          OTHERS       = 99.

      IF sy-subrc <> 0.
*** This is no showstopper => ignore...
      ENDIF.
ENDFORM.                    " LOG_REFRESH
