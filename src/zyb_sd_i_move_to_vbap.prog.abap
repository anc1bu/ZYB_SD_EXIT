*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_MOVE_TO_VBAP
*& - Müşteri - Malzeme ye göre default Palet, Kutu, Kutu Etiketi,
*&   Karo Alt Bilgi doldurma
*& - Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
*&---------------------------------------------------------------------*
* Tanımlamalar
  DATA:
*" Müşteri - Malzeme Palet Kutu Bilgisi
    ls_md001     LIKE zyb_sd_t_md001,
*" Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
    ls_olc_md001 LIKE zyb_t_md001.
*    ls_hienr01 LIKE vbpa.  "Üst müşteri zyb_sd_t_md001 tablosundan
  "çıkarıldı. Çünkü alt müşteri hiç bir zaman farklı üst müşteriye
  "atanmayacağı için bu tabloda üst müşteri olmasına gerek yok.

  "--------->> Anıl CENGİZ 27.07.2018 09:25:49
  "YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
  CHECK vbap-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
  "---------<<

  CLEAR: ls_md001, ls_olc_md001.
*&*********************************************************************
*& --> Müşteri - Malzemeye göre default değer doldurma
*&*********************************************************************
*  LOOP AT xvbpa INTO ls_hienr01 WHERE posnr EQ '000000'
*                                AND parvw = '1D'.
*  ENDLOOP.
*  IF ls_hienr01 IS NOT INITIAL.
*    SELECT SINGLE * FROM zyb_sd_t_md001
*      INTO ls_md001
*      WHERE vtweg EQ vbak-vtweg
*      AND hienr01 = ls_hienr01-kunnr
*      AND kunnr EQ vbak-kunnr
*      AND matnr EQ vbap-matnr.
*  ENDIF.
*  IF ls_md001 IS INITIAL.
  SELECT SINGLE * FROM zyb_sd_t_md001
    INTO ls_md001
      WHERE vtweg EQ vbak-vtweg
        AND kunnr EQ vbak-kunnr
        AND matnr EQ vbap-matnr.
*  ENDIF.
  IF vbak-vtweg NE '20'.

    IF ls_md001 IS INITIAL.
* YUR-192 -->

      SELECT SINGLE  * FROM zyb_sd_t_md001
                       INTO ls_md001
                      WHERE vtweg EQ vbak-vtweg
                        AND matnr EQ vbap-matnr.
*** Sevkiyat planlama ekranında palet sayısı düzenlendiği için
*      SELECT  * FROM zyb_sd_t_md001
*                INTO ls_md001
*               WHERE vtweg EQ vbak-vtweg
*                 AND matnr EQ vbap-matnr.
*
*        CASE tvak-kalvg.
*          WHEN gc_vg_3.
*            SELECT SINGLE COUNT(*) FROM zyb_t_md001
*                                  WHERE bkmtp EQ 'PAL'
*                                    AND matnr EQ ls_md001-matnr
*                                    AND mvgr1 EQ ls_md001-mvgr1
*                                    AND mvgr2 EQ ls_md001-mvgr2
*                                    AND begda LE vbak-audat
*                                    AND endda GE vbak-audat.
*            IF sy-subrc = 0.
*              EXIT.
*            ELSE.
*              CLEAR ls_md001.
*            ENDIF.
*          WHEN gc_vg_4 OR gc_vg_5.
*            SELECT SINGLE COUNT(*) FROM zyb_t_md001
*                                  WHERE bkmtp EQ 'KUT'
*                                    AND matnr EQ ls_md001-matnr
*                                    AND mvgr2 EQ ls_md001-mvgr2
*                                    AND begda LE vbak-audat
*                                    AND endda GE vbak-audat.
*            IF sy-subrc = 0.
*              EXIT.
*            ELSE.
*              CLEAR ls_md001.
*            ENDIF.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDSELECT.

    ENDIF.
*<--YUR-192
    IF ls_md001 IS INITIAL.
      SELECT SINGLE * FROM zyb_sd_t_md001
    INTO ls_md001
      WHERE vtweg EQ vbak-vtweg
        AND kunnr EQ vbak-kunnr.
    ENDIF.

    IF ls_md001 IS INITIAL.
      SELECT SINGLE * FROM zyb_sd_t_md001
    INTO ls_md001
      WHERE vtweg EQ vbak-vtweg.
    ENDIF.

  ENDIF.

* sadece kalem yaratılırken doldurulacak.
  IF NOT ( ls_md001 IS INITIAL AND
           svbap-tabix = 0     AND
*           vbak-auart EQ gc_au_za09 ).
           tvak-kalvg EQ gc_vg_a ).

    CASE tvak-kalvg.
      WHEN gc_vg_3.
        MOVE ls_md001-mvgr1 TO vbap-mvgr1.
        MOVE ls_md001-mvgr2 TO vbap-mvgr2.
        MOVE ls_md001-mvgr3 TO vbap-mvgr3.
        MOVE ls_md001-mvgr4 TO vbap-mvgr4.
      WHEN gc_vg_4 OR gc_vg_5.
        MOVE ls_md001-mvgr2 TO vbap-mvgr2.
        MOVE ls_md001-mvgr3 TO vbap-mvgr3.
        MOVE ls_md001-mvgr4 TO vbap-mvgr4.
      WHEN OTHERS.
    ENDCASE.
    "--------->> Anıl CENGİZ 03.08.2018 15:22:02
    "YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi

    IF vbak-vtweg EQ '10'.

      CASE tvak-kalvg.
        WHEN gc_vg_3.
          MOVE ls_md001-mvgr1 TO vbap-mvgr1.
          MOVE ls_md001-mvgr2 TO vbap-mvgr2.
          MOVE ls_md001-mvgr3 TO vbap-mvgr3.
          MOVE ls_md001-mvgr4 TO vbap-mvgr4.
        WHEN gc_vg_4 OR gc_vg_5.
          MOVE ls_md001-mvgr1 TO vbap-mvgr1. "Palet miktarını siparişte
*hesaplayabilmek için bunu da gönderdik. Sadece yurtiçi için yaptık.
          MOVE ls_md001-mvgr2 TO vbap-mvgr2.
          MOVE ls_md001-mvgr3 TO vbap-mvgr3.
          MOVE ls_md001-mvgr4 TO vbap-mvgr4.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
    "---------<<
  ENDIF.
*&*********************************************************************
*& <-- Müşteri - Malzemeye göre default değer doldurma
*&*********************************************************************
**&*********************************************************************
**& --> Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
**&*********************************************************************
*  break bbozaci.
*    IF NOT vbap-mvgr1 IS INITIAL AND NOT vbap-mvgr2 IS INITIAL
*       AND vbap-vrkme NE vbap-meins.
*      SELECT SINGLE * FROM zyb_t_md001
*          INTO ls_olc_md001
*        WHERE matnr EQ vbap-matnr
*          AND mvgr1 EQ vbap-mvgr1
*          AND mvgr2 EQ vbap-mvgr2
*          AND meinh EQ vbap-vrkme.
*
*      IF NOT ls_olc_md001 IS INITIAL.
*        MOVE ls_olc_md001-umren TO vbap-umzin.
*        MOVE ls_olc_md001-umren TO vbap-umvkn.
*
*        MOVE ls_olc_md001-umrez TO vbap-umziz.
*        MOVE ls_olc_md001-umrez TO vbap-umvkz.
*      ENDIF.
*    ENDIF.
**&*********************************************************************
**& <-- Palet ve Kutu Düzeyinde Malzeme Ölçü Birimi Dönüşümleri
**&*********************************************************************
  IF vbak-vbtyp EQ 'L'.
    vbap-kwmeng = vbap-zmeng.
    vbap-vrkme = vbap-zieme.
  ENDIF.

*  "--------->> Anıl CENGİZ 03.10.2018 14:26:30
*  "YUR-177 Satış siparişine yeni kalem eklendiğinde günün fiyatlandırma
*  "tarihini almalı
*  IF vbak-vtweg EQ '10' AND t180-trtyp EQ 'V' AND call_bapi IS INITIAL.
*    vbkd-prsdt = sy-datum.
*  ENDIF.
*  "---------<<
