class ZCX_SD_PALETFTR_MAMULLE definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SD_PALETFTR_MAMULLE,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '049',
      attr1 type scx_attrname value 'MESSAGES',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SD_PALETFTR_MAMULLE .
  constants:
    begin of ZSD_046,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '046',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_046 .
  constants:
    begin of ZSD_047,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '047',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_047 .
  data MESSAGES type ref to IF_RECA_MESSAGE_LIST .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGES type ref to IF_RECA_MESSAGE_LIST optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_PALETFTR_MAMULLE IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MESSAGES = MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SD_PALETFTR_MAMULLE .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
