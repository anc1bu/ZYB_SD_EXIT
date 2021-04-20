class ZCL_IM_LE_SHP_DELIVERY_PRO definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_LE_SHP_DELIVERY_PRO IMPLEMENTATION.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~change_field_attributes.
    DATA: ls_screen TYPE shp_screen_attributes.
    FIELD-SYMBOLS: <ls_vbuk>   TYPE vbukvb.
    FREE: ct_field_attributes.

    IF if_trtyp EQ 'V'." Değiştir
      IF if_panel EQ 'HADM'. " Başlık - Yönetim.
        READ TABLE it_xvbuk ASSIGNING  <ls_vbuk> WITH KEY vbeln = is_likp-vbeln
                                                          wbstk = 'C'.
        IF sy-subrc EQ 0.
          CLEAR ls_screen.
          ls_screen-name  = 'LIKP-LIFEX'.
          ls_screen-input = 1.
          APPEND ls_screen TO ct_field_attributes.
        ENDIF.
      ENDIF.

*      READ TABLE it_xvbuk ASSIGNING  <ls_vbuk> WITH KEY vbeln = is_likp-vbeln
*                                                        pkstk = 'C'.
*      IF sy-subrc = 0.
*        READ TABLE it_xvbuk ASSIGNING  <ls_vbuk> WITH KEY vbeln = is_likp-vbeln
*                                                        wbstk = 'C'.
*        IF sy-subrc <> 0.
*          CLEAR ls_screen.
*          ls_screen-name  = 'LIKP-ANZPK'. " Ambalaj Sayısı
*          ls_screen-input = 1.
*          APPEND ls_screen TO ct_field_attributes.
*        ENDIF.
*      ENDIF.
    ENDIF.
  ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION.
  FIELD-SYMBOLS:
      <ls_xvbup> TYPE VBUPVB.
  data: ls_log type shp_badi_error_log.

  CLEAR ls_log.

  READ TABLE it_xvbup ASSIGNING <ls_xvbup> WITH KEY vbeln = is_xlips-vbeln
                                                    posnr = is_xlips-posnr.
  IF sy-subrc = 0.
   IF <ls_xvbup>-kosta EQ 'B' OR <ls_xvbup>-kosta EQ 'C'.
    cf_item_not_deletable = 'X'.

    ls_log-msgid = 'ZSD_VL'.
    ls_log-msgno = '002'.
    ls_log-msgty = 'E'.
    ls_log-msgv1 = is_xlips-vbeln.
    ls_log-msgv2 = is_xlips-posnr.
    ls_log-msgv3 = is_xlips-matnr.
    append ls_log to ct_log.
    IF 1 = 2. MESSAGE e002(zsd_vl). ENDIF.
   ENDIF.
  ENDIF.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION.
  break bbozaci.

    CALL FUNCTION 'ZYB_SD_F_VL_DEL'
      EXPORTING
        i_likp        = is_likp.
  endmethod.


METHOD if_ex_le_shp_delivery_proc~delivery_final_check.
  DATA:
    ls_finchdel  TYPE finchdel,
    ls_shp01     TYPE zyb_sd_t_shp01,
    ls_vttk      TYPE vttk,
    lv_datum(10) TYPE c.

  FIELD-SYMBOLS: <ls_xlikp> TYPE likpvb,
                 <ls_xlips> TYPE lipsvb,
                 <ls_xvbuk> TYPE vbukvb,
                 <ls_xvbfa> TYPE vbfavb.

  CLEAR: ls_finchdel.
  "--------->> Anıl CENGİZ 27.01.2020 14:11:28
  "YUR-578
  "Mali Belge kontrolü tamam değilse her türlü hataya düşmesi için yıldızlandı.
*    IF if_trtyp EQ 'H'. " Yaratma
  "---------<<
  LOOP AT it_xvbuk ASSIGNING <ls_xvbuk> WHERE updkz NE 'D'
                                          AND cmpsi EQ 'B'. "Mali Belge kontrolü yürütüldü, işlem tamam değil
    "--------->> Anıl CENGİZ 22.03.2021 16:04:32
    "YUR-873
    ASSIGN it_xlips[ vbeln = <ls_xvbuk>-vbeln ] TO FIELD-SYMBOL(<is_xlips>).
    "---------<<
    "--------->> Anıl CENGİZ 06.10.2020 23:04:03
    "YUR-744
*    READ TABLE it_xlikp ASSIGNING <ls_xlikp> WITH KEY vbeln = <ls_xvbuk>-vbeln.
    "---------<<
    CLEAR ls_finchdel.
    ls_finchdel-vbeln    = <ls_xvbuk>-vbeln.
    ls_finchdel-pruefung = '99'.
    ls_finchdel-msgty    = 'E'.
    ls_finchdel-msgid    = 'ZSD'.
    ls_finchdel-msgno    = '078'.
    ls_finchdel-msgv1    = <ls_xvbuk>-vbeln.
    ls_finchdel-msgv2    = <is_xlips>-vgbel.
    INSERT ls_finchdel INTO TABLE ct_finchdel.
  ENDLOOP.
*    ENDIF.

* Mal çıkışı yapılan teslimatların çekilen partilerin
* başka teslimatların planlanan partilerinde olmaması gerekli
  IF is_v50agl-warenausgang EQ 'X'.
    LOOP AT it_xlikp ASSIGNING <ls_xlikp> WHERE updkz NE 'D'.
      CLEAR: ls_finchdel.

* mal çıkışı ancak günün tarihi olabilir.  İhracat için yıldızlandı.
*        IF <ls_xlikp>-wadat_ist NE sy-datum AND sy-uname NE 'XACENGIZ'.
*          CLEAR: ls_finchdel.
*          ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
*          ls_finchdel-pruefung = '99'.
*          ls_finchdel-msgty    = 'E'.
*          ls_finchdel-msgid    = 'ZSD_VL'.
*          ls_finchdel-msgno    = '008'.
*
*          CLEAR lv_datum.
*          CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*            EXPORTING
*              date_internal = <ls_xlikp>-wadat_ist
*            IMPORTING
*              date_external = lv_datum.
*
*          ls_finchdel-msgv1    = lv_datum.
*          INSERT ls_finchdel INTO TABLE ct_finchdel.
*          IF 1 = 2. MESSAGE e008(zsd_vl). ENDIF.
*        ENDIF.


* Taşıma birimi yapılmadan mal çıkışı yapılamaz. (ZT99 çıktısı)

      DATA: lv_paketleme TYPE c.

      IF <ls_xlikp>-lfart EQ 'ZT01' OR <ls_xlikp>-lfart EQ 'ZT02' OR
         <ls_xlikp>-lfart EQ 'ZT05'.
        LOOP AT it_xlips ASSIGNING <ls_xlips> WHERE vbeln EQ <ls_xlikp>-vbeln
                                               AND ( pstyv EQ 'Z025' OR
                                                     pstyv EQ 'Z027').
          EXIT.
        ENDLOOP.
        IF sy-subrc <> 0.
          lv_paketleme = 'X'.
        ENDIF.
      ENDIF.

      READ TABLE it_xvbuk ASSIGNING <ls_xvbuk> WITH KEY vbeln = <ls_xlikp>-vbeln.
      IF sy-subrc = 0.
        IF <ls_xvbuk>-pkstk NE 'C' AND
           lv_paketleme     EQ 'X'.

          CLEAR: ls_finchdel.
          ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
          ls_finchdel-pruefung = '99'.
          ls_finchdel-msgty    = 'E'.
          ls_finchdel-msgid    = 'ZSD_VL'.
          ls_finchdel-msgno    = '004'.
          ls_finchdel-msgv1    = <ls_xlikp>-vbeln.
          INSERT ls_finchdel INTO TABLE ct_finchdel.
          IF 1 = 2. MESSAGE e004(zsd_vl). ENDIF.
        ENDIF.
      ENDIF.

      LOOP AT it_xvbfa ASSIGNING <ls_xvbfa> WHERE vbelv EQ <ls_xlikp>-vbeln
                                              AND posnv EQ '000000'
                                              AND vbtyp_n EQ '8'. " Nakliye
        CLEAR ls_vttk.
        SELECT SINGLE * FROM vttk
              INTO ls_vttk
             WHERE tknum EQ <ls_xvbfa>-vbeln.

        IF ( ls_vttk-shtyp EQ 'Z002' OR ls_vttk-shtyp EQ 'Z003' ) AND
           ( ls_vttk-vsart EQ '01' OR ls_vttk-vsart EQ '05'     ) AND " kamyon kendi kamyonu
           ls_vttk-/bev1/rpmowa IS INITIAL.

          CLEAR ls_finchdel.
          ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
          ls_finchdel-pruefung = '99'.
          ls_finchdel-msgty    = 'E'.
          ls_finchdel-msgid    = 'ZSD_VL'.
          ls_finchdel-msgno    = '005'.
          ls_finchdel-msgv1    = ls_vttk-tknum.
          ls_finchdel-msgv2    = <ls_xlikp>-vbeln.
          INSERT ls_finchdel INTO TABLE ct_finchdel.
          IF 1 = 2. MESSAGE e005(zsd_vl). ENDIF.

        ENDIF.
      ENDLOOP.
* Nakliye ilişkili teslimatlarda mal çıkışı için plaka zorunlu
      IF sy-subrc <> 0 AND <ls_xvbuk>-trsta NE space.
        CLEAR ls_finchdel.
        ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
        ls_finchdel-pruefung = '99'.
        ls_finchdel-msgty    = 'E'.
        ls_finchdel-msgid    = 'ZSD_VL'.
        ls_finchdel-msgno    = '005'.
        ls_finchdel-msgv1    = ls_vttk-tknum.
        ls_finchdel-msgv2    = <ls_xlikp>-vbeln.
        INSERT ls_finchdel INTO TABLE ct_finchdel.
        IF 1 = 2. MESSAGE e005(zsd_vl). ENDIF.
      ENDIF.

      LOOP AT it_xlips ASSIGNING <ls_xlips>
               WHERE vbeln EQ <ls_xlikp>-vbeln
                 AND updkz NE 'D'.
        CLEAR: ls_shp01, ls_finchdel.
        IF NOT <ls_xlips>-charg IS INITIAL.
          SELECT SINGLE * FROM zyb_sd_t_shp01
              INTO ls_shp01
             WHERE vbeln       NE <ls_xlips>-vbeln
               AND charg       EQ <ls_xlips>-charg
               AND charg_fiili EQ space.

          IF NOT ls_shp01 IS INITIAL.
            CLEAR: ls_finchdel.
            ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
            ls_finchdel-pruefung = '99'.
            ls_finchdel-msgty    = 'E'.
            ls_finchdel-msgid    = 'ZSD_VL'.
            ls_finchdel-msgno    = '003'.
            ls_finchdel-msgv1    = <ls_xlips>-charg.
            ls_finchdel-msgv2    = ls_shp01-vbeln.
            ls_finchdel-msgv3    = ls_shp01-posnr.
            INSERT ls_finchdel INTO TABLE ct_finchdel.
            IF 1 = 2. MESSAGE e003(zsd_vl). ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~fill_delivery_header.
  ENDMETHOD.


  METHOD if_ex_le_shp_delivery_proc~fill_delivery_item.
    FIELD-SYMBOLS:
      <ls_xlips> TYPE lipsvb.

** Üst kalemden konteyner bilgilerinin alt kaleme taşınması
    IF NOT cs_lips-uecha IS INITIAL.
      READ TABLE it_xlips ASSIGNING <ls_xlips>
                          WITH KEY vbeln = cs_lips-vbeln
                                   posnr = cs_lips-uecha.
      IF sy-subrc = 0.
        cs_lips-zzknttnt = <ls_xlips>-zzknttnt.
        cs_lips-zzkontno = <ls_xlips>-zzkontno.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~item_deletion.
    break bbozaci.
    CALL FUNCTION 'ZYB_SD_F_VL_DEL'
      EXPORTING
        i_likp        = is_likp
       I_LIPS        = is_xlips.
  ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY.
  endmethod.


  method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
  endmethod.


  METHOD if_ex_le_shp_delivery_proc~save_and_publish_document.
    TYPES: BEGIN OF ty_charg ,
             vbeln TYPE vbeln_vl,
             charg TYPE charg_d,
           END OF ty_charg.
    DATA:
      lt_charg TYPE STANDARD TABLE OF ty_charg,
      ls_charg TYPE ty_charg.

    DATA:
      lt_shp01 TYPE TABLE OF zyb_sd_t_shp01,
      ls_shp01 TYPE  zyb_sd_t_shp01,
      lt_shp03 TYPE TABLE OF zyb_sd_t_shp03,
      ls_shp03 TYPE  zyb_sd_t_shp03,
      ls_shp04 TYPE  zyb_sd_t_shp04,
      lv_auart TYPE auart.

    DATA: ls_tabfield TYPE tabfield.

    FIELD-SYMBOLS:
      <ls_xvbuk> TYPE vbukvb,
      <ls_xvbup> TYPE vbupvb,
      <ls_yvbup> TYPE vbupvb,
      <ls_xlikp> TYPE likpvb,
      <ls_xlips> TYPE lipsvb,
      <ls_vbfs>  TYPE vbfs.

** Mal Çıkışı yapıldığında toplama palet ile ilgili bilgiler SHP03 tablosuna koyulur.

    IF is_v50agl-warenausgang EQ 'X' OR   " Mal Çıkışı Etkin.
       is_v50agl-warenausg_storno EQ 'X'. " Mal Çıkışı Ters Kaydı Etkin

      LOOP AT it_xlikp ASSIGNING <ls_xlikp> WHERE updkz NE 'D'.
        FREE: lt_shp03.
        LOOP AT it_vbfs INTO <ls_vbfs>
                        WHERE vbeln EQ <ls_xlikp>-vbeln
                          AND msgty CA 'EAX'.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        IF is_v50agl-warenausgang EQ 'X'. " Mal Çıkışı Etkin.
          LOOP AT it_xlips ASSIGNING <ls_xlips>
                               WHERE vbeln EQ <ls_xlikp>-vbeln
                                 AND charg NE space
                                 AND updkz NE 'D'.
            CLEAR lv_auart.
            SELECT SINGLE auart FROM vbak
                  INTO lv_auart
                 WHERE vbeln EQ <ls_xlips>-vgbel.
            SELECT COUNT(*) FROM tvak
                 WHERE auart EQ lv_auart
                   AND kalvg EQ '5'. " Toplama palet

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            CLEAR ls_shp03.
            ls_shp03-vbeln = <ls_xlips>-vbeln.
            IF NOT <ls_xlips>-uecha IS INITIAL.
              ls_shp03-uecha = <ls_xlips>-uecha.
              ls_shp03-posnr = <ls_xlips>-posnr.
            ELSE.
              ls_shp03-uecha = <ls_xlips>-posnr.
            ENDIF.
            ls_shp03-charg  = <ls_xlips>-charg.
            ls_shp03-lfimg  = <ls_xlips>-lfimg.
            ls_shp03-vrkme  = <ls_xlips>-vrkme.
            ls_shp03-kontno = <ls_xlips>-zzkontno.

            CLEAR ls_tabfield.
            ls_tabfield-tabname   = 'ZYB_SD_T_SHP03'.
            ls_tabfield-fieldname = 'KONT_SIRASI'.

            CALL FUNCTION 'RS_CONV_EX_2_IN'
              EXPORTING
                input_external               = <ls_xlips>-zzkontno
                table_field                  = ls_tabfield
              IMPORTING
                output_internal              = ls_shp03-kont_sirasi
              EXCEPTIONS
                input_not_numerical          = 1
                too_many_decimals            = 2
                more_than_one_sign           = 3
                ill_thousand_separator_dist  = 4
                too_many_digits              = 5
                sign_for_unsigned            = 6
                too_large                    = 7
                too_small                    = 8
                invalid_date_format          = 9
                invalid_date                 = 10
                invalid_time_format          = 11
                invalid_time                 = 12
                invalid_hex_digit            = 13
                unexpected_error             = 14
                invalid_fieldname            = 15
                field_and_descr_incompatible = 16
                input_too_long               = 17
                no_decimals                  = 18
                invalid_float                = 19
                conversion_exit_error        = 20
                OTHERS                       = 21.

            APPEND ls_shp03 TO lt_shp03.

          ENDLOOP.

          IF NOT lt_shp03[] IS INITIAL.
            MODIFY zyb_sd_t_shp03 FROM TABLE lt_shp03.
          ENDIF.

          READ TABLE it_xvbuk ASSIGNING <ls_xvbuk>
                               WITH KEY vbeln = <ls_xlikp>-vbeln.
          IF sy-subrc = 0.
            IF <ls_xvbuk>-trsta NE space. " Nakliye ilişkili
              LOOP AT it_xlips ASSIGNING <ls_xlips>
                                   WHERE vbeln EQ <ls_xlikp>-vbeln
                                     AND vtweg NE '20'. " İhracat hariç
                EXIT.
              ENDLOOP.
              IF sy-subrc = 0.
                CLEAR ls_shp04.
                ls_shp04-shp_number = <ls_xlikp>-vbeln.
                ls_shp04-nakftdrm   = 'A'.
                MODIFY zyb_sd_t_shp04 FROM ls_shp04.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        " Mal Çıkışı Ters Kaydı Etkin
        IF is_v50agl-warenausg_storno EQ 'X'.
          DELETE FROM zyb_sd_t_shp03 WHERE vbeln EQ <ls_xlikp>-vbeln.

          SELECT COUNT(*) FROM zyb_sd_t_shp04
               WHERE shp_number EQ <ls_xlikp>-vbeln
                 AND nakftdrm  EQ 'A'.
          IF sy-subrc = 0.
            DELETE FROM zyb_sd_t_shp04
                  WHERE shp_number EQ <ls_xlikp>-vbeln.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

** Geri depolama yapıldığında ZYB_SD_T_SHP01 tablosundaki fiili parti silinir.
*** el terminali ile geri depolama yapılacağı için işlem kodu kontrolü konuldu.
    CHECK sy-tcode EQ 'LT0G'.
    FREE: lt_charg.
    LOOP AT it_xvbup ASSIGNING <ls_xvbup> WHERE updkz EQ 'U'.
      CLEAR ls_charg.
      READ TABLE it_yvbup ASSIGNING <ls_yvbup>
                           WITH KEY vbeln = <ls_xvbup>-vbeln
                                    posnr = <ls_xvbup>-posnr.
      IF sy-subrc EQ 0.
        IF  <ls_xvbup>-kosta EQ 'A' AND ( <ls_yvbup>-kosta EQ 'C' OR
                                          <ls_yvbup>-kosta EQ 'B' ).
          READ TABLE it_xlips ASSIGNING <ls_xlips>
                                WITH KEY vbeln = <ls_xvbup>-vbeln
                                         posnr = <ls_xvbup>-posnr.
          IF sy-subrc = 0.
            ls_charg-vbeln = <ls_xlips>-vbeln.
            ls_charg-charg = <ls_xlips>-charg.
            APPEND  ls_charg TO lt_charg.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CHECK NOT lt_charg[] IS INITIAL.

    FREE: lt_shp01.
    SELECT * FROM zyb_sd_t_shp01
       INTO TABLE lt_shp01
       FOR ALL ENTRIES IN lt_charg
            WHERE vbeln       EQ lt_charg-vbeln
              AND charg_fiili EQ lt_charg-charg.

    LOOP AT lt_shp01 INTO ls_shp01.
      CLEAR: ls_shp01-ok , ls_shp01-charg_fiili.
      MODIFY lt_shp01 FROM ls_shp01 TRANSPORTING ok charg_fiili.
    ENDLOOP.

    IF NOT lt_shp01[] IS INITIAL.
      MODIFY zyb_sd_t_shp01 FROM TABLE lt_shp01.
    ENDIF.
  ENDMETHOD.


  method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE.
    INCLUDE ZYB_SD_I_SAVE_DOCUMENT_PREPARE.
  endmethod.
ENDCLASS.
