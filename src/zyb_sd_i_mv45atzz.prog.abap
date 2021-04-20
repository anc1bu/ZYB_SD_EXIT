*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_MV45ATZZ
*&---------------------------------------------------------------------*

tables:
  zyb_sd_s_siparis.

data:tb_xkomv2 like xkomv occurs 0 with header line.
data:lv_flag type char1.
data:lv_flag2 type char1.

types: begin of values,
         zz_knuma_ag type knuma_ag,
         botext      type botext,
         boart       type boart,
         boarttxt    type vtext,
         lcnum       type lcnum,
         wrtak       type wrtak,
         open_value  type ak_gesamt,
         waers       type waers,
         datab       type datab,
         datbi       type datbi,
       end of values.
data:
  tb_kmplist like          zyb_sd_s_kmplist occurs 0 with header line,
  gt_return  type table of ddshretval       with header line.

data: values_tab type table of values with header line.

constants:
  gc_vkorg_san   type vkorg   value '1100', " Sanayi Dağıtım Kanalı
  gc_vkorg_paz   type vkorg   value '2100', " Pazarlama Dağıtım Kanalı
  gc_vtweg_ic    type vtweg   value '10',   " Yurtiçi Dağıtım Kanalı
  gc_vtweg_ihr   type vtweg   value '20',   " Yurtdışı Dağıtım Kanalı
  gc_vtweg_dgr   type vtweg   value '30',   " Diğer Dağıtım Kanalı

  gc_au_za01     type auart   value 'ZA01', " Tam.Plt.Ürün.Stş.
  gc_au_za02     type auart   value 'ZA02', " Tam.Plt.Numune.Stş.
  gc_au_za03     type auart   value 'ZA03', " Toplama.Plt.Nmne.Stş
  gc_au_za04     type auart   value 'ZA04', " Emanet Verme
  gc_au_za05     type auart   value 'ZA05', " Diğer Satışlar
  gc_au_za06     type auart   value 'ZA06', " Kısmi.Plt.Ürün.Stş.
  gc_au_za07     type auart   value 'ZA07', " Yrt.Dışı.Stş.Tahmin
  gc_au_za08     type auart   value 'ZA08', " Toplama.Plt.Ürün.Stş
  gc_au_za09     type auart   value 'ZA09', " YB.Pzrlm.Stş.
  gc_au_za10     type auart   value 'ZA10', " Plt.Dışı.Ürün.Stş.
  gc_au_za11     type auart   value 'ZA11', " Plt.Dışı.Numune.Stş.
  gc_au_zc06     type auart   value 'ZC06', " Alacak dknt.talebi
  gc_au_zd01     type auart   value 'ZD01', " Borç dekontu talebi
  gc_au_zp01     type auart   value 'ZP01', " Tam.Plt.Prfm.Tklf.
  gc_au_zp02     type auart   value 'ZP02', " Plt.Dışı.Prfm.Tklf
  gc_au_zr01     type auart   value 'ZR01', " İade Siparişi
  gc_au_zr02     type auart   value 'ZR02', " Pazarlama İade Siparişi
  gc_au_zc08     type auart   value 'ZC08', " Paz Alacak dknt.talebi
  gc_au_zd03     type auart   value 'ZD03', " Paz Borç Talebi

  gc_vg_3        type kalvg   value '3',    " Tam Palet Belge Şeması
  gc_vg_4        type kalvg   value '4',    " Kısmi Palet Belge Şeması
  gc_vg_5        type kalvg   value '5',    " Toplama Palet Belge Şeması
  gc_vg_6        type kalvg   value '6',    " Palet/Kutu Dışı Belge Şeması
  gc_vg_a        type kalvg   value 'A',    " Palet Dışı Belge Şeması

  gc_depo_mamul  type lgort   value '1200', " Mamül Depo Yeri
  gc_depo_stddis type lgort   value '1202', " Standart Dışı Depo Yeri
  gc_depo_ihr    type lgort   value '1205', " Standart İhracat Depo Yeri
  gc_depo_numune type lgort   value '1220', " Numune Depo Yeri
  gc_depo_iade   type lgort   value '1240', " İade Depo Yeri
  gc_depo_dekor  type lgort   value '1280', " Dekor Depo Yeri
  gc_depo_adnyyk type lgort   value '1190', " Adana YYK depo

  gc_mtart_yyk   type mtart value 'ZYYK',   " YYK ya ait malzeme türü.
  gc_mtart_ztic  type mtart value 'ZTIC'.   " ZTIC ya ait malzeme türü"ONUR PALA 20.01.2016

define add_message.
  clear lb_msg.
  "--------->> add by mehmet sertkaya 22.07.2019 11:19:05
* YUR-441
  IF call_bapi  eq 'X'.
   MESSAGE ID &2 TYPE &1 NUMBER &3
           WITH &4 &5 &6 &7.
  ENDIF.
  "-----------------------------<<


  lb_msg-msgty = &1.
  lb_msg-msgid = &2.
  lb_msg-msgno = &3.
  lb_msg-msgv1 = &4.
  lb_msg-msgv2 = &5.
  lb_msg-msgv3 = &6.
  lb_msg-msgv4 = &7.
  append lb_msg to tb_msg.
end-of-definition.

define show_message.
  CHECK call_bapi IS INITIAL.
  CALL FUNCTION 'RHVM_SHOW_MESSAGE'
    EXPORTING
      mess_header = 'İşlem sonucu'
    TABLES
      tem_message = tb_msg
    EXCEPTIONS
      canceled    = 1
      OTHERS      = 2.
end-of-definition.

define add_rang.
  CLEAR &1.
   &1-sign   = &2.
   &1-option = &3.
   &1-low    = &4.
   &1-high    = &5.
   APPEND &1.
end-of-definition.
