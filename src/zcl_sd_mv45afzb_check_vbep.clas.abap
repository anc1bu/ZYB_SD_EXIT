class zcl_sd_mv45afzb_check_vbep definition
  public
  final
  create public .

  public section.

    constants c_trtyp_change type trtyp value 'V'.          "#EC NOTEXT
    constants c_vtweg_dom type vtweg value '10'.            "#EC NOTEXT
    constants c_vtweg_exp type vtweg value '20'.            "#EC NOTEXT
    constants c_mtart_yyk type mtart value 'ZYYK'.
    class-data gs_params type zsds_param_check_vbep .

    class-methods check_goods_date
      raising
        zcx_sd_exit .
    methods constructor
      importing
        value(is_vbep)     type vbep
        value(is_vbak)     type vbak
        value(is_vbap)     type vbap
        value(is_old_vbap) type vbap
        value(is_t180)     type t180
        !it_xvbep          type tab_xyvbep .
    class-methods check_open_quantity
      returning
        value(rv_return) type sy-subrc .
    methods controls
      raising
        zcx_sd_exit .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_CHECK_VBEP IMPLEMENTATION.


  METHOD check_goods_date.

    DATA: lv_tslmt_gun TYPE zsdt_sip_deg_knt-tslmt_gun,
          lv_day_diff  TYPE zsdt_sip_deg_knt-tslmt_gun.



    CHECK : gs_params-vbap-pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm,
            gs_params-vbep-edatu IS NOT INITIAL
            AND gs_params-vbak-erdat > '20190219',
            sy-cprog NE 'SDV03V02'. "V_V2 işlem kodunda kontrol yok.

    "--------->> add by mehmet sertkaya 24.06.2019 14:44:12
    "YUR-372
    SELECT SINGLE COUNT(*) FROM mara
           WHERE matnr EQ gs_params-vbap-matnr AND
                 mtart EQ c_mtart_yyk.
    IF sy-subrc EQ 0 AND lines( gs_params-xvbep ) GT 1.
      LOOP AT gs_params-xvbep INTO DATA(ls_vbep)
              WHERE bmeng GT 0.
        gs_params-vbak-erdat = ls_vbep-edatu.
      ENDLOOP.
    ENDIF.
    "-----------------------------<<
    "--------->> Anıl CENGİZ 13.03.2019 09:16:02
    "YUR-350 Sipariş miktarı açık miktar kadar düşürülürse
    "kontrole girme.
    CHECK check_open_quantity( ) EQ 0.
    "---------<<
    lv_day_diff = gs_params-vbep-edatu - gs_params-vbak-erdat.
    "--------->> Anıl CENGİZ 22.02.2019 07:54:40
    "YUR-328 Bayi sevk(termin) gün sayısı bakım kontrol tablosu
    "Erişim Sırası 1
    SELECT SINGLE tslmt_gun
        INTO lv_tslmt_gun
        FROM zsdt_sip_deg_knt
        WHERE vkorg EQ gs_params-vbak-vkorg
          AND vtweg EQ gs_params-vbak-vtweg
          AND kunnr EQ gs_params-vbak-kunnr.
    IF sy-subrc NE 0.
      "---------<<
      "Erişim Sırası 2
      SELECT SINGLE tslmt_gun
          INTO lv_tslmt_gun
          FROM zsdt_sip_deg_knt
          WHERE vkorg EQ gs_params-vbak-vkorg
            AND vtweg EQ gs_params-vbak-vtweg
            AND lgort EQ gs_params-vbap-lgort.
      "--------->> Anıl CENGİZ 21.06.2019 13:46:28
      "YUR-421
*      if lv_day_diff gt lv_tslmt_gun and lv_tslmt_gun ne 0.
      IF lv_day_diff GE lv_tslmt_gun AND sy-subrc EQ 0.
        "---------<<
        "--------->> Anıl CENGİZ 15.02.2021 15:00:07
        "YUR-847
*        select single mandt ##WRITE_OK
*          into sy-mandt
*          from zsdt_svk_tur_kul
*          where vkorg eq gs_params-vbak-vkorg
*          and  vtweg eq gs_params-vbak-vtweg
*          and  uname eq sy-uname.
        TRY.
            DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                              var = 'USER'
                                                                              val = REF #( sy-uname )
                                                                              surec = 'YI_YKLME_TH_KNTRL' ) ) .
            ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

*            IF sy-subrc NE 0.
            IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL. "İstisna kullanıcı değilse.
              "---------<<
              RAISE EXCEPTION TYPE zcx_sd_exit
                EXPORTING
                  textid = zcx_sd_exit=>goods_date
                  days   = lv_tslmt_gun.
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
*        select single mandt ##WRITE_OK
*          into sy-mandt
*          from zsdt_svk_tur_kul
*          where vkorg eq gs_params-vbak-vkorg
*          and  vtweg eq gs_params-vbak-vtweg
*          and  uname eq sy-uname.
        TRY.
            rr_exc_user = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                        var = 'USER'
                                                                        val = REF #( sy-uname )
                                                                        surec = 'YI_YKLME_TH_KNTRL' ) ) .
            ASSIGN rr_exc_user->* TO <lv_exc_user>.

*            IF sy-subrc NE 0.
            IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL. "İstisna kullanıcı değilse.
              "---------<<
              RAISE EXCEPTION TYPE zcx_sd_exit
                EXPORTING
                  textid = zcx_sd_exit=>goods_date
                  days   = lv_tslmt_gun.
            ENDIF.
          CATCH zcx_sd_exc_vld_cntrl INTO lx_sd_exc_vld_cntrl.
            RAISE EXCEPTION TYPE zcx_bc_exit_imp
              EXPORTING
                messages = lx_sd_exc_vld_cntrl->messages.
        ENDTRY.
      ENDIF.

    ENDIF.

  ENDMETHOD.


method check_open_quantity.
  data: lv_ord_diff     type vbap-kwmeng,
        lv_cum_ord_diff type vbap-kwmeng,
        lv_omeng        type vbbe-omeng,
        ls_xvbep        type vbepvb.

  "omeng = İhtiyacın MİP'ye aktarılması için DÖB cinsinden açık miktar
  "bmeng = Teyit edilen miktar
  "wmeng = Satış ölçü birimi cinsinden müşterinin sipariş miktarı

  if gs_params-t180-trtyp eq c_trtyp_change.

    clear: lv_ord_diff, lv_omeng, ls_xvbep, lv_cum_ord_diff.

    "--------->> Anıl CENGİZ 02.04.2019 08:43:09
    "YUR-363 teslimatı yapılmamış olan siparişlerde problem çıkartıyor.
    "Bu kontrol teslimat miktarı 0 değil ise ancak sipariş miktarını değiştirmeye
    "izin vermeli.
    read table gs_params-xvbep with key vbeln = gs_params-vbep-vbeln
                                        posnr = gs_params-vbep-posnr
                                        etenr = gs_params-vbep-etenr
      into ls_xvbep.
    "---------<<

    lv_ord_diff = gs_params-vbep-wmeng - gs_params-vbep-bmeng.

    "Kümüle ihtiyaç miktarı alınır. "YUR-365
    lv_cum_ord_diff = gs_params-vbap-kwmeng - gs_params-vbap-kbmeng.

    select single omeng
      from vbbe
      into lv_omeng
      where vbeln = gs_params-vbep-vbeln
      and posnr = gs_params-vbep-posnr
      and etenr = gs_params-vbep-etenr.
    if ( sy-subrc eq 0
      and lv_ord_diff eq lv_omeng )
      or ( sy-subrc eq 0 and lv_ord_diff eq 0 and lv_omeng ne 0
          "--------->> Anıl CENGİZ 01.04.2019 18:22:35
          "YUR-363
           and ls_xvbep-vsmng ne 0 ) "Teslimat miktarı 0 olmamalı.
      "---------<<
      "--------->> Anıl CENGİZ 08.04.2019 11:00:48
      "YUR-365
      "Teslimatı yapılmamış ise ve tam teyitli değil ise kontrole girme.
      or ( gs_params-vbep-etenr ne '0001' and lv_cum_ord_diff ne gs_params-vbep-bmeng and ls_xvbep-vsmng eq 0 ).
      "---------<<
      rv_return = 4.
    endif.
  endif.

endmethod.


  method constructor.

    clear gs_params.

    gs_params-vbep = is_vbep.
    gs_params-vbak = is_vbak.
    gs_params-vbap = is_vbap.
    gs_params-*vbap = is_old_vbap.
    gs_params-t180 = is_t180.
    gs_params-xvbep = it_xvbep.

  endmethod.


method controls.
  case gs_params-vbak-vtweg.
    when c_vtweg_dom.
      "{Added by eyolal&acengiz 18.02.2019
      "YUR-308 Depo Yeri Seçildiğinde Mal Hazıredim Tarihi Kontrolü
      check_goods_date( ).
      "}Added by eyolal&acengiz 18.02.2019
    when c_vtweg_exp.

  endcase.

endmethod.
ENDCLASS.
