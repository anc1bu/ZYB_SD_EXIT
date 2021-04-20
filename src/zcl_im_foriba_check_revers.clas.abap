class ZCL_IM_FORIBA_CHECK_REVERS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_MB_CHECK_LINE_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FORIBA_CHECK_REVERS IMPLEMENTATION.


METHOD if_ex_mb_check_line_badi~check_line.
  "--------->> Anıl CENGİZ 11.11.2019 11:16:29
  "YUR-515
  CALL FUNCTION '/FORIBA/ED0_F206'
    EXPORTING
      i_mkpf           = is_mkpf
      i_mseg           = is_mseg
    EXCEPTIONS
      no_allow_reverse = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
    TYPE sy-msgty
    NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  "---------<<
ENDMETHOD.
ENDCLASS.
