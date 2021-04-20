*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_ZXMBCU02
*&---------------------------------------------------------------------*
TABLES: zyb_wm_t_ist_usr.
DATA: tb_msg LIKE symsg    OCCURS 0 WITH HEADER LINE,
      tb_ret LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

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
DATA:
  gt_vrm TYPE zyb_sd_ty_vrm_check,
  gs_vrm TYPE LINE OF zyb_sd_ty_vrm_check,
  ls_158 TYPE t158b.

DATA: ls_shp02 TYPE zyb_sd_t_shp02,
      ls_vbap  TYPE vbap,
      lv_menge TYPE menge_d,
      lv_charg TYPE charg_d.
**acengiz --> YUR-5 Barkodda Yapılan Manuel İşlemler
DATA: lv_matnr2 TYPE matnr.
**acengiz <-- YUR-5 Barkodda Yapılan Manuel İşlemler
FREE: gt_vrm, tb_msg.
CLEAR: gs_vrm, lv_matnr2.

* WM işlemlerinde kontrol yapılmaz.
CLEAR zyb_wm_t_ist_usr.
SELECT SINGLE * FROM zyb_wm_t_ist_usr
   WHERE field1 EQ '1'
     AND bname EQ sy-uname.

IF sy-subrc = 0.
  " İhracatta depo birimi oluşturulduktan sonra el terminalinde
  " sipariş stoğu altına kaydırıldığı için kural koyuldu.
  IF i_mseg-bwart NE '413'.
    " Depo birimi oluşturulan kalemler için virman işlemi yapılamaz
    PERFORM storage_unit_check IN PROGRAM saplzyb_sd_g_vrm
                                IF FOUND
                                USING i_mseg-matnr
                                      i_mseg-werks
                                      i_mseg-lgort
                                      i_mseg-charg
                                      i_mseg-menge
                                      i_mseg-meins
                                      'X'. " call outside
  ENDIF.
  EXIT.
ENDIF.


* 102 hareketinde virman yapılıyor.
* malzeme belgesi başlığında TERS yazıyor ise kontrole girmeyecek
CHECK i_mkpf-bktxt NE 'TERS'.
**acengiz --> YUR-5 Barkodda Yapılan Manuel İşlemler
IMPORT lv_matnr2 = lv_matnr2 FROM MEMORY ID 'ZYB_PP_PALET_TEYIT_FORM-GOODSMVT'.
IF sy-subrc EQ 0 AND lv_matnr2 NE i_mseg-matnr.
  RETURN. "palet teyit programında alt kalite malzeme koduna çevirdikleri için
  " mal girişi sırasındaki malzeme kodu siparişin içerisinden farklı ise kontrol yapmayalım.
ELSE.
**acengiz <-- YUR-5 Barkodda Yapılan Manuel İşlemler
  MOVE-CORRESPONDING i_mseg TO gs_vrm.
  APPEND gs_vrm TO gt_vrm.


  CLEAR: tb_ret, tb_ret[].
  CALL FUNCTION 'ZYB_SD_F_VRM_CHECK'
    EXPORTING
      user_exit = 'X'
      vrm_check = gt_vrm
    TABLES
      return    = tb_ret.

  IF NOT tb_ret[] IS INITIAL.
    LOOP AT tb_ret.
      CLEAR ls_158.
      SELECT SINGLE * FROM t158b
          INTO ls_158
         WHERE tcode EQ sy-tcode
           AND bwart EQ i_mseg-bwart.

      IF sy-subrc = 0.
        add_message: tb_ret-type tb_ret-id tb_ret-number
                     tb_ret-message_v1 tb_ret-message_v2 tb_ret-message_v3
                     tb_ret-message_v4.
      ELSE.
        MESSAGE ID tb_ret-id TYPE tb_ret-type NUMBER tb_ret-number
                WITH tb_ret-message_v1 tb_ret-message_v2 tb_ret-message_v3
                     tb_ret-message_v4.
      ENDIF.
    ENDLOOP.
  ENDIF.


  IF NOT tb_msg[] IS INITIAL.
    CALL FUNCTION 'RHVM_SHOW_MESSAGE'
      EXPORTING
        mess_header = 'İşlem sonucu'
      TABLES
        tem_message = tb_msg
      EXCEPTIONS
        canceled    = 1
        OTHERS      = 2.
    MESSAGE e000(zsd_mas) WITH 'İşlem Sonuçlarını Kontrol Ediniz!!'
                             '' '' '' DISPLAY LIKE 'I'.
  ENDIF.
ENDIF.
