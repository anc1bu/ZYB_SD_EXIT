FUNCTION-POOL zyb_sd_g_gnl.                 "MESSAGE-ID ..

* INCLUDE LZYB_SD_G_GNLD...                  " Local class definition

DATA:
  gt_ret      LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
  gs_ret      LIKE LINE OF gt_ret,
  gv_txt(100) TYPE c.

  CONSTANTS:
    gc_palet_olc TYPE meinh VALUE 'PAL',   " Palet ölçü birimi
    gc_kutu_olc  TYPE meinh VALUE 'KUT',   " Kutu ölçü birimi
    gc_mtart_amb TYPE mtart VALUE 'ZAMB',  " Ambalaj malzeme türü
    gc_mtart_yyk TYPE mtart VALUE 'ZYYK',  " Yapı Kimyasalı malzeme türü
    gc_mtart_yrm TYPE mtart VALUE 'ZYRM',  " Yarı Mamül Türü
    gc_matkl_plt TYPE matkl VALUE 'Y0301', " palet mal gurubu
    gc_matkl_kut TYPE matkl VALUE 'Y0302', " Kutu  mal gurubu
    gc_matkl_trb TYPE matkl VALUE 'Y0303', " torba mal gurubu
    gc_sanayi    TYPE vkorg VALUE '1100',
    gc_yurtici   TYPE vtweg VALUE '10',   " Yurtiçi Dağıtım Kanalı
    gc_yurtdisi  TYPE vtweg VALUE '20',   " Yurtdışı Dağıtım Kanalı
    gc_diger     TYPE vtweg VALUE '30',   " Diğer Dağıtım Kanalı
    gc_kvewe TYPE kvewe    VALUE 'A'.

  DATA: gs_t685 TYPE t685,
        gc_yes   TYPE sy-marky VALUE 'X'.         "Boolsches "yes"
