FUNCTION-POOL zyb_sd_g_log.                 "MESSAGE-ID ..
* INCLUDE LZYB_SD_G_LOGD...                  " Local class definition

* DESCRIPTION: This function module is used insert messages in the
* application log

CONSTANTS:
  probclass_very_high TYPE bal_s_msg-probclass VALUE '1',
  probclass_high      TYPE bal_s_msg-probclass VALUE '2',
  probclass_medium    TYPE bal_s_msg-probclass VALUE '3',
  probclass_low       TYPE bal_s_msg-probclass VALUE '4',
  probclass_none      TYPE bal_s_msg-probclass VALUE ' '.

* message types
CONSTANTS:
  msgty_x    TYPE sy-msgty            VALUE 'X',
  msgty_a    TYPE sy-msgty            VALUE 'A',
  msgty_e    TYPE sy-msgty            VALUE 'E',
  msgty_w    TYPE sy-msgty            VALUE 'W',
  msgty_i    TYPE sy-msgty            VALUE 'I',
  msgty_s    TYPE sy-msgty            VALUE 'S',
  msgty_none TYPE sy-msgty            VALUE ' '.

DATA:
  l_log_handle   TYPE balloghndl,
  l_s_log        TYPE bal_s_log,
  it_log_handles TYPE bal_t_logh,
  l_dummy        TYPE string,
  l_ext_no       TYPE bal_s_log-extnumber,
  l_s_mdef       TYPE bal_s_mdef.
*  it_lognm       TYPE TABLE OF bal_t_lgnm,
*  wa_lognm       LIKE LINE OF it_lognm.

DATA:
  wa_msg               TYPE bal_s_msg,
  wa_msg_handle        TYPE balmsghndl,
  gv_msg_was_logged    TYPE boolean,
  gv_msg_was_displayed TYPE boolean.
