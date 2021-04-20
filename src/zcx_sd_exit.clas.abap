class ZCX_SD_EXIT definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of DAY_LIMIT,
      msgid type symsgid value 'ZSD_VA',
      msgno type symsgno value '052',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DAY_LIMIT .
  constants:
    begin of GOODS_DATE,
      msgid type symsgid value 'ZSD_VA',
      msgno type symsgno value '053',
      attr1 type scx_attrname value 'DAYS',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of GOODS_DATE .
  constants C_ERROR type BAPI_MTYPE value 'E'. "#EC NOTEXT
  data DAYS type INT4 .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !DAYS type INT4 optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_EXIT IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->DAYS = DAYS .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
