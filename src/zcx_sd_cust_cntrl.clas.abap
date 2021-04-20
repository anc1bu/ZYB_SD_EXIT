class ZCX_SD_CUST_CNTRL definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZSD_022,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '022',
      attr1 type scx_attrname value 'GV_KTOKD',
      attr2 type scx_attrname value 'GV_VKORG',
      attr3 type scx_attrname value 'GV_VTWEG',
      attr4 type scx_attrname value 'GV_BRSCH',
    end of ZSD_022 .
  constants:
    begin of ZSD_023,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '023',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_023 .
  constants:
    begin of ZSD_024,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '024',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_024 .
  constants:
    begin of ZSD_025,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '025',
      attr1 type scx_attrname value 'GV_KTOKD',
      attr2 type scx_attrname value 'GV_VKORG',
      attr3 type scx_attrname value 'GV_VTWEG',
      attr4 type scx_attrname value 'GV_BRSCH',
    end of ZSD_025 .
  constants:
    begin of ZSD_026,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '026',
      attr1 type scx_attrname value 'GV_KTOKD',
      attr2 type scx_attrname value 'GV_VKORG',
      attr3 type scx_attrname value 'GV_VTWEG',
      attr4 type scx_attrname value 'GV_BRSCH',
    end of ZSD_026 .
  constants:
    begin of ZSD_027,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '027',
      attr1 type scx_attrname value 'GV_KKBER',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_027 .
  constants:
    begin of ZSD_028,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '028',
      attr1 type scx_attrname value 'GV_WAERS',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_028 .
  constants:
    begin of ZSD_029,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '029',
      attr1 type scx_attrname value 'GV_KUNNR',
      attr2 type scx_attrname value 'GV_KKBER',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_029 .
  constants:
    begin of ZSD_030,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '030',
      attr1 type scx_attrname value 'GV_KTOKD',
      attr2 type scx_attrname value 'GV_VKORG',
      attr3 type scx_attrname value 'GV_VTWEG',
      attr4 type scx_attrname value 'GV_BRSCH',
    end of ZSD_030 .
  constants:
    begin of ZSD_031,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '031',
      attr1 type scx_attrname value 'GV_KTGRD',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_031 .
  constants:
    begin of ZSD_032,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '032',
      attr1 type scx_attrname value 'GV_KTOKD',
      attr2 type scx_attrname value 'GV_VKORG',
      attr3 type scx_attrname value 'GV_VTWEG',
      attr4 type scx_attrname value 'GV_BRSCH',
    end of ZSD_032 .
  constants:
    begin of ZSD_033,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '033',
      attr1 type scx_attrname value 'GV_TAXK1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_033 .
  constants:
    begin of ZSD_034,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '034',
      attr1 type scx_attrname value 'GV_KUNNR',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_034 .
  constants:
    begin of ZSD_035,
      msgid type symsgid value 'ZSD',
      msgno type symsgno value '035',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZSD_035 .
  data GV_KTOKD type KTOKD .
  data GV_VKORG type VKORG .
  data GV_VTWEG type VTWEG .
  data GV_BRSCH type BRSCH .
  data GV_KKBER type KKBER .
  data GV_WAERS type WAERS .
  data GV_KUNNR type KUNNR .
  data GV_KTGRD type KTGRD .
  data GV_TAXK1 type TAXK1 .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !GV_KTOKD type KTOKD optional
      !GV_VKORG type VKORG optional
      !GV_VTWEG type VTWEG optional
      !GV_BRSCH type BRSCH optional
      !GV_KKBER type KKBER optional
      !GV_WAERS type WAERS optional
      !GV_KUNNR type KUNNR optional
      !GV_KTGRD type KTGRD optional
      !GV_TAXK1 type TAXK1 optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SD_CUST_CNTRL IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->GV_KTOKD = GV_KTOKD .
me->GV_VKORG = GV_VKORG .
me->GV_VTWEG = GV_VTWEG .
me->GV_BRSCH = GV_BRSCH .
me->GV_KKBER = GV_KKBER .
me->GV_WAERS = GV_WAERS .
me->GV_KUNNR = GV_KUNNR .
me->GV_KTGRD = GV_KTGRD .
me->GV_TAXK1 = GV_TAXK1 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
