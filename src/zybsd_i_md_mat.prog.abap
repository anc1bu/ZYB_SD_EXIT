*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_MD_MAT
*& Malzeme  SD alanı ile ilgili kontroller
*& - SD Alanı Genişletme Kontrolleri
*& - Kalem Tipi Kontrolleri
*& - Dahili Mahsuplaştırma için sanayi de açılmayan malzemenin kontrolü
*& - Defolu ürünlerin Mip Karakteristiği 'ND' olması kontrolü
*& - Malzeme Hesap tayini kontrolü
*&---------------------------------------------------------------------*
* Tanımlamalar
*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_MASDATA_DEF
*&---------------------------------------------------------------------*
DATA:
* Malzeme Anaverisi Uyarlama Tablosu
  lt_c001 LIKE zyb_sd_t_c001 OCCURS 0 WITH HEADER LINE,
  t_c001  LIKE zyb_sd_t_c001 OCCURS 0 WITH HEADER LINE,

* Müşteri Anaverisi Uyarlama Tablosu
  lt_c002 LIKE zyb_sd_t_c002 OCCURS 0 WITH HEADER LINE,
  t_c002  LIKE zyb_sd_t_c002 OCCURS 0 WITH HEADER LINE,
  tb_msg  LIKE symsg OCCURS 0 WITH HEADER LINE.

DATA:
  l_c001 LIKE zyb_sd_t_c001,
  l_c002 LIKE zyb_sd_t_c002,
  l_t014 LIKE t014,
  l_knkk LIKE knkk,
  lv_taxkd LIKE knvi-taxkd.

CONSTANTS:
  gc_textcus   TYPE bezei40 VALUE 'Uyarlamayı Kontrol Edin (ZSD002)',
  gc_textmat   TYPE bezei40 VALUE 'Uyarlamayı Kontrol Edin (ZSD001)',
  gc_vkorg_paz TYPE vkorg   VALUE '2100',
  gc_vkorg_san TYPE vkorg   VALUE '1100',
  gc_extwg_def TYPE extwg   VALUE 'DEFO', " Malzeme Kaliteleri (defolu)
  gc_mip_nd    TYPE dismm   VALUE 'ND',
  gc_dwerk_paz TYPE dwerk   VALUE '2000',
  gc_vtweg_ic  TYPE vtweg   VALUE '10',
  gc_vtweg_dis TYPE vtweg   VALUE '20',
  gc_vtweg_dgr TYPE vtweg   VALUE '30'.

DATA:
  gv_txt     TYPE bezei40,
  lv_mandt   TYPE mandt.


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

DEFINE show_message.
  CALL FUNCTION 'RHVM_SHOW_MESSAGE'
    EXPORTING
      mess_header = 'İşlem sonucu'
    TABLES
      tem_message = tb_msg
    EXCEPTIONS
      canceled    = 1
      OTHERS      = 2.
END-OF-DEFINITION.

CLEAR: lt_c001, lt_c001[], l_c001.

** Kalem Tipi grubu üzerinden kontrol edilceği için kaldırıldı
***&*********************************************************************
***& --> Defolu ürünlerin Mip Karakteristiği 'ND' olması kontrolü
***&*********************************************************************
*** Defolu ürün mü?
**IF wmara-extwg EQ gc_extwg_def AND wmarc-dismm  NE gc_mip_nd.
**  MESSAGE e012(zsd_mas) WITH wmara-matnr wmarc-werks gc_mip_nd.
**ENDIF.
***&*********************************************************************
***& <-- Defolu ürünlerin Mip Karakteristiği 'ND' olması kontrolü
***&*********************************************************************

CHECK NOT wmvke IS INITIAL.
*&*********************************************************************
*& --> SD Alanı Genişletme
*&*********************************************************************
SELECT * FROM zyb_sd_t_c001
    INTO  TABLE lt_c001
    WHERE mtart EQ wmara-mtart.

IF NOT lt_c001[] IS INITIAL.
  READ TABLE lt_c001 WITH KEY vkorg = wmvke-vkorg
                              vtweg = wmvke-vtweg.
  IF sy-subrc <> 0.
    MESSAGE e003(zsd_mas)
       WITH wmara-mtart wmvke-vkorg wmvke-vtweg gc_textmat
       DISPLAY LIKE 'I'.
  ENDIF.
ELSE.
  MESSAGE e004(zsd_mas) WITH wmara-mtart  gc_textmat
    DISPLAY LIKE 'I'.
ENDIF.
*&*********************************************************************
*& <-- SD Alanı Genişletme
*&*********************************************************************

*&*********************************************************************
*& --> Kalem Tipi Kontrolleri
*&*********************************************************************
CHECK NOT lt_c001 IS INITIAL.

CLEAR: t_c001, t_c001[].

LOOP AT lt_c001 WHERE vkorg EQ wmvke-vkorg
                  AND vtweg EQ wmvke-vtweg
                  AND extwg EQ wmara-extwg
                  AND mtpos EQ wmvke-mtpos.
  EXIT.
ENDLOOP.

IF sy-subrc <> 0.

  t_c001[] = lt_c001[].

  SORT t_c001 BY extwg mtpos vkorg vtweg.
  DELETE ADJACENT DUPLICATES FROM t_c001 COMPARING extwg mtpos vkorg vtweg.

  CLEAR gv_txt.
  LOOP AT t_c001 WHERE vkorg EQ wmvke-vkorg
                   AND vtweg EQ wmvke-vtweg
                   AND extwg EQ wmara-extwg.
    IF gv_txt IS INITIAL.
      WRITE t_c001-mtpos TO gv_txt.
      CONDENSE gv_txt.
    ELSE.
      CONCATENATE gv_txt t_c001-mtpos INTO gv_txt
                                  SEPARATED BY ' , '.
    ENDIF.
  ENDLOOP.
  MESSAGE e005(zsd_mas) WITH wmara-mtart wmvke-vkorg
                             wmvke-vtweg gv_txt
  DISPLAY LIKE 'I'.
ENDIF.
*&*********************************************************************
*& <-- Kalem Tipi Kontrolleri
*&*********************************************************************

*&*********************************************************************
*& --> Dahili Mahsuplaştırma belgesi Kontrolleri
*&  Sanayi de açılmamış malzeme pazarlama şirketinde açılamaz !!
*&*********************************************************************
CLEAR lv_mandt.
IF wmvke-vkorg EQ gc_vkorg_paz AND wmvke-dwerk NE gc_dwerk_paz.
  SELECT SINGLE mandt FROM mvke
      INTO lv_mandt
     WHERE matnr EQ wmvke-matnr
       AND vkorg EQ gc_vkorg_san
       AND vtweg EQ wmvke-vtweg.
  IF sy-subrc <> 0 AND sy-cprog NE 'SAPMSED7'.
*    MESSAGE e011(zsd_mas) WITH gc_vkorg_san wmvke-vtweg.
  ENDIF.
ENDIF.
*&*********************************************************************
*& <-- Dahili Mahsuplaştırma belgesi Kontrolleri
*&  Sanayi de açılmamış malzeme pazarlama şirketinde açılamaz !!
*&*********************************************************************

*&*********************************************************************
*& --> Malzeme Hesap Tayini Kontrolü
*&*********************************************************************
CHECK NOT lt_c001 IS INITIAL.

CLEAR: t_c001, t_c001[].

LOOP AT lt_c001 WHERE vkorg EQ wmvke-vkorg
                  AND vtweg EQ wmvke-vtweg
                  AND mtart EQ wmara-mtart
                  AND ktgrm EQ wmvke-ktgrm.
  EXIT.
ENDLOOP.

IF sy-subrc <> 0.
  t_c001[] = lt_c001[].

  SORT t_c001 BY ktgrm vkorg vtweg.
  DELETE ADJACENT DUPLICATES FROM t_c001 COMPARING ktgrm vkorg vtweg.

  CLEAR gv_txt.
  LOOP AT t_c001 WHERE vkorg EQ wmvke-vkorg
                   AND vtweg EQ wmvke-vtweg.
    IF gv_txt IS INITIAL.
      WRITE t_c001-ktgrm TO gv_txt.
      CONDENSE gv_txt.
    ELSE.
      CONCATENATE gv_txt t_c001-ktgrm INTO gv_txt
                                  SEPARATED BY ' , '.
    ENDIF.
  ENDLOOP.
  MESSAGE e013(zsd_mas) WITH wmara-mtart wmvke-vkorg
                             wmvke-vtweg gv_txt
  DISPLAY LIKE 'I'.
ENDIF.
*&*********************************************************************
*& <-- Malzeme Hesap Tayini Kontrolü
*&*********************************************************************



*&*********************************************************************
*& --> Palet Tipi ve Kutu Tipi kontrolleri
*&*********************************************************************
DATA lv_count TYPE i.
IF wmvke-mvgr1 IS NOT INITIAL.
  CLEAR lv_count.
  SELECT COUNT( DISTINCT matnr ) FROM mvke INTO lv_count
    WHERE vkorg EQ wmvke-vkorg
      AND mvgr1 EQ wmvke-mvgr1
      AND matnr NE wmvke-matnr.

  IF lv_count IS NOT INITIAL.
    "&: & farklı & malzemeye daha tayin edilmiş. Kontrol ediniz.
    MESSAGE e016(zsd_mas)
      WITH 'Palet Tipi' wmvke-mvgr1 lv_count.
  ENDIF.
ENDIF.

IF wmvke-mvgr2 IS NOT INITIAL.
  CLEAR lv_count.
  SELECT COUNT( DISTINCT matnr ) FROM mvke INTO lv_count
    WHERE vkorg EQ wmvke-vkorg
      AND mvgr2 EQ wmvke-mvgr2
      AND matnr NE wmvke-matnr.

  IF lv_count IS NOT INITIAL.
    "&: & farklı & malzemeye daha tayin edilmiş. Kontrol ediniz.
    MESSAGE e016(zsd_mas)
      WITH 'Kutu Tipi' wmvke-mvgr2 lv_count.
  ENDIF.
ENDIF.
*&*********************************************************************
*& <-- Palet Tipi ve Kutu Tipi kontrolleri
*&*********************************************************************
