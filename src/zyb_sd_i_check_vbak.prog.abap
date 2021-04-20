*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_CHECK_VBAK
*&---------------------------------------------------------------------*
DATA: ls_akkp  LIKE akkp,
      lv_name1 TYPE name1_gp.

DATA: lv_garg  TYPE seqg3-garg,
      lt_seqg3 LIKE seqg3 OCCURS 0 WITH HEADER LINE.


IF vbak-vtweg EQ gc_vtweg_ic AND vbak-vkorg EQ gc_vkorg_paz.

* Mali belge müşterisi ile sipariş veren kontrol edilir.
  CLEAR: ls_akkp.
  IF vbkd-lcnum IS NOT INITIAL.

    SELECT SINGLE * FROM akkp
       INTO ls_akkp
      WHERE lcnum EQ vbkd-lcnum.

    IF vbak-kunnr NE ls_akkp-kunnr.
      CLEAR lv_name1.
      SELECT SINGLE name1 FROM kna1
         INTO lv_name1
        WHERE kunnr EQ ls_akkp-kunnr.

      MESSAGE i030(zsd_va)
          WITH ls_akkp-kunnr lv_name1 '(Sipariş Saklanamaz)'.
    ENDIF.

    IF NOT vbkd-lcnum IS INITIAL.
      CLEAR lv_garg.
      CONCATENATE sy-mandt vbkd-lcnum INTO lv_garg.

      FREE: lt_seqg3.
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient               = sy-mandt
          gname                 = 'AKKP'
          garg                  = lv_garg
          guname                = space
        TABLES
          enq                   = lt_seqg3
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT lt_seqg3 WHERE guname NE sy-uname.
        EXIT.
      ENDLOOP.

      IF sy-subrc = 0.
        MESSAGE i031(zsd_va) WITH vbkd-lcnum lt_seqg3-guname.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
