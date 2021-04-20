*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_MOVE_TO_VBAK
*& - Sipariş Düzeyinde Kampanya Numarası Belirleme
*&---------------------------------------------------------------------*
DATA:
  gv_knuma TYPE knuma_ag,
  gv_zterm TYPE dzterm,
  gv_lcnum TYPE lcnum,
  gv_boart TYPE boart,
  paz.

CLEAR paz.
IF vbak-auart EQ 'ZA09' OR vbak-auart EQ 'ZC08' OR
   vbak-auart EQ 'ZD03' OR vbak-auart EQ 'ZR02'.
  paz = 'X'.
  EXIT.
ENDIF.

"--------->> Anıl CENGİZ 29.01.2020 21:58:38
"YUR-578 - Refactoring kapsamında ZCL_SD_MV45AFZZ_MVTOVBAK_001 içerisine taşındı.
**IF sy-uname = 'BBOZACI' OR sy-uname = 'ATASKIN' OR sy-uname = 'ANILC'
**OR
**   sy-uname = 'ANILT'.
**&--------------------------------------------------------------------*
**& --> Kampanya Numarası Belirleme
**&--------------------------------------------------------------------*
**  IF sy-tcode(2) EQ 'VA' AND  ( t180-trtyp EQ 'H' OR
*IF ( t180-trtyp EQ 'H' OR
**   t180-trtyp EQ 'V' ) AND vbak-vkorg EQ gc_vkorg_paz
*t180-trtyp EQ 'V' ) AND ( vbak-vkorg EQ '2100' OR vbak-vkorg EQ '1100' )
**                    and vbak-zz_knuma_ag is initial
*                    AND ( vbak-vtweg EQ '10' OR vbak-vtweg EQ '30' )
*                    AND vbak-auart NE gc_au_za09
*                    AND vbak-auart NE gc_au_zr02
*                    AND vbak-auart NE gc_au_zc08
*                    AND vbak-auart NE gc_au_zd03
*                    AND vbak-vkbur NE '1120'
**                    and vbkd-lcnum is initial
*  "--------->> Anıl CENGİZ 01.04.2019 09:41:57
*  "YUR-361 Satış Siparişinde Müşteri Değiştiğinde
*  "Mali Belge Değişmiyor
*                    AND NEW zcl_sd_mv45afzz_movetovbak( is_vbak = vbak
*                                                        is_vbkd = vbkd
*                                                        iv_call_bapi = call_bapi
*                                           )->check_lcnum_change( ) EQ abap_true.
*  "---------<<
*
*  CLEAR: gv_knuma, gv_zterm, gv_lcnum, gv_boart.
*  CALL FUNCTION 'ZYB_SD_F_KMP_SELECT_POPUP'
*    EXPORTING
*      i_vkorg = vbak-vkorg
*      i_vtweg = vbak-vtweg
*      i_kunnr = vbak-kunnr
*      i_date  = vbkd-prsdt
*      i_auart = vbak-auart
*    IMPORTING
*      e_knuma = gv_knuma
*      e_zterm = gv_zterm
*      e_lcnum = gv_lcnum
*      e_boart = gv_boart.
*
** kampanya (ticari promosyon) kodu belirleme
*  IF NOT gv_knuma IS INITIAL.
*    vbak-zz_knuma_ag = gv_knuma.
*  ELSE.
*    MESSAGE e005(zsd_va) WITH vbak-kunnr DISPLAY LIKE 'I'.
*  ENDIF.
** ödeme koşulu belirleme
*  IF NOT gv_zterm IS INITIAL.
*    kurgv-zterm = gv_zterm.
*  ENDIF.
** mali belge belirleme
*  IF NOT gv_lcnum IS INITIAL.
*    vbkd-lcnum = gv_lcnum.
*  ENDIF.
*
** ödeme biçimi belirleme
*  IF NOT gv_boart IS INITIAL.
*    CASE gv_boart.
*      WHEN 'ZY01'. vbkd-zlsch = 'C'. " Çek Kampanyası
*      WHEN 'ZY02'. vbkd-zlsch = 'K'. " Kredi Kartı Kampanyası
*      WHEN 'ZY03'. vbkd-zlsch = 'H'. " Banka Havalesi Kampanyası
*    ENDCASE.
*  ENDIF.
*ENDIF.
"---------<<

* kampanya ile ilgili bilgili 8310 nolu ekranda ve / bapi doldurur.
IF NOT vbak-zz_knuma_ag IS INITIAL.
  PERFORM fill_data.
ELSE.
  IF call_bapi EQ 'X' AND vbak-vtweg NE gc_vtweg_ihr AND
    vbak-vkorg EQ gc_vkorg_san AND paz EQ space
    "--------->> Anıl CENGİZ 08.06.2018 09:37:50
    "YUR-35 Numune Siparişlerinde Blokaj Hatası
     AND vbak-kkber IS NOT INITIAL
    "---------<<
    "--------->> Anıl CENGİZ 26.06.2018 08:27:54
    "YUR-44 ZSD017 numune onayı
    AND vbak-netwr NE 0
    AND vbak-auart NE 'ZA11'.
    "---------<<
    MESSAGE e005(zsd_va) WITH vbak-kunnr.
  ENDIF.
ENDIF.



IF vbak-vtweg = gc_vtweg_ic AND t180-trtyp = 'H'
  "--------->> Anıl CENGİZ 14.08.2018 13:32:23
 "YUR-111 Sevkiyat Türü İlk Sipariş Açılırken Hep "01 - Kamyon" Geliyor.
  AND vbkd-vsart IS INITIAL.
  "---------<<
  vbkd-vsart = '01'.
ENDIF.



* Added By RCELEBI AT ACRON DATE: 21.10.2016
* Kampanya numarasının iade edilebilir kontrolü.
* CS0005157
DATA: ls_zyb_sd_kmpny_knt TYPE zyb_sd_kmpny_knt,
      lv_message(60).

CLEAR: ls_zyb_sd_kmpny_knt, lv_message.

SELECT SINGLE * FROM zyb_sd_kmpny_knt INTO ls_zyb_sd_kmpny_knt
  WHERE knuma_ag EQ vbak-zz_knuma_ag.

IF ls_zyb_sd_kmpny_knt-iade EQ 'X'
AND ( vbak-auart EQ 'ZR01' OR vbak-auart EQ 'ZC06' ).
  "ATASKIN ZC06 eklendi.
  CONCATENATE vbak-zz_knuma_ag
  'numaralı kampanyanın iade girişi kapatılmıştır'
  INTO lv_message.
  MESSAGE lv_message TYPE 'E'.
ENDIF.

"--------->> Anıl CENGİZ 06.08.2018 07:52:30
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
IF ls_zyb_sd_kmpny_knt-spkpt EQ abap_true AND NOT ( t180-trtyp EQ 'V' OR
t180-trtyp EQ 'A' ).
  CONCATENATE vbak-zz_knuma_ag
  'numaralı kampanya sipariş girişine kapatılmıştır.'
  INTO lv_message.
  MESSAGE lv_message TYPE 'E'.
ENDIF.
"---------<<

"--------->> Anıl CENGİZ 28.09.2020 09:01:34
"YUR-739
***acengiz --> YUR-9  Planlanan Siparişte Değişiklik Yapılmasının Engel
** LV09CF63
*EXPORT vbak FROM vbak TO MEMORY ID 'ZSD_ENGL'.
*EXPORT t180 FROM t180 TO MEMORY ID 'ZSD_ENGL1'.
***acengiz <-- YUR-9  Planlanan Siparişte Değişiklik Yapılmasının Engel
"---------<<

*--->>>MOZDOGAN 25.07.2018 11:21:59
* YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi

DATA: ls_xvbap LIKE xvbap.
DATA: da_vara, da_varm.

DATA(lv_valid) =

NEW zcl_sd_paletftr_mamulle( )->valid(
                                   EXPORTING
                                     iv_auart = vbak-auart
                                     iv_vtweg = vbak-vtweg
                                     iv_kunnr = vbak-kunnr ).

IF lv_valid EQ abap_true AND t180-trtyp = 'H'.

  READ TABLE xvbap INTO ls_xvbap
    WITH KEY pstyv = zcl_sd_paletftr_mamulle=>cv_pltklm.

  IF sy-subrc <> 0.
    "--------->> Anıl CENGİZ 12.08.2020 16:44:12
    "YUR-712
    CLEAR: *vbep.
    "---------<<
    vbap-waerk = vbak-waerk.
    vbap-matnr = zcl_sd_paletftr_mamulle=>cv_pltmlzno.
    "--------->> Anıl CENGİZ 16.10.2018 06:32:21
    "YUR-191 Bayi Cari Hesap Raporunda formül düzeltmesi önemli
    "Ödeme Garanti Şeması Dolmasığı için Eklendi
    vbap-abges = 1.
    SELECT SINGLE akart FROM akkp INTO vbap-abfor WHERE lcnum EQ
    vbkd-lcnum.
    "---------<<

    IF *vbap-waerk IS INITIAL.
      *vbap-waerk = vbap-waerk.
    ENDIF.

    rv45a-mabnr = zcl_sd_paletftr_mamulle=>cv_pltmlzno.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = rv45a-mabnr
      IMPORTING
        output = rv45a-mabnr.

    gv_rv45a_mabnr_gefuellt = charx.
    xvbap_loop_fcode = 'ENT1'.

    PERFORM vbap_matnr_matwa_fuellen(sapfv45p).
    PERFORM vbap-matnr_pruefen(sapfv45p) USING charx
                                               sy-subrc.

    PERFORM vbap-spart_pruefen_fe(sapfv45p).
    PERFORM vbap-pstyv_pruefen(sapfv45p).

    PERFORM vbap_fuellen(sapfv45p).
    PERFORM vbap-matnr_null_pruefen(sapfv45p).

    PERFORM vbap_bearbeiten(sapfv45p).
    rv45a-kwmeng = '1.000'.
    IF vbapin-kwmeng IS INITIAL.
      vbapin-kwmeng = rv45a-kwmeng.
    ENDIF.

    PERFORM vbep-wmeng_setzen(sapfv45e).
    PERFORM vbep_edatu_pruefen(sapfv45e).
    PERFORM vbep_fuellen(sapfv45e).
    PERFORM vbep-wmeng_pruefen_handler(sapfv45e) CHANGING da_vara.
    PERFORM vbep-wmeng_pruefen_handler(sapfv45e) CHANGING da_varm.
    PERFORM vbep_bearbeiten(sapfv45e).

*      PERFORM koein_ermitteln(sapfv45p).
    PERFORM komv_bearbeiten(sapfv45p).

  ENDIF.
ENDIF.
*<<<---MOZDOGAN 25.07.2018 11:21:59

*--->>>MOZDOGAN 26.11.2018 14:19:08 YUR-220 Yurtbay USA Nihai Müşteri
*Çıktıları
CONSTANTS: lc_posnr TYPE posnr VALUE '000000',
           lc_par1d TYPE parvw VALUE '1D',
           lc_trtyp TYPE trtyp VALUE 'H'.
IF t180-trtyp = lc_trtyp.
  TRY.
      NEW zcl_sd_yurtbayusa( is_params = VALUE #( kunnr = VALUE #( xvbpa[ posnr = lc_posnr
                                                                          parvw = lc_par1d ]-kunnr )
                                                  vkorg = vbak-vkorg
                                                  vtweg = vbak-vtweg
                                                  spart = vbak-spart
                                                  vbtyp = vbak-vbtyp
                                                  auart = vbak-auart ) )->kunnr_check( it_vbpa = xvbpa[] ).
    CATCH cx_root INTO DATA(lo_cx_root).
  ENDTRY.
ENDIF.
*<<<---MOZDOGAN 26.11.2018 14:19:08 YUR-220 Yurtbay USA Nihai Müşteri
*Çıktıları

"--------->> Anıl CENGİZ 29.05.2019 11:14:40
"YUR-380
IF ( t180-trtyp EQ 'V' OR
      t180-trtyp EQ 'H' ) AND
      vbkd-lcnum IS NOT INITIAL AND
      call_bapi NE 'X'.

  CALL FUNCTION 'ENQUEUE_EVAKKPE'
    EXPORTING
      lcnum          = vbkd-lcnum
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDIF.
"---------<<
"--------->> Anıl CENGİZ 23.02.2021 11:11:42
"YUR-852 -> ZCL_SD_MV45AFZZ_FORM_RDDOC_003 içerisine taşında
*"--------->> Anıl CENGİZ 07.12.2018 09:54:01
*"YUR-249
*IF t180-trtyp EQ 'V' AND vbkd-lcnum IS NOT INITIAL.
*  zcl_sd_toolkit=>enqueue_read_akkp( vbkd-lcnum ).
*ENDIF.
*"---------<<
"---------<<
