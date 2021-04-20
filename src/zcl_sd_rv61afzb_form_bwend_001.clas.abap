CLASS zcl_sd_rv61afzb_form_bwend_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_rv61afzb_form_bwrtnend .

    TYPES: ty_prclst TYPE zsdt_apr_prclst.
    TYPES: ty_unitprc TYPE zsdt_apr_unitprc.
    TYPES: tth_prclst TYPE HASHED TABLE OF ty_prclst WITH UNIQUE KEY zzlgort pltyp_p extwg.
    TYPES: tt_unitprc TYPE TABLE OF ty_unitprc WITH DEFAULT KEY.
    TYPES ty_xkomv TYPE komv_index .
    TYPES:
      tt_xkomv TYPE STANDARD TABLE OF ty_xkomv .
  PROTECTED SECTION.

private section.

  constants CV_EXPORT type VTWEG value '20'. "#EC NOTEXT
  data GT_PRCLST type TTH_PRCLST .
  data GT_UNITPRC type TT_UNITPRC .

  methods CALCULATE_RATE
    changing
      !CT_XKOMV type TT_XKOMV .
  methods CHECK_MATNR
    importing
      !IS_KOMP type KOMP
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  methods CHECK_RATE
    importing
      !IS_KOMP type KOMP
      !IT_XKOMV type TT_XKOMV
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  type-pools ABAP .
  methods CHECK_USER
    returning
      value(RV_RETURN) type ABAP_BOOL
    raising
      ZCX_BC_EXIT_IMP .
  methods CHECK_VBELN_VL
    importing
      !IS_KOMK type KOMK
      !IT_XKOMV type TT_XKOMV
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  methods CHECK_LGORT
    importing
      !IS_KOMP type KOMP
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND
      ZCX_BC_EXIT_IMP .
  methods CHECK_MTART
    importing
      !IS_KOMP type KOMP
    raising
      ZCX_BC_EXIT_IMP
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  methods CHECK_KTOKD
    importing
      !IV_KUNNR type KUNNR
    returning
      value(RV_RETURN) type ABAP_BOOL
    raising
      ZCX_BC_EXIT_IMP
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  methods CHECK_PRICE_LIST
    importing
      !IS_KOMP type KOMP
      !IT_XKOMV type TT_XKOMV
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
  class-methods GET_TWEWT
    importing
      !IV_EXTWG type EXTWG
    returning
      value(RV_EWBEZ) type EWBEZ .
  methods CHECK_UNIT_AND_MINIMUM_PRICE
    importing
      !IS_KOMK type KOMK
      !IS_KOMP type KOMP
      !IT_XKOMV type TT_XKOMV
    raising
      ZCX_SD_RV61AFZB_FORM_BWRTNEND .
ENDCLASS.



CLASS ZCL_SD_RV61AFZB_FORM_BWEND_001 IMPLEMENTATION.


  METHOD calculate_rate.

    DATA: lv_kwert TYPE komv_index-kbetr.

    LOOP AT ct_xkomv ASSIGNING FIELD-SYMBOL(<ls_xkomv>)
      WHERE kschl EQ 'ZS01'.
      lv_kwert = <ls_xkomv>-kwert.
      IF <ls_xkomv>-kawrt NE 0.
        <ls_xkomv>-kbetr =  lv_kwert * 1000 / <ls_xkomv>-kawrt.
      ENDIF.
    ENDLOOP.

    LOOP AT ct_xkomv ASSIGNING <ls_xkomv>
     WHERE kschl EQ 'ZS02'.
      lv_kwert = <ls_xkomv>-kwert.
      IF <ls_xkomv>-kawrt NE 0.
        <ls_xkomv>-kbetr =  lv_kwert * 10 / <ls_xkomv>-kawrt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


METHOD check_ktokd.

  DATA: lv_ktokd TYPE ktokd.

  SELECT SINGLE ktokd
    FROM kna1
    INTO lv_ktokd
    WHERE kunnr = iv_kunnr.
  IF sy-subrc EQ 0 AND lv_ktokd EQ 'PERS'.
    rv_return = abap_true.
  ENDIF.

ENDMETHOD.


  METHOD check_lgort.
    "--------->> Anıl CENGİZ 07.11.2019 21:56:32
    "YUR-508 depo yeri kontrolü
*        SELECT SINGLE mandt
*          FROM zsdt_apr_explgrt
*          INTO sy-mandt
*          WHERE lgort = <ls_komp>-zzlgort.
*        IF sy-subrc EQ 0.
*          ASSIGN <lt_xkomv>[ kschl = 'ZF01'
*                             kinak = ' ' ] TO <ls_komv>.
*          IF <ls_komv> IS ASSIGNED.
**            MESSAGE e009(zsd) WITH <ls_komp>-zzlgort.
*            RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
*              EXPORTING
*                textid = zcx_sd_rv61afzb_form_bwrtnend=>zsd_009
*                lgort  = <ls_komp>-zzlgort.
*          ENDIF.
*        ENDIF.
    TRY.
        DATA(rr_vld_lgort) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                           var = 'LGORT'
                                                                           val = REF #( is_komp-zzlgort )
                                                                           surec = 'YI_MNL_FYT' ) ) .
        ASSIGN rr_vld_lgort->* TO FIELD-SYMBOL(<lv_vld_lgort>).

      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.

    IF <lv_vld_lgort> EQ abap_true. "Geçerli depolar için aşağıdaki kontrol çalışacaktır.
*            MESSAGE e009(zsd) WITH <ls_komp>-zzlgort.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '009'
                   id_msgv1 = is_komp-zzlgort ).

      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.

*    RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
*      EXPORTING
*        textid = zcx_sd_rv61afzb_form_bwrtnend=>zsd_009
*        lgort  = is_komp-zzlgort.
    ENDIF.

  ENDMETHOD.


  METHOD check_matnr.
    "YUR-508 malzeme kodu kontrolü
    SELECT SINGLE mandt
    FROM zsdt_apr_expmat
    INTO sy-mandt
    WHERE matnr = is_komp-matnr.
    IF sy-subrc EQ 0.
* MESSAGE e010(zsd) WITH <ls_komp>-matnr.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '010'
                   id_msgv1 = is_komp-matnr ). "& malzemesi için manuel fiyat girilemez!

      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.

*    RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
*      EXPORTING
*        textid = zcx_sd_rv61afzb_form_bwrtnend=>zsd_010
*        matnr  = is_komp-matnr.
    ENDIF.

  ENDMETHOD.


  METHOD check_mtart.

    TRY.
        DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                           var = 'MTART'
                                                                           val = REF #( is_komp-mtart )
                                                                           surec = 'YI_MNL_FYT' ) ) .
        ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.

    IF <lv_vld_mtart> EQ abap_true. "Geçerli malzeme türleri için aşağıdaki kontrol çalışacaktır.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '058'
                   id_msgv1 = is_komp-mtart ). "& malzeme türü için manuel fiyat giremezsiniz!

      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.
    ENDIF.

  ENDMETHOD.


METHOD check_price_list.

  DATA: ls_prclst TYPE ty_prclst.

  ASSIGN gt_prclst[ KEY primary_key COMPONENTS zzlgort = is_komp-zzlgort
                                               pltyp_p = is_komp-pltyp_p
                                               extwg   = is_komp-extwg   ] TO FIELD-SYMBOL(<gs_prclst>).
  IF sy-subrc NE 0.
    SELECT SINGLE *
      FROM zsdt_apr_prclst
      INTO ls_prclst
      WHERE zzlgort EQ is_komp-zzlgort
        AND pltyp_p EQ is_komp-pltyp_p
        AND extwg   EQ is_komp-extwg.
    IF sy-subrc EQ 0.
      INSERT ls_prclst INTO TABLE gt_prclst ASSIGNING <gs_prclst>.
    ENDIF.
  ENDIF.

  IF <gs_prclst> IS ASSIGNED AND <gs_prclst>-yi_mnl_fyt EQ abap_true.
    DATA(lo_msg) = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '063'
                 id_msgv1 = is_komp-zzlgort
                 id_msgv2 = is_komp-pltyp_p
                 id_msgv3 = get_twewt( is_komp-extwg ) ). "& depo, & liste fiyatı ve & kalite için manuel fiyat giremezsiniz!
    RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
      EXPORTING
        messages = lo_msg.
  ENDIF.

ENDMETHOD.


  METHOD check_rate.

    LOOP AT it_xkomv ASSIGNING FIELD-SYMBOL(<ls_xkomv>)
       WHERE kschl EQ 'ZS02'.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0 AND <ls_xkomv>-kbetr NE 0.
      LOOP AT it_xkomv ASSIGNING <ls_xkomv>
          WHERE kschl EQ 'ZF01'
            AND kinak EQ abap_false.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.

        "--------->> Anıl CENGİZ 14.12.2020 13:54:34
        "YUR-773
*        LOOP AT it_xkomv ASSIGNING <ls_xkomv>
*          WHERE kschl EQ 'ZS01'
*            AND kinak EQ 'X'.
*          EXIT.
*        ENDLOOP.
        LOOP AT it_xkomv ASSIGNING <ls_xkomv>
          WHERE kschl EQ 'ZS01'
          "--------->> Anıl CENGİZ 23.03.2021 16:58:38
          "YUR-874
*           AND kwert LE 0.
           AND kwert EQ 0.
          "---------<<
          EXIT.
        ENDLOOP.
        "---------<<
        IF sy-subrc EQ 0.
*    MESSAGE e019(zsd) WITH ls_komv-kschl.
          DATA(lo_msg) = cf_reca_message_list=>create( ).
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD'
                       "--------->> Anıl CENGİZ 23.03.2021 17:01:14
                       "YUR-874
*                       id_msgno = '019' "Manuel fiyat net fiyattan büyük olamaz!
                       id_msgno = '098' "Manuel fiyat net fiyatla aynı olamaz!
                       "---------<<
                       id_msgv1 = <ls_xkomv>-kschl ).

          RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
            EXPORTING
              messages = lo_msg.

*        RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
*          EXPORTING
*            textid = zcx_sd_rv61afzb_form_bwrtnend=>zsd_019
*            kschl  = <ls_xkomv>-kschl.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


METHOD check_unit_and_minimum_price.

  DATA: ls_unitprc        TYPE ty_unitprc,
        lv_zf01_kbetr(10),
        lv_unitprc(10),
        lv_zs02_kbetr(10).

  ASSIGN it_xkomv[ kposn = is_komp-kposn kschl = 'ZS02' ] TO FIELD-SYMBOL(<ls_zs02>).
  CHECK: sy-subrc EQ 0.
  ASSIGN it_xkomv[ kposn = is_komp-kposn kschl = 'ZF01' ] TO FIELD-SYMBOL(<ls_zf01>).
  CHECK: sy-subrc EQ 0.
  "--------->> Anıl CENGİZ 24.09.2020 07:44:13
  "YUR-718
  DATA(lt_unitprc) = VALUE tt_unitprc( FOR wa IN gt_unitprc WHERE ( pltyp_p = is_komp-pltyp_p AND
                                                                    extwg = is_komp-extwg AND
                                                                    datbi > is_komk-prsdt AND
                                                                    datab < is_komk-prsdt  ) ( wa ) ).
  DESCRIBE TABLE lt_unitprc.
  IF sy-tfill > 1.
    DATA(lo_msg) = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '074'
                 id_msgv1 = 'ZSDT_APR_UNITPRC'
                 id_msgv2 = is_komp-pltyp_p
                 id_msgv3 = get_twewt( is_komp-extwg )
                 id_msgv4 = is_komk-prsdt ). "& liste fiyatı, & kalite ve & fiyat için manuel fiyat giremezsiniz! (&)
    RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
      EXPORTING
        messages = lo_msg.
  ENDIF.
*  ASSIGN gt_unitprc[ KEY primary_key COMPONENTS pltyp_p = is_komp-pltyp_p
*                                                extwg   = is_komp-extwg   ] TO FIELD-SYMBOL(<gs_unitprc>).
  ASSIGN lt_unitprc[ 1 ] TO FIELD-SYMBOL(<ls_unitprc>).
  IF sy-subrc NE 0.
    SELECT *
      FROM zsdt_apr_unitprc
      APPENDING TABLE gt_unitprc
      WHERE pltyp_p EQ is_komp-pltyp_p
        AND extwg EQ is_komp-extwg
        AND datbi GE is_komk-prsdt
        AND datab LE is_komk-prsdt.
    IF sy-subrc EQ 0.
      DELETE ADJACENT DUPLICATES FROM gt_unitprc COMPARING ALL FIELDS.
      DESCRIBE TABLE gt_unitprc.
      IF sy-tfill > 1.
        lo_msg = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '074'
                     id_msgv1 = 'ZSDT_APR_UNITPRC'
                     id_msgv2 = is_komp-pltyp_p
                     id_msgv3 = get_twewt( is_komp-extwg )
                     id_msgv4 = is_komk-prsdt ). "& liste fiyatı, & kalite ve & fiyat için manuel fiyat giremezsiniz! (&)
        RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
          EXPORTING
            messages = lo_msg.
      ENDIF.
      ASSIGN gt_unitprc[ 1 ] TO <ls_unitprc>.
    ENDIF.
  ENDIF.
  "---------<<
  IF sy-subrc EQ 0. "<gs_unitprc> IS ASSIGNED
    IF <ls_zf01>-kbetr LT <ls_unitprc>-kbetr AND
       <ls_zf01>-waers EQ <ls_unitprc>-waers.
      lo_msg        = cf_reca_message_list=>create( ).
      lv_zf01_kbetr = <ls_zf01>-kbetr.
      lv_unitprc    = <ls_unitprc>-kbetr.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '072'
                   id_msgv1 = is_komp-pltyp_p
                   id_msgv2 = get_twewt( is_komp-extwg )
                   id_msgv3 = lv_unitprc
                   id_msgv4 = lv_zf01_kbetr ). "& liste fiyatı, & kalite için manuel fiyat & fiyat den düşük olamaz!
      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.
    ENDIF.

    IF <ls_zs02>-kbetr LT <ls_unitprc>-kbetr AND
       <ls_zs02>-waers EQ <ls_unitprc>-waers.
      lo_msg = cf_reca_message_list=>create( ).
      lv_zs02_kbetr = <ls_zs02>-kbetr.
      lv_unitprc    = <ls_unitprc>-kbetr.
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '066'
                   id_msgv1 = is_komp-pltyp_p
                   id_msgv2 = get_twewt( is_komp-extwg )
                   id_msgv3 = lv_zs02_kbetr
                   id_msgv4 = lv_unitprc ). "& liste fiyatı, & kalite ve & fiyat için manuel fiyat giremezsiniz! (&)
      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDIF.

ENDMETHOD.


  METHOD check_user.

    TRY.
        DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                          var = 'USER'
                                                                          val = REF #( sy-uname )
                                                                          surec = 'YI_MNL_FYT' ) ) .
        ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).
      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.

    rv_return = <lv_exc_user>.

  ENDMETHOD.


METHOD check_vbeln_vl.

  DATA: lt_old_komv TYPE tt_komv.

  CHECK: NEW zcl_sd_apr_event_create( iv_process    = 'ZF01'
                                      is_vbak       = VALUE #( vbeln = is_komk-belnr ) )->check_delivery( ) EQ abap_true. "Onaylanmış ve teslimatı var ise.

  SELECT *
    FROM konv
    INTO CORRESPONDING FIELDS OF TABLE lt_old_komv
     WHERE knumv EQ is_komk-knumv
       AND kschl EQ 'ZF01'
       AND kinak EQ space.

  LOOP AT it_xkomv ASSIGNING FIELD-SYMBOL(<ls_new_komv>)
    WHERE kschl EQ 'ZF01'
      AND kinak EQ space.
    ASSIGN lt_old_komv[ kposn = <ls_new_komv>-kposn ] TO FIELD-SYMBOL(<ls_old_komv>).
    IF <ls_old_komv> IS ASSIGNED.
      IF <ls_old_komv>-kwert NE <ls_new_komv>-kwert.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '057' ). "Man.Fyt.Sürecinde teslimat başlamış. Fiyat değiştiremezsiniz!
        RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
          EXPORTING
            messages = lo_msg.
      ENDIF.
    ELSE.
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '057' ). "Man.Fyt.Sürecinde teslimat başlamış. Fiyat değiştiremezsiniz!
      RAISE EXCEPTION TYPE zcx_sd_rv61afzb_form_bwrtnend
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD get_twewt.

  SELECT SINGLE ewbez
    FROM twewt
    INTO rv_ewbez
    WHERE spras = 'T'
      AND extwg = iv_extwg.

ENDMETHOD.


  METHOD zif_bc_exit_imp~execute.
    "--------->> Anıl CENGİZ 18.03.2019 16:51:04
    "YUR-340 Yurtiçi Manuel Fiyat Onay Mekanizması v.0 - Programlama
    FIELD-SYMBOLS: <lt_xkomv> TYPE tt_xkomv,
                   <ls_komk>  TYPE komk,
                   <ls_komp>  TYPE komp.

    DATA:  lr_data  TYPE REF TO data.

    lr_data = co_con->get_vars( 'XKOMV' ). ASSIGN lr_data->* TO <lt_xkomv>.
    lr_data = co_con->get_vars( 'KOMK' ).  ASSIGN lr_data->* TO <ls_komk>.
    lr_data = co_con->get_vars( 'KOMP' ).  ASSIGN lr_data->* TO <ls_komp>.

    "--------->> Anıl CENGİZ 7 May 2020 09:44:18
    "YUR-654
    CHECK: <ls_komk>-vtweg EQ '10',
   "--------->> Anıl CENGİZ 06.01.2021 16:01:01
   "YUR-813
           <ls_komp>-charg IS INITIAL,
    "---------<<
    "--------->> Anıl CENGİZ 08.01.2021 14:36:05
    "YUR-815
           <ls_komp>-matnr IS NOT INITIAL.
    "---------<<
    "---------<<
    "--------->> Anıl CENGİZ 16.12.2019 14:46:11
    "YUR-539
*  IF <ls_komk>-erdat GT '20191217'.
    ASSIGN <lt_xkomv>[ kschl = 'ZF01'
                       kinak = ' ' ] TO FIELD-SYMBOL(<ls_komv>).
    CHECK: <ls_komv> IS ASSIGNED AND <ls_komv>-kbetr NE 0 . "Manuel fiyat var ise aşağıdaki kontrollere girilir.

    calculate_rate(
      CHANGING
        ct_xkomv = <lt_xkomv> ).

    TRY .
        check_rate(
          EXPORTING
            is_komp  = <ls_komp>
            it_xkomv = <lt_xkomv> ). "Sistemden bulunan fiyat ile girilen manuel fiyat aynı olamaz. İstisna kullanıcıdan bağımsız.

        CHECK:  check_user( ) EQ abap_false. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
        "--------->> Anıl CENGİZ 01.06.2020 07:25:57
        "YUR-661
        CHECK:  check_ktokd( <ls_komk>-kunnr ) EQ abap_false. "istisna müşteri hesap grubu ise aşağıdaki kontrole girmez.
        "---------<<
        check_lgort( <ls_komp> ). "İlgili depolar için manuel fiyat giremezsiniz.

        check_matnr( <ls_komp> ). "İlgili malzemeler için manuel fiyat giremezsiniz.
        "--------->> Anıl CENGİZ 30 Nis 2020 15:41:53
        "YUR-651
        check_mtart( <ls_komp> ). "İlgili malzeme türleri için manuel fiyat giremezsiniz.
        "---------<<
        check_vbeln_vl(
          EXPORTING
            is_komk  = <ls_komk>
            it_xkomv = <lt_xkomv> ). "Teslimat başlamış ise manuel fiyat girilemez. (Değiştirilemez.)
        "--------->> Anıl CENGİZ 28.07.2020 15:19:41
        "YUR-701
        check_price_list(
          EXPORTING
            is_komp  = <ls_komp>
            it_xkomv = <lt_xkomv> ). "DEPO/LISTE FİYATI/KALITE Bazında Manuel Fiyat Girişi Kontrolü
        "---------<<
        "--------->> Anıl CENGİZ 01.09.2020 14:06:37
        "YUR-718
        check_unit_and_minimum_price(
          EXPORTING
            is_komk  = <ls_komk>
            is_komp  = <ls_komp>
            it_xkomv = <lt_xkomv> ).
        "---------<<
      CATCH zcx_sd_rv61afzb_form_bwrtnend INTO DATA(lx_sd_bwrtnend).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            previous = lx_sd_bwrtnend
            messages = lx_sd_bwrtnend->messages.
    ENDTRY.
*  ENDIF.
    "---------<<
  ENDMETHOD.
ENDCLASS.
