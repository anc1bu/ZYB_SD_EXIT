CLASS zcl_sd_sevk_irsaliye_cikti DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "--------->>Anıl CENGİZ 23.01.2020 09:01:00
    "YUR-769
    TYPES: BEGIN OF ty_zmsmtp,
             smtp TYPE ad_smtpadr,
           END OF ty_zmsmtp,
           tt_zmsmtp TYPE TABLE OF ty_zmsmtp WITH DEFAULT KEY.
    "---------<<
    TYPES:
      BEGIN OF ty_mail,
        kunag       TYPE kunnr,
        kunwe       TYPE kunnr,
        hkunnr      TYPE hkunnr_kh,
        smtp_addr   TYPE ad_smtpadr,
        smtp_sender TYPE ad_smtpadr,
      END OF ty_mail .
    TYPES:
      tt_mail TYPE TABLE OF ty_mail .
    TYPES:
      BEGIN OF ty_delvry,
        kunag    TYPE kunnr,
        kunwe    TYPE kunnr,
        hkunnr   TYPE hkunnr_kh,
        land1_ag TYPE land1,
        land1_we TYPE land1,
        land1_hk TYPE land1,
        adrnr_ag TYPE adrnr,
        adrnr_we TYPE adrnr,
        adrnr_hk TYPE adrnr,
        ernam    TYPE ernam,
        "--------->>Anıl CENGİZ 23.59.2020 08:59:48
        "YUR-769
        zm_smtp  TYPE tt_zmsmtp,
        "---------<<
      END OF ty_delvry .

    CLASS zcl_sd_irsaliye_ciktisi DEFINITION LOAD .
    METHODS constructor
      IMPORTING
        !is_nast TYPE zcl_sd_irsaliye_ciktisi=>ty_nast
      RAISING
        zcx_sd_sevk_irsaliye_cikti .
    METHODS send_mail_delivery
      RAISING
        zcx_sd_sevk_irsaliye_cikti .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS cv_sevk_irs TYPE na_kschl VALUE 'ZL01'.       "#EC NOTEXT
    CONSTANTS cv_sevk_irs_pdf TYPE na_kschl VALUE 'ZL04'.   "#EC NOTEXT
    DATA gt_mail TYPE tt_mail .
    DATA gs_irs_cikti TYPE zsds_irs_cikti .
    DATA gs_delvry TYPE ty_delvry .

    METHODS send_mail
      RAISING
        zcx_bc_mail_send .
    METHODS set_mail_address .
    METHODS set_mail_address_soldto .
    METHODS set_mail_address_shipto .
    METHODS set_mail_address_custhiear .
    METHODS set_mailadress_socreater .
    METHODS set_mail_address_hierch .
    METHODS set_mailadress_partnerzm.
ENDCLASS.



CLASS zcl_sd_sevk_irsaliye_cikti IMPLEMENTATION.


  METHOD constructor.

    "Kontroller ve çıktı bilgilerinin dolması için çağrılır.
    TRY .
        gs_irs_cikti = NEW zcl_sd_irsaliye_ciktisi( CORRESPONDING #( is_nast ) )->get_output_data( ).
      CATCH zcx_sd_irsaliye_ciktisi INTO DATA(lx_sd_irsaliye_ciktisi).
        RAISE EXCEPTION TYPE zcx_sd_sevk_irsaliye_cikti
          EXPORTING
            messages = lx_sd_irsaliye_ciktisi->messages.
    ENDTRY.


    "Teslimat bilgilerinin müşteri hiyearşisine göre çekilmesi
    SELECT SINGLE likp~kunnr AS kunwe
                  likp~kunag
                  knvh~hkunnr
                  kna1~land1 AS land1_ag
                  kna1~adrnr AS adrnr_ag
                  vbak~ernam
      FROM likp
      INNER JOIN lips ON lips~vbeln = likp~vbeln
      INNER JOIN vbap ON lips~vgbel = vbap~vbeln
                     AND lips~vgpos = vbap~posnr
      INNER JOIN vbak ON vbap~vbeln = vbak~vbeln
      INNER JOIN knvh ON likp~kunag = knvh~kunnr
      INNER JOIN kna1 ON likp~kunag = kna1~kunnr
      INTO CORRESPONDING FIELDS OF gs_delvry
      WHERE likp~vbeln EQ is_nast-objky
        AND knvh~hityp EQ 'A'
        AND hkunnr EQ '0000200199'. "Sadece ALES in yurtiçi müşterileri için mail gönderilir.
    IF sy-subrc EQ 0.
      SELECT SINGLE adrnr AS adrnr_hk
                    land1 AS land1_hk
        FROM kna1
        INTO CORRESPONDING FIELDS OF gs_delvry
        WHERE kunnr EQ '0000200199'.
    ELSE.
      "Teslimat bilgilerinin sipariş verene göre göre çekilmesi
      SELECT SINGLE likp~kunnr AS kunwe
                    likp~kunag
                    kna1~adrnr AS adrnr_ag
                    kna1~land1 AS land1_ag
                    vbak~ernam
        FROM likp
        INNER JOIN lips ON lips~vbeln = likp~vbeln
        INNER JOIN vbap ON lips~vgbel = vbap~vbeln
                       AND lips~vgpos = vbap~posnr
        INNER JOIN vbak ON vbap~vbeln = vbak~vbeln
        INNER JOIN kna1 ON likp~kunag = kna1~kunnr
        INTO CORRESPONDING FIELDS OF gs_delvry
        WHERE likp~vbeln EQ is_nast-objky.
    ENDIF.
    "Teslimat bilgilerinin malı teslim alana göre çekilmesi
    SELECT SINGLE kna1~adrnr AS adrnr_we
                  kna1~land1 AS land1_we
      FROM likp
      INNER JOIN kna1 ON likp~kunnr = kna1~kunnr
      INTO CORRESPONDING FIELDS OF gs_delvry
      WHERE likp~vbeln EQ is_nast-objky.


*"--------->>Anıl CENGİZ 23.04.2020 09:04:13
*"YUR-769
*"Sipariş üzerindeki ZM muhattabının doldurulması.
    SELECT DISTINCT adr6~smtp_addr
      FROM likp
      INNER JOIN lips ON lips~vbeln = likp~vbeln
      INNER JOIN vbpa ON lips~vgbel = vbpa~vbeln
                     AND vbpa~posnr EQ 000000
                     AND vbpa~parvw EQ 'ZM'
      INNER JOIN pa0105 ON pa0105~pernr = vbpa~pernr
                       AND pa0105~subty = '0001'
      INNER JOIN usr21 ON usr21~bname = pa0105~usrid
      INNER JOIN adr6 ON adr6~persnumber = usr21~persnumber
                     AND adr6~addrnumber = usr21~addrnumber
      INTO TABLE gs_delvry-zm_smtp
      WHERE likp~vbeln EQ is_nast-objky.
*"---------<<

  ENDMETHOD.


  METHOD send_mail.
    DATA: job_output_info       TYPE ssfcrescl,
          otf_data              TYPE tsfotf,
          ls_control_parameters TYPE ssfctrlop,
          ls_output_options     TYPE ssfcompop,
          pv_pdf_data           TYPE xstring,
          pv_pdf_size           TYPE i,
          pt_pdf_lines          TYPE STANDARD TABLE OF tline,
          pt_tab                TYPE STANDARD TABLE OF lxe_xtab,
          pv_status             TYPE char1,
          lv_formname           TYPE rs38l_fnam,
          v_language            TYPE sflangu VALUE 'E',
          v_e_devtype           TYPE rspoptype,
          lv_sender_address     TYPE so_rec_ext.

    CLEAR: pv_pdf_data, lv_formname,ls_control_parameters, ls_output_options, pv_pdf_size.

    REFRESH: pt_pdf_lines[], pt_tab[].

    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        i_language    = v_language
        i_application = 'SAPDEFAULT'
      IMPORTING
        e_devtype     = v_e_devtype.

    ls_output_options-tdprinter     = v_e_devtype.
    ls_control_parameters-langu     = sy-langu.
    ls_control_parameters-no_dialog = abap_true.
    ls_control_parameters-getotf    = abap_true.
    ls_output_options-xdfcmode      = abap_true.
    ls_output_options-xsfcmode      = abap_true.
    ls_output_options-tdimmed       = abap_true.
    ls_output_options-tdnewid       = abap_true.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZYB_SD_IRSALIYE_MAIL_NEW' "tnapr-sform
      IMPORTING
        fm_name            = lv_formname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CALL FUNCTION lv_formname
      EXPORTING
        is_irs_cikti       = gs_irs_cikti
        control_parameters = ls_control_parameters
        output_options     = ls_output_options
      IMPORTING
        job_output_info    = job_output_info
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
        max_linewidth         = 132
      IMPORTING
        bin_filesize          = pv_pdf_size
        bin_file              = pv_pdf_data
      TABLES
        otf                   = job_output_info-otfdata[]
        lines                 = pt_pdf_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'LXE_COMMON_XSTRING_TO_TABLE'
      EXPORTING
        in_xstring = pv_pdf_data
      IMPORTING
        pstatus    = pv_status
      TABLES
        ex_tab     = pt_tab.

    IF pv_status EQ 'S'.

      LOOP AT gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>)
        WHERE smtp_sender IS NOT INITIAL.
        lv_sender_address = <gs_mail>-smtp_sender.
      ENDLOOP.

      LOOP AT gt_mail ASSIGNING <gs_mail>
        WHERE smtp_addr IS NOT INITIAL.

        zcl_bc_mail_send=>send_attachment( is_params = VALUE #( iv_subject    = |Yurtbay Seramik-{ gs_irs_cikti-ust_sag-belge_no }_İrsaliye Bilgileri|
                                                                is_sender     = VALUE #( email = lv_sender_address )
                                                                is_recipient  = VALUE #( email = <gs_mail>-smtp_addr )
                                                                it_body       = VALUE #( ( |Değerli İş Ortağımız,| )
                                                                                         ( || )
                                                                                         ( |Siparişiniz olan ürünlerin yükleme irsaliye bilgisi ektedir.| )
                                                                                         ( || )
                                                                                         ( |Saygılarımızla| )
                                                                                         ( || ) )
                                                                iv_commit     = SWITCH #( sy-tcode WHEN 'VL71'  THEN abap_true
                                                                                                   WHEN 'VL03N' THEN abap_true
                                                                                                   WHEN 'VL02N' THEN abap_true ) )
                                            it_attach = VALUE #( ( att_type     = 'PDF'
                                                                   att_subject  = |{ gs_irs_cikti-ust_sag-belge_no }_Irsaliye_Bilgisi.pdf|
                                                                   att_content  = VALUE #( FOR wa IN pt_tab ( line = wa-text ) ) ) ) ).

        WRITE / | { <gs_mail>-smtp_addr } adresine mail gönderilmiştir!|.
      ENDLOOP.
      "---------<<
    ENDIF.

  ENDMETHOD.


  METHOD send_mail_delivery.

    set_mail_address( ).

    TRY .
        send_mail( ).
      CATCH zcx_bc_mail_send INTO DATA(lx_bc_mail_send).
        RAISE EXCEPTION TYPE zcx_sd_sevk_irsaliye_cikti
          EXPORTING
            messages = lx_bc_mail_send->messages.
    ENDTRY.

  ENDMETHOD.


  METHOD set_mailadress_socreater.

    DATA: lt_mail TYPE tt_mail.

    SELECT smtp_addr
      FROM adr6
      INNER JOIN usr21 ON adr6~addrnumber = usr21~addrnumber
                      AND adr6~persnumber = usr21~persnumber
      INTO CORRESPONDING FIELDS OF TABLE lt_mail
      WHERE usr21~bname EQ gs_delvry-ernam.
    IF sy-subrc EQ 0.
      LOOP AT lt_mail ASSIGNING FIELD-SYMBOL(<ls_mail>).
        APPEND INITIAL LINE TO gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>).
        <gs_mail>-kunag = gs_delvry-kunag.
        <gs_mail>-kunwe = gs_delvry-kunwe.
        <gs_mail>-hkunnr = gs_delvry-hkunnr.
        CONDENSE <ls_mail>-smtp_addr NO-GAPS.
        <gs_mail>-smtp_addr = <ls_mail>-smtp_addr.
      ENDLOOP.
    ENDIF.

    SELECT smtp_addr AS smtp_sender
      FROM adr6
      INNER JOIN usr21 ON adr6~addrnumber = usr21~addrnumber
                      AND adr6~persnumber = usr21~persnumber
      INTO CORRESPONDING FIELDS OF TABLE lt_mail
      WHERE usr21~bname EQ sy-uname.
    IF sy-subrc EQ 0.
      LOOP AT lt_mail ASSIGNING <ls_mail>.
        APPEND INITIAL LINE TO gt_mail ASSIGNING <gs_mail>.
        CONDENSE <ls_mail>-smtp_sender NO-GAPS.
        <gs_mail>-smtp_sender = <ls_mail>-smtp_sender.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_mail_address.

    CASE gs_delvry-kunag .
      WHEN '0000200069'. "Koçtaş müşterisinde malı teslimalan bazında mail atılır.
        "Malı teslim alana göre mail adresi doldurma.
        set_mail_address_shipto( ).
      WHEN OTHERS.
        "Sipariş verene göre mail adresi doldurma.
        set_mail_address_soldto( ).
    ENDCASE.
    "Üst müşteri için mail bilgilerinin doldurulması.
    set_mail_address_hierch( ).
    "Siparişi açan kullanıcının mail bilgilerinin doldurulması.
    set_mailadress_socreater( ).
    "--------->>Anıl CENGİZ 23.49.2020 08:49:07
    "YUR-769
    "Siparişteki ZM muattabının doldurulması.
    set_mailadress_partnerzm( ).
    "---------<<
    "Mail adresi boş olanlar silinir.
    DELETE gt_mail WHERE ( smtp_addr NS '@' AND smtp_addr IS NOT INITIAL ).
    DELETE gt_mail WHERE ( smtp_sender NS '@' AND  smtp_sender IS NOT INITIAL  ).
    "--------->>Anıl CENGİZ 23.10.2020 10:10:04
    "YUR-769
    SORT gt_mail BY smtp_addr.
    DELETE ADJACENT DUPLICATES FROM gt_mail COMPARING smtp_addr.
    "---------<<

  ENDMETHOD.


  METHOD set_mail_address_custhiear.
  ENDMETHOD.


  METHOD set_mail_address_hierch.

    DATA: lt_mail TYPE tt_mail.

    CHECK: gs_delvry-adrnr_hk IS NOT INITIAL,
           gs_delvry-land1_hk EQ 'TR'.

    SELECT smtp_addr
      FROM adr6
      INTO CORRESPONDING FIELDS OF TABLE lt_mail
      WHERE addrnumber EQ gs_delvry-adrnr_hk
        AND flg_nouse EQ abap_false.
    IF sy-subrc EQ 0.
      LOOP AT lt_mail  ASSIGNING FIELD-SYMBOL(<ls_mail>).
        APPEND INITIAL LINE TO gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>).
        <gs_mail>-kunag = gs_delvry-kunag.
        <gs_mail>-kunwe = gs_delvry-kunwe.
        <gs_mail>-hkunnr = gs_delvry-hkunnr.
        CONDENSE <ls_mail>-smtp_addr NO-GAPS.
        <gs_mail>-smtp_addr = <ls_mail>-smtp_addr.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_mail_address_shipto.

    DATA: lt_mail TYPE tt_mail.

    CHECK: gs_delvry-adrnr_we IS NOT INITIAL,
           gs_delvry-land1_we EQ 'TR'.

    SELECT smtp_addr
      FROM adr6
      INTO CORRESPONDING FIELDS OF TABLE lt_mail
      WHERE addrnumber EQ gs_delvry-adrnr_we
        AND flg_nouse EQ abap_false.
    IF sy-subrc EQ 0.
      LOOP AT lt_mail  ASSIGNING FIELD-SYMBOL(<ls_mail>).
        APPEND INITIAL LINE TO gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>).
        <gs_mail>-kunag = gs_delvry-kunag.
        <gs_mail>-kunwe = gs_delvry-kunwe.
        <gs_mail>-hkunnr = gs_delvry-hkunnr.
        CONDENSE <ls_mail>-smtp_addr NO-GAPS.
        <gs_mail>-smtp_addr = <ls_mail>-smtp_addr.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_mail_address_soldto.

    DATA: lt_mail TYPE tt_mail.

    CHECK: gs_delvry-adrnr_ag IS NOT INITIAL,
           gs_delvry-land1_ag EQ 'TR'.

    SELECT smtp_addr
      FROM adr6
      INTO CORRESPONDING FIELDS OF TABLE lt_mail
      WHERE addrnumber EQ gs_delvry-adrnr_ag
        AND flg_nouse EQ abap_false.
    IF sy-subrc EQ 0.
      LOOP AT lt_mail  ASSIGNING FIELD-SYMBOL(<ls_mail>).
        APPEND INITIAL LINE TO gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>).
        <gs_mail>-kunag = gs_delvry-kunag.
        <gs_mail>-kunwe = gs_delvry-kunwe.
        <gs_mail>-hkunnr = gs_delvry-hkunnr.
        CONDENSE <ls_mail>-smtp_addr NO-GAPS.
        <gs_mail>-smtp_addr = <ls_mail>-smtp_addr.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD set_mailadress_partnerzm.

    LOOP AT gs_delvry-zm_smtp ASSIGNING FIELD-SYMBOL(<ls_mail>).
      APPEND INITIAL LINE TO gt_mail ASSIGNING FIELD-SYMBOL(<gs_mail>).
      CONDENSE <ls_mail>-smtp NO-GAPS.
      <gs_mail>-smtp_addr = <ls_mail>-smtp.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
