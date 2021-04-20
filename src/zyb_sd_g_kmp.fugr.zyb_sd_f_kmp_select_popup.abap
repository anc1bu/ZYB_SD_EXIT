FUNCTION zyb_sd_f_kmp_select_popup.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VKORG) TYPE  VKORG
*"     REFERENCE(I_VTWEG) TYPE  VTWEG
*"     REFERENCE(I_KUNNR) TYPE  KUNNR
*"     REFERENCE(I_DATE) TYPE  DATUM
*"     VALUE(I_AUART) TYPE  AUART OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_KNUMA) TYPE  KNUMA_AG
*"     REFERENCE(E_ZTERM) TYPE  DZTERM
*"     REFERENCE(E_LCNUM) TYPE  LCNUM
*"     REFERENCE(E_BOART) TYPE  BOART
*"----------------------------------------------------------------------
  PERFORM clear_table.

* Müşteriye ait geçerli kampanyaları bulma
  CALL FUNCTION 'ZYB_SD_F_KMP_FIND'
    EXPORTING
      i_vkorg      = i_vkorg
      i_vtweg      = i_vtweg
      i_kunnr      = i_kunnr
      i_date       = i_date
      i_auart      = i_auart
    IMPORTING
      kmplist      = tb_kmplist[]
    EXCEPTIONS
      not_found    = 1
      format_error = 2
      OTHERS       = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

* Anıl taşkın 22.11.2016
  DELETE tb_kmplist WHERE vkorg NE i_vkorg.
* Anıl taşkın 22.11.2016

  "--------->> Anıl CENGİZ 16.08.2018 10:42:09
  "YUR-121 ZYB_SD_KMPNY_KNT tablosu "Sipariş Girişine Kapatma"
  "Sadece Satış Siparişi için Çalışmalı
  SELECT SINGLE vbtyp FROM tvak INTO lv_vbtyp WHERE auart = i_auart.
  SELECT * FROM zyb_sd_kmpny_knt INTO TABLE lt_kmpny_knt.

  CASE lv_vbtyp.
    WHEN 'C'.
      LOOP AT tb_kmplist INTO DATA(ls_kmplist).
        READ TABLE lt_kmpny_knt INTO DATA(ls_kmpny_knt)
          WITH KEY knuma_ag = ls_kmplist-knuma_ag.
        IF ls_kmpny_knt-spkpt EQ abap_true.
          DELETE tb_kmplist WHERE knuma_ag EQ ls_kmpny_knt-knuma_ag.
        ENDIF.
        "--------->> Anıl CENGİZ 09.09.2020 13:19:05
        "YUR-706
        IF i_auart NE 'ZA11'. "Plt/Kut.Dışı Nmn.Stş
          DELETE tb_kmplist WHERE boart EQ 'ZY08'. "YB. Bedelsiz Kampnya
        ENDIF.
        "---------<<
      ENDLOOP.
    WHEN OTHERS.
  ENDCASE.
  "---------<<
  PERFORM make_field_catalog.
  PERFORM popup_to_select USING lv_vbtyp
    CHANGING e_knuma e_zterm e_lcnum e_boart.
ENDFUNCTION.
