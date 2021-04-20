*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_CHECK_XVBEP_DEL
*&---------------------------------------------------------------------*
*& - İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&---------------------------------------------------------------------*
* Data
DATA:
  lv_tesmik LIKE zyb_sd_t_shp02-tesmik,
  lv_fark   TYPE menge_d,
  ls_vbep   LIKE vbep.
*&*********************************************************************
*& --> İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&*********************************************************************

"--------->> Anıl CENGİZ 23.07.2018 15:04:08
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi v.0
* lv_fark = vbap-kwmeng - vbep-cmeng.
CHECK vbak-vtweg EQ '20'.
"---------<<
READ TABLE xvbep INTO ls_vbep
  WITH KEY posnr = vbap-posnr.
lv_fark = vbap-kwmeng - ls_vbep-cmeng.
"---------<<
SELECT SUM( tesmik ) FROM zyb_sd_t_shp02
      INTO lv_tesmik
     WHERE vbeln EQ vbap-vbeln
       AND posnr EQ vbap-posnr
       AND loekz EQ space.

IF lv_fark LT lv_tesmik.
  MESSAGE e035(zsd_va) WITH vbap-vbeln vbap-posnr lv_tesmik
      DISPLAY LIKE 'I'.
ENDIF.
*&*********************************************************************
*& <-- İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&*********************************************************************
