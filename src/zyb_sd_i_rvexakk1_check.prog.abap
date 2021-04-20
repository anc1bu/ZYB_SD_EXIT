*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_RVEXAKK1_CHECK
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              XAKKD STRUCTURE  AKKDVB
*"              XAKKB STRUCTURE  AKKBVB
*"       CHANGING
*"             VALUE(XAKKP) LIKE  AKKPVB STRUCTURE  AKKPVB
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Yapılan Kontroller
*& - ticari promosyon no kontrolü
*& - Çek para birimi ve mali belge para birimi karşılaştırılması
*& - Mali belge tutarı ile çek tutarı karşılaştırması
*& - ticari promosyon no
*&---------------------------------------------------------------------*

"--------->> Anıl CENGİZ 10.08.2020 11:40:34
"YUR-706 - ZCL_SD_EXIT_SMOD_RVEXAKK1_001 sınıfı içerisine taşınmıştır.
*
*DATA:
*  tb_kc001         LIKE zyb_sd_t_kc001 OCCURS 0  WITH HEADER LINE,
*  lt_cek           LIKE TABLE OF zyb_fi_cekdurum WITH HEADER LINE,
*  lt_ret           LIKE TABLE OF bapiret2        WITH HEADER LINE,
*  gv_txt           TYPE bezei40,
*  ls_akkp          LIKE akkp,
*  ls_kona          LIKE kona,
*  lv_wrbtr         TYPE wrbtr,
*  lv_wrbtr_txt(15) TYPE c,
*  lv_lcnum         TYPE vbkd-lcnum.
*
*CONSTANTS:
*  gc_ret   TYPE icon_d VALUE '@02@',
*  gc_erase TYPE sy-ucomm VALUE 'GELO'.
*
*"VX14N de XAKKP değişkeni tam olarak dolmadığı için LS_AKKP ye çevrilmiştir.
*                                                            "20150907
*
*IF NOT xakkp-lcnum IS INITIAL.
*  CLEAR ls_akkp.
*  SELECT SINGLE * FROM akkp INTO ls_akkp
*    WHERE lcnum = xakkp-lcnum.
*  "--------->> Anıl CENGİZ 26.06.2019 10:38:47
*  "YUR-422
*  IF sy-subrc IS INITIAL AND ls_akkp-zzknuma IS INITIAL.
***   IF xakkp-zzknuma IS INITIAL.
**    CLEAR lv_lcnum.
**    SELECT SINGLE vbkd~lcnum FROM vbkd
**      INNER JOIN vbap ON vbap~vbeln EQ vbkd~vbeln
**      INTO lv_lcnum
**      WHERE vbkd~lcnum EQ ls_akkp-lcnum
**      AND vbap~abgru EQ space.
**    IF NOT lv_lcnum IS INITIAL.
**      MESSAGE e021(zyb_sd) DISPLAY LIKE 'I'.
**    ENDIF.
*  ELSE.
*    "---------<<
*    IF sy-ucomm NE gc_erase.
*      CLEAR ls_kona.
*      SELECT SINGLE * FROM kona
*        INTO ls_kona
*        WHERE knuma EQ ls_akkp-zzknuma.
*      IF sy-subrc = 0.
*        IF NOT ls_kona-kfrst IS INITIAL .
*          MESSAGE e024(zyb_sd) DISPLAY LIKE 'I'.
*        ELSE.
*          CASE ls_kona-boart.
*            WHEN 'ZY01' OR 'ZY04'.
*              IF ls_akkp-akart NE 'Z1'. " Çek Kampanyası
*                CLEAR gv_txt.
*                CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
*                SEPARATED BY space.
*                MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
*              ENDIF.
*            WHEN 'ZY02'.
*              IF ls_akkp-akart NE 'Z2'. " Kredi Kartı Kampanyası
*                CLEAR gv_txt.
*                CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
*                SEPARATED BY space.
*                MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
*              ENDIF.
*            WHEN 'ZY03'.
*              IF ls_akkp-akart NE 'Z3'. " Banka Havalesi Kampanyası
*                CLEAR gv_txt.
*                CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
*                SEPARATED BY space.
*                MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
*              ENDIF.
*            WHEN 'ZY07'.
*              IF ls_akkp-akart NE 'Z4'. " Palet Kampanyası
*                CLEAR gv_txt.
*                CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
*                SEPARATED BY space.
*                MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
*              ENDIF.
*            WHEN OTHERS.
*              CLEAR gv_txt.
*              CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
*              SEPARATED BY space.
*              MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
*          ENDCASE.
*        ENDIF.
*      ELSE.
*        MESSAGE e023(zyb_sd) DISPLAY LIKE 'I'.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*ENDIF.
*
** Mali belge kullanılabilirlik kontrolü
*CLEAR: tb_kc001, tb_kc001[].
*IF xakkp-akkst EQ '' AND sy-ucomm EQ 'SICH' OR sy-ucomm EQ 'BACK'.
*
*  CLEAR ls_akkp.
*  SELECT SINGLE * FROM akkp
*      INTO ls_akkp
*     WHERE zzknuma EQ xakkp-zzknuma
*       AND lcnum   NE xakkp-lcnum
*       AND kunnr   EQ xakkp-kunnr
*       AND akkst   EQ 'D'.
*
*  IF NOT ls_akkp IS INITIAL.
*    MESSAGE e020(zyb_sd) WITH xakkp-zzknuma ls_akkp-lcnum
*        DISPLAY LIKE 'I'.
*  ENDIF.
*ENDIF.
*
**CLEAR: tb_kc001, tb_kc001[].
*if xakkp-akkst eq 'D' and xakkp-updkz ne 'D' and sy-ucomm eq 'SICH'.
***********************************************************************
**& --> begin ticari promosyon no kontrolü
***********************************************************************
*  if xakkp-lcnum is initial.
*    message e018(zyb_sd) display like 'I'.
*  endif.
*
*  if xakkp-zzknuma is initial.
*    message e019(zyb_sd) display like 'I'.
*  endif.
*  clear ls_akkp.
*  select single * from akkp
*      into ls_akkp
*     where zzknuma eq xakkp-zzknuma
*       and lcnum   ne xakkp-lcnum
*       and kunnr   eq xakkp-kunnr
*       and akkst   eq 'D'.
*
*  if not ls_akkp is initial.
*    message e020(zyb_sd) with xakkp-zzknuma ls_akkp-lcnum
*        display like 'I'.
*  endif.
************************************************************************
**& <-- end ticari promosyon no kontrolü
***********************************************************************
*
*  select *  from zyb_sd_t_kc001
*      into table tb_kc001
*     where knuma_ag eq xakkp-zzknuma
*       and lcnum    eq xakkp-lcnum
*       and loekz    eq space.
*
***********************************************************************
**& --> beg Kampanya Para birimi ve mali belge para birimi karşılaştırılması
***********************************************************************
*  if ls_kona-waers ne xakkp-waers.
*    clear gv_txt.
*    concatenate 'Kampanya Para Birimi :' ls_kona-waers into gv_txt
*          separated by space.
*    message e025(zyb_sd) with gv_txt display like 'I'.
*  endif.
************************************************************************
**& <-- end Kampanya Para birimi ve mali belge para birimi karşılaştırılması
***********************************************************************
*
***********************************************************************
**& --> beg Çek para birimi ve mali belge para birimi karşılaştırılması
***********************************************************************
*  if not tb_kc001[] is initial .
*    loop at tb_kc001 where waers ne xakkp-waers.
*      exit.
*    endloop.
*    if sy-subrc = 0.
*      clear gv_txt.
*      concatenate 'Para Birimi:' xakkp-waers 'olmalı' into gv_txt
*            separated by space.
*      message e009(zy_sd) with gv_txt display like 'I'.
*    endif.
*  endif.
***********************************************************************
**& <-- end Çek para birimi ve mali belge para birimi karşılaştırılması
***********************************************************************
***********************************************************************
**& --> begin Mali belge tutarı ile çek tutarı karşılaştırması
***********************************************************************
** tahsil edilmiş çeklerin durumları kontrol edilmiyor.
*  free: lt_cek, lt_ret.
** sadece Çek belge türü için tutar kontrol edilir.
*  if xakkp-akart eq 'Z1'.
*    loop at tb_kc001 where ( blart ne 'C4' and blart ne 'C5')." AND
*      "belnr IS NOT INITIAL.
*      clear lt_cek.
*      lt_cek-bukrs    = tb_kc001-bukrs.
*      lt_cek-gjahr    = tb_kc001-gjahr.
*      lt_cek-portfo   = tb_kc001-portfo.
*      lt_cek-boeno    = tb_kc001-boeno.
*      lt_cek-bank     = tb_kc001-bank.
*      lt_cek-accou    = tb_kc001-accou.
*      lt_cek-knuma_ag = tb_kc001-knuma_ag.
*      lt_cek-lcnum    = tb_kc001-lcnum.
*      append lt_cek.
*    endloop.
*    if tb_kc001-belnr is not initial.
*      call function 'ZYB_FI_F_CSDURUM'
*        tables
*          t_cek    = lt_cek
*          t_return = lt_ret.
*
** iptal edilmiş çekler karşılaştırmaya dahil edilmez.
*      loop at lt_cek where icon eq gc_ret.
*        delete tb_kc001 where knuma_ag eq lt_cek-knuma_ag
*                          and lcnum    eq lt_cek-lcnum
*                          and boeno    eq lt_cek-boeno.
*      endloop.
*    endif.
**  break anilc.
*    clear lv_wrbtr.
*    loop at tb_kc001.
*      lv_wrbtr = lv_wrbtr + tb_kc001-wrbtr.
*    endloop.
*
*    if lv_wrbtr ne xakkp-wrtak.
*      clear gv_txt.
*      write lv_wrbtr to lv_wrbtr_txt. condense lv_wrbtr_txt.
*      concatenate 'Çek Tutarı: ' lv_wrbtr_txt xakkp-waers into gv_txt
*          separated by space.
*      message e013(zyb_sd) with gv_txt display like 'I'.
*
*    endif.
*  endif.
***********************************************************************
**& <-- end Mali belge tutarı ile çek tutarı karşılaştırması
***********************************************************************
*endif.
"---------<<
