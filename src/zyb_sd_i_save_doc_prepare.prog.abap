*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_SAVE_DOC_PREPARE
*&---------------------------------------------------------------------*
*&Note:
*Bu include içerisine eklenecek kontroller için
*&---------------------------------------------------------------------*

DATA: ls_xvbap LIKE xvbap,
      ls_vbep  LIKE xvbep,
      ls_vbap  LIKE vbap,
      ls_xvbup LIKE xvbup,
      lv_pasif TYPE c,
      tb_msg   LIKE TABLE OF symsg,
      lb_msg   LIKE symsg.
*      tb_msg   like symsg occurs 0 with header line.
DATA: lv_mtart TYPE mtart,
      lv_matkl TYPE matkl. "20.01.2016 onur pala

* -->Yuvarlama ile ilgili tanımlamalar
DATA: lv_tam     TYPE c,
      lv_vrkme   TYPE vrkme,
      lv_pal_mik TYPE menge_d,
      lv_eqty    TYPE menge_d.

DATA lv_error_msg TYPE  bapiret2-message.

* <--
** Hedef Miktar Doldurma
IF vbak-auart EQ gc_au_za07 AND sy-tcode+0(2) EQ 'VA'.
  LOOP AT xvbap INTO ls_xvbap WHERE abgru EQ space
                                AND updkz NE updkz_delete.
    ls_xvbap-zmeng = ls_xvbap-kwmeng.
    ls_xvbap-zieme = ls_xvbap-vrkme.
    MODIFY xvbap FROM ls_xvbap TRANSPORTING zmeng zieme.
  ENDLOOP.
ENDIF.

*--->>>MOZDOGAN 06.06.2018 17:46:08
DATA: lv_brwr TYPE vbak-netwr.

LOOP AT xvbap.
  ADD xvbap-netwr TO lv_brwr.
  ADD xvbap-mwsbp TO lv_brwr.
ENDLOOP.
*<<<---MOZDOGAN 06.06.2018 17:46:08

"--------->> Anıl CENGİZ 19.08.2019 17:27:08
"YUR-447 ile ZCL_SD_MV45AFZZ_SDP-CHECK_FINDOC içerisine alındı.
*etomrukcu 25.01.2016
*borç dekontu kampanya açık değer kontrolü
*IF vbak-auart EQ 'ZD01' OR vbak-auart EQ 'ZD04'.
*  LOOP AT xvbap WHERE abgru IS NOT INITIAL.
*    EXIT.
*  ENDLOOP.
*  IF ( lv_brwr > zyb_sd_s_siparis-ak_gesamt ) AND
*     ( vbap-faksp IS INITIAL AND vbap-faksp EQ *vbap-faksp ) AND
*     vbkd-lcnum IS NOT INITIAL AND sy-subrc NE 0.
**        MESSAGE e036(zsd_va) WITH XVBAK-ZZ_KNUMA_AG.
*
**--->>>MOZDOGAN 06.06.2018 15:06:05 CALL_BAPI kontrolü
*    IF call_bapi = 'X'.
*      MESSAGE e036(zsd_va) WITH vbak-zz_knuma_ag.
*    ELSE.
*      add_message: 'E'
*                   'ZSD_VA'
*                   '036'
*                   vbak-zz_knuma_ag
*                   space
*                   space
*                   space.
*    ENDIF.
**<<<---MOZDOGAN 06.06.2018 15:06:05
*
*  ENDIF.
*ENDIF.
"---------<<

DATA: ls_tvap LIKE tvap.
** Net tutar kontrolü
IF vbak-auart NE gc_au_za07 AND vbak-auart+0(2) NE 'ZC'.
  LOOP AT xvbap INTO ls_xvbap WHERE abgru EQ space
                                AND updkz NE updkz_delete
                                AND netwr LE 0.
    CLEAR ls_tvap.
    SELECT SINGLE * FROM tvap
          INTO ls_tvap
         WHERE pstyv EQ ls_xvbap-pstyv.

    IF ls_tvap-prsfd CA 'B '.
      CONTINUE.
    ENDIF.
    "--------->> Anıl CENGİZ 10.10.2018 11:35:49
    "YUR-188 Palet kaleminin artık sipariş temizleme programında
    "teslimat miktarının 0 olduğu durumda hata vermemesi için
    "yazıldı.
    IF ls_xvbap-pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm AND
      sy-tcode EQ 'ZSD041'.
      CONTINUE.
    ENDIF.
    "---------<<
    IF NOT ( vbak-auart EQ 'ZA04' OR vbak-auart EQ 'ZA12' ).
      IF call_bapi EQ 'X' AND call_bapi_simulation_mode EQ space.
        MESSAGE e018(zsd_va) WITH ls_xvbap-posnr
                                  ls_xvbap-matnr
                                  ls_xvbap-arktx.
      ELSE.
        add_message: 'E'
                     'ZSD_VA'
                     '018'
                     ls_xvbap-posnr
                     ls_xvbap-matnr
                     ls_xvbap-arktx
                     space.
        IF 1 = 2. MESSAGE e018(zsd_va). ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDIF.
** yuvarlama miktarı kontrolü

CLEAR: lv_tam, lv_vrkme, lv_pasif.

CASE tvak-kalvg.
  WHEN gc_vg_3.
    lv_tam = 'X'.
    lv_vrkme = 'PAL'.
  WHEN gc_vg_5.  lv_vrkme = 'KUT'.
  WHEN  OTHERS. lv_pasif = 'X'.
ENDCASE.

* Pazarlama yurtiçi malzeme satışlarında dönüşüm olmayacak
IF vbak-vtweg EQ gc_vtweg_ic OR vbak-vbtyp EQ 'L'.
  lv_pasif = 'X'.
ENDIF.


* zsd006 ekranı palet-kutu vs kontrolu
IF sy-tcode = 'VA01' OR sy-tcode = 'VA02' .
  IF vbak-vtweg EQ gc_vtweg_ihr.
    LOOP AT xvbap INTO ls_xvbap WHERE abgru EQ space
                                  AND updkz NE updkz_delete.
      IF xvbak-auart = 'ZA08'.
        IF ( ls_xvbap-mvgr2 IS INITIAL  OR ls_xvbap-mvgr3 IS INITIAL OR
        ls_xvbap-mvgr4 IS INITIAL ).
*             MESSAGE s037(zsd_va) DISPLAY LIKE 'E' .
          IF call_bapi = 'X'.
            MESSAGE e037(zsd_va) WITH 'Kalem:' ls_xvbap-posnr.
          ELSE.
            add_message: 'E'
                       'ZSD_VA'
                       '037'
                       'Kalem:'
                       ls_xvbap-posnr
                       space
                       space.
          ENDIF.

        ENDIF.
      ELSEIF  ( xvbak-auart = 'ZA01' ) OR ( xvbak-auart = 'ZA07' ) .

        DATA: lv_mvgr1 LIKE zyb_sd_t_md001-mvgr1.

        IF  ls_xvbap-matnr NS '.1' AND ls_xvbap-matnr NS 'T'.


*          ZSD006  kontrol
          SELECT SINGLE mvgr1 FROM zyb_sd_t_md001
            INTO  lv_mvgr1
            WHERE kunnr EQ xvbak-kunnr
              AND matnr EQ ls_xvbap-matnr
              AND vtweg EQ xvbak-vtweg
              AND mvgr1 EQ ls_xvbap-mvgr1
              AND mvgr2 EQ ls_xvbap-mvgr2
              AND mvgr3 EQ ls_xvbap-mvgr3
              AND mvgr4 EQ ls_xvbap-mvgr4.

          IF sy-subrc <> 0.
            IF call_bapi = 'X'.
              MESSAGE e037(zsd_va) WITH 'Kalem:' ls_xvbap-posnr.
            ELSE.
              add_message: 'E'
                               'ZSD_VA'
                               '037'
                        'Kalem:'
                       ls_xvbap-posnr
                        space
                        space.
            ENDIF.
          ENDIF.

*          ZSD005 Palet kontrol
          CLEAR lv_mvgr1.
          SELECT SINGLE mvgr1 FROM zyb_t_md001
            INTO  lv_mvgr1
            WHERE matnr EQ ls_xvbap-matnr
              AND mvgr1 EQ ls_xvbap-mvgr1
              AND mvgr2 EQ ls_xvbap-mvgr2
              AND bkmtp EQ 'PAL'.

          IF sy-subrc <> 0.
            IF call_bapi = 'X'.
              MESSAGE e043(zsd_va) WITH 'Kalem:' ls_xvbap-posnr.
            ELSE.
              add_message: 'E'
                               'ZSD_VA'
                               '043'
                        'Kalem:'
                       ls_xvbap-posnr
                        space
                        space.
            ENDIF.
          ENDIF.


*          ZSD005 Kutu kontrol
          CLEAR lv_mvgr1.
          SELECT SINGLE mvgr1 FROM zyb_t_md001
            INTO  lv_mvgr1
            WHERE matnr EQ ls_xvbap-matnr
              AND mvgr2 EQ ls_xvbap-mvgr2
              AND bkmtp EQ 'KUT'.

          IF sy-subrc <> 0.
            IF call_bapi = 'X'.
              MESSAGE e043(zsd_va) WITH 'Kalem:' ls_xvbap-posnr.
            ELSE.
              add_message: 'E'
                               'ZSD_VA'
                               '043'
                        'Kalem:'
                       ls_xvbap-posnr
                        space
                        space.
            ENDIF.
          ENDIF.


          IF ( ls_xvbap-mvgr1 IS INITIAL  OR ls_xvbap-mvgr2 IS INITIAL
           OR ls_xvbap-mvgr3 IS INITIAL  OR ls_xvbap-mvgr4 IS INITIAL ).
*              MESSAGE s037(zsd_va) DISPLAY LIKE 'E' .
            IF call_bapi = 'X'.
              MESSAGE e037(zsd_va) WITH 'Kalem:' ls_xvbap-posnr.
            ELSE.
              add_message: 'E'
                                'ZSD_VA'
                                '037'
                         'Kalem:'
                       ls_xvbap-posnr
                         space
                         space.
            ENDIF.
          ENDIF.




        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDIF.

IF 1 = 2 . "21.11.2016 tarihinde, kullanıcıların ilerleyebilmesi için
  " geçiçi süreyle kaldırıldı
  LOOP AT xvbap INTO ls_xvbap WHERE abgru EQ space
                                AND updkz NE updkz_delete.


    DATA: lv_count TYPE i.
    CLEAR lv_count.
    SELECT COUNT( DISTINCT matnr ) FROM mvke INTO lv_count
      WHERE vkorg EQ xvbak-vkorg
        AND mvgr1 EQ ls_xvbap-mvgr1.

    IF lv_count IS INITIAL.
      "&: & e tayin edilmiş malzeme bulunmuyor. Kontrol ediniz.
      IF call_bapi = 'X'.
        MESSAGE e039(zsd_va) WITH 'Palet Tipi' ls_xvbap-mvgr1.
      ELSE.
        add_message: 'E' 'ZSD_VA' '039'
                     'Palet Tipi' ls_xvbap-mvgr1 space space.
      ENDIF.
    ENDIF.

    IF lv_count GT 1.
      "&: & e tayin edilmiş birden fazla malzeme var. Kontrol ediniz.
      IF call_bapi = 'X'.
        MESSAGE e040(zsd_va) WITH 'Palet Tipi' ls_xvbap-mvgr1.
      ELSE.
        add_message: 'E' 'ZSD_VA' '040'
                     'Palet Tipi' ls_xvbap-mvgr1 space space.
      ENDIF.
    ENDIF.


    CLEAR lv_count.
    SELECT COUNT( DISTINCT matnr ) FROM mvke INTO lv_count
      WHERE vkorg EQ xvbak-vkorg
        AND mvgr2 EQ ls_xvbap-mvgr2.

    IF lv_count IS INITIAL.
      "&: & e tayin edilmiş malzeme bulunmuyor. Kontrol ediniz.
      IF call_bapi = 'X'.
        MESSAGE e039(zsd_va) WITH 'Kutu Tipi' ls_xvbap-mvgr2.
      ELSE.
        add_message: 'E' 'ZSD_VA' '039'
                    'Kutu Tipi' ls_xvbap-mvgr2 space space.
      ENDIF.
    ENDIF.

    IF lv_count GT 1.
      "&: & e tayin edilmiş birden fazla malzeme var. Kontrol ediniz.
      add_message: 'E' 'ZSD_VA' '040'
                   'Kutu Tipi' ls_xvbap-mvgr2 space space.
    ENDIF.



    CLEAR: lv_pal_mik, lv_eqty.
    LOOP AT xvbep INTO ls_vbep WHERE vbeln EQ ls_xvbap-vbeln
                                 AND posnr EQ ls_xvbap-posnr
                                 AND updkz NE updkz_delete
                                 AND wmeng GT 0.
      lv_pal_mik = lv_pal_mik + ls_vbep-wmeng.
    ENDLOOP.

    IF lv_pal_mik GT 0.
      CLEAR lv_eqty.
      CALL FUNCTION 'ZYB_SD_F_CONVERT_TO_ALT_UOM'
        EXPORTING
          plt_tam                  = lv_tam
          p_alt_uom                = lv_vrkme
          p_cur_qty                = lv_pal_mik
          p_matnr                  = ls_xvbap-matnr
          p_mvgr1                  = ls_xvbap-mvgr1
          p_mvgr2                  = ls_xvbap-mvgr2
        IMPORTING
*         ep_alt_qty               = lv_aqty
          ep_uom_qty               = lv_eqty
        EXCEPTIONS
          unit_not_found           = 1
          format_error             = 2
          uom_not_consistent       = 3
          obligatory               = 4
          type_not_consistent      = 5
          not_convertible_material = 6
          not_customize_material   = 7
          empty_palet              = 8
          OTHERS                   = 9.

      IF sy-subrc <> 0.
        IF call_bapi EQ 'X'.
          MESSAGE e012(zsd_va) WITH ls_xvbap-mvgr1
                                    ls_xvbap-mvgr2
                                    ls_xvbap-posnr
                                    ls_xvbap-matnr.
*      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          add_message: 'E' 'ZSD_VA' '012'
                   ls_xvbap-mvgr1
                   ls_xvbap-mvgr2
                   ls_xvbap-posnr
                   ls_xvbap-matnr.

          IF 1 = 2. MESSAGE e012(zsd_va). ENDIF.
        ENDIF.
      ENDIF.

      IF ls_xvbap-vrkme NE ls_xvbap-meins.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr              = ls_xvbap-matnr
            i_in_me              = ls_xvbap-meins
            i_out_me             = ls_xvbap-vrkme
            i_menge              = lv_eqty
          IMPORTING
            e_menge              = lv_eqty
          EXCEPTIONS
            error_in_application = 1
            error                = 2
            OTHERS               = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.

      IF lv_eqty NE ls_xvbap-kwmeng.
        IF call_bapi EQ 'X'.
          IF sy-tcode NE 'ZSD008'. " Virman Programı.
            MESSAGE e012(zsd_va) WITH ls_xvbap-mvgr1
                                      ls_xvbap-mvgr2
                                      ls_xvbap-posnr
                                      ls_xvbap-matnr.

          ENDIF.
        ELSE.
          add_message: 'E' 'ZSD_VA' '012'
                   ls_xvbap-mvgr1
                   ls_xvbap-mvgr2
                   ls_xvbap-posnr
                   ls_xvbap-matnr.

          IF 1 = 2. MESSAGE e012(zsd_va). ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDIF.

* Teyit miktarı kontrolü
IF vbak-vtweg EQ gc_vtweg_ic AND
   vbak-vbtyp NE 'L'.

  LOOP AT xvbap INTO ls_xvbap WHERE abgru EQ space
                                AND updkz NE updkz_delete
"--------->> Anıl CENGİZ 27.07.2018 13:58:21
" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
                                AND pstyv NE
                                zcl_sd_paletftr_mamulle=>cv_pltklm.
    "---------<<
    IF ls_xvbap-lgort IS INITIAL AND vbak-vbtyp NE 'K'.
      IF call_bapi = 'X'.
        MESSAGE e026(zsd_va) WITH ls_xvbap-posnr.
      ELSE.
        add_message: 'E' 'ZSD_VA' '026'
                 ls_xvbap-posnr
                 space
                 space
                 space.
      ENDIF.
    ENDIF.

    "--------->> Anıl CENGİZ 29.01.2020 18:04:34
    "YUR-581 - Refactoring kapsamında ZCL_SD_MV45AFZZ_FORM_SDP_001 içerisine taşındı.
*    SELECT SINGLE mtart matkl FROM mara
*      INTO (lv_mtart,lv_matkl) "20.01.2016 onur pala
*      WHERE matnr = ls_xvbap-matnr.
*    IF sy-cprog(6) NE 'RVKRED'.
*      IF ls_xvbap-kwmeng NE ls_xvbap-kbmeng
*        AND lv_mtart NE gc_mtart_yyk
*        AND lv_mtart NE gc_mtart_ztic "20.01.2016 onur pala
*        AND lv_matkl NE 'Y0603'."20.01.2016 onur pala
*        IF call_bapi EQ 'X'.
*          MESSAGE e019(zsd_va)
*             WITH ls_xvbap-vbeln ls_xvbap-posnr ls_xvbap-matnr.
*        ELSE.
*          add_message: 'E' 'ZSD_VA' '019'
*                   ls_xvbap-vbeln
*                   ls_xvbap-posnr
*                   ls_xvbap-matnr
*                   space.
*          IF 1 = 2. MESSAGE e019(zsd_va). ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*    FREE: lv_mtart.
    "---------<<

    IF ls_xvbap-route IS INITIAL AND ls_xvbap-werks EQ '1000'.
      IF call_bapi EQ 'X'.
        MESSAGE e029(zsd_va) WITH ls_xvbap-posnr 'Malı Teslim Alan'.
      ELSE.
        add_message: 'E' 'ZSD_VA' '029'
                 ls_xvbap-posnr
                 'Malı Teslim Alan'
                 space
                 space.
        IF 1 = 2. MESSAGE e029(zsd_va). ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  READ TABLE xvbkd WITH KEY posnr = '000000'.

  IF sy-ucomm = 'SICH'. "Sadece kaydet kısmında gir
    IF sy-subrc = 0 AND xvbkd-vsart IS INITIAL
    AND xvbkd-updkz NE updkz_delete.

      IF call_bapi = 'X'.
        MESSAGE e027(zsd_va).
      ELSE.
        add_message: 'E' 'ZSD_VA' '027'
                     space
                     space
                     space
                     space.
      ENDIF.
    ENDIF.
  ENDIF.

  DATA: ls_akkp  LIKE akkp,
        lv_name1 TYPE name1_gp.

  IF vbak-vtweg EQ gc_vtweg_ic AND vbak-vkorg EQ gc_vkorg_paz.
* Mali belge müşterisi ile sipariş veren kontrol edilir.
    CLEAR ls_akkp.
    IF xvbkd-lcnum IS NOT INITIAL.

      SELECT SINGLE * FROM akkp
         INTO ls_akkp
        WHERE lcnum EQ xvbkd-lcnum.

      IF vbak-kunnr NE ls_akkp-kunnr.
        CLEAR lv_name1.
        SELECT SINGLE name1 FROM kna1
           INTO lv_name1
          WHERE kunnr EQ ls_akkp-kunnr.

        MESSAGE e030(zsd_va)
            WITH ls_akkp-kunnr lv_name1 '(Sipariş Saklanamaz)'.
      ENDIF.
    ENDIF.
  ENDIF.

  "--------->> Anıl CENGİZ 16.08.2018 16:01:44
  " Bu kod YUR-113 ile yıldızlanmıştı ancak iki gün
  "sonrasında YUR-113 ile gene açılmıştır. Sebebi VA02 de açığa düşen
  "siparişleri kaydedebilmek için hatanın geçilmesi gerekiyordu. Ancak
  "bunun yerine hata mesajı kalsın kullanıcı siparişi silsin kararı
  "alindi.

  IF sy-cprog(6) NE 'RVKRED'.
* kredi kontrolü
    LOOP AT xvbup INTO ls_xvbup WHERE updkz NE updkz_delete
                    AND cmppi EQ 'B'. " Kredi kontrolü işlem tamam
      "değil
      IF ls_xvbup-absta NE 'C'.   " Red gerekçesi yoksa
        IF call_bapi EQ 'X'.
          MESSAGE e020(zsd_va)
             WITH ls_xvbup-vbeln ls_xvbup-posnr.
        ELSE.
          add_message: 'E' 'ZSD_VA' '020'
                   ls_xvbup-vbeln
                   ls_xvbup-posnr
                   space
                   space.
          IF 1 = 2. MESSAGE e020(zsd_va). ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  "---------<<
ENDIF.
* V_V2 işlem kodundan düzeltme yapıldığında hatalara takılmayacak
IF sy-cprog EQ 'SDV03V02'.
  EXIT.
ENDIF.

"--------->> Anıl CENGİZ 04.04.2020 08:51:23
"YUR-628 ZCL_SD_MV45AFZZ_FORM_SDP_002 içerisine taşınmıştır.
*"--------->> Anıl CENGİZ 01.08.2018 14:48:36
*" YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*IF t180-trtyp NE 'A'.
*  CLEAR: lb_msg.
*  lb_msg = NEW zcl_sd_paletftr_mamulle( )->plt_klm_kontrol(
*                                             is_vbak = vbak
*                                             it_xvbap = xvbap[] ).
*  IF lb_msg IS NOT INITIAL.
*    APPEND lb_msg TO tb_msg.
*  ENDIF.
*ENDIF.
*"---------<<
"---------<<

"--------->> Anıl CENGİZ 05.03.2019 17:06:40
IF t180-trtyp NE 'A'.

  DATA(lt_return) = NEW zcl_sd_mv45afzz_sdp( is_vbak = vbak
                                             it_xvbup = xvbup[]
                                             it_xvbap = xvbap[]
                                             it_xvbkd = xvbkd[]
                                            )->controls( ).

  IF lt_return IS NOT INITIAL.
    IF call_bapi EQ abap_false.
      APPEND LINES OF lt_return TO tb_msg.
    ELSE.
      ASSIGN lt_return[ 1 ] TO FIELD-SYMBOL(<ls_return>).
      IF sy-subrc EQ 0.
        MESSAGE ID <ls_return>-msgid TYPE <ls_return>-msgty NUMBER <ls_return>-msgno.
      ENDIF.
    ENDIF.
  ENDIF.

ENDIF.
"---------<<

"--------->> Anıl CENGİZ 08.04.2020 10:30:07
"YUR-634 ZCL_SD_MV45AFZZ_FORM_SDP_004 içerisine taşındı.
**{Added by eyolal at 26.03.2019
*"YUR-340
*DATA: lo_apr_event    TYPE REF TO zcl_sd_apr_event_create,
*      lv_process_zf01 TYPE zsdt_apr_procest-process VALUE 'ZF01',
*      lv_message      TYPE string,
*      lv_amount       TYPE zsdt_apr_wrkflw-amount,
*      lv_xkwmeng      TYPE vbap-kwmeng,
*      lv_ykwmeng      TYPE vbap-kwmeng,
*      lv_apr_exp      TYPE abap_bool.
*
*CLEAR: lv_apr_exp.
*
*SELECT SINGLE mandt INTO sy-mandt
*  FROM zsdt_apr_expuser
*  WHERE vkorg EQ vbak-vkorg
*  AND vtweg EQ vbak-vtweg
*  AND uname EQ sy-uname.
*
*IF sy-subrc EQ 0 AND t180-trtyp EQ 'V'.
*  lv_apr_exp = abap_true.
*ENDIF.
*
*IF lv_apr_exp EQ abap_false.
*  "Bütün kalemlerde ret nedeni var ise girmesine gerek yok.
*  LOOP AT xvbap TRANSPORTING NO FIELDS
*    WHERE abgru IS INITIAL.
*    EXIT.
*  ENDLOOP.
*  IF sy-subrc EQ 0. "Ret nedeni olmayan en az bir kalem var ise girer.
*
*    TRY.
*        READ TABLE xkomv TRANSPORTING NO FIELDS WITH KEY kschl = lv_process_zf01.
*        IF sy-subrc EQ 0.
*          lo_apr_event = NEW zcl_sd_apr_event_create(
*                     iv_process   = lv_process_zf01
*                     iv_simulate  = abap_true
*                     is_vbak      = vbak
*                     is_ovbak     = yvbak
*                     it_vbap      = xvbap[]
*                     it_komv      = xkomv[]
*                     is_t180      = t180 ).
*
*          DATA(lv_kposn) = lo_apr_event->get_considered_cond_item( ).
*
*          DATA(lv_approvable) = lo_apr_event->is_approvable( ).
*
*        ENDIF.
*      CATCH cx_root INTO DATA(lo_cx_root).
*        zcl_bc_gui_toolkit=>deep_cx_root( CHANGING cx_root = lo_cx_root ).
*        lv_message =  CONV #( lo_cx_root->if_message~get_text( ) ).
*
*        DATA(lv_posnr_txt) = |Klm:{ lv_kposn ALPHA = OUT }|.
*        add_message: 'E' 'ZSD_VA' '000'
*                  lv_posnr_txt
*                  lv_message
*                  space
*                  space.
*
*    ENDTRY.
*
*  ENDIF.
*
*  IF t180-trtyp EQ 'V'. "değişiklik modu
*
*    SELECT SINGLE amount INTO lv_amount
*     FROM zsdt_apr_wrkflw
*    WHERE process EQ lv_process_zf01
*      AND vbeln   EQ vbak-vbeln
*      AND deleted EQ space.
*
*    IF sy-subrc EQ 0. "belge onay iş akışı aktif
*
*      SELECT SINGLE mandt FROM zsdt_apr_statu INTO sy-mandt
*        WHERE process EQ lv_process_zf01
*          AND vbeln   EQ vbak-vbeln
*          AND action  IN ( 'R', '' ).
*      "--------->> Anıl CENGİZ 11.11.2019 15:14:08
*      "YUR-502
**      IF sy-subrc <> 0."belge onaylanmış
*      IF sy-subrc <> 0 AND "belge onaylanmış
*         vbak-erdat NE sy-datum. "aynı gün içerisinde ise kontrollere girme.
*        "---------<<
*        TRY.
*            DATA(ls_datcnt) = NEW zcl_sd_apr_toolkit( is_vbak = vbak )->get_date_controls( ).
*
*            DATA(lv_diff) = sy-datum - vbak-erdat.
*
*            DATA(lv_rate) = zcl_sd_apr_toolkit=>get_amount_change_rate( EXPORTING is_vbak = vbak iv_wf_amount = lv_amount ).
*
*            IF lv_diff GT ls_datcnt-zdays AND ls_datcnt-zdays GT 0. "gün aşımı
*              add_message: 'E' 'ZSD_VA' '061'
*                    ls_datcnt-zdays
*                    space
*                    space
*                    space.
*            ELSEIF lv_rate GT ls_datcnt-zrate AND ls_datcnt-zrate GT 0. "oran aşımı
*              add_message: 'E' 'ZSD_VA' '062'
*                     ls_datcnt-zrate
*                     space
*                     space
*                     space.
*            ELSEIF lv_rate LT 0 AND abs( lv_rate ) GT ls_datcnt-zrate AND ls_datcnt-zrate GT 0. "oran düşülmüş
*              MESSAGE w064(zsd_va).
*            ENDIF.
*          CATCH zcx_sd_apr ##NO_HANDLER.
*
*        ENDTRY.
*
*        LOOP AT xvbap INTO ls_vbap.
*          ADD ls_vbap-kwmeng TO lv_xkwmeng.
*        ENDLOOP.
*
*        LOOP AT yvbap INTO ls_vbap.
*          ADD ls_vbap-kwmeng TO lv_ykwmeng.
*        ENDLOOP.
*
*        IF lv_ykwmeng GT lv_xkwmeng.
*          add_message: 'E' 'ZSD_VA' '063'
*                     space
*                     space
*                     space
*                     space.
*        ENDIF.
*
*      ENDIF.
*    ENDIF.
*  ENDIF.
*ENDIF.
*
**}Added by eyolal at 26.03.2019
"---------<<
"---------<<
IF NOT tb_msg[] IS INITIAL.
  show_message.
*  MESSAGE e013(zsd_va).
  MESSAGE s013(zsd_va).
  PERFORM folge_gleichsetzen(saplv00f).
  fcode = 'ENT1'.
  SET SCREEN syst-dynnr.
  LEAVE SCREEN.
ENDIF.
