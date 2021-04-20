*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_BIL_PROCESS_DEF
*&---------------------------------------------------------------------*
TABLES:
  t001k, t001, t030, bkpf.
DATA:
  gs_vbrk  LIKE vbrk,
* Inter-company Muhasebe Belgeleri Tablosu
  wa_bl01  LIKE zyb_sd_t_bl01,
  gt_vbrk  LIKE vbrkvb   OCCURS 0 WITH HEADER LINE,
  gt_vbrp  LIKE vbrpvb   OCCURS 0 WITH HEADER LINE,
  gt_komv  LIKE komv     OCCURS 0 WITH HEADER LINE,
  gt_vbpa  LIKE vbpavb   OCCURS 0 WITH HEADER LINE,
  gt_komfk LIKE komfk    OCCURS 0 WITH HEADER LINE,
  gt_thead LIKE theadvb  OCCURS 0 WITH HEADER LINE,
  gt_mbew  LIKE mbew     OCCURS 0 WITH HEADER LINE,
  gt_bkpf  LIKE bkpf     OCCURS 0 WITH HEADER LINE,
  gt_bseg  LIKE bseg     OCCURS 0 WITH HEADER LINE,
  gt_acchd LIKE acchd    OCCURS 0 WITH HEADER LINE,
  gt_accit LIKE accit    OCCURS 0 WITH HEADER LINE,
  gt_acccr LIKE acccr    OCCURS 0 WITH HEADER LINE,
  t_mwdat  LIKE rtax1u15 OCCURS 0 WITH HEADER LINE.

* For bapi
DATA :
  ls_hd LIKE bapiache09,
  it_ag LIKE bapiacgl09          OCCURS 0 WITH HEADER LINE,
  it_ap LIKE bapiacap09          OCCURS 0 WITH HEADER LINE,
  it_ca LIKE bapiaccr09          OCCURS 0 WITH HEADER LINE,
  it_rt LIKE bapiret2            OCCURS 0 WITH HEADER LINE,
  it_tx LIKE bapiactx09          OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF gt_account  OCCURS 0,
        vbeln     TYPE vbeln_vf,
        posnr     TYPE posnr_vf,
        matnr     TYPE matnr,
        stk_hkont TYPE hkont,
        smm_hkont TYPE hkont,
        mwskz     TYPE mwskz,
      END OF gt_account.

DATA: BEGIN OF gt_taxtut OCCURS 0,
        hkont    LIKE rtax1u15-hkont,
        tax_code LIKE bapiactx09-tax_code,
        wmwst    LIKE rtax1u15-wmwst,
        amt_base TYPE bapiamtbase,
        tltut    LIKE konv-kwert,
      END OF gt_taxtut.
DATA:
  retcode      LIKE sy-subrc,         "Returncode
  gv_bukrs     TYPE bukrs,
  gv_vendor    TYPE lifnr,
  gv_zterm     TYPE dzterm,
  gv_kunnr     TYPE kunnr,
  gv_type(1)   TYPE c,
  gv_ftrtip(1) TYPE c.

CONSTANTS:
  gc_stk_doc_type         TYPE blart VALUE 'KR' ,  " Satıcı kaydı için
  gc_stk_tax_code         TYPE mwskz VALUE '**' ,  " Satıcı kaydı için vergi kodu
  gc_smm_doc_type         TYPE blart VALUE 'WL' ,  " Smm Kaydı için
  gc_bs_act               TYPE glvor VALUE 'RFBU',
  gc_curtp_00             TYPE curtp VALUE '00' ,  " Belge para birimi
  gc_curtp_10             TYPE curtp VALUE '10' ,  " Şirket Kodu para birimi
  gc_koaid_d              TYPE koaid VALUE 'D'  ,  " Koşul Sınıfı = ( Vergi )
  gc_koart_mus            TYPE koart VALUE 'D'  ,  " Hesap Türü ( Müşteri )
  gc_koart_stc            TYPE koart VALUE 'K'  ,  " Hesap Türü ( Satıcı )
  gc_ktosl_stk            TYPE ktosl VALUE 'BSX',  " 153 'lü Hesaplar için İşlem
  gc_ktosl_smm            TYPE ktosl VALUE 'GBB',  " 621 'li Hesaplar için İşlem
  gc_bklas_hzm            TYPE bklas VALUE '3011', " Hizmet için değerleme sınıfı
  gc_mwsk1_h0             TYPE mwskz VALUE 'A0' ,  " Hsp.KDV %0 vergi göstergesi
  gc_mwsk1_h1             TYPE mwskz VALUE 'A1' ,  " Hsp.KDV %1 vergi göstergesi
  gc_mwsk1_h8             TYPE mwskz VALUE 'A2' ,  " Hsp.KDV %8 vergi göstergesi
  gc_mwsk1_h18            TYPE mwskz VALUE 'A3' ,  " Hsp.KDV %18 vergi göstergesi
  gc_mwsk1_w0             TYPE mwskz VALUE 'W0' ,  " Hsp.KDV %0 vergi göstergesi
  gc_mwsk1_w1             TYPE mwskz VALUE 'W3' ,  " Hsp.KDV %1 vergi göstergesi
  gc_mwsk1_w8             TYPE mwskz VALUE 'W1' ,  " Hsp.KDV %8 vergi göstergesi
  gc_mwsk1_w18            TYPE mwskz VALUE 'W2' ,  " Hsp.KDV %18 vergi göstergesi
  gc_mwsk1_i0             TYPE mwskz VALUE 'V0' ,  " İnd.KDV %0 vergi göstergesi
  gc_mwsk1_i1             TYPE mwskz VALUE 'V1' ,  " İnd.KDV %1 vergi göstergesi
  gc_mwsk1_i8             TYPE mwskz VALUE 'V2' ,  " İnd.KDV %8 vergi göstergesi
  gc_mwsk1_i18            TYPE mwskz VALUE 'V3' ,  " İnd.KDV %18 vergi göstergesi
*  gc_mwsk1_v0             TYPE mwskz VALUE 'V0' ,  "
  gc_mwsk1_v1             TYPE mwskz VALUE 'E1' ,  " %1 KDV, Alımlar ve Giderler İçin İnd.KDV
  gc_mwsk1_v8             TYPE mwskz VALUE 'E2' ,  " %8 KDV, Vazgeçilen Alımlar İçin Hesaplanan KDV
  gc_mwsk1_v18            TYPE mwskz VALUE 'E3' ,  " %18 KDV, Vazgeçilen Alımlar İçin Hesaplanan KDV

  gc_bil_create           TYPE char1 VALUE 'C'  ,  " Dahili Mahsuplaştırma Oluşturma
  gc_bil_create_sipref(1) TYPE c     VALUE 'A',    " Dahili Mahsup Oluşturma (Sip)
  gc_bil_cancel_sipref(1) TYPE c     VALUE 'B',    " Dahili Mahsup İptal (Sip)
  gc_bil_cancel           TYPE char1 VALUE 'I'  ,  " Dahili Mahsuplşatırma İptal
  gc_stk_create           TYPE char1 VALUE '1'  ,  " Intercompany Satıcı Kaydı
  gc_smm_create           TYPE char1 VALUE '2'  ,  " Intercompany SMM Kaydı
  gc_stk_cancel           TYPE char1 VALUE '3'  ,  " Intercompany Satıcı Kaydı İptal
  gc_smm_cancel           TYPE char1 VALUE '4'  ,  " Intercompany SMM Kaydı İptal
  gc_stc_hzm_create(1)    TYPE c     VALUE '5' ,   " Intercompany satıcı hizmet kaydı
  gc_stc_hzm_cancel(1)    TYPE c     VALUE '6' ,   " Inter.comp satıcı hizmet iptal
  gc_stc_iad_create(1)    TYPE c     VALUE '7' ,   " Inter.comp stc iade kaydı
  gc_stc_iad_cancel(1)    TYPE c     VALUE '8' ,   " Inter.comp stc iade kaydı iptal
  gc_stc_hzmiad_create(1) TYPE c     VALUE '9' ,   " Inter.comp stc hizmet iade kaydı
  gc_stc_hzmiad_cancel(1) TYPE c     VALUE 'a' ,   " Inter.comp stc hizmet iade iptal

  gc_ftrtip_hzmt(1)       TYPE c     VALUE 'H' ,   " Inter.comp hizmet faturası
  gc_ftrtip_hzmtiad(1)    TYPE c     VALUE 'i' ,   " Inter.comp hizmet iade faturası
  gc_ftrtip_std(1)        TYPE c     VALUE 'S' ,   " Inter.comp standart fatura
  gc_ftrtip_iad(1)        TYPE c     VALUE 'R' ,   " Inter.comp iade fatura

  gc_kschl_icbill         TYPE sna_kschl VALUE 'ZF98', " Siparişe ilişkin DM oluşturma
  gc_reason_rev           TYPE stgrd VALUE '01' ,  " Muhasebe belgesi ters kayıt nedeni
  gc_mus_parvw            TYPE parvw VALUE 'Z1' .  " Paz. Satış Yaptığı Müşteri Rolü

* For Logs
DATA:
  tb_lognumbers TYPE  bal_t_lgnm,
  wa_lognumbers LIKE LINE OF   tb_lognumbers.

CONSTANTS:
  gc_log_obj    TYPE balobj_d  VALUE 'ZYB_SD_LOG',
  gc_log_subobj TYPE balsubobj VALUE 'ZYB_SD001'.

* For Batch-input
DATA :
  va_mode TYPE ctu_mode   VALUE 'N',
  bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
  messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

* For Message
DATA:
  tb_msg   LIKE symsg    OCCURS 0 WITH HEADER LINE.
CONSTANTS:
  gc_msg_id TYPE symsgid VALUE 'ZSD_VF'.

* For Seltab
DATA:
  seltab    TYPE TABLE OF rsparams,
  seltab_wa LIKE LINE OF  seltab.

DEFINE add_message.
  clear tb_msg.
  tb_msg-msgty = &1.
  tb_msg-msgid = &2.
  tb_msg-msgno = &3.
  tb_msg-msgv1 = &4.
  tb_msg-msgv2 = &5.
  tb_msg-msgv3 = &6.
  tb_msg-msgv4 = &7.
  append tb_msg.
END-OF-DEFINITION.
DEFINE sel.
  clear seltab_wa.
  seltab_wa-selname = &1.
  seltab_wa-sign    = 'I'.
  seltab_wa-option  = &2.
  seltab_wa-low     = &3.
  seltab_wa-high    = &4.
  append seltab_wa to seltab.
END-OF-DEFINITION.
