class ZCL_SD_MV45AFZB_FRM_CHVBEP_003 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHVBEP .
protected section.
private section.

  methods CHECK_OPEN_QUANTITY
    importing
      !IS_T180 type T180
      !IT_XVBEP type TAB_XYVBEP
      !IS_VBEP type VBEP
      !IS_VBAP type VBAP
    returning
      value(RV_RETURN) type SY-SUBRC .
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHVBEP_003 IMPLEMENTATION.


METHOD check_open_quantity.

  DATA: lr_data         TYPE REF TO data,
        lv_ord_diff     TYPE vbap-kwmeng,
        lv_cum_ord_diff TYPE vbap-kwmeng,
        lv_omeng        TYPE vbbe-omeng,
        ls_xvbep        TYPE vbepvb.

  "omeng = İhtiyacın MİP'ye aktarılması için DÖB cinsinden açık miktar
  "bmeng = Teyit edilen miktar
  "wmeng = Satış ölçü birimi cinsinden müşterinin sipariş miktarı

  IF is_t180-trtyp EQ zif_sd_mv45afzb_frm_chvbep=>c_trtyp_change.

    CLEAR: lv_ord_diff, lv_omeng, ls_xvbep, lv_cum_ord_diff.

    "--------->> Anıl CENGİZ 02.04.2019 08:43:09
    "YUR-363 teslimatı yapılmamış olan siparişlerde problem çıkartıyor.
    "Bu kontrol teslimat miktarı 0 değil ise ancak sipariş miktarını değiştirmeye
    "izin vermeli.
    READ TABLE it_xvbep WITH KEY vbeln = is_vbep-vbeln
                                 posnr = is_vbep-posnr
                                 etenr = is_vbep-etenr
      INTO ls_xvbep.
    "---------<<

    lv_ord_diff = is_vbep-wmeng - is_vbep-bmeng.

    "Kümüle ihtiyaç miktarı alınır. "YUR-365
    lv_cum_ord_diff = is_vbap-kwmeng - is_vbap-kbmeng.

    SELECT SINGLE omeng
      FROM vbbe
      INTO lv_omeng
      WHERE vbeln = is_vbep-vbeln
        AND posnr = is_vbep-posnr
        AND etenr = is_vbep-etenr.
    IF ( sy-subrc EQ 0
      AND lv_ord_diff EQ lv_omeng )
      OR ( sy-subrc EQ 0 AND lv_ord_diff EQ 0 AND lv_omeng NE 0
          "--------->> Anıl CENGİZ 01.04.2019 18:22:35
          "YUR-363
           AND ls_xvbep-vsmng NE 0 ) "Teslimat miktarı 0 olmamalı.
      "---------<<
      "--------->> Anıl CENGİZ 08.04.2019 11:00:48
      "YUR-365
      "Teslimatı yapılmamış ise ve tam teyitli değil ise kontrole girme.
      OR ( is_vbep-etenr NE '0001' AND lv_cum_ord_diff NE is_vbep-bmeng AND ls_xvbep-vsmng EQ 0 ).
      "---------<<
      rv_return = 4.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD zif_bc_exit_imp~execute.
  "Depo Yeri Seçildiğinde Mal Hazıredim Tarihi Kontrolü YUR-308
  FIELD-SYMBOLS: <gs_vbep>      TYPE vbep,
                 <gs_star_vbep> TYPE vbep,
                 <gs_vbap>      TYPE vbap,
                 <gs_vbak>      TYPE vbak,
                 <gt_xvbep>     TYPE tab_xyvbep,
                 <gs_t180>      TYPE t180.

  DATA: lr_data   TYPE REF TO data,
        lv_tesmik TYPE lqua_verme,
        lv_sipmik TYPE menge_d.

  lr_data = co_con->get_vars( 'XVBEP[]' ). ASSIGN lr_data->* TO <gt_xvbep>.
  lr_data = co_con->get_vars( 'VBEP' ).    ASSIGN lr_data->* TO <gs_vbep>.
  lr_data = co_con->get_vars( '*VBEP' ).   ASSIGN lr_data->* TO <gs_star_vbep>.
  lr_data = co_con->get_vars( 'VBAP' ).    ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( 'VBAK' ).    ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'T180' ).    ASSIGN lr_data->* TO <gs_t180>.

  CHECK: <gs_vbak>-vtweg EQ zif_sd_mv45afzb_frm_chvbep=>c_vtweg_dom.

  DATA: lv_tslmt_gun TYPE zsdt_sip_deg_knt-tslmt_gun,
        lv_day_diff  TYPE zsdt_sip_deg_knt-tslmt_gun.


  CHECK : <gs_vbap>-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm,
          <gs_vbep>-edatu IS NOT INITIAL,
          <gs_vbak>-erdat > '20190219',
          sy-cprog NE 'SDV03V02'. "V_V2 işlem kodunda kontrol yok.

  "--------->> add by mehmet sertkaya 24.06.2019 14:44:12
  "YUR-372
  SELECT SINGLE COUNT(*)
    FROM mara
    WHERE matnr EQ <gs_vbap>-matnr
      AND mtart EQ zif_sd_mv45afzb_frm_chvbep=>c_mtart_yyk.
  IF sy-subrc EQ 0 AND lines( <gt_xvbep> ) GT 1.
    LOOP AT <gt_xvbep> ASSIGNING FIELD-SYMBOL(<gs_xvbep>)
      WHERE bmeng GT 0.
      <gs_vbak>-erdat = <gs_xvbep>-edatu.
    ENDLOOP.
  ENDIF.
  "-----------------------------<<
  "--------->> Anıl CENGİZ 13.03.2019 09:16:02
  "YUR-350 Sipariş miktarı açık miktar kadar düşürülürse
  "kontrole girme.
  CHECK check_open_quantity( is_t180  = <gs_t180>
                             it_xvbep = <gt_xvbep>
                             is_vbep  = <gs_vbep>
                             is_vbap  = <gs_vbap> ) EQ 0.
  "---------<<
  lv_day_diff = <gs_vbep>-edatu - <gs_vbak>-erdat.
  "--------->> Anıl CENGİZ 22.02.2019 07:54:40
  "YUR-328 Bayi sevk(termin) gün sayısı bakım kontrol tablosu
  "Erişim Sırası 1
  SELECT SINGLE tslmt_gun
      INTO lv_tslmt_gun
      FROM zsdt_sip_deg_knt
      WHERE vkorg EQ <gs_vbak>-vkorg
        AND vtweg EQ <gs_vbak>-vtweg
        AND kunnr EQ <gs_vbak>-kunnr.
  IF sy-subrc NE 0.
    "---------<<
    "Erişim Sırası 2
    SELECT SINGLE tslmt_gun
        INTO lv_tslmt_gun
        FROM zsdt_sip_deg_knt
        WHERE vkorg EQ <gs_vbak>-vkorg
          AND vtweg EQ <gs_vbak>-vtweg
          AND lgort EQ <gs_vbap>-lgort.
    "--------->> Anıl CENGİZ 21.06.2019 13:46:28
    "YUR-421
*      if lv_day_diff gt lv_tslmt_gun and lv_tslmt_gun ne 0.
    IF lv_day_diff GE lv_tslmt_gun AND sy-subrc EQ 0.
      "---------<<
      "--------->> Anıl CENGİZ 15.02.2021 15:00:07
      "YUR-847
*      SELECT SINGLE mandt ##WRITE_OK
*        INTO sy-mandt
*        FROM zsdt_svk_tur_kul
*        WHERE vkorg EQ <gs_vbak>-vkorg
*          AND vtweg EQ <gs_vbak>-vtweg
*          AND uname EQ sy-uname.
      TRY.
          DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                       var = 'USER'
                                                                       val = REF #( sy-uname )
                                                                       surec = 'YI_YKLME_TH_KNTRL' ) ) .
          ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

*            IF sy-subrc NE 0.
          IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL. "İstisna kullanıcı değilse.
            "---------<<
            DATA(lo_msg) = cf_reca_message_list=>create( ).
            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZSD_VA'
                         id_msgno = '053'
                         id_msgv1 = CONV #( lv_tslmt_gun ) ).
            RAISE EXCEPTION TYPE zcx_bc_exit_imp
              EXPORTING
                messages = lo_msg.
          ENDIF.
        CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lx_sd_exc_vld_cntrl->messages.
      ENDTRY.
    ENDIF.
  ELSE.
    IF lv_day_diff GE lv_tslmt_gun.
      "---------<<
      "--------->> Anıl CENGİZ 15.02.2021 15:00:07
      "YUR-847
*      SELECT SINGLE mandt ##WRITE_OK
*        INTO sy-mandt
*        FROM zsdt_svk_tur_kul
*        WHERE vkorg EQ <gs_vbak>-vkorg
*          AND vtweg EQ <gs_vbak>-vtweg
*          AND uname EQ sy-uname.
      TRY.
          rr_exc_user = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                      var = 'USER'
                                                                      val = REF #( sy-uname )
                                                                      surec = 'YI_YKLME_TH_KNTRL' ) ) .
          ASSIGN rr_exc_user->* TO <lv_exc_user>.

*            IF sy-subrc NE 0.
          IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL. "İstisna kullanıcı değilse.
            "---------<<
            lo_msg = cf_reca_message_list=>create( ).
            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZSD_VA'
                         id_msgno = '053'
                         id_msgv1 = CONV #( lv_tslmt_gun ) ).
            RAISE EXCEPTION TYPE zcx_bc_exit_imp
              EXPORTING
                messages = lo_msg.
          ENDIF.
        CATCH zcx_sd_exc_vld_cntrl INTO lx_sd_exc_vld_cntrl.
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lx_sd_exc_vld_cntrl->messages.
      ENDTRY.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
