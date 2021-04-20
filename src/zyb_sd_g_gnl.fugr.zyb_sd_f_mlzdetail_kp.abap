FUNCTION ZYB_SD_F_MLZDETAIL_KP.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PLT_TAM) TYPE  XFELD OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN_VA OPTIONAL
*"     VALUE(I_POSNR) TYPE  POSNR_VA OPTIONAL
*"     VALUE(I_MATNR) TYPE  MATNR OPTIONAL
*"     VALUE(I_MENGE) TYPE  MENGE_D OPTIONAL
*"     VALUE(I_MEINS) TYPE  MEINS OPTIONAL
*"     VALUE(I_DATUM) TYPE  SY-DATUM DEFAULT SY-DATUM
*"     VALUE(I_TIP) TYPE  CHAR20 OPTIONAL
*"     VALUE(I_PALET) TYPE  MVGR1
*"     VALUE(I_KUTU) TYPE  MVGR2
*"  EXPORTING
*"     REFERENCE(E_MLZ) TYPE  ZYB_SD_S_MLZDETAIL
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
*& yurtdışı siparişine ait ürünler için sipariş no ve kalem no olmalıdır
*"----------------------------------------------------------------------

  DATA:
    ls_md002 LIKE zyb_t_md001,
    ls_vbak  LIKE vbak,
    ls_vbap  LIKE vbap,
    ls_md001 LIKE zyb_sd_t_md001,
    ls_mara  LIKE mara, ht,
    lt_bom   LIKE TABLE OF stpox WITH HEADER LINE.

  FREE: gt_ret.

  IF i_vbeln IS NOT INITIAL AND i_posnr IS NOT INITIAL.
  ELSE.
    IF i_matnr IS INITIAL.
      PERFORM add_msg USING 'E'
                       'FB'
                       '334'
                       space
                       space
                       space
                       space.
      IF 1 = 2. MESSAGE e334(fb). ENDIF.
    ENDIF.
  ENDIF.
  CLEAR: ls_vbak, ls_vbap, ls_mara.
  IF NOT i_vbeln IS INITIAL AND NOT i_posnr IS INITIAL.

    SELECT SINGLE * FROM vbak
        INTO  ls_vbak
        WHERE vbeln EQ i_vbeln.

    SELECT SINGLE * FROM vbap
        INTO ls_vbap
        WHERE vbeln EQ i_vbeln
          AND posnr EQ i_posnr.

    IF sy-subrc = 0.
      e_mlz-vbeln   = ls_vbap-vbeln.
      e_mlz-posnr   = ls_vbap-posnr.
      e_mlz-matnr   = ls_vbap-matnr.
      e_mlz-palet   = ls_vbap-mvgr1.
      e_mlz-kutu    = ls_vbap-mvgr2.
      e_mlz-kutuetk = ls_vbap-mvgr3.
      e_mlz-karoalt = ls_vbap-mvgr4.
    ELSE.
      PERFORM add_msg USING 'E'
                       'SV'
                       '166'
                       i_vbeln
                       i_posnr
                       'sipariş kalemi'
                       space.

      IF 1 = 2. MESSAGE e166(sv). ENDIF.
    ENDIF.
  ELSE.
    e_mlz-matnr = i_matnr.
  ENDIF.

  SELECT SINGLE * FROM mara INTO ls_mara
      WHERE matnr EQ e_mlz-matnr.

  IF sy-subrc <> 0.
    PERFORM add_msg USING 'E'
                      'SV'
                      '166'
                      e_mlz-matnr
                      'malzeme kodu'
                      space
                      space.
    IF 1 = 2. MESSAGE e166(sv). ENDIF.
  ENDIF.

  IF ls_vbap IS INITIAL.
*    SELECT SINGLE * FROM zyb_sd_t_md001
*        INTO ls_md001
*       WHERE vtweg EQ gc_yurtici
*         AND kunnr EQ space
*         AND matnr EQ e_mlz-matnr.

    SELECT * UP TO 1 ROWS FROM zyb_sd_t_md001
        INTO ls_md001
       WHERE vtweg EQ gc_yurtici
         AND kunnr EQ space
         AND matnr EQ e_mlz-matnr
         AND MVGR1 EQ i_palet
         AND MVGR2 EQ I_KUTU
      ORDER BY MVGR2 DESCENDING.
    ENDSELECT.

    IF ls_md001 IS INITIAL.
      SELECT SINGLE * FROM zyb_sd_t_md001
          INTO ls_md001
         WHERE vtweg EQ gc_yurtici
           AND kunnr EQ space.
    ENDIF.

    IF i_tip NE 'HU'.
      IF ls_md001 IS INITIAL.
        PERFORM add_msg USING 'E'
                          'SV'
                          '029'
                          'ZYB_SD_T_MD001'
                          'tablosunda seçime uygun değer bulunamadı'
                          space
                          space.
        IF 1 = 2. MESSAGE e029(sv). ENDIF.
      ENDIF.
    ENDIF.

    e_mlz-palet   = ls_md001-mvgr1.
    e_mlz-kutu    = ls_md001-mvgr2.
    e_mlz-kutuetk = ls_md001-mvgr3.
    e_mlz-karoalt = ls_md001-mvgr4.
  ENDIF.

  IF i_tip NE 'HU'.
** giriş ölçü birimi kontrolü
    CLEAR gv_txt.
    CASE i_meins.
      WHEN gc_palet_olc.
        IF plt_tam IS INITIAL.
          gv_txt = 'Kutu ölçü birimi (KUT) girilebilir.'.
          PERFORM add_msg USING 'E'
                                'SV'
                                '48'
                                gv_txt
                                space
                                space
                                space.
          return[] = gt_ret[].
          EXIT.
        ENDIF.
      WHEN gc_kutu_olc.
        IF NOT plt_tam IS INITIAL.
          gv_txt = 'Palet ölçü birimi (PAL)'.
          PERFORM add_msg USING 'E'
                                'SV'
                                '48'
                                gv_txt
                                space
                                space
                                space.
          return[] = gt_ret[].
          EXIT.
        ENDIF.
      WHEN OTHERS.
        gv_txt =
        'Tam Palet için Palet ölçü birimi (PAL) Yarım Palet için Kutu ölçü bi' &
        'rimi (KUT) girilebilir.'
        .
        PERFORM add_msg USING 'E'
                              'SV'
                              '48'
                              gv_txt
                              space
                              space
                              space.
        return[] = gt_ret[].
        EXIT.
    ENDCASE.
  ENDIF.

** MVGR alanları tanımları
  SELECT SINGLE bezei FROM tvm1t
      INTO e_mlz-palet_txt
     WHERE mvgr1 EQ e_mlz-palet
       AND spras EQ sy-langu.

  SELECT SINGLE bezei FROM tvm2t
      INTO e_mlz-kutu_txt
     WHERE mvgr2 EQ e_mlz-kutu
       AND spras EQ sy-langu.

  SELECT SINGLE bezei FROM tvm3t
      INTO e_mlz-kutuetk_txt
     WHERE mvgr3 EQ e_mlz-kutuetk
       AND spras EQ sy-langu.

  SELECT SINGLE bezei FROM tvm4t
      INTO e_mlz-karoalt_txt
     WHERE mvgr4 EQ e_mlz-karoalt
       AND spras EQ sy-langu.


* Malzeme numaraları
* YYK lar için palet fantom yok ambalaj malzemesi var.

  IF NOT e_mlz-palet IS INITIAL.
    IF ls_mara-mtart EQ gc_mtart_yyk.
      SELECT SINGLE mvke~matnr FROM mvke
          INNER JOIN mara ON mara~matnr EQ mvke~matnr
              INTO e_mlz-palet_mat
             WHERE mvke~mvgr1 EQ e_mlz-palet
               AND mvke~vkorg EQ gc_sanayi
               AND mvke~vtweg EQ gc_diger
               AND mara~mtart EQ gc_mtart_amb
               AND mara~matkl EQ gc_matkl_plt.
    ELSE.
      SELECT mvke~matnr FROM mvke
              INNER JOIN mara ON mara~matnr EQ mvke~matnr
              INTO e_mlz-palet_mat
             WHERE mvke~mvgr1 EQ e_mlz-palet
               AND mvke~vkorg EQ gc_sanayi
               AND mvke~vtweg EQ gc_diger
  " yarımamül fantom malzemesi olduğu için kapatıldı
*             AND mara~mtart EQ gc_mtart_amb
               AND mara~mtart EQ gc_mtart_yrm
               AND mara~matkl EQ gc_matkl_plt.
        EXIT.

* Palet tipleri birden fazla fantom malzemeye atanmasına
* karar verildiğinden kaldırıldı

*    IF sy-tabix > 1.
*    PERFORM add_msg USING 'E'
*                          'SV'
*                          '166'
*                          ''
*                          'Palet tipi'
*                          'birden fazla malzemeye atanmıştır.'
*                           space.
*    CHECK 1 = 2.
*    ENDIF.
      ENDSELECT.
    ENDIF.

    IF e_mlz-palet_mat IS INITIAL.
      PERFORM add_msg USING 'E'
                       'SV'
                       '166'
                       e_mlz-palet
                       'palet kodu için'
                       'palet malzemesi'
                       space.
      IF 1 = 2. MESSAGE e166(sv). ENDIF.
    ENDIF.
  ENDIF.

  IF e_mlz-palet_mat IS NOT INITIAL AND
     ls_mara-mtart NE gc_mtart_yyk.
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        aumgb                 = 'X'
        capid                 = 'PP01'
        datuv                 = sy-datum
        ehndl                 = '1'
        emeng                 = 1
        mktls                 = 'X'
        mehrs                 = 'X'
        mmory                 = 'X'
        mtnrv                 = e_mlz-palet_mat
        stlan                 = '1'
        werks                 = '1000'
      TABLES
        stb                   = lt_bom
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.
    CLEAR : ht, e_mlz-palet_amb.
    LOOP AT lt_bom WHERE matmk = 'Y0301'.
      IF e_mlz-palet_amb IS NOT INITIAL.
        IF i_tip NE 'HU'.
          PERFORM add_msg USING 'E' 'ZYB_SD' '051'
                        e_mlz-palet_mat '' ''
                        space.
          IF 1 = 2. MESSAGE e051(zyb_sd). ENDIF.
          ht = 'X'.
          EXIT .
        ENDIF.
      ENDIF.
      e_mlz-palet_amb = lt_bom-idnrk.
      IF i_tip EQ 'HU'.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF sy-subrc NE 0.

      PERFORM add_msg USING 'E' 'ZYB_SD' '050'
                            e_mlz-palet_mat '' ''
                            space.
      IF 1 = 2. MESSAGE e050(zyb_sd). ENDIF.

    ENDIF.
  ELSEIF e_mlz-palet_mat IS NOT INITIAL AND
         ls_mara-mtart   EQ gc_mtart_yyk.
    e_mlz-palet_amb = e_mlz-palet_mat.
  ELSE.
    PERFORM add_msg USING 'E' 'ZYB_SD' '053'
                            e_mlz-palet_mat '' ''
                            space.
    IF 1 = 2. MESSAGE e053(zyb_sd). ENDIF.
  ENDIF.

  IF i_tip EQ 'HU'.
    return[] = gt_ret[].
    EXIT.
  ENDIF.

  IF NOT e_mlz-kutu IS INITIAL.
    IF ls_mara-mtart NE gc_mtart_yyk.
      SELECT SINGLE mvke~matnr FROM mvke
              INNER JOIN mara ON mara~matnr EQ mvke~matnr
              INTO e_mlz-kutu_mat
             WHERE mvke~mvgr2 EQ e_mlz-kutu
               AND mvke~vkorg EQ gc_sanayi
               AND mvke~vtweg EQ gc_diger
  " yarımamül fantom malzemesi olduğu için kapatıldı
*             AND mara~mtart EQ gc_mtart_amb
               AND mara~mtart EQ gc_mtart_yrm
               AND mara~matkl EQ gc_matkl_kut.
    ELSE.
      SELECT SINGLE mvke~matnr FROM mvke
              INNER JOIN mara ON mara~matnr EQ mvke~matnr
              INTO e_mlz-kutu_mat
             WHERE mvke~mvgr2 EQ e_mlz-kutu
               AND mvke~vkorg EQ gc_sanayi
               AND mvke~vtweg EQ gc_diger
               AND mara~mtart EQ gc_mtart_amb
*             AND mara~mtart EQ gc_mtart_yrm
               AND mara~matkl EQ gc_matkl_trb.
    ENDIF.

    IF e_mlz-kutu_mat IS INITIAL.
      PERFORM add_msg USING 'E'
                         'SV'
                         '166'
                         e_mlz-kutu
                         'kutu kodu için'
                         'kutu malzemesi'
                         space.
      IF 1 = 2. MESSAGE e166(sv). ENDIF.
    ENDIF.
  ENDIF.

  IF NOT e_mlz-kutuetk IS INITIAL.
    SELECT SINGLE mvke~matnr FROM mvke
            INNER JOIN mara ON mara~matnr EQ mvke~matnr
            INTO e_mlz-kutuetk_mat
           WHERE mvke~mvgr3 EQ e_mlz-kutuetk
             AND mvke~vkorg EQ gc_sanayi
             AND mvke~vtweg EQ gc_diger
             AND mara~mtart EQ gc_mtart_amb.
    " ambalaj malzemesi olduğu için kapatıldı
*             AND mara~mtart EQ gc_mtart_yrm.

    IF e_mlz-kutuetk_mat IS INITIAL.
      PERFORM add_msg USING 'E'
                         'SV'
                         '166'
                         e_mlz-kutuetk
                         'kutu etiketi kodu için'
                         'kutu etiketi malzemesi'
                         space.
      IF 1 = 2. MESSAGE e166(sv). ENDIF.
    ENDIF.
  ENDIF.

* Ölçü Dönüşümleri
  IF NOT e_mlz-matnr IS INITIAL AND NOT e_mlz-palet IS INITIAL AND
     NOT e_mlz-kutu IS INITIAL.

    IF NOT plt_tam IS INITIAL.
* palet miktarı
      PERFORM convert_menge USING e_mlz-matnr
                                  e_mlz-palet
                                  e_mlz-kutu
                                  i_menge
                                  gc_palet_olc
                        CHANGING  e_mlz-palet_mik
                                  e_mlz-palet_olc.

* kutu miktarı
      SELECT SINGLE * FROM zyb_t_md001 INTO ls_md002
              WHERE bkmtp = 'PAL'
                AND matnr = e_mlz-matnr
                AND mvgr1 = e_mlz-palet
                AND mvgr2 = e_mlz-kutu
                AND begda <= i_datum
                AND endda >= i_datum.

      IF sy-subrc = 0.
        e_mlz-kutu_mik = i_menge * ( ls_md002-umrez / ls_md002-umren ).
        e_mlz-kutu_olc = 'ST'.

      ELSE.
        PERFORM add_msg USING 'E'
                           'SV'
                           '029'
                           'ZYB_T_MD001'
                           'tablosunda seçime uygun'
                           'kutu miktarı bulunamadı!'
                           space.
        IF 1 = 2. MESSAGE e029(sv). ENDIF.
      ENDIF.
      e_mlz-kutuetk_mik = e_mlz-kutu_mik.
      e_mlz-kutuetk_olc = e_mlz-kutu_olc.
    ELSE.

      PERFORM convert_menge USING e_mlz-matnr
                                  space
                                  e_mlz-kutu
                                  i_menge
                                  gc_kutu_olc
                        CHANGING  e_mlz-kutu_mik
                                  e_mlz-kutu_olc.

      e_mlz-kutuetk_mik = i_menge.
      e_mlz-kutuetk_olc = i_meins.
      e_mlz-palet_mik   = 1.
      e_mlz-palet_olc   = 'PAL'.
    ENDIF.
  ENDIF.

  IF NOT e_mlz-matnr IS INITIAL.
    PERFORM conversion_exit_alpha_input CHANGING e_mlz-matnr.
  ENDIF.
  IF NOT e_mlz-palet_mat IS INITIAL.
    PERFORM conversion_exit_alpha_input CHANGING e_mlz-palet_mat.
  ENDIF.
  IF NOT e_mlz-kutu_mat IS INITIAL.
    PERFORM conversion_exit_alpha_input CHANGING e_mlz-kutu_mat.
  ENDIF.
  IF NOT e_mlz-kutuetk_mat IS INITIAL.
    PERFORM conversion_exit_alpha_input CHANGING e_mlz-kutuetk_mat.
  ENDIF.
  return[] = gt_ret[].
ENDFUNCTION.
