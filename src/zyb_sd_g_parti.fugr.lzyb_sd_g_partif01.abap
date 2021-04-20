*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_PARTIF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REFRESH_DATA
*&---------------------------------------------------------------------*
FORM refresh_data .
  CLEAR:
   gv_class,
   gv_klart,
   gv_obtab,
   gv_objec.

  CLEAR:
   gt_val_num,  gt_val_num[],
   gt_val_char, gt_val_char[],
   gt_val_curr, gt_val_curr[],
   gt_ret,      gt_ret[].
ENDFORM.                    " REFRESH_DATA
*&---------------------------------------------------------------------*
*&      Form  ADD_MSG
*&---------------------------------------------------------------------*
FORM add_msg  USING    p_ret LIKE bapiret2
              CHANGING ret   LIKE bapiret2.
  CLEAR: ret.
  ret-type       = p_ret-type.
  ret-id         = P_ret-id.
  ret-number     = P_ret-number.
  ret-message_v1 = p_ret-message_v1.
  ret-message_v1 = p_ret-message_v2.
  ret-message_v1 = p_ret-message_v3.
  ret-message_v1 = p_ret-message_v4.
ENDFORM.                    " ADD_MSG
