FUNCTION-POOL zyb_sd_g_uom                 "MESSAGE-ID ..
MESSAGE-ID 61.

TABLES: rdpr,  mara,
        t399d, tvm1, tvm2.
DATA: iwerks     LIKE rdpr-werks,
      irdprf     LIKE rdpr-rdprf,
      imenge     LIKE rdpr-bdmng,
      omenge     LIKE rdpr-vormg,
      iref_werks LIKE rdpr-werks,
      merk_werks LIKE rdpr-werks,
      merk_rdprf LIKE rdpr-rdprf,
      xline      LIKE sy-tabix,
      help       TYPE f.

DATA: BEGIN OF rdprx OCCURS 10.
        INCLUDE STRUCTURE rdpr.
DATA: END OF rdprx.

* INCLUDE LZYB_SD_G_UOMD...                  " Local class definition
DATA :
  ws_c_cf   TYPE  p DECIMALS 5,
  wa_c_cf2  TYPE  marm,
  ws_c_mara TYPE  mara.
DATA :
  ws_base_cf    TYPE  p DECIMALS 5,
  ws_cur_qty    TYPE  p DECIMALS 5,
  wa_base_cf1   TYPE  marm,
  wa_curr_cf2   TYPE  marm,
  ws_alt_cf3    TYPE  zyb_t_md001, " Palet ve kutu cinsine göre dönüşüm tablosu
  ws_base_meins TYPE  mara-meins,
  ws_alt_uom    TYPE  mara-meins,
  ws_curr_uom   TYPE  mara-meins.

DATA:
  rt_code TYPE sy-subrc.

CONSTANTS:
  gc_palet_olc  TYPE meinh VALUE 'PAL',   " Palet ölçü birimi
  gc_kutu_olc   TYPE meinh VALUE 'KUT',   " Kutu ölçü birimi
  gc_typ_plt(1) TYPE c     VALUE 'P',     " Palet
  gc_typ_kut(1) TYPE c     VALUE 'K',     " Kutu
  gc_matkl_plt  TYPE matkl VALUE 'Y0301', " palet mal gurubu
  gc_matkl_kut  TYPE matkl VALUE 'Y0302', " Kutu  mal gurubu
  gc_matkl_trb  TYPE matkl VALUE 'Y0303', " torba mal gurubu
  gc_mtart_amb  TYPE mtart VALUE 'ZAMB', " Ambalaj malzeme türü
  gc_mtart_yrm  TYPE mtart VALUE 'ZYRM', " Yarı Mamül Malzeme Türü
  gc_sanayi     TYPE vkorg VALUE '1100',
  gc_yurtici    TYPE vtweg VALUE '10',   " Yurtiçi Dağıtım Kanalı
  gc_yurtdisi   TYPE vtweg VALUE '20',   " Yurtdışı Dağıtım Kanalı
  gc_diger      TYPE vtweg VALUE '30',   " Diğer Dağıtım Kanalı
  gc_base(10)   TYPE p VALUE '0.00500' DECIMALS 5.
