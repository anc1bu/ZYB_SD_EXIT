*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_FILL_VBRK_VBRP
*& - Nakliye Belgesi Devralım
*& - İhracat Muhasebe Kayıt Blokajı
*&---------------------------------------------------------------------*
DATA: lv_tknum TYPE tknum.
*&---------------------------------------------------------------------*
*& --> Nakliye Belgesi Devralım
*&---------------------------------------------------------------------*
CLEAR lv_tknum.


IF vbrk-vtweg = '20'. " İhracat

  vbrk-taxk1 = kurgv-taxk1.

*   vbrk-fktyp EQ 'L' AND " Teslimat İlişkili Fatura
  IF vbrk-vbtyp EQ 'M' . " Fatura Belgesi
    SELECT SINGLE vttp~tknum FROM vttp
        INNER JOIN vttk ON  vttk~tknum EQ vttp~tknum
              INTO lv_tknum
             WHERE vttp~vbeln EQ likp-vbeln
               AND vttk~shtyp EQ 'Z001'. " Ana güzargah

    IF NOT lv_tknum IS  INITIAL.
      MOVE lv_tknum TO vbrk-zztknum.
    ENDIF.
  ENDIF.
ENDIF.
*&---------------------------------------------------------------------*
*& <-- Nakliye Belgesi Devralım
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& --> İhracat Muhasebe Kayıt Blokajı
*&---------------------------------------------------------------------*
IF vbrk-vtweg = '20' AND " İhracat
*   vbrk-fktyp EQ 'L' AND " Teslimat İlişkili Fatura
 vbrk-vbtyp EQ 'M' AND " Fatura Belgesi
 t180-trtyp EQ 'H'.
  vbrk-rfbsk = 'A'. " kayıt blokajı
  CLEAR vbrk-exnum.
ENDIF.
*&---------------------------------------------------------------------*
*& <-- İhracat Muhasebe Kayıt Blokajı
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& --> Dahili Mahsuplaştırma için Sipariş Nedeni Doldurma
*&---------------------------------------------------------------------*
IF vbrk-fkart EQ 'ZM04'.
  SELECT SINGLE augru_auft FROM vbrp INTO vbrp-augru_auft
    WHERE vbeln = vbap-vbeln
    AND posnr = vbap-posnr.
ENDIF.
*&---------------------------------------------------------------------*
*& <-- Dahili Mahsuplaştırma için Sipariş Nedeni Doldurma
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*& --> VBRP Ek Alan Doldurma
*&---------------------------------------------------------------------*
*break mozdogan.
*DATA: t_krk LIKE TABLE OF zyb_sd_s_krk_val      WITH HEADER LINE,
*      atnam LIKE TABLE OF bapicharactrangetable WITH HEADER LINE.
*
*DO 2 TIMES.
*atnam-sign   = 'I'.
*atnam-option = 'EQ'.
*IF sy-tabix  = 1.
* atnam-low   = 'RENK_TONU'.
*ELSE.
* atnam-low   = 'KALIBRE'.
*ENDIF.
*APPEND atnam.
*ENDDO.
*
*CALL FUNCTION 'ZYB_SD_F_BATCH_READ_MUL'
*  TABLES
*    tb_krk         = t_krk
*    atnam_rt       = atnam
.


*&---------------------------------------------------------------------*
*& <-- VBRP Ek Alan Doldurma
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& --> Çıktı Bilgileri
*&---------------------------------------------------------------------*
*break mozdogan.
*DATA: lines TYPE TABLE OF tline WITH HEADER LINE,
*      header LIKE thead.
*
*DATA: l_kna1  TYPE kna1,
*      t_vbrk  TYPE TABLE OF vbrk,
*      l_vbrk  TYPE vbrk,
*      l_marc  TYPE marc,
*      l_t001  TYPE t001,
*      l_t005t TYPE t005t,
*      l_t023t TYPE t023t,
*      l_adres TYPE zyb_sd_s_adres.
*
*DEFINE fill_header.
*  CLEAR header.
*  header-tdid     = &1.
*  header-tdobject = &2.
*  header-tdname   = '$000000001'.
*  header-tdspras  = &3.
*END-OF-DEFINITION.
*
*DEFINE save_text.
*  CALL FUNCTION 'SAVE_TEXT'
*    EXPORTING
*     client   = sy-mandt
*      header  = &1
*    TABLES
*      lines   = &2
*   EXCEPTIONS
*     id       = 1
*     language = 2
*     name     = 3
*     object   = 4
*     OTHERS   = 5.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*END-OF-DEFINITION.
*REFRESH t_vbrk.
*CLEAR: l_kna1, l_vbrk, l_marc, l_t001, l_t005t, l_t023t, l_adres.
*SELECT SINGLE * FROM kna1  INTO l_kna1  WHERE kunnr = vbrk-kunag.
*SELECT SINGLE * FROM t023t INTO l_t023t WHERE matkl = vbrp-matkl
*                                          AND spras = l_kna1-spras.
*SELECT SINGLE * FROM t005t INTO l_t005t WHERE land1 = l_kna1-land1
*                                          AND spras = l_kna1-spras.
*SELECT SINGLE * FROM marc INTO l_marc   WHERE werks = vbrp-werks
*                                          AND matnr = vbrp-matnr.
*SELECT SINGLE * FROM t001 INTO l_t001   WHERE bukrs = vbrk-bukrs.
*fill_header 'Z002' 'VBBK' l_kna1-spras.
*
*CALL FUNCTION 'ZYB_SD_F_ADRESBILGILERI'
*  EXPORTING
*    adrnr          = l_kna1-adrnr
* IMPORTING
*   adres           = l_adres
* EXCEPTIONS
*   not_found_adrnr = 1
*   OTHERS          = 2.
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*CLEAR lines.
*lines-tdline = l_adres-name1.
*APPEND lines.
*lines-tdline = l_adres-post_code1.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_t005t-landx.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_adres-remark.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_kna1-ort02.
*APPEND lines.
*save_text header lines.
*CLEAR header. REFRESH lines.
*
*fill_header 'Z001' 'VBBK' l_kna1-spras.
**lines-tdline = BOŞ.
**APPEND lines.
*CLEAR lines.
*lines-tdline = vbrk-fkdat.
*APPEND lines.
*CLEAR lines.
*lines-tdline = vbrk-vbeln.
*APPEND lines.
*save_text header lines.
*CLEAR header. REFRESH lines.
*
*fill_header 'Z004' 'VBBK' l_kna1-spras.
*
*SELECT * FROM vbrk INTO TABLE t_vbrk
*                   WHERE zztknum = vbrk-zztknum
*                     AND vbtyp   = 'U'.
*
*SORT t_vbrk by vbeln DESCENDING.
*READ TABLE t_vbrk INTO l_vbrk INDEX 1.
*CLEAR lines.
*lines-tdline = l_vbrk-zzprfm.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_vbrk-fkdat.
*APPEND lines.
*save_text header lines.
*CLEAR header. REFRESH lines.
*
*fill_header 'Z005' 'VBBK' l_kna1-spras.
*
*CLEAR lines.
*lines-tdline = l_t023t-wgbez60.
*APPEND lines.
*CONCATENATE 'INCOTERMS 2000: ' vbrk-inco1'&'vbrk-inco2
*INTO lines-tdline RESPECTING BLANKS.
*APPEND lines.
*CLEAR lines.
*CONCATENATE 'H.S CLASSIFICATION CODE OF THE GOODS ' l_marc-stawn(7)
*INTO lines-tdline RESPECTING BLANKS.
*APPEND lines.
*CLEAR lines.
*lines-tdline = 'DOCUMENTARY CREDIT NUMBER:'.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_t001-adrnr.
*APPEND lines.
*CLEAR lines.
*lines-tdline = l_adres-remark.
*APPEND lines.
*save_text header lines.
*CLEAR header. REFRESH lines.
