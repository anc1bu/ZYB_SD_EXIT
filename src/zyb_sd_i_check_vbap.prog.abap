*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_CHECK_VBAP
*& - ZA07 (İhracat Stş Tahmin Sip) Aynı malzeme farklı klmde girilemez
*& - İhracatta ay içerisinde bir malzemenin bir müşteride tek ZA07
*& siparişi olabilir
*& - Sipariş stoğu olan özel kaleme ret nedeni koyulamama kontrolü
*& - Açık Üretim Siparişi kontrolü
*& - Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
*& - Girilebilir depo yerlerinin kısıtlaması
*&---------------------------------------------------------------------*
*        F_TVAK  = TVAK
*        F_TVAP  = TVAP
*        FDIALOG = DA_DIALOG
*        FXVBAP  = XVBAP[]
*        FVBAP   = VBAP.
*&*********************************************************************
*& Tanımlamalar
*&*********************************************************************
DATA:
  ls_xvbap LIKE vbapvb,
  ls_mska  LIKE mska,
  lv_beg   TYPE d,
  lv_end   TYPE d,
  ls_mara  LIKE mara.

DATA: lt_ordinf LIKE ordinf_cu OCCURS 0 WITH HEADER LINE,
      lv_urtmik TYPE co_psmng.
DATA: BEGIN OF lt_sip OCCURS 0 ,
        vbeln TYPE vbeln_va,
        posnr TYPE posnr_va,
        matnr TYPE matnr,
        vdatu TYPE edatu_vbak,
      END OF lt_sip.

CONSTANTS:
  gc_text      TYPE bezei40 VALUE 'Yeni kalem eklemezsiniz!'.

RANGES:
  r_datum FOR vbak-vdatu.

"--------->> Anıl CENGİZ 13.08.2018 11:13:58
DATA: lv_error TYPE string.
IF t180-trtyp NE 'A'.
  TRY.
      NEW zcl_sd_mv45afzb_checkvbap( it_xvbap = xvbap[]
                                     ir_t180 = REF #( t180 ) )->kontroller( ).
    CATCH cx_root INTO DATA(lo_cx_root).
      lv_error = lo_cx_root->if_message~get_text( ).
  ENDTRY.
ENDIF.
"---------<<

"--------->> Anıl CENGİZ 29.06.2020 17:08:50
"YUR-644

"---------<<
*&*********************************************************************
*& Tanımlamalar
*&*********************************************************************
*&*********************************************************************
*& Depo Yeri Yetkisi Kontrolü
*&*********************************************************************
*IF vbak-vtweg EQ '10'. "Sadece yurtiçinde bölge stokları için kontrol
*kondu.
AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
                ID 'ACTVT' FIELD '01' " read access
                ID 'LGORT'FIELD vbap-lgort. " actual value
IF sy-subrc <> 0.
  MESSAGE e098(zyb_sd) WITH vbap-lgort.
ENDIF.
*ENDIF.

CLEAR: ls_mara.
SELECT SINGLE  * FROM mara INTO ls_mara
        WHERE matnr = vbap-matnr.

IF vbak-auart NE 'ZA07'.
  IF vbap-matnr IS NOT INITIAL AND
     ( vbak-auart NE 'ZA08' AND vbak-auart NE 'ZA03') AND
     ( vbak-vbtyp NE 'K' AND vbak-vbtyp NE 'L' AND vbak-vbtyp NE 'H').

*   --20181115 tarihinde Alptekin, Aysun, Anıl Talebni üzerine kapatıldı.
*   if ls_mara-matkl = 'MOKKS' AND ls_mara-meins = 'ST' AND LS_MARA-MATNR = 'O'. KRİTERLERİ EKLENDİ
*   NEDENİ MAİLLERDE GEÇİYOR AYSUN HANIMLARIN İHRACATIN İSTEĞİ ZA01 DEN GİREBİLMEK İSTİYORLAR
    IF ls_mara-mtart = 'ZM3P' AND ls_mara-meins = 'ST'.
      IF ( ls_mara-matkl = 'MOFFL' OR ls_mara-matkl = 'MOKKS' ) AND ls_mara-meins = 'ST' AND ls_mara-matnr+0(1) = 'O'.

      ELSE.
        MESSAGE e028(zsd_va).
      ENDIF.

    ENDIF.

  ENDIF.
ENDIF.

IF ( *vbap-mvgr1 <> vbap-mvgr1 OR *vbap-mvgr2 <> vbap-mvgr2 ) AND
vbep-wmeng <> 0.
  MESSAGE s006(zsd_va) DISPLAY LIKE 'E' . "WITH ls_xvbap-posnr gc_text. .
ENDIF.

IF vbak-vtweg EQ '20'.
  CASE tvak-kalvg.
    WHEN gc_vg_3.
    WHEN gc_vg_4 OR gc_vg_5 .
      IF NOT vbap-mvgr1 IS INITIAL.
        MESSAGE e007(zsd_va).
      ENDIF.
    WHEN OTHERS.
      IF NOT vbap-mvgr1 IS INITIAL.
        MESSAGE e007(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr2 IS INITIAL.
        MESSAGE e014(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr3 IS INITIAL.
        MESSAGE e015(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr4 IS INITIAL.
        MESSAGE e016(zsd_va).
      ENDIF.
  ENDCASE.
ENDIF.

"--------->> Anıl CENGİZ 03.08.2018 15:30:10
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
" Yarım palet ve kısmi palette palet hesaplpaması yapabilsin diye.
IF vbak-vtweg EQ '10'. "Sadece yurtiçi için yaptık.
  CASE tvak-kalvg.
    WHEN gc_vg_3.
    WHEN gc_vg_4 OR gc_vg_5 .
      IF NOT vbap-mvgr1 IS INITIAL.
*        MESSAGE e007(zsd_va).
      ENDIF.
    WHEN OTHERS.
      IF NOT vbap-mvgr1 IS INITIAL.
        MESSAGE e007(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr2 IS INITIAL.
        MESSAGE e014(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr3 IS INITIAL.
        MESSAGE e015(zsd_va).
      ENDIF.
      IF NOT vbap-mvgr4 IS INITIAL.
        MESSAGE e016(zsd_va).
      ENDIF.
  ENDCASE.
ENDIF.
"---------<<



*&*********************************************************************
*& --> ZA07 (İhracat Stş Tahmin Sip) Aynı mlzme farklı klmde girilemez
*&*********************************************************************
CLEAR ls_xvbap.
***IF vbak-auart EQ gc_au_za07 AND vbak-vkorg EQ gc_vkorg_san AND
***   vbak-vtweg EQ gc_vtweg_ihr.
***  LOOP AT xvbap INTO ls_xvbap WHERE updkz NE updkz_delete
***                                AND abgru EQ space
***                                AND posnr NE vbap-posnr
***                                AND matnr EQ vbap-matnr.
***    EXIT.
***  ENDLOOP.
***
***  IF  sy-subrc = 0.
***    MESSAGE e002(zsd_va) WITH ls_xvbap-posnr gc_text DISPLAY LIKE
*'I'.
***  ENDIF.
***ENDIF.
*&*********************************************************************
*& <-- ZA07 (İhracat Stş Tahmin Sip) Aynı mlzme farklı klmde girilemez
*&*********************************************************************

*&*********************************************************************
*& --> İhracatta ay içerisinde bir malzemenin bir müşteride tek ZA07
*& siparişi olabilir
*&*********************************************************************
FREE: lt_sip, r_datum.

IF sy-calld = ''.


  IF vbak-auart EQ gc_au_za07 AND vbak-vkorg EQ gc_vkorg_san AND
     vbak-vtweg EQ gc_vtweg_ihr AND vbap-abgru EQ space.
    CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
      EXPORTING
        iv_date             = vbak-vdatu
      IMPORTING
        ev_month_begin_date = lv_beg
        ev_month_end_date   = lv_end.

    add_rang: r_datum 'I' 'BT' lv_beg lv_end.

    SELECT vbak~vbeln
           vbap~posnr
           vbak~vdatu
           vbap~matnr FROM vbak
      INNER JOIN vbap ON vbap~vbeln EQ vbak~vbeln AND
                         vbap~posnr EQ vbap~posnr
       INTO CORRESPONDING FIELDS OF TABLE lt_sip
          WHERE vbak~auart EQ gc_au_za07
            AND vbak~vdatu IN r_datum
            AND vbak~kunnr EQ vbak-kunnr
            AND vbak~vkorg EQ vbak-vkorg
            AND vbak~vtweg EQ vbak-vtweg
            AND vbak~spart EQ vbak-spart
            AND vbap~matnr EQ vbap-matnr
            AND vbap~abgru EQ space.

    LOOP AT lt_sip WHERE vbeln NE vbak-vbeln.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
*      MESSAGE e003(zsd_va) WITH 'Sip No:' lt_sip-vbeln
*                                'Klm No:' lt_sip-posnr
*                          DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.
ENDIF.
*&*********************************************************************
*& <-- İhracatta ay içerisinde bir malzemenin bir müşteride tek ZA07
*& siparişi olabilir
*&*********************************************************************

*&*********************************************************************
*& --> Sipariş stoğu olan özel kaleme ret nedeni koyulamama kontrolü
*&*********************************************************************
CLEAR: ls_mska.
IF NOT vbap-abgru IS INITIAL AND
   vbap-abgru NE yvbap-abgru AND
  "--------->> add by mehmet sertkaya 10.10.2018 14:03:53
   vbap-abgru NE 'Z5'.
  "-----------------------------<<
  SELECT SINGLE * FROM mska
    INTO ls_mska
   WHERE matnr EQ vbap-matnr
     AND werks EQ vbap-werks
     AND vbeln EQ vbap-vbeln
     AND posnr EQ vbap-posnr
     AND  kalab GT 0.
  IF sy-subrc EQ 0.
    MESSAGE e004(zsd_va) WITH vbap-vbeln vbap-posnr vbap-matnr
                       DISPLAY LIKE 'I'.
  ENDIF.
ENDIF.
*&*********************************************************************
*& --> Sipariş stoğu olan özel kaleme ret nedeni koyulamama kontrolü
*&*********************************************************************
*&*********************************************************************
*& --> Üretim Siparişi kontrolü
*Anıl taşkın kapattı
*&*********************************************************************
**IF t459k-mntga IS INITIAL         AND
**   yvbap-kwmeng NE *vbap-kwmeng   AND
**   yvbap-kwmeng > 0               AND
**   vbap-vbelv EQ vbap-vbeln      AND
**   vbap-posnv EQ vbap-posnr      AND
**   ( vbap-kzvbr EQ kzvbr_e OR
**     vbap-sobkz EQ chare )       AND
**   vbapd-updkz NE updkz_new      AND
**   vbak-auart  NE gc_au_za07     AND
**   yvbap-vbeln eq vbap-vbeln     and
**   yvbap-posnr eq vbap-posnr.
**  PERFORM order_check TABLES lt_ordinf
**                       USING vbap-vbelv vbap-posnv.
**ENDIF.
**
**DATA: lv_psmng TYPE co_psmng,
**      lt_afpo  LIKE afpo OCCURS 0 WITH HEADER LINE.
**
**CLEAR lv_urtmik.
**IF NOT lt_ordinf[] IS INITIAL.
**  FREE: lt_afpo.
**  SELECT * FROM afpo
**      INTO TABLE lt_afpo
**     FOR ALL ENTRIES IN lt_ordinf
**       WHERE aufnr EQ lt_ordinf-aufnr
**         AND matnr EQ lt_ordinf-matnr
**         AND kdauf EQ lt_ordinf-vbeln
**         AND kdpos EQ lt_ordinf-vbelp.
**
**  LOOP AT lt_afpo.
**    CLEAR lv_psmng.
*** toplam miktar - ıskarta miktarı
**    lv_psmng = lt_afpo-psmng - lt_afpo-psamg.
**    IF vbap-vrkme NE lt_afpo-amein.
**      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
**        EXPORTING
**          i_matnr              = lt_afpo-matnr
**          i_in_me              = lt_afpo-amein
**          i_out_me             = vbap-vrkme
**          i_menge              = lv_psmng
**        IMPORTING
**          e_menge              = lv_psmng
**        EXCEPTIONS
**          error_in_application = 1
**          error                = 2
**          OTHERS               = 3.
**    ENDIF.
**    lv_urtmik = lv_urtmik + lv_psmng.
**  ENDLOOP.
**  IF vbap-kwmeng LT lv_urtmik.
**    MESSAGE e017(zsd_va) WITH lv_urtmik.
**  ENDIF.
**ENDIF.
*&*********************************************************************
*& <-- Üretim Siparişi kontrolü
*&*********************************************************************
*&*********************************************************************
*& --> Depo Yeri Kontrolü
*&*********************************************************************
IF  vbap-werks NE '2000'.
  CASE vbap-lgort.
    WHEN '1200' OR '2101' OR '2106' OR '2107' OR '2134' OR '2135' OR
         '2100'.
      IF vbak-vtweg EQ gc_vtweg_ihr.
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
      ENDIF.

      IF ( vbak-auart  EQ gc_au_za02 OR vbak-auart EQ gc_au_za03
           OR vbak-auart EQ gc_au_za11 ).
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
      ENDIF.
    WHEN '2000'.
      MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
    WHEN OTHERS.

      "--> Talep: 8000004364
*      IF vbap-lgort EQ '1250'.
*        MESSAGE e032(zsd_va) WITH '1250 ' vbap-posnr vbap-matnr.
*      ENDIF.
      "<-- Talep: 8000004364

      IF vbap-lgort EQ '1202'  AND " Üretim yarım palet
         call_bapi  IS INITIAL AND vbak-auart NE gc_au_za06.
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
      ENDIF.

* Numune siparişi dışında numune depo yeri girilirse hata verir.
      IF  vbap-lgort   EQ '1220' AND
         ( vbak-auart  NE gc_au_za02 AND vbak-auart NE gc_au_za03
           AND vbak-auart NE gc_au_za11 ).
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr..
      ENDIF.

* Adana sevkiyat noktası dışında girilirse hata verir

**-->
** Adana deposundan da eskişehirden de ürün olabileceği için kontrol
*kaldırıldı
*IF vbap-lgort EQ '1190' AND vbap-vstel NE '1200' AND ls_mara-mtart EQ
*'ZYYK'.
*        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
*      ENDIF.
**--<
      IF vbap-lgort EQ '1181' AND ls_mara-mtart NE 'ZYYK'.
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
      ENDIF.

* Eskişehir sevkiyat noktası dışında girilirse hata verir
      IF vbap-lgort EQ '1181' AND vbap-vstel NE '1300'.
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr.
      ENDIF.

      IF vbap-lgort EQ '1240' AND vbak-auart NE gc_au_zr01.
        MESSAGE e032(zsd_va) WITH vbap-lgort vbap-posnr vbap-matnr..
      ENDIF.

  ENDCASE.
ENDIF.

"Standart belgelerde bu kontrole girmemeli.
DATA: ls_kalvg TYPE tvak-kalvg,
      lv_mtpos TYPE mvke-mtpos.
CLEAR: ls_kalvg.
SELECT SINGLE kalvg FROM tvak INTO ls_kalvg
  WHERE auart = vbak-auart.
IF vbak-vtweg EQ gc_vtweg_dgr AND vbap-lgort IS INITIAL
  AND ls_kalvg NE 'A'.
  CLEAR lv_mtpos.
  SELECT SINGLE mtpos FROM mvke INTO lv_mtpos
          WHERE matnr = vbap-matnr
            AND vkorg = vbak-vkorg
            AND vtweg = vbak-vtweg.
  IF lv_mtpos NE 'Z030'.
    MESSAGE e033(zsd_va) WITH vbap-posnr vbap-matnr.
  ENDIF.
ENDIF.
*&*********************************************************************
*& <-- Depo Yeri Kontrolü
*&*********************************************************************

"--------->> Anıl CENGİZ 07.06.2018 07:44:16
"YUR-28 Palet Satış Ekranı
IF lines( xvbap[] ) > 0.
  DATA(lt_return) = NEW zcl_sd_palet( )->pltkalem_kontrol(
                          EXPORTING
                            it_xvbap = xvbap[] ).
  IF lines( lt_return ) > 0.
    MESSAGE e126(zyb_sd).
  ENDIF.
ENDIF.
"---------<<

*--->>>MOZDOGAN 25.07.2018 10:30:30
*YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*LOOP AT xvbkd INTO DATA(ls_vbkd) WHERE posnr = 10
*                                   AND delco IS NOT INITIAL.
*EXIT.
*ENDLOOP.
LOOP AT xvbap TRANSPORTING NO FIELDS
              WHERE pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm
              AND vkaus IS NOT INITIAL.
  EXIT.
ENDLOOP.

IF sy-subrc <> 0.
  DESCRIBE TABLE xvbap.
  IF sy-tfill > 1.
    CALL FUNCTION 'ZSD_FPLTFAT_SETQUANTITY'
      EXPORTING
        i_vbak  = vbak
        i_vbap  = vbap
      TABLES
        it_vbap = xvbap[]
        it_vbep = xvbep[].
    "--------->> Anıl CENGİZ 26.10.2018 14:19:18
    "YUR-203 300111930 numaralı sipariş stok olmamasına rağmen teyit veriyor.
    "Sadece palet kalemi için yapmamız gerekiyor. Yoksa bütün kalemlere teyit
    "veriyor.
    IF vbap-pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.
      READ TABLE xvbap INTO DATA(ls_vbap)
        WITH KEY vbeln = vbap-vbeln
                 posnr = vbap-posnr.

      vbap-kwmeng = vbap-klmeng = vbap-kbmeng = ls_vbap-kwmeng.
    ENDIF.
    "---------<<

    READ TABLE xvbap[] TRANSPORTING NO FIELDS
      WITH KEY pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm
               netwr = 0.
    IF sy-subrc EQ 0.
      "--------->> Anıl CENGİZ 21.01.2019 13:28:55
      "YUR-254 Excelden toplu sipariş kalemi yapıştırıldığında
      "VA01 ekranında dump alnıyor
      "Sadecee palet kalemim için pricing yapılmalı.
      IF vbap-pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.
        "---------<<
        PERFORM vbkd_pricing(sapfv45k).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.


*IF vbap-pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.
*
*  DATA: lt_vbfa TYPE TABLE OF vbfa,
*        lt_vbup TYPE TABLE OF vbup,
*        lt_vbep TYPE TABLE OF vbepvb,
*        lt_vbap TYPE TABLE OF vbapvb.
*
*  lt_vbfa[] = xvbfa[].
*  lt_vbup[] = xvbup[].
*  lt_vbep[] = xvbep[].
*  lt_vbap[] = xvbap[].
*
*  CALL FUNCTION 'RV_SCHEDULE_CHECK_DELIVERIES'
*    EXPORTING
*      fbeleg                  = vbak-vbeln
*      fposnr                  = vbap-posnr
*      if_no_sort              = 'X'
*    TABLES
*      fvbfa                   = lt_vbfa
*      fvbup                   = lt_vbup
*      fxvbep                  = lt_vbep
*      fvbap                   = lt_vbap
*    EXCEPTIONS
*      fehler_bei_lesen_fvbup  = 1
*      fehler_bei_lesen_fxvbep = 2
*      OTHERS                  = 3.
*
*  IF sy-subrc <> 0.
*
*  ELSE.
*
*
*    READ TABLE xvbap TRANSPORTING NO FIELDS
*      WITH KEY vbeln = vbap-vbeln
*               posnr = vbap-posnr.
*
*    DATA(lv_tbx) = sy-tabix.
*
**       for binary search
*    SORT lt_vbep BY vbeln posnr etenr.
*    READ TABLE lt_vbep ASSIGNING FIELD-SYMBOL(<ls_vbep2>)
*                       WITH KEY vbeln = vbak-vbeln
*                                posnr = vbap-posnr
*                       BINARY SEARCH.
*    IF sy-subrc = 0.
*      DATA: ls_vbap1 TYPE vbapvb.
*
*      MOVE-CORRESPONDING vbap TO ls_vbap1.
*
*      ls_vbap1-lsmeng = ls_vbap1-kwmeng - <ls_vbep2>-vsmng.
*      vbap-lsmeng = vbap-kwmeng - <ls_vbep2>-vsmng.
*
*      MODIFY xvbap[] INDEX lv_tbx FROM ls_vbap1 TRANSPORTING lsmeng.
*    ENDIF.
*  ENDIF.
*
*ENDIF.

*<<<---MOZDOGAN 25.07.2018 10:30:30
