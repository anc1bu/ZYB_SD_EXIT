class ZCX_SD_RV61AFZB_FORM_BWRTNEND definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SD_RV61AFZB_FORM_BWRTNEND,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '049',
      attr1 type scx_attrname value 'MESSAGES',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  constants:
    begin of ZSD_019,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '019',
      attr1 type scx_attrname value 'KSCHL',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_019 .
  constants:
    begin of ZSD_009,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'LGORT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_009 .
  constants:
    begin of ZSD_010,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '010',
      attr1 type scx_attrname value 'MATNR',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_010 .
  data KSCHL type KSCHA .
  data LGORT type LGORT_D .
  data MATNR type MATNR .
  data MESSAGES type ref to IF_RECA_MESSAGE_LIST .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !KSCHL type KSCHA optional
      !LGORT type LGORT_D optional
      !MATNR type MATNR optional
      !MESSAGES type ref to IF_RECA_MESSAGE_LIST optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_RV61AFZB_FORM_BWRTNEND IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->KSCHL = KSCHL .
me->LGORT = LGORT .
me->MATNR = MATNR .
me->MESSAGES = MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SD_RV61AFZB_FORM_BWRTNEND .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
