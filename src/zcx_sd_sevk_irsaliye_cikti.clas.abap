class ZCX_SD_SEVK_IRSALIYE_CIKTI definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_RECA_MESSAGE_LIST .

  data MESSAGES type ref to IF_RECA_MESSAGE_LIST .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGES type ref to IF_RECA_MESSAGE_LIST optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_SEVK_IRSALIYE_CIKTI IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MESSAGES = MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
