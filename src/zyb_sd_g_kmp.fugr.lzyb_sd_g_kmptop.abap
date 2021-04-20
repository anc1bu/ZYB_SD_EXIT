FUNCTION-POOL zyb_sd_g_kmp
   MESSAGE-ID zsd_kmp.

* INCLUDE LZYB_SD_G_KMPD...                  " Local class definition

TYPES:
  BEGIN OF ty_list,
    vkorg TYPE vkorg,
    vtweg TYPE vtweg,
    kunnr TYPE kunnr,
    date  TYPE datum,
  END OF ty_list.


DATA:
  it_t6b1  LIKE t6b1  OCCURS 0 WITH HEADER LINE,
  it_t6b2  LIKE t6b2  OCCURS 0 WITH HEADER LINE,
  it_t6b2f LIKE t6b2f OCCURS 0 WITH HEADER LINE,
  it_t685a LIKE t685a OCCURS 0 WITH HEADER LINE.

DATA:
  it_901        LIKE a901 OCCURS 0 WITH HEADER LINE,
  it_kona       LIKE kona OCCURS 0 WITH HEADER LINE,
  it_akkp       LIKE akkp OCCURS 0 WITH HEADER LINE,
  gt_akkp_bdlsz TYPE TABLE OF akkp.

DATA:
  tb_list    TYPE TABLE OF ty_list,
  wa_list    TYPE ty_list,

  tb_kmplist LIKE zyb_sd_s_kmplist OCCURS 0 WITH HEADER LINE,
  wa_kmplist TYPE LINE OF  zyb_sd_ty_kmplist.

CONSTANTS:
  co_kschl TYPE kschl VALUE 'ZP04',
  co_kappl TYPE kappl VALUE 'V'.

* Pop-up Seçimi
TYPE-POOLS: slis.

DATA: e_exit.
DATA:
  gt_fcat     TYPE slis_t_fieldcat_alv WITH HEADER LINE,
  gs_selfield TYPE slis_selfield,
  gs_private  TYPE slis_data_caller_exit.

CONSTANTS:
  gc_strname LIKE dd02l-tabname VALUE 'ZYB_SD_S_KMPLIST',
  gc_alv     TYPE slis_tabname VALUE 'GT_ALV',
  gc_title   LIKE sy-title VALUE 'Kampanya Seçimi'.

"--------->> Anıl CENGİZ 16.08.2018 10:44:08
" YUR-121 ZYB_SD_KMPNY_KNT tablosu "Sipariş Girişine Kapatma"
"Sadece Satış Siparişi için Çalışmalı
DATA: lv_vbtyp     TYPE vbtyp,
      lt_kmpny_knt TYPE TABLE OF zyb_sd_kmpny_knt.
"---------<<

* alv de görünen tanımları değiştirir.
DEFINE text_change.
  clear ls_fcat.
  ls_fcat-seltext_s    = ls_fcat-seltext_s.
  ls_fcat-reptext_ddic = &2.
  ls_fcat-seltext_l    = &3.
  ls_fcat-seltext_m    = &2.
  modify ct_fcat from ls_fcat
         transporting seltext_s seltext_m seltext_l reptext_ddic ddictxt
         where fieldname = &1.

END-OF-DEFINITION.

*&-------------------------------------------------------------*
*& Alanın görüntülenen sütun genişliğini ayarlamak için kullanılır.
*& ABAP Dictionary’ de tanımlı bir alan ise doldurmaya gerek yoktur.
*& Alan uzunluğu Domain üzerinden devralınır. Veri tipi : NUMC6
*&-------------------------------------------------------------*
DEFINE outputlen.
  clear ls_fcat .
  ls_fcat-outputlen = &2.
  modify ct_fcat from ls_fcat
         transporting outputlen where fieldname = &1.
END-OF-DEFINITION.

*&-------------------------------------------------------------*
*& Sıfır alanlar boş olarak görüntülenir.
*&-------------------------------------------------------------*
DEFINE no_zero.
  clear ls_fcat .
  ls_fcat-no_zero = 'X'.
  modify ct_fcat from ls_fcat
         transporting no_zero where fieldname = &1.
END-OF-DEFINITION.

*&-------------------------------------------------------------*
*& Listede gizlenmesi için kullanılır.
*&-------------------------------------------------------------*
DEFINE no_out.
  clear ls_fcat .
  ls_fcat-no_out = 'X'.
  modify ct_fcat from ls_fcat
         transporting no_out where fieldname = &1.
END-OF-DEFINITION.
