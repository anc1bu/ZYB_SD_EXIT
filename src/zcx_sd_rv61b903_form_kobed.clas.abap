class ZCX_SD_RV61B903_FORM_KOBED definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZSD_045,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '045',
      attr1 type scx_attrname value 'KAPPL',
      attr2 type scx_attrname value 'KSCHL',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_045 .
  constants:
    begin of ZSD_048,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '048',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_048 .
  data BUKRS type BUKRS .
  data VKORG type VKORG .
  data VTWEG type VTWEG .
  data KAPPL type SNA_KAPPL .
  data KSCHL type SNA_KSCHL .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !BUKRS type BUKRS optional
      !VKORG type VKORG optional
      !VTWEG type VTWEG optional
      !KAPPL type SNA_KAPPL optional
      !KSCHL type SNA_KSCHL optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_RV61B903_FORM_KOBED IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->BUKRS = BUKRS .
me->VKORG = VKORG .
me->VTWEG = VTWEG .
me->KAPPL = KAPPL .
me->KSCHL = KSCHL .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
