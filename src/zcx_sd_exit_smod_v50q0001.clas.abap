class ZCX_SD_EXIT_SMOD_V50Q0001 definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SD_EXIT_SMOD_V50Q0001,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '049',
      attr1 type scx_attrname value 'MESSAGES',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SD_EXIT_SMOD_V50Q0001 .
  data MESSAGES type ref to IF_RECA_MESSAGE_LIST .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGES type ref to IF_RECA_MESSAGE_LIST optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_EXIT_SMOD_V50Q0001 IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MESSAGES = MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SD_EXIT_SMOD_V50Q0001 .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
