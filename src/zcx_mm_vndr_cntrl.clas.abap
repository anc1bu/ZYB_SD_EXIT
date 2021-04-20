class ZCX_MM_VNDR_CNTRL definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZMM_036,
      msgid type symsgid value 'ZMM',
      msgno type symsgno value '036',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZMM_036 .
  constants:
    begin of ZMM_037,
      msgid type symsgid value 'ZMM',
      msgno type symsgno value '037',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZMM_037 .
  constants:
    begin of ZMM_038,
      msgid type symsgid value 'ZMM',
      msgno type symsgno value '038',
      attr1 type scx_attrname value 'GV_LIFNR',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZMM_038 .
  data GV_LIFNR type LIFNR .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !GV_LIFNR type LIFNR optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_MM_VNDR_CNTRL IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->GV_LIFNR = GV_LIFNR .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
