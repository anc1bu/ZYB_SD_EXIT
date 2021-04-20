class ZCX_SD_PARTI_GRP definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_SD_PARTI_GRP,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '049',
      attr1 type scx_attrname value 'MESSAGES',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_SD_PARTI_GRP .
  constants:
    begin of ZSD_038,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '038',
      attr1 type scx_attrname value 'STOK_TIPI',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_038 .
  constants:
    begin of ZSD_039,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '039',
      attr1 type scx_attrname value 'STOK_TIPI',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_039 .
  constants:
    begin of ZSD_040,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '040',
      attr1 type scx_attrname value 'STOK_TIPI',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_040 .
  constants:
    begin of ZSD_041,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '041',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_041 .
  constants:
    begin of ZSD_043,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '043',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_043 .
  constants:
    begin of ZSD_044,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '044',
      attr1 type scx_attrname value 'SVKNO',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_044 .
  data CHARG type CHARG_D .
  data STOK_TIPI type CHAR10 .
  data SVKNO type ZYB_SD_E_SVKNO .
  data MESSAGES type ref to IF_RECA_MESSAGE_LIST .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !CHARG type CHARG_D optional
      !STOK_TIPI type CHAR10 optional
      !SVKNO type ZYB_SD_E_SVKNO optional
      !MESSAGES type ref to IF_RECA_MESSAGE_LIST optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_PARTI_GRP IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->CHARG = CHARG .
me->STOK_TIPI = STOK_TIPI .
me->SVKNO = SVKNO .
me->MESSAGES = MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_SD_PARTI_GRP .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
