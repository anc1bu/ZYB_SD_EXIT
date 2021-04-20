class ZCL_SD_MV45AFZZ_SDP definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_params,
        t_xvbkd     TYPE va_vbkdvb_t,
        t_xvbap     TYPE va_vbapvb_t,
        t_xvbup     TYPE va_vbupvb_t,
        s_vbak      TYPE vbak,
        t_kmplist   TYPE zyb_sd_t_kmplist,
        t_findocexp TYPE HASHED TABLE OF zsdt_findoc_expc WITH UNIQUE KEY auart,
      END OF ty_params .

  methods CONSTRUCTOR
    importing
      !IT_XVBKD type TAB_XYVBKD
      !IT_XVBAP type TAB_XYVBAP
      !IS_VBAK type VBAK
      !IT_XVBUP type TAB_XYVBUP .
  class-methods CONTROLS
    returning
      value(RT_RETURN) type TDT_SYMSG .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA gs_params TYPE ty_params .
    CONSTANTS c_lgort_1200 TYPE lgort_d VALUE '1200'.       "#EC NOTEXT
    CONSTANTS c_lgort_1250 TYPE lgort_d VALUE '1250'.       "#EC NOTEXT
    CONSTANTS c_vtweg_dom TYPE vtweg VALUE '10'.            "#EC NOTEXT
    CONSTANTS c_vtweg_exp TYPE vtweg VALUE '20'.            "#EC NOTEXT
    CONSTANTS c_updkz_d TYPE char1 VALUE 'D'.               "#EC NOTEXT
    CONSTANTS c_shptype_kk TYPE vsarttr VALUE '05'.         "#EC NOTEXT
    CONSTANTS c_ordtype_c TYPE vbtyp VALUE 'C'.             "#EC NOTEXT
    CONSTANTS c_ordtype_l TYPE vbtyp VALUE 'L'.             "#EC NOTEXT

    CLASS-METHODS check_prod_ord
      RETURNING
        VALUE(rt_return) TYPE tdt_symsg .
    CLASS-METHODS check_lgort_1250
      RETURNING
        VALUE(rt_return) TYPE tdt_symsg .
    CLASS-METHODS check_shp_type
      RETURNING
        VALUE(rt_return) TYPE tdt_symsg .
    CLASS-METHODS define_lgort
      EXPORTING
        VALUE(ev_lgort)  TYPE lgort_d
      RETURNING
        VALUE(rt_return) TYPE tdt_symsg .
    CLASS-METHODS check_findoc
      RETURNING
        VALUE(rt_return) TYPE tdt_symsg .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_SDP IMPLEMENTATION.


  METHOD check_findoc.
    DATA: lv_amount TYPE netwr,
          lv_expc   TYPE zsdt_findoc_expc.

    CHECK: gs_params-s_vbak-vkbur NE '1120'.
    "--------->> Anıl CENGİZ 16.09.2019 15:01:30
    "YUR-487 Alacak dekontu ise kontrole girme.
    CHECK: gs_params-s_vbak-vbtyp NE 'K'.
    "---------<<

    "İstisna tablosunda yoksa.
    ASSIGN gs_params-t_findocexp[ KEY primary_key COMPONENTS auart = gs_params-s_vbak-auart ] TO FIELD-SYMBOL(<ls_expc>).

    IF sy-subrc NE 0.
      SELECT SINGLE *
        FROM zsdt_findoc_expc
        INTO lv_expc
        WHERE auart EQ gs_params-s_vbak-auart .
      IF sy-subrc EQ 0.
        INSERT lv_expc INTO TABLE gs_params-t_findocexp ASSIGNING <ls_expc>.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

    CLEAR: lv_amount.
    "--------->> Anıl CENGİZ 23.09.2019 09:38:29
    "YUR-447
    "GS_PARAMS statik olduğu için ekrandan çıkmadan yeniden sipariş açıldığında OPEN_VALUE açık değer güncellenmiyor.
    "Tekrar güncellenmesi için temizlendi.
    REFRESH: gs_params-t_kmplist.
    "---------<<
    ASSIGN gs_params-t_kmplist[ knuma_ag = gs_params-s_vbak-zz_knuma_ag ] TO FIELD-SYMBOL(<ls_kmp>).

    IF sy-subrc NE 0.

      ASSIGN gs_params-t_xvbkd[ posnr = '000000' ]-prsdt TO FIELD-SYMBOL(<lv_prsdt>).

      CALL FUNCTION 'ZYB_SD_F_KMP_FIND'
        EXPORTING
          i_vkorg      = gs_params-s_vbak-vkorg
          i_vtweg      = gs_params-s_vbak-vtweg
          i_kunnr      = gs_params-s_vbak-kunnr
          i_date       = <lv_prsdt>
          i_auart      = gs_params-s_vbak-auart
        IMPORTING
          kmplist      = gs_params-t_kmplist
        EXCEPTIONS
          not_found    = 1
          format_error = 2
          OTHERS       = 3.

      ASSIGN gs_params-t_kmplist[ knuma_ag = gs_params-s_vbak-zz_knuma_ag ] TO <ls_kmp>.

      IF sy-subrc NE 0.
        APPEND VALUE #( msgty = 'E'
                        msgid = 'ZSD_VA'
                        msgno = '036'
                        msgv1 = gs_params-s_vbak-zz_knuma_ag ) TO rt_return .
        RETURN.
      ENDIF.

    ENDIF.

    LOOP AT gs_params-t_xvbap ASSIGNING FIELD-SYMBOL(<ls_vbap>)
      WHERE abgru IS INITIAL
      "--------->> Anıl CENGİZ 29.06.2020 12:38:48
      "YUR-675
      AND updkz NE 'D'.
      "---------<<
      ADD <ls_vbap>-netwr TO lv_amount.
      ADD <ls_vbap>-mwsbp TO lv_amount.
      "--------->> add by mehmet sertkaya 26.08.2019 11:23:17
      "YUR-447 - Açığa Sipariş Girme Hatası
      DATA ls_db TYPE vbap.

      ASSIGN gs_params-t_xvbup[ vbeln = <ls_vbap>-vbeln
                                posnr = <ls_vbap>-posnr ]
                       TO FIELD-SYMBOL(<ls_vbup>).
      IF sy-subrc EQ 0.
        IF <ls_vbup>-cmppi EQ 'A'.
          SELECT SINGLE * INTO ls_db FROM vbap
                          WHERE vbeln EQ <ls_vbap>-vbeln AND
                                posnr EQ <ls_vbap>-posnr .
          IF sy-subrc EQ 0.
            ADD ls_db-netwr TO <ls_kmp>-open_value.
            ADD ls_db-mwsbp TO <ls_kmp>-open_value.
          ENDIF.
        ENDIF.
      ENDIF.

      "-----------------------------<<
    ENDLOOP.


    IF lv_amount GT <ls_kmp>-open_value.
      APPEND VALUE #( msgty = 'E'
                      msgid = 'ZSD_VA'
                      msgno = '036'
                      msgv1 = gs_params-s_vbak-zz_knuma_ag ) TO rt_return .
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD check_lgort_1250.

    LOOP AT gs_params-t_xvbap ASSIGNING FIELD-SYMBOL(<ls_xvbap>)
      WHERE lgort NE c_lgort_1250
      AND lgort IS NOT INITIAL
      AND updkz NE c_updkz_d.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0 "Kalemlerde depo yeri 1250 olmayan herhangi bi şey var mı?
    AND line_exists( gs_params-t_xvbap[ lgort = c_lgort_1250 ] ). "Herhangi satırda 1250 varsa hata patlat.

      APPEND VALUE #( msgty = 'E'
                      msgid = 'ZSD_VA'
                      msgno = '054'
                      msgv1 = c_lgort_1250 ) TO rt_return.
    ENDIF.


  ENDMETHOD.


  METHOD check_prod_ord.

    DATA : lt_aufnr TYPE TABLE OF aufk-aufnr,
           lv_objnr TYPE jest-objnr.

    LOOP AT gs_params-t_xvbap ASSIGNING FIELD-SYMBOL(<ls_xvbap>)
      WHERE bedae EQ 'ZKEV'
      AND abgru IS NOT INITIAL
      AND updkz NE c_updkz_d.

      REFRESH lt_aufnr.

      SELECT aufnr
        INTO TABLE lt_aufnr
        FROM aufk
        WHERE kdauf EQ <ls_xvbap>-vbeln
        AND   kdpos EQ <ls_xvbap>-posnr
        AND   loekz EQ abap_false. "Silme işareti buraya alındı.
      IF sy-subrc EQ 0.

        LOOP AT lt_aufnr ASSIGNING FIELD-SYMBOL(<lv_aufnr>).

          CONCATENATE 'OR' <lv_aufnr> INTO lv_objnr.
          SELECT SINGLE COUNT(*)
            FROM jest
            WHERE objnr EQ lv_objnr
            AND stat IN ('I0045') "silme işareti I0076 kaldırıldı
                                  "I0045 "Teknik olarak tamamlandı
            AND inact EQ space.
          IF sy-subrc NE 0. "Teknik olarak tamamlandı değilse.
            SHIFT <lv_aufnr> LEFT DELETING LEADING '0'.
            APPEND VALUE #( msgty = 'E'
                            msgid = 'ZSD_VA'
                            msgno = '057'
                            msgv1 = <ls_xvbap>-posnr
                            msgv2 = <lv_aufnr> ) TO rt_return.
            RETURN.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_shp_type.

    DATA: lv_day_diff        TYPE zsdt_sip_deg_knt-svktur_gun,
          lv_svktur_gun      TYPE zsdt_sip_deg_knt-svktur_gun,
          lv_svktur_gun_char TYPE char10,
          lv_lgort           TYPE lgort_d,
          ls_vbkd            TYPE vbkdvb.

    "--------->> Anıl CENGİZ 28.09.2020 16:55:42
    "YUR-739
    "Başlık ile kalem ayrı olamaz kontrolü.
*    LOOP AT gs_params-t_xvbkd ASSIGNING FIELD-SYMBOL(<lt_vbkd>)
*      WHERE posnr IS NOT INITIAL.
*      IF <lt_vbkd>-vsart IS NOT INITIAL.
*        APPEND VALUE #( msgty = 'E'
*            msgid = 'ZSD_VA'
*            msgno = '055' ) TO rt_return.
*        RETURN.
*      ENDIF.
*    ENDLOOP.
    "---------<<
    "--------->> Anıl CENGİZ 08.04.2019 10:37:46
    "YUR-365 Teyit Almamışlarda Kontrol Çalışmamalı
    "Bütün kalemleri teyitli ise bu kontrol çalışmalıdır.
    LOOP AT gs_params-t_xvbap ASSIGNING FIELD-SYMBOL(<ls_xvbap>)
      WHERE posnr IS NOT INITIAL.
      IF <ls_xvbap>-kwmeng NE <ls_xvbap>-kbmeng.
        RETURN.
      ENDIF.
    ENDLOOP.
    "---------<<

    READ TABLE gs_params-t_xvbkd INTO ls_vbkd INDEX 1.
    IF ls_vbkd-vsart EQ c_shptype_kk. "Sadece kendi kamyonu olduğunda"

      "Depo yerine göre kontrol.
      rt_return = define_lgort( IMPORTING ev_lgort = lv_lgort ).

      CHECK rt_return IS INITIAL.

      "Erişim sırası 1
      SELECT SINGLE svktur_gun
        INTO lv_svktur_gun
        FROM zsdt_sip_deg_knt
        WHERE vkorg EQ gs_params-s_vbak-vkorg
          AND vtweg EQ gs_params-s_vbak-vtweg
          AND kunnr EQ gs_params-s_vbak-kunnr
          AND lgort EQ space.
      IF sy-subrc NE 0.
        "Erişim sırası 2
        SELECT SINGLE svktur_gun
          INTO lv_svktur_gun
          FROM zsdt_sip_deg_knt
          WHERE vkorg EQ gs_params-s_vbak-vkorg
            AND vtweg EQ gs_params-s_vbak-vtweg
            AND lgort EQ lv_lgort
            AND kunnr EQ space.
        IF sy-subrc EQ 0.
          lv_day_diff = sy-datum - gs_params-s_vbak-erdat.
        ELSE.
          APPEND VALUE #( msgty = 'E'
                          msgid = 'ZSD_VA'
                          msgno = '059'
                          msgv1 = 'ZSDT_SIP_DEG_KNT'
                          msgv2 = lv_lgort
                          msgv3 = gs_params-s_vbak-kunnr ) TO rt_return .
          RETURN.
        ENDIF.
      ELSE.
        lv_day_diff = sy-datum - gs_params-s_vbak-erdat.
      ENDIF.

      IF lv_day_diff GT lv_svktur_gun
        OR ( lv_day_diff EQ 0 AND lv_svktur_gun EQ 0 ).
        "and lv_svktur_gun ne 0.

        "--------->> Anıl CENGİZ 15.02.2021 14:27:06
        "YUR-847
*        SELECT SINGLE mandt ##WRITE_OK
*          INTO sy-mandt
*          FROM zsdt_svk_tur_kul
*          WHERE vkorg EQ gs_params-s_vbak-vkorg
*           AND  vtweg EQ gs_params-s_vbak-vtweg
*           AND  uname EQ sy-uname.
        TRY.
            DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                         var = 'USER'
                                                                         val = REF #( sy-uname )
                                                                         surec = 'YI_SVK_TRH_KNTRL' ) ) .
            ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).

*            IF sy-subrc NE 0.
            IF sy-subrc NE 0 AND <lv_exc_user> IS INITIAL.
              "---------<<
              lv_svktur_gun_char = lv_svktur_gun.
              CONDENSE lv_svktur_gun_char.
              APPEND VALUE #( msgty = 'E'
                              msgid = 'ZSD_VA'
                              msgno = '056'
                              msgv1 = lv_svktur_gun_char ) TO rt_return.
            ENDIF.
          CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
            RAISE EXCEPTION TYPE zcx_bc_exit_imp
              EXPORTING
                messages = lx_sd_exc_vld_cntrl->messages.
        ENDTRY.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    gs_params-t_xvbap = it_xvbap.
    gs_params-t_xvbup = it_xvbup.
    gs_params-t_xvbkd = it_xvbkd.
    gs_params-s_vbak = is_vbak.

  ENDMETHOD.


  METHOD controls.

    LOOP AT gs_params-t_xvbap TRANSPORTING NO FIELDS
      WHERE updkz NE c_updkz_d.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0. "Sipariş silme sırasında bu kod çalışmaz.

      CASE gs_params-s_vbak-vtweg.
        WHEN c_vtweg_dom.
          "--------->> Anıl CENGİZ 05.03.2019 17:52:59
          "YUR-328 Bayi sevk(termin) gün sayısı bakım kontrol tablosu
          IF gs_params-s_vbak-erdat > '20190311'.
            "12.03.2019 tarihinden itibaren girilen siparişler için
            "geçerlidir.
            "YUR-340 kapsamında kapatıldı. Minimum onay tutarını tuttrabilmek için
            "aynı siparişte girilmesi sağlandı.
*          data(lt_rt1) = check_lgort_1250( ). "1250 ile diğer depolar
*          append lines of lt_rt1 to rt_return.
            "aynı siparişte olamaz.
            DATA(lt_rt2) = check_shp_type( ). "Sevk türü kontrolü.
            "---------<<
            "--------->> Anıl CENGİZ 07.10.2020 00:09:22
            "YUR-744 - ZCL_SD_MV45AFZZ_FORM_SVDOC_003 içerisine taşındı.
*            "--------->> Anıl CENGİZ 19.08.2019 16:26:42
*            "YUR-447
*            DATA(lt_rt4) = check_findoc( ). "Mali belge kontrolü
*            "---------<<
            "---------<<
          ENDIF.
        WHEN c_vtweg_exp.
          "--------->> add by mehmet sertkaya 11.03.2019 11:18:39
          "YUR-341 İhracat Satış Siparişine Ret Nedeni Koyma Kontrolü
          DATA(lt_rt3) = check_prod_ord( ).
          "---------<<
      ENDCASE.
*--------------------------------------------------------------------*
      "Add Errors
*--------------------------------------------------------------------*

      APPEND LINES OF lt_rt2 TO rt_return.
      APPEND LINES OF lt_rt3 TO rt_return.
*      APPEND LINES OF lt_rt4 TO rt_return.

      SORT rt_return.
      DELETE ADJACENT DUPLICATES FROM rt_return COMPARING ALL FIELDS.

    ENDIF.

  ENDMETHOD.


  METHOD define_lgort.

    DATA: ls_vbap TYPE vbapvb.

    ASSIGN gs_params-t_xvbap[
      lgort = c_lgort_1250
    ]-lgort TO FIELD-SYMBOL(<lv_lgort>).

    IF <lv_lgort> IS ASSIGNED.
      ev_lgort = <lv_lgort>.
    ELSE.
      READ TABLE gs_params-t_xvbap INTO ls_vbap INDEX 2. "ilk satır palet.
      IF sy-subrc NE 0.
        READ TABLE gs_params-t_xvbap INTO ls_vbap INDEX 1. "YYK için.
        IF sy-subrc EQ 0.
          ev_lgort = ls_vbap-lgort.
        ELSE.
          APPEND VALUE #( msgty = 'E'
                          msgid = 'ZSD_VA'
                          msgno = '058'
                          msgv1 = '' ) TO rt_return.
          RETURN.
        ENDIF.
      ELSE.
        ev_lgort = ls_vbap-lgort.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
