*&---------------------------------------------------------------------*
*& Report  ZYBSD_R_BIL_PROCESS
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zybsd_r_bil_process.

INCLUDE zybsd_i_bil_process_def.
INCLUDE zybsd_i_bil_process_sel.
INCLUDE zybsd_i_bil_process_frm.


START-OF-SELECTION.
**  islemlerin yapılmaya başlandığı noktadır.
  FREE: tb_msg.
  CLEAR: gv_type, gv_ftrtip.
  PERFORM get_data CHANGING retcode.

  IF retcode = 0.
    break bbozaci.
    PERFORM set_process_type CHANGING gv_type.
    IF NOT gv_type IS INITIAL.
      PERFORM process USING gv_type CHANGING retcode.
    ENDIF.
  ENDIF.

END-OF-SELECTION.
**  Son olarak yapılacak işlemler.
    PERFORM create_log.
  IF p_job IS INITIAL.
    PERFORM show_log.
  ENDIF.
*  IF NOT tb_msg[] IS INITIAL.
*    PERFORM show_message.
*  ENDIF.
