*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_KMPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TABLE
*&---------------------------------------------------------------------*
FORM clear_table .
  FREE:
    tb_list.

  CLEAR: it_akkp, it_akkp[],
    it_t6b1, it_t6b1[], it_t6b2, it_t6b2[], it_t6b2f, it_t6b2f[],
    it_t685a, it_t685a[], it_901, it_901[], it_kona, it_kona[],
    wa_list, wa_kmplist, tb_kmplist[], gt_fcat[].
ENDFORM.                    " CLEAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  PROMOSYON_TUR_BUL
*&---------------------------------------------------------------------*
FORM promosyon_tur_bul .

  SELECT * FROM t6b1
      INTO TABLE it_t6b1
      WHERE kappl EQ 'V'  " Satış Dağıtım
        AND abtyp EQ 'C'  " Ticari Promosyon
        AND boart LIKE 'Z%'.

  CHECK sy-subrc = 0.

  SELECT * FROM t6b2
   INTO TABLE it_t6b2
   FOR ALL ENTRIES IN it_t6b1
   WHERE kappl   EQ it_t6b1-kappl
     AND kobog   EQ it_t6b1-kobog
     AND kogruty EQ 'A'.   " Ticari Promosyon için Koşul Grubu

  CHECK sy-subrc = 0.

  SELECT * FROM t6b2f
     INTO TABLE it_t6b2f
     FOR ALL ENTRIES IN it_t6b2
     WHERE kappl EQ it_t6b2-kappl
       AND kobog EQ it_t6b2-kobog.

  CHECK sy-subrc = 0.

  SELECT * FROM t685a
     INTO TABLE it_t685a
     FOR ALL ENTRIES IN it_t6b2f
     WHERE kappl EQ it_t6b2f-kappl
       AND kschl EQ it_t6b2f-kschl
       AND koaid EQ 'H'. " Ticari Promosyon koşulu

  LOOP AT it_t6b2f.
    READ TABLE it_t685a WITH KEY kschl = it_t6b2f-kschl.
    IF sy-subrc <> 0.
      DELETE it_t6b2f.
    ENDIF.
  ENDLOOP.
  SORT it_t6b2f BY kobog zaehk.
ENDFORM.                    " PROMOSYON_TUR_BUL
*&---------------------------------------------------------------------*
*&      Form  READ_CONDITION_RECORD
*&---------------------------------------------------------------------*
FORM read_condition_record .
  SELECT * FROM a901
     INTO TABLE it_901
     FOR ALL ENTRIES IN tb_list
          WHERE kappl EQ co_kappl        AND
                kschl EQ co_kschl        AND
                vkorg EQ tb_list-vkorg   AND
                vtweg EQ tb_list-vtweg   AND
                kunnr EQ tb_list-kunnr   AND
                datab LE tb_list-date    AND
                datbi GE tb_list-date.
ENDFORM.                    " READ_CONDITION_RECORD
*&---------------------------------------------------------------------*
*&      Form  READ_KONA
*&---------------------------------------------------------------------*
FORM read_kona .
* onaylı olan promosylar okunur.
*  SELECT * FROM kona
*     INTO TABLE it_kona
*     FOR ALL ENTRIES IN it_901
*     WHERE knuma EQ it_901-knuma_ag
*       AND kfrst EQ space.
  IF it_akkp[] IS NOT INITIAL.
    SELECT * FROM kona AS kon

"--------->> Anıl CENGİZ 16.08.2018 10:46:45
"YUR-121 ZYB_SD_KMPNY_KNT tablosu "Sipariş Girişine Kapatma"
"Sadece Satış Siparişi için Çalışmalı

*"--------->> Anıl CENGİZ 06.08.2018 08:08:21
*" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*   INNER JOIN zyb_sd_kmpny_knt AS knt ON kon~knuma = knt~knuma_ag
*"---------<<
       INTO CORRESPONDING FIELDS OF TABLE it_kona
       FOR ALL ENTRIES IN it_akkp "it_901
       WHERE kon~knuma EQ it_akkp-zzknuma AND
             kon~kfrst EQ space.
*"--------->> Anıl CENGİZ 06.08.2018 08:03:01
*" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*            AND knt~spkpt EQ abap_false.
*    "---------<<

    "---------<<
  ELSE.
    SELECT * FROM kona AS kon
"--------->> Anıl CENGİZ 06.08.2018 08:00:28
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
   INNER JOIN zyb_sd_kmpny_knt AS knt ON kon~knuma = knt~knuma_ag
"---------<<
    INTO CORRESPONDING FIELDS OF TABLE it_kona
    FOR ALL ENTRIES IN tb_list "it_901
      WHERE kon~vkorg EQ tb_list-vkorg   AND
            kon~vtweg EQ tb_list-vtweg   AND
            kon~datab LE tb_list-date    AND
            kon~datbi GE tb_list-date    AND
"--------->> Anıl CENGİZ 06.08.2018 08:03:01
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
            knt~spkpt EQ abap_false.
    "---------<<

  ENDIF.


ENDFORM.                    " READ_KONA
*&---------------------------------------------------------------------*
*&      Form  SET_VALUES
*&---------------------------------------------------------------------*
FORM set_values  USING    "ls_901 TYPE a901
                          ls_akkp TYPE akkp
                          ls_kona TYPE kona
                          i_auart TYPE auart
                 CHANGING ls_kmplist TYPE zyb_sd_s_kmplist
                          retcode.
  " ZP04 koşuluna bağlı 901 tablosundan ulaşmak yerine kampanya ve mali belge
  " değerleri üzerinden istenilen aşağıdaki bilgilere ulaşıyoruz.
**----->
*  ls_kmplist-vkorg    = ls_901-vkorg.
*  ls_kmplist-vtweg    = ls_901-vtweg.
*  ls_kmplist-kunnr    = ls_901-kunnr.
*  ls_kmplist-knuma_ag = ls_901-knuma_ag.
**<----
  IF ls_akkp-zzknuma IS NOT INITIAL.
    ls_kmplist-kunnr    = ls_akkp-kunnr.
    ls_kmplist-knuma_ag = ls_akkp-zzknuma.


    "--------->> Anıl CENGİZ 16.09.2019 15:25:59
    "YUR-488
*    READ TABLE it_kona WITH KEY knuma = ls_kmplist-knuma_ag.
    LOOP AT it_kona WHERE knuma EQ ls_kmplist-knuma_ag
                      AND datab LE sy-datum
                      AND datbi GE sy-datum.
      EXIT.
    ENDLOOP.
    "---------<<
    IF sy-subrc = 0.
      ls_kmplist-botext   = it_kona-botext.
      ls_kmplist-boart    = it_kona-boart.
      ls_kmplist-zterm    = it_kona-zterm.
      ls_kmplist-datab    = it_kona-datab.
      ls_kmplist-datbi    = it_kona-datbi.
*----->
      ls_kmplist-vkorg    = it_kona-vkorg.
      ls_kmplist-vtweg    = it_kona-vtweg.
*<----
    ELSE.
      retcode = 1.
      EXIT.
    ENDIF.

  ELSE.
*    ls_kmplist-kunnr    = ls_kona-kunnr.
    ls_kmplist-knuma_ag = ls_kona-knuma.
    ls_kmplist-botext   = ls_kona-botext.
    ls_kmplist-boart    = ls_kona-boart.
    ls_kmplist-zterm    = ls_kona-zterm.
    ls_kmplist-datab    = ls_kona-datab.
    ls_kmplist-datbi    = ls_kona-datbi.
    ls_kmplist-vkorg    = ls_kona-vkorg.
    ls_kmplist-vtweg    = ls_kona-vtweg.
  ENDIF.

  SELECT SINGLE vtext FROM t6b1t
   INTO ls_kmplist-boarttxt
  WHERE boart EQ ls_kmplist-boart
    AND spras EQ sy-langu.

  SELECT SINGLE vtext FROM tvzbt
       INTO ls_kmplist-ztermtxt
      WHERE zterm EQ ls_kmplist-zterm
        AND spras EQ sy-langu.

* Mali Belge değerleri alınıyor.
  PERFORM loc_read_calc_open_values USING ls_kmplist-knuma_ag
                                          ls_kmplist-kunnr
                                          ls_kmplist-boart
                                 CHANGING ls_kmplist-lcnum
                                          ls_kmplist-wrtak
                                          ls_kmplist-open_value
                                          ls_kmplist-waers
                                          retcode.
  IF NOT i_auart = 'ZR01' AND
     NOT i_auart = 'ZC06' AND
     NOT i_auart = 'ZD01'.

    IF retcode EQ 0 AND ls_kmplist-open_value LE 0.
      retcode = 1.
    ENDIF.
  ENDIF.

  IF retcode <> 0.
    EXIT.
  ENDIF.
ENDFORM.                    " SET_VALUES
*&---------------------------------------------------------------------*
*&      Form  LOC_READ_CALC_OPEN_VALUES
*&---------------------------------------------------------------------*
FORM loc_read_calc_open_values  USING    p_knuma
                                         p_kunnr
                                         p_boart
                                CHANGING ep_lcnum
                                         ep_wrtak
                                         ep_open_value
                                         ep_waers
                                         rt_code.
  DATA:
    ls_akkp  LIKE akkp,
    gv_akart TYPE akart.

  CLEAR: ls_akkp, gv_akart.

  CASE p_boart.
    WHEN 'ZY01'. gv_akart = 'Z1'. " Çek Kampanyası (%)
    WHEN 'ZY02'. gv_akart = 'Z2'. " Kredi Kartı Kampanyası (%)
    WHEN 'ZY03'. gv_akart = 'Z3'. " Banka Havalesi Kampanyası (%)
    WHEN 'ZY04'. gv_akart = 'Z1'. " Çek Kampanyası (Fyt)
    WHEN 'ZY05'. gv_akart = 'Z2'. " Kredi Kartı Kampanyası (Fyt)
    WHEN 'ZY06'. gv_akart = 'Z3'. " Banka Havalesi Kampanyası (Fyt)
    WHEN 'ZY07'. gv_akart = 'Z4'. " Palet Kampanyası (Fyt)
      "--------->> Anıl CENGİZ 10.08.2020 13:05:58
      "YUR-706
    WHEN 'ZY08'.
      gv_akart = 'Z5'. " Bedelsiz Kampanya (Fyt)
      CLEAR: p_kunnr.
      "---------<<
  ENDCASE.

  SELECT SINGLE * FROM akkp INTO ls_akkp
      WHERE akart   EQ gv_akart
        AND akkei   EQ '2'
        AND akktp   EQ 'O'
        AND zzknuma EQ p_knuma
        AND akkst   EQ 'D'
        AND kunnr   EQ p_kunnr.

  IF sy-subrc = 0.
    ep_lcnum = ls_akkp-lcnum.
    ep_wrtak = ls_akkp-wrtak.
    ep_waers = ls_akkp-waers.

    CALL FUNCTION 'RV_LOC_READ_CALC_OPEN_VALUES'
      EXPORTING
        lc_nummer      = ls_akkp-lcnum
        lc_no_buffer   = 'X'
      IMPORTING
*       OPEN_SALES_ORDER                =
*       OPEN_DELIVERY  =
*       OPEN_INVOICE   =
        open_total     = ep_open_value
*       OPEN_TOTAL_OVERDRAFT            =
*       OPEN_SAL_PROZ  =
*       OPEN_DEL_PROZ  =
*       OPEN_INV_PROZ  =
*       OPEN_TOTAL_PROZ                 =
*       OPEN_TOTAL_PROZ_OVERDRAFT       =
*       CURRENCY       =
      EXCEPTIONS
        lc_not_exist   = 1
        negativ_values = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ELSE.
    rt_code = 2.
  ENDIF.
ENDFORM.                    " LOC_READ_CALC_OPEN_VALUES
*&---------------------------------------------------------------------*
*&      Form  MAKE_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM make_field_catalog.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = gc_alv
      i_structure_name       = gc_strname
    CHANGING
      ct_fieldcat            = gt_fcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  PERFORM fieldcatalog_merge_chg CHANGING gt_fcat[].
ENDFORM.                    " MAKE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  FIELDCATALOG_MERGE_CHANGE
*&---------------------------------------------------------------------*
FORM fieldcatalog_merge_chg CHANGING ct_fcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fcat TYPE LINE OF slis_t_fieldcat_alv.

*  DELETE ct_fcat WHERE fieldname EQ 'VKORG'
*                    OR fieldname EQ 'VTWEG'
*                    OR fieldname EQ 'LCNUM'.

  text_change 'KNUMA_AG'    'Kampanya No'       'Kampanya No'.
  text_change 'BOTEXT'      'Kampanya Tnm'      'Kampanya Tanım'.
  text_change 'BOART'       'Kampanya Tür'      'Kampanya Tür'.
  text_change 'BOTEXT'      'Kmp Tür Tnm'       'Kampanya Tür Tanım'.
  text_change 'ZTERM'       'Ödeme Koşulu'      'Ödeme Koşulu'.
  text_change 'ZTERMTXT'    'Ödeme Koşulu Tnm'  'Ödeme Koşulu Tanım'.
  text_change 'WRTAK'       'Kampanya Tutarı'   'Kampanya Tutarı'.
  text_change 'OPEN_VALUE'  'Kalan Tutar'       'Kalan Tutar'.

  no_out 'VKORG'.
  no_out 'VTWEG'.
*  no_out 'LCNUM'.
ENDFORM.                    " FIELDCATALOG_MERGE_CHANGE
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_SELECT
*&---------------------------------------------------------------------*
FORM popup_to_select USING pv_vbtyp TYPE vbtyp
       CHANGING ep_knuma ep_zterm ep_lcnum ep_boart.
  DATA: lin TYPE i.

  CLEAR lin.
  DESCRIBE TABLE tb_kmplist LINES lin.

  gs_private-columnopt = 'X'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title               = gc_title
*     I_SELECTION           = 'X'
*     I_ALLOW_NO_SELECTION  =
      i_zebra               = 'X'
      i_screen_start_column = 5
      i_screen_start_line   = 5
      i_screen_end_column   = 150
      i_screen_end_line     = 20
*     I_CHECKBOX_FIELDNAME  =
*     I_LINEMARK_FIELDNAME  =
*     I_SCROLL_TO_SEL_LINE  = 'X'
      i_tabname             = gc_alv
      i_structure_name      = gc_strname
      it_fieldcat           = gt_fcat[]
*     IT_EXCLUDING          =
*     I_CALLBACK_PROGRAM    =
*     I_CALLBACK_USER_COMMAND       =
      is_private            = gs_private
    IMPORTING
      es_selfield           = gs_selfield
      e_exit                = e_exit
    TABLES
      t_outtab              = tb_kmplist
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF e_exit EQ 'X' OR gs_selfield IS INITIAL.
    MESSAGE e000(zsd_va) WITH 'Lütfen Satır Seçiniz!'.
  ENDIF.

  READ TABLE tb_kmplist INDEX gs_selfield-tabindex.
  IF sy-subrc = 0.
    ep_knuma = tb_kmplist-knuma_ag.
    ep_zterm = tb_kmplist-zterm.
    ep_lcnum = tb_kmplist-lcnum.
    ep_boart = tb_kmplist-boart.

    "--------->> Anıl CENGİZ 25.11.2019 12:17:31
    "YUR-509
    TRY.
        zcl_sd_kmp_find=>check_vadetar( VALUE #( knuma_ag = ep_knuma
                                                 lcnum    = ep_lcnum
                                                 vbtyp    = pv_vbtyp ) ).
      CATCH zcx_sd_kmp_find INTO DATA(lo_cx_kmp_find).
        CLEAR: ep_knuma, ep_zterm, ep_lcnum, ep_boart.
        DATA(lv_msg) = lo_cx_kmp_find->if_message~get_text( ).
        MESSAGE lv_msg TYPE lo_cx_kmp_find->error RAISING check_vadetar.
    ENDTRY.
    "---------<<
    "--------->> Anıl CENGİZ 07.12.2018 07:39:47
    "YUR-249 Cari hesaplardaki bakiye sorunlar
    TRY .
        zcl_sd_toolkit=>enqueue_read_akkp( ep_lcnum ).
      CATCH zcx_bc_exit_imp INTO DATA(lx_bc_exit_imp).
        DATA: lt_list TYPE bapirettab.
        DATA(lo_msg) = lx_bc_exit_imp->messages.
        lo_msg->get_list_as_bapiret( IMPORTING et_list = lt_list ).
        zcl_sd_toolkit=>hata_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'E' ) ( CORRESPONDING #( wa ) ) ) ).
        zcl_sd_toolkit=>bilgi_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'W' OR type = 'I' ) ( CORRESPONDING #( wa ) ) ) ).
    ENDTRY.
    "---------<<
  ENDIF.
ENDFORM.                    " POPUP_TO_SELECT
*&---------------------------------------------------------------------*
*&      Form  READ_AKKP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_akkp.
  " Geçerli mali belgeler okunuyor.
  SELECT * FROM akkp
    INTO TABLE it_akkp
*     FOR ALL ENTRIES IN tb_list
    WHERE kunnr EQ wa_list-kunnr AND
          akkst EQ 'D' AND
          akktp EQ 'O' .
  "--------->> Anıl CENGİZ 02.06.2018 10:34:57
  "YUR-28 Palet Satış Ekranı (DT:YUR-24) v.0 - Programlama
*Mali belge türü palet olanlar getirilmeyecek.
*          akart NE 'Z4'.
  "---------<<

  "--------->> Anıl CENGİZ 10.08.2020 12:54:43
  "YUR-706
  SELECT *
    FROM akkp
    INTO TABLE gt_akkp_bdlsz
    WHERE akktp EQ 'O'
    AND akart EQ 'Z5'.
  IF sy-subrc EQ 0.
    DESCRIBE TABLE gt_akkp_bdlsz.
    IF sy-tfill > 1.
      MESSAGE e064(zsd) DISPLAY LIKE 'I'.
    ELSE.
      APPEND LINES OF gt_akkp_bdlsz TO it_akkp.
    ENDIF.
  ENDIF.
  "---------<<
ENDFORM.                    " READ_AKKP
