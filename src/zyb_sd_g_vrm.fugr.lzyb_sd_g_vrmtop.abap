FUNCTION-POOL zyb_sd_g_vrm.                 "MESSAGE-ID ..
* INCLUDE LZYB_SD_G_VRMD...                  " Local class definition
TYPES: BEGIN OF ty_batch,
         matnr TYPE matnr,
         charg TYPE charg_d,
         atnam TYPE atnam,
         atbez TYPE atbez,
         atfor TYPE atfor,
         atwrt TYPE atwrt,
         atflv TYPE atflv,
         unit  TYPE meins,
       END OF ty_batch.
DATA:
  gt_batch TYPE TABLE OF ty_batch,
  gs_batch TYPE          ty_batch.

DATA:
  tb_check TYPE         zyb_sd_ty_vrm_check,
  wa_check TYPE LINE OF zyb_sd_ty_vrm_check.

DATA:
* " Parti Karakteristik / İşlem Türü Zorunluluk Bakım Tablosu
  gt_c003 LIKE zyb_sd_t_c003 OCCURS 0 WITH HEADER LINE,
  tb_msg  LIKE bapiret2      OCCURS 0 WITH HEADER LINE,
  gv_txt  TYPE bezei40.

DATA:
  gv_islem TYPE zyb_sd_e_islem.

DATA:
  gt_blk  LIKE zyb_sd_s_bloke OCCURS 0 WITH HEADER LINE,
  gs_blk  LIKE LINE OF gt_blk.

CONSTANTS:
  gc_tip_grs        TYPE zyb_sd_e_islem VALUE 'A', " Mal girişi
  gc_tip_icvir      TYPE zyb_sd_e_islem VALUE 'B', " İç Piyasa Virman
  gc_tip_disvir     TYPE zyb_sd_e_islem VALUE 'C', " Dış Piyasa Virman

  gc_bwart_grs      TYPE bwart VALUE '101',
  gc_bwart_ictoic   TYPE bwart VALUE '311',
  gc_bwart_ictodis  TYPE bwart VALUE '413',
  gc_bwart_distoic  TYPE bwart VALUE '411',
  gc_bwart_distodis TYPE bwart VALUE '413',

  gc_sobkz_e        TYPE sobkz VALUE 'E',
  gc_first          TYPE extwg VALUE '6',         " First Kalite
  gc_ihr_export     TYPE extwg VALUE '8',         " İhracat Export Kalite
  "--------->> Anıl CENGİZ 27.04.2019 10:41:56
  "YUR-381
  gc_ihr_ucuncu     TYPE extwg VALUE '3',         "1, ST Karışık Export Kalite
  "---------<<
  gc_stddis_depo    TYPE lgort_d VALUE '1202',    " Yarım Palet Deposu

  gc_auart_thmn     TYPE auart VALUE 'ZA07',      " Tahmin Siparişi

  gc_batch_class    LIKE  klah-class   VALUE 'ZYB_MAMUL_PARTI', " Parti Mamul Classı
  gc_palet_atnam    TYPE  cabn-atnam   VALUE 'PALET_TIPI',   " Palet Tipi
  gc_kutu_atnam     TYPE  cabn-atnam   VALUE 'KUTU_TIPI',    " Kutu Tipi
  gc_kutet_atnam    TYPE  cabn-atnam   VALUE 'KUTU_ETKT',    " Kutu Etiketi
  gc_karoalt_atnam  TYPE  cabn-atnam   VALUE 'KARO_ALT_BLGS', " Karo alt bilgi
  gc_pltagr_atnam   TYPE  cabn-atnam   VALUE 'PALET_AGIRLIK', " Palet Ağırlık
  gc_renkton_atnam  TYPE  cabn-atnam   VALUE 'RENK_TONU',    " Renk Tonu
  gc_kalibre_atnam  TYPE  cabn-atnam   VALUE 'KALIBRE',      " Kalibre
  gc_pltdrm_atnam   TYPE  cabn-atnam   VALUE 'PALET_DRM',    " Palet Durum
  charx             TYPE c             VALUE 'X'.
