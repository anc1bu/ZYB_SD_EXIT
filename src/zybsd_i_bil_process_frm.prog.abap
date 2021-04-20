*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_BIL_PROCESS_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data CHANGING cf_retcode.
  DATA: lr_vbrk  LIKE vbrk,
        lv_vbtyp TYPE vbtyp,
        ls_vbrk  LIKE vbrk.

  CLEAR: lr_vbrk, lv_vbtyp.

  MOVE p_vbeln TO lr_vbrk-vbeln.
  CALL FUNCTION 'RV_INVOICE_DOCUMENT_READ'
    EXPORTING
      konv_read    = 'X'
      vbrk_i       = lr_vbrk
    IMPORTING
      vbrk_e       = gs_vbrk
    TABLES
      xkomv        = gt_komv
      xvbpa        = gt_vbpa
      xvbrk        = gt_vbrk
      xvbrp        = gt_vbrp
      xkomfk       = gt_komfk
      xthead       = gt_thead
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    cf_retcode = sy-subrc.
    add_message: sy-msgty sy-msgid sy-msgno
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CASE gs_vbrk-fkart.
      WHEN 'ZM01'. gv_ftrtip = gc_ftrtip_std.
      WHEN 'ZM02'. gv_ftrtip = gc_ftrtip_hzmt.
      WHEN 'ZM03'. gv_ftrtip = gc_ftrtip_iad.
      WHEN 'ZM04'. gv_ftrtip = gc_ftrtip_hzmtiad.
      WHEN OTHERS.
        IF NOT gs_vbrk-sfakn IS INITIAL.
          CLEAR ls_vbrk.
          SELECT SINGLE * FROM vbrk
                INTO ls_vbrk
               WHERE vbeln EQ gs_vbrk-vbeln
                 AND vbtyp IN ('5', '6').
          IF sy-subrc = 0.
            CASE ls_vbrk-fkart.
              WHEN 'ZM01'. gv_ftrtip = gc_ftrtip_std.
              WHEN 'ZM02'. gv_ftrtip = gc_ftrtip_hzmt.
              WHEN 'ZM03'. gv_ftrtip = gc_ftrtip_iad.
              WHEN 'ZM04'. gv_ftrtip = gc_ftrtip_hzmtiad.
            ENDCASE.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS
*&---------------------------------------------------------------------*
FORM process USING p_type CHANGING cf_retcode.
  CASE p_type.
    WHEN gc_bil_create.
** Dahili Mahsuplaştırma Fatura belgesini oluşturma
      PERFORM create_billing_document CHANGING cf_retcode.
    WHEN gc_bil_create_sipref.
** Sipariş ilişkili intercompany faturası oluşturma
      PERFORM create_bil_docu_related_order CHANGING cf_retcode.
    WHEN gc_bil_cancel.
** Dahili Mahsuplaştırma Fatura belgesini iptal etme
      PERFORM canceled_billing_document CHANGING cf_retcode.
    WHEN gc_stk_create.
** Dahili Mahsuplaştırma satıcı kaydı.
      PERFORM vendor_accounting_record CHANGING cf_retcode.
      IF cf_retcode = 0 AND gv_ftrtip NE gc_ftrtip_hzmtiad AND
         gv_ftrtip  NE gc_ftrtip_hzmt.
        PERFORM set_process_type CHANGING gv_type.
        IF NOT gv_type IS INITIAL.
          PERFORM process USING gv_type CHANGING cf_retcode.
        ENDIF.
      ENDIF.
    WHEN gc_smm_create.
** Dahili Mahsuplaştırma SMM kaydı.
      CHECK cf_retcode = 0.
      PERFORM smm_accounting_record CHANGING cf_retcode.
    WHEN gc_stk_cancel.
**  Satıcı muhasebe bel. ters kayıt.
      PERFORM cancelled_acc_record USING gc_stk_cancel
                                CHANGING cf_retcode.
    WHEN gc_smm_cancel.
**  SMM muhasebe bel. ters kayıt.
      PERFORM cancelled_acc_record USING gc_smm_cancel
                               CHANGING cf_retcode.
      IF cf_retcode = 0.
        PERFORM set_process_type CHANGING gv_type.
        IF NOT gv_type IS INITIAL.
          PERFORM process USING gv_type CHANGING cf_retcode.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " PROCESS
*&---------------------------------------------------------------------*
*&      Form  CREATE_BILLING_DOCUMET
*&---------------------------------------------------------------------*
FORM create_billing_document  CHANGING cf_retcode.
  DATA :
    i_bill     LIKE bapivbrk OCCURS 0 WITH HEADER LINE,
    i_cond     LIKE bapikomv OCCURS 0 WITH HEADER LINE,
    i_return   LIKE bapireturn1 OCCURS 0 WITH HEADER LINE,
    i_ccard    LIKE bapiccard_vf OCCURS 0 WITH HEADER LINE,
    tb_vbrp    LIKE vbrp OCCURS 0 WITH HEADER LINE,

    mesaj(200) TYPE c,
    lin        TYPE i.


  tb_vbrp[] = gt_vbrp[].
  SORT tb_vbrp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM tb_vbrp COMPARING vgbel.

  CLEAR: lin.
  DESCRIBE TABLE tb_vbrp LINES lin.

  IF lin = 0.
    cf_retcode = 1.
    add_message: 'E' gc_msg_id '006' '' '' '' ''.
    IF 1 = 2.  MESSAGE e006(zsd_vf).  ENDIF.
  ENDIF.

  CHECK cf_retcode = 0.

  LOOP AT tb_vbrp.
    i_bill-ref_doc = tb_vbrp-vgbel.
    i_bill-bill_date = gs_vbrk-fkdat.
    i_bill-ref_doc_ca = 'J'.
    APPEND i_bill.
  ENDLOOP.

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEFROMDATA'
*   EXPORTING
*     POSTING                 =
    TABLES
      billing_data_in   = i_bill
      condition_data_in = i_cond
      returnlog_out     = i_return
      ccard_data_in     = i_ccard.

  LOOP AT i_return.
    PERFORM add_message USING i_return.
  ENDLOOP.

  LOOP AT i_return WHERE type   EQ 'S'  AND
                         id     EQ 'VF' AND
                         number EQ '311'.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    DELETE tb_msg WHERE msgty EQ 'E' AND msgid EQ 'VF' AND
                        msgno EQ '003'.
    PERFORM bapi_commit.
  ELSE.
    PERFORM bapi_rollback.
  ENDIF.
ENDFORM.                    " CREATE_BILLING_DOCUMET
*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
FORM bapi_commit .
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ENDFORM.                    " BAPI_COMMIT
*&---------------------------------------------------------------------*
*&      Form  BAPI_ROLLBACK
*&---------------------------------------------------------------------*
FORM bapi_rollback .
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ENDFORM.                    " BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*&      Form  SET_PROCESS_TYPE
*&---------------------------------------------------------------------*
* A - Dahili Mahsup Oluşturma (Sip)    ( gc_bil_create_sipref )
* B - Dahili Mahsup İptal (Sip)        ( gc_bil_cancel_sipref )
* C - Dahili Mahsuplaştırma Oluşturma  ( gc_bil_create )
* I - Dahili Mahsuplşatırma İptal      ( gc_bil_cancel )
* 1 - Intercompany Satıcı Kaydı        ( gc_stk_create )
* 2 - Intercompany SMM Kaydı           ( gc_smm_create )
* 3 - Intercompany Satıcı Kaydı İptal  ( gc_stk_cancel )
* 4 - Intercompany SMM Kaydı İptal     ( gc_smm_cancel )
* 5 - Intercompany satıcı hizmet kaydı ( gc_stc_hzm_create )
* 6 - Inter.comp satıcı hizmet iptal   ( gc_stc_hzm_cancel )
* 7 - Inter.comp stc iade kaydı        ( gc_stc_iad_create )
* 8 - Inter.comp stc iade kaydı iptal  ( gc_stc_iad_cancel )
*& 9 - Inter.comp stc hizmet iade kaydı ( gc_stc_hzmiad_create )
*& a - Inter.comp stc hizmet iade iptal ( gc_stc_hzmiad_cancel )
*----------------------------------------------------------------------*
FORM set_process_type  CHANGING ep_type.
  DATA: cf_retcode TYPE sy-subrc.

  CLEAR: cf_retcode, ep_type.

  CASE gs_vbrk-vbtyp.
    WHEN 'M'.
* Daha önceden mahsup faturası oluştu mu?
      PERFORM check_mahsup_faturasi USING ' ' CHANGING cf_retcode.
      IF cf_retcode EQ 0.
        ep_type = gc_bil_create.
      ENDIF.
    WHEN 'N' OR 'S'.
      CASE gs_vbrk-fktyp.
        WHEN 'A'. " Sipariş İlişkili
          PERFORM check_mahsup_faturasi_sip USING space CHANGING cf_retcode.
          IF cf_retcode EQ 0.
            ep_type = gc_bil_cancel_sipref.
          ENDIF.
        WHEN 'L'. " Teslimat İlişkili
* Daha önceden mahsup faturası iptal edildi mi?
          PERFORM check_mahsup_faturasi USING 'T' CHANGING cf_retcode.
          IF cf_retcode EQ 0.
            ep_type = gc_bil_cancel.
          ENDIF.
      ENDCASE.
    WHEN '5'.

* Intercompany Muhasebe Belgesi
      PERFORM check_accounting_document USING space CHANGING ep_type
                                                           cf_retcode.
      IF  cf_retcode <> 0.
        CLEAR ep_type.
      ENDIF.
    WHEN '6'.
      IF gv_ftrtip EQ gc_ftrtip_hzmtiad OR gv_ftrtip EQ gc_ftrtip_iad.
        PERFORM check_accounting_document USING space CHANGING ep_type
                                                             cf_retcode.
      ELSE.
        PERFORM check_accounting_document USING 'T' CHANGING ep_type
                                                             cf_retcode.
      ENDIF.
      IF  cf_retcode <> 0.
        CLEAR ep_type.
      ENDIF.
    WHEN 'P'. " Borç Dekontu
      PERFORM check_mahsup_faturasi_sip USING space CHANGING cf_retcode.
      IF cf_retcode EQ 0.
        ep_type = gc_bil_create_sipref.
      ENDIF.
    WHEN 'O'. " Alacak Dekontu
      IF gs_vbrk-fktyp EQ 'L'.
* Daha önceden mahsup faturası oluştu mu?
        PERFORM check_mahsup_faturasi USING ' ' CHANGING cf_retcode.
        IF cf_retcode EQ 0.
          ep_type = gc_bil_create.
        ENDIF.
      ELSE.
        PERFORM check_mahsup_faturasi_sip USING space CHANGING cf_retcode.
        IF cf_retcode EQ 0.
          ep_type = gc_bil_create_sipref.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " SET_PROCESS_TYPE
*&---------------------------------------------------------------------*
*&      Form  CHECK_MAHSUP_FATURASI
*&---------------------------------------------------------------------*
*& ' '  - Oluşturma
*& T    - Ters Kayıt
*&---------------------------------------------------------------------*
FORM check_mahsup_faturasi  USING VALUE(p_val) TYPE char1
                            CHANGING ep_retcode.
  DATA: lt_vbuk LIKE vbuk OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_vbuk , lt_vbuk[].

  SELECT * FROM vbuk
      INTO TABLE lt_vbuk
      FOR ALL ENTRIES IN gt_vbrp
      WHERE vbeln EQ gt_vbrp-vgbel.

  CASE  p_val.
    WHEN ' '.
      LOOP AT lt_vbuk WHERE fkivk CA 'AB'.
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0.
        ep_retcode = 1.
        add_message: 'E' gc_msg_id '001' '' '' '' ''.
        IF 1 = 2.  MESSAGE e001(zsd_vf).  ENDIF.
      ENDIF.
    WHEN 'T'.
      LOOP AT lt_vbuk WHERE fkivk NE 'C'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        ep_retcode = 1.
        add_message: 'E' gc_msg_id '002' '' '' '' ''.
        IF 1 = 2.  MESSAGE e002(zsd_vf).  ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " CHECK_MAHSUP_FATURASI
*&---------------------------------------------------------------------*
*&      Form  CANCELED_BILLING_DOCUMENT
*&---------------------------------------------------------------------*
FORM canceled_billing_document  CHANGING ep_retcode.
  DATA:
    BEGIN OF lt_vbeln OCCURS 0 ,
      vbeln LIKE vbfa-vbeln,
    END OF lt_vbeln.

  DATA:
    tb_vbrp   LIKE vbrp OCCURS 0 WITH HEADER LINE.

  DATA:
    lin        TYPE i,
    lv_vbtyp_n TYPE vbtyp_n.

  CLEAR: lin, lv_vbtyp_n, tb_vbrp, tb_vbrp[],
         lt_vbeln, lt_vbeln[], ep_retcode.

  tb_vbrp[] = gt_vbrp[].
  SORT tb_vbrp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM tb_vbrp COMPARING vgbel.

  IF gs_vbrk-vbtyp EQ 'S'.
    lv_vbtyp_n = '6'.
  ELSE.
    lv_vbtyp_n = '5'.
  ENDIF.

  SELECT vbfa~vbeln FROM vbfa
      INNER JOIN vbrk ON vbrk~vbeln EQ vbfa~vbeln
      INTO CORRESPONDING FIELDS OF TABLE lt_vbeln
      FOR ALL ENTRIES IN tb_vbrp
      WHERE vbfa~vbelv   EQ tb_vbrp-vgbel
        AND vbfa~vbtyp_v EQ tb_vbrp-vgtyp
        AND vbfa~vbtyp_n EQ lv_vbtyp_n
        AND vbrk~fksto   EQ space.

  LOOP AT lt_vbeln.
    " bapi dump verdiği için kapatıldı.
*    PERFORM bapi_cancelled_bildoc USING lt_vbeln-vbeln
*                               CHANGING ep_retcode.

    PERFORM batch_input_cancelled_bildoc USING lt_vbeln-vbeln
                                      CHANGING ep_retcode.
  ENDLOOP.
ENDFORM.                    " CANCELED_BILLING_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  SHOW_MESSAGE
*&---------------------------------------------------------------------*
FORM show_message.
  CHECK NOT tb_msg[] IS INITIAL.
  CALL FUNCTION 'RHVM_SHOW_MESSAGE'
    EXPORTING
      mess_header = 'İşlem sonucu'
    TABLES
      tem_message = tb_msg
    EXCEPTIONS
      canceled    = 1
      OTHERS      = 2.
ENDFORM.                    " SHOW_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
FORM add_message  USING  i_ret LIKE bapireturn1.
  CLEAR tb_msg.
  tb_msg-msgty = i_ret-type.
  tb_msg-msgid = i_ret-id.
  tb_msg-msgno = i_ret-number.
  tb_msg-msgv1 = i_ret-message_v1.
  tb_msg-msgv2 = i_ret-message_v2.
  tb_msg-msgv3 = i_ret-message_v3.
  tb_msg-msgv4 = i_ret-message_v4.
  APPEND tb_msg.
ENDFORM.                    " ADD_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  CHECK_ACCOUNTING_DOCUMENT
*& p_val = ' ' --> Yaratma
*& p_val = 'T' --> Ters Kayıt
*& 1 - Intercompany Mal Giriş Muhasebe Belgesi Yaratma ( gc_stk_create )
*& 2 - Intercompany Mal Çıkış Muhasebe Belgesi Yaratma ( gc_smm_create )
*& 3 - Intercompany Mal Giriş Muhasebe Belgesi İptal   ( gc_stk_create )
*& 4 - Intercompany Mal Çıkış Muhasebe Belgesi İptal   ( gc_smm_create )
*& 5 - Intercompany satıcı hizmet kaydı ( gc_stc_hzm_create )
*& 6 - Inter.comp satıcı hizmet iptal   ( gc_stc_hzm_cancel )
*& 7 - Inter.comp stc iade kaydı        ( gc_stc_iad_create )
*& 8 - Inter.comp stc iade kaydı iptal  ( gc_stc_iad_cancel )
*& 9 - Inter.comp stc hizmet iade kaydı ( gc_stc_hzmiad_create )
*& a - Inter.comp stc hizmet iade iptal ( gc_stc_hzmiad_cancel )
*&---------------------------------------------------------------------*
FORM check_accounting_document  USING VALUE(p_val) TYPE char1
                                CHANGING ep_type
                                         ep_retcode.
  DATA:
    l_bl01 LIKE zyb_sd_t_bl01,
    subrc  LIKE sy-subrc.

  CLEAR: l_bl01, ep_type, subrc, wa_bl01.

  CASE p_val.
    WHEN ' '.
      SELECT SINGLE * FROM zyb_sd_t_bl01
         INTO l_bl01
        WHERE vbeln EQ gs_vbrk-vbeln.

    WHEN 'T'.
      SELECT SINGLE * FROM zyb_sd_t_bl01
         INTO l_bl01
        WHERE vbeln EQ gs_vbrk-sfakn.
  ENDCASE.

  IF NOT l_bl01 IS INITIAL.
    wa_bl01 = l_bl01.
    CASE p_val.
      WHEN ' '.

* Mal giriş / Hizmet giriş belgesi var mı? Var ise subrc 0 dan farklı döner
        IF NOT l_bl01-belnr1 IS INITIAL.

          PERFORM check_bkpf USING p_val l_bl01-bukrs l_bl01-belnr1
                                   l_bl01-gjahr1
                          CHANGING subrc.
          IF subrc = 0.
            ep_type = gc_stk_create.
            EXIT.
          ENDIF.
* Mal Çıkış Belgelsi var mı? Var ise subrc 0 dan farklı döner
          IF NOT l_bl01-belnr2 IS INITIAL AND subrc <> 0.
            PERFORM check_bkpf USING p_val l_bl01-bukrs l_bl01-belnr2
                                     l_bl01-gjahr2
                            CHANGING subrc.
            IF subrc = 0.
              IF gv_ftrtip EQ gc_ftrtip_std OR gv_ftrtip EQ gc_ftrtip_iad.
                ep_type = gc_smm_create.
                EXIT.
              ENDIF.
            ENDIF.
          ELSEIF l_bl01-belnr2 IS INITIAL AND subrc <> 0.
            IF gv_ftrtip EQ gc_ftrtip_std OR gv_ftrtip EQ gc_ftrtip_iad.
              ep_type = gc_smm_create.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
        IF subrc = 0.
          ep_retcode = 1.
          add_message: 'E' gc_msg_id '004' gs_vbrk-vbeln '' '' ''.
          IF 1 = 2.  MESSAGE e004(zsd_vf).  ENDIF.
          EXIT.
        ENDIF.
      WHEN 'T'.
* Mal Çıkış Belgelsinin ters var mı? Var ise subrc 0 dan farklı döner
        IF NOT l_bl01-belnr2 IS INITIAL.
          PERFORM check_bkpf USING p_val l_bl01-bukrs l_bl01-belnr2
                                   l_bl01-gjahr2
                          CHANGING subrc.
          IF subrc = 0.
            ep_type = gc_smm_cancel.
            EXIT.
          ENDIF.
* Mal giriş belgesinin ters kaydı var mı? Var ise subrc 0 dan farklı döner
          IF NOT l_bl01-belnr1 IS INITIAL AND subrc <> 0.
            PERFORM check_bkpf USING p_val l_bl01-bukrs l_bl01-belnr1
                                     l_bl01-gjahr1
                            CHANGING subrc.
            IF subrc = 0.
              ep_type = gc_stk_cancel.
              EXIT.
            ENDIF.
          ELSEIF l_bl01-belnr1 IS INITIAL AND subrc <> 0.
            ep_retcode = 1.
            add_message: 'E' gc_msg_id '005' gs_vbrk-sfakn '' '' ''.
            IF 1 = 2.  MESSAGE e005(zsd_vf).  ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE p_val.
      WHEN ' '.
        ep_type = gc_stk_create.
      WHEN 'T'.
        ep_retcode = 1.
        add_message: 'E' gc_msg_id '003' '' '' '' ''.
        IF 1 = 2.  MESSAGE e003(zsd_vf).  ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " CHECK_ACCOUNTING_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BKPF
*& p_val = ' ' --> Yaratma
*& p_val = 'T' --> Ters Kayıt
*&---------------------------------------------------------------------*
FORM check_bkpf  USING    p_val
                          p_bukrs
                          p_belnr
                          p_gjahr
                 CHANGING ep_subrc.
  DATA: ls_bkpf LIKE bkpf.
  CLEAR: ls_bkpf, ep_subrc.

  SELECT SINGLE * FROM bkpf
      INTO ls_bkpf
     WHERE bukrs EQ p_bukrs
       AND belnr EQ p_belnr
       AND gjahr EQ p_gjahr.

  CASE p_val.
    WHEN ' '.
      IF NOT ls_bkpf       IS INITIAL AND ls_bkpf-stblg IS INITIAL AND
             ls_bkpf-stjah IS INITIAL.
        ep_subrc = 1.
      ENDIF.
    WHEN 'T'.
      IF NOT ls_bkpf       IS INITIAL AND NOT ls_bkpf-stblg IS INITIAL
        AND NOT ls_bkpf-stjah IS INITIAL.
        ep_subrc = 1.
      ENDIF.
  ENDCASE.
ENDFORM.                    " CHECK_BKPF
*&---------------------------------------------------------------------*
*&      Form  VENDOR_ACCOUNTING_RECORD
*&---------------------------------------------------------------------*
FORM vendor_accounting_record CHANGING cf_retcode.
** Satıcı kaydı için datalar toplanır
  PERFORM account_global_data CHANGING cf_retcode.
  CHECK cf_retcode = 0.
** Satıcı kaydı oluşurulur.
  PERFORM bapi_stk_record CHANGING cf_retcode.
ENDFORM.                    " VENDOR_ACCOUNTING_RECORD
*&---------------------------------------------------------------------*
*&      Form  BAPI_STK_RECORD
*&---------------------------------------------------------------------*
FORM bapi_stk_record CHANGING retcode.
  DATA:
    gv_itemno TYPE posnr_acc,
    l_netwr   LIKE vbrk-netwr,
    i_wrbtr   LIKE bseg-wrbtr,
    lv_ot     LIKE bapiache09-obj_type,
    lv_ok     LIKE bapiache09-obj_key,
    lv_os     LIKE bapiache09-obj_sys.

** Bapi Tabloları temizlenir
  PERFORM bapi_clear_table.

** Başlık Satırı

  PERFORM  fill_header_account USING gc_stk_create CHANGING ls_hd.

*&--------------------------------------------------------------------*
*&  --> Satıcı Satırı
*&--------------------------------------------------------------------*
  CLEAR: gv_itemno.
  ADD 1 TO gv_itemno.

  PERFORM fill_vendor_item USING gv_itemno CHANGING it_ap[].
*&--------------------------------------------------------------------*
*&  <-- Satıcı Satırı
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&  --> Satıcı Satırı için  PB kalemleri
*&--------------------------------------------------------------------*
* Mahsuplaştırma belgesi Müşteri Satırı okunur.
  READ TABLE gt_accit WITH KEY koart = gc_koart_mus.

  IF sy-subrc <> 0.
    retcode = 1.
    add_message: 'E'
                 gc_msg_id
                 '016'
                 space
                 space
                 space
                 space.
    IF 1 = 2.  MESSAGE e016(zsd_vf).  ENDIF.

    EXIT.
  ENDIF.

  READ TABLE gt_acccr WITH KEY awtyp = gt_accit-awtyp
                               awref = gt_accit-awref
                               posnr = gt_accit-posnr
                               curtp = gc_curtp_00.

  CHECK sy-subrc = 0.

  PERFORM fill_currency_items USING 'V' gv_itemno gc_stk_create ' '
                           CHANGING it_ca[].
*&--------------------------------------------------------------------*
*&  <-- Satıcı Satırı için  PB kalemleri
*&--------------------------------------------------------------------*
  LOOP AT gt_vbrp WHERE fkimg GT 0.
*&--------------------------------------------------------------------*
*&  --> Ana hesap satırı
*&--------------------------------------------------------------------*
    ADD 1 TO gv_itemno.

    CLEAR gt_account.
    READ TABLE gt_account WITH KEY vbeln = gt_vbrp-vbeln
                                   posnr = gt_vbrp-posnr.

    PERFORM fill_account_item USING gv_itemno gc_stk_create ' '
                           CHANGING it_ag[].
*&--------------------------------------------------------------------*
*&  <-- Ana hesap satırı
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&  --> Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*
    PERFORM fill_currency_items USING 'I' gv_itemno gc_stk_create ' '
                             CHANGING it_ca[].
*&--------------------------------------------------------------------*
*&  <-- Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&  --> Ana hesap satırı için  Vergi Satırı
*&--------------------------------------------------------------------*
    CLEAR: gt_taxtut, i_wrbtr.
    REFRESH t_mwdat.

    i_wrbtr = gt_vbrp-netwr.
    PERFORM calculate_tax USING gv_bukrs
                                gt_account-mwskz
                                gs_vbrk-waerk
                                i_wrbtr
                        CHANGING t_mwdat[].
    READ TABLE t_mwdat INDEX 1.

    IF sy-subrc = 0.
      PERFORM fill_tax_item CHANGING it_tx[].

      gt_taxtut-hkont    = t_mwdat-hkont.
      gt_taxtut-tax_code = gt_account-mwskz.
      CASE gv_ftrtip.
        WHEN gc_ftrtip_hzmt    OR gc_ftrtip_std.
          gt_taxtut-wmwst    = t_mwdat-wmwst.
          gt_taxtut-amt_base = gt_vbrp-netwr.
        WHEN gc_ftrtip_hzmtiad OR gc_ftrtip_iad.
          gt_taxtut-wmwst    = -1 * t_mwdat-wmwst.
          gt_taxtut-amt_base = -1 * gt_vbrp-netwr.
      ENDCASE.
*          gt_taxtut-wmwst    = t_mwdat-wmwst.
*          gt_taxtut-amt_base = gt_vbrp-netwr.
      COLLECT gt_taxtut.
    ENDIF.
*&--------------------------------------------------------------------*
*&  <-- Ana hesap satırı için  Vergi Satırı
*&--------------------------------------------------------------------*
  ENDLOOP.

* Kalem bazında toplam alınan vergi tutarı toplam vergi matrahından
* hesaplanan vergiden farklı ise son hesaplanan vergi alınır.

  LOOP AT gt_taxtut.
    REFRESH t_mwdat.
    CLEAR i_wrbtr.
    i_wrbtr = gt_taxtut-amt_base.
    PERFORM calculate_tax USING gv_bukrs
                                gt_taxtut-tax_code
                                gs_vbrk-waerk
                                i_wrbtr
                        CHANGING t_mwdat[].

    READ TABLE t_mwdat INDEX 1.
    IF t_mwdat-wmwst NE gt_taxtut-wmwst.
      gt_taxtut-wmwst = t_mwdat-wmwst.
    ENDIF.
    MODIFY gt_taxtut.
  ENDLOOP.

  LOOP AT it_tx.
    ADD 1 TO gv_itemno.
    it_tx-itemno_acc = gv_itemno.
    MODIFY it_tx.

* fill amount
    CLEAR:  it_ca.
    it_ca-itemno_acc   = gv_itemno.
    it_ca-curr_type    = gt_acccr-curtp.
    it_ca-currency     = gt_acccr-waers.
    it_ca-exch_rate    = gt_acccr-kursf.
    READ TABLE gt_taxtut WITH KEY hkont    = it_tx-gl_account
                                  tax_code = it_tx-tax_code.
    IF sy-subrc = 0.
      it_ca-amt_doccur   = gt_taxtut-wmwst.
      it_ca-amt_base     = gt_taxtut-amt_base.
    ENDIF.
    APPEND it_ca.
  ENDLOOP.

  break bbozaci.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_hd
    IMPORTING
      obj_type       = lv_ot
      obj_key        = lv_ok
      obj_sys        = lv_os
    TABLES
      accountgl      = it_ag
      accountpayable = it_ap
      accounttax     = it_tx
      currencyamount = it_ca
      return         = it_rt.

  LOOP AT it_rt WHERE type CA 'EAX'.
    add_message: it_rt-type it_rt-id it_rt-number it_rt-message_v1
                 it_rt-message_v2 it_rt-message_v3 it_rt-message_v4.
  ENDLOOP.
  IF sy-subrc <> 0.
    PERFORM bapi_commit.
    PERFORM modify_table USING gs_vbrk-vbeln gc_stk_create
                               lv_ot lv_ok lv_os.

  ELSE.
    PERFORM bapi_rollback.
    retcode = 1.
  ENDIF.
  break bbozaci.
ENDFORM.                    " BAPI_STK_RECORD
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------*
FORM convert_to_local_currency  USING    p_datum
                                         p_netwr
                                         p_waerk
                                         p_currency
                                         p_rate
                                CHANGING ep_netwr.
  CLEAR ep_netwr.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      client           = sy-mandt
      date             = p_datum
      foreign_amount   = p_netwr
      foreign_currency = p_waerk
      local_currency   = p_currency
      rate             = p_rate
*     TYPE_OF_RATE     = 'M'
    IMPORTING
      local_amount     = ep_netwr
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_GLOBAL_DATA
*&---------------------------------------------------------------------*
FORM account_global_data  CHANGING retcode.
  DATA: ls_komv TYPE komv,
        lv_txt  TYPE text10.

  DATA: ls_tvko LIKE tvko.

  CLEAR:
    gv_bukrs, gv_vendor, gv_zterm, gv_kunnr, retcode.

  FREE: gt_account, gt_mbew.
* Faturanın muhasebe belgesi okunur.
  PERFORM get_bil_account_document CHANGING retcode.

  IF NOT gt_vbrp[] IS INITIAL.
    SELECT * FROM mbew INTO TABLE gt_mbew
        FOR ALL ENTRIES IN gt_vbrp
        WHERE matnr EQ gt_vbrp-matnr
          AND lvorm EQ space.
  ENDIF.

  READ TABLE gt_vbpa WITH KEY vbeln = gs_vbrk-vbeln
                              posnr = '000000'
                              parvw = gc_mus_parvw.
  IF sy-subrc = 0.
    gv_kunnr = gt_vbpa-kunnr.
  ENDIF.

* Satıcı kaydı için aşağıdaki veriler alınır.

*  SELECT SINGLE kna1~lifnr
*                lfb1~bukrs
*                lfb1~zterm FROM kna1
*    INNER JOIN lfb1 ON lfb1~lifnr EQ kna1~lifnr
*       INTO (gv_vendor, gv_bukrs, gv_zterm)
*      WHERE kna1~kunnr EQ gs_vbrk-kunrg
*        AND lfb1~bukrs NE gs_vbrk-bukrs.
  CLEAR ls_tvko.
  SELECT SINGLE * FROM tvko
      INTO ls_tvko
     WHERE vkorg EQ gs_vbrk-vkorg.

  IF NOT ls_tvko-lifnr IS INITIAL.
    gv_vendor = ls_tvko-lifnr.
    SELECT SINGLE bukrs zterm FROM lfb1
         INTO (gv_bukrs, gv_zterm)
        WHERE lifnr EQ ls_tvko-lifnr.
  ENDIF.

  IF gv_vendor IS INITIAL.
    retcode = 1.
    add_message: 'E'
                 gc_msg_id
                 '007'
                 gs_vbrk-vkorg
                 'Satış organizasyonu uyarlamasını kontrol edin'
                 space
                 space.
    IF 1 = 2.  MESSAGE e007(zsd_vf).  ENDIF.
  ENDIF.

  IF gv_bukrs IS INITIAL.
    retcode = 1.
    add_message: 'E' gc_msg_id '008' '' '' '' ''.
    IF 1 = 2.  MESSAGE e008(zsd_vf).  ENDIF.
  ENDIF.
  IF gv_zterm IS INITIAL.
    retcode = 1.
    add_message: 'E' gc_msg_id '009' '' '' '' ''.
    IF 1 = 2.  MESSAGE e009(zsd_vf).  ENDIF.
  ENDIF.

  CHECK retcode = 0.

  LOOP AT gt_vbrp WHERE fkimg GT 0.
    CLEAR: gt_account, ls_komv.
    gt_account-vbeln = gt_vbrp-vbeln.
    gt_account-posnr = gt_vbrp-posnr.
    gt_account-matnr = gt_vbrp-matnr.
    READ TABLE gt_komv INTO ls_komv WITH KEY knumv = gs_vbrk-knumv
                                             kposn = gt_vbrp-posnr
                                             koaid = gc_koaid_d.
    IF sy-subrc = 0.
      CASE ls_komv-mwsk1.
        WHEN gc_mwsk1_h0.  gt_account-mwskz = gc_mwsk1_i0.
        WHEN gc_mwsk1_h1.  gt_account-mwskz = gc_mwsk1_i1.
        WHEN gc_mwsk1_h8.  gt_account-mwskz = gc_mwsk1_i8.
        WHEN gc_mwsk1_h18. gt_account-mwskz = gc_mwsk1_i18.
*        WHEN gc_mwsk1_w0.  gt_account-mwskz = gc_mwsk1_h0.
        WHEN gc_mwsk1_w1.  gt_account-mwskz = gc_mwsk1_v1.
        WHEN gc_mwsk1_w8.  gt_account-mwskz = gc_mwsk1_v8.
        WHEN gc_mwsk1_w18. gt_account-mwskz = gc_mwsk1_v18.
      ENDCASE.
    ENDIF.
    PERFORM set_account USING gv_bukrs CHANGING gt_account-stk_hkont
                                                gt_account-smm_hkont
                                                retcode.
*** geçici
*    gt_account-stk_hkont = '1530700001'.
    IF retcode <> 0.
      CLEAR lv_txt.
      CASE retcode.
        WHEN 1. lv_txt = 'Stok'.
        WHEN 2. lv_txt = 'SMM'.
        WHEN OTHERS.
      ENDCASE.
      add_message: 'E' gc_msg_id '010' gt_vbrp-matnr lv_txt '' ''.
      IF 1 = 2.  MESSAGE e010(zsd_vf).  ENDIF.
    ENDIF.
    APPEND gt_account.
  ENDLOOP.
ENDFORM.                    " ACCOUNT_GLOBAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_ACCOUNT
*&---------------------------------------------------------------------*
FORM set_account  USING    p_bukrs
                  CHANGING ep_stk_hkont
                           ep_smm_hkont
                           ep_retcode.

  DATA: lv_bklas TYPE bklas.

  CLEAR: ep_stk_hkont, ep_smm_hkont, ep_retcode, lv_bklas.

  IF gv_ftrtip EQ gc_ftrtip_hzmt OR gv_ftrtip EQ gc_ftrtip_hzmtiad.
    lv_bklas = gc_bklas_hzm.
  ENDIF.

  SELECT SINGLE * FROM t001  WHERE bukrs EQ p_bukrs.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM t001k WHERE bukrs EQ p_bukrs.
  ENDIF.

  IF sy-subrc = 0.
* 153 lü kayıt için
    SELECT SINGLE * FROM t030
      WHERE ktopl EQ t001-ktopl
        AND ktosl EQ gc_ktosl_stk
        AND bwmod EQ t001k-bwmod
        AND komok EQ space
        AND bklas EQ lv_bklas.
    IF sy-subrc = 0.
      ep_stk_hkont = t030-konth.
    ELSE.
      ep_retcode = 1.
      EXIT.
    ENDIF.


    CLEAR: t030.
    IF gv_ftrtip NE gc_ftrtip_hzmt AND
       gv_ftrtip NE gc_ftrtip_hzmtiad.
* 621 li kayıtlar için
      SELECT SINGLE * FROM t030
        WHERE ktopl EQ t001-ktopl
          AND ktosl EQ gc_ktosl_smm
          AND bwmod EQ t001k-bwmod
          AND komok EQ space
          AND bklas EQ space.
      IF sy-subrc = 0.
        ep_smm_hkont = t030-konth.
      ELSE.
        ep_retcode = 2.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " SET_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  GET_BIL_ACCOUNT_DOCUMENT
*&---------------------------------------------------------------------*
FORM get_bil_account_document CHANGING ep_retcode.
  DATA:
    i_docu     LIKE acc_doc OCCURS 0 WITH HEADER LINE,
    lv_bsgblnr LIKE bseg-belnr.
* SD faturasına ait muhasebe belgeleri okunur
  CLEAR: i_docu, i_docu[].

  CALL FUNCTION 'AC_DOCUMENT_RECORD'
    EXPORTING
      i_awtyp      = 'VBRK'
      i_awref      = gs_vbrk-vbeln
      i_bukrs      = gs_vbrk-bukrs
      x_dialog     = space
    TABLES
      t_documents  = i_docu
    EXCEPTIONS
      no_reference = 1
      no_document  = 2
      OTHERS       = 3.

  IF sy-subrc <> 0.
    ep_retcode = 1.
    add_message: sy-msgty sy-msgid sy-msgno
             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

* Muhasebe belgesinden okunur.
  CLEAR: lv_bsgblnr.
  READ TABLE i_docu WITH KEY awtyp = 'BKPF'.
  CHECK sy-subrc EQ 0.
  lv_bsgblnr = i_docu-docnr .

  CLEAR: gt_acchd, gt_acchd[], gt_accit, gt_accit[],
         gt_acccr, gt_acccr[], gt_bkpf,  gt_bkpf[],
         gt_bseg,  gt_bseg[].

  CALL FUNCTION 'FI_DOCUMENT_READ'
    EXPORTING
      i_bukrs     = i_docu-bukrs
      i_belnr     = lv_bsgblnr
      i_gjahr     = i_docu-ac_gjahr
    TABLES
      t_acchd     = gt_acchd
      t_accit     = gt_accit
      t_acccr     = gt_acccr
      t_bkpf      = gt_bkpf
      t_bseg      = gt_bseg
    EXCEPTIONS
      wrong_input = 1
      not_found   = 2
      OTHERS      = 3.
  IF sy-subrc <> 0.
    ep_retcode = 1.
    add_message: sy-msgty sy-msgid sy-msgno
             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
ENDFORM.                    " GET_BIL_ACCOUNT_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_TAX
*&---------------------------------------------------------------------*
FORM calculate_tax  USING    p_bukrs
                             p_mwskz
                             p_waerk
                             p_netwr
                    CHANGING lt_mwdat LIKE t_mwdat[].


  CLEAR: lt_mwdat, lt_mwdat[].

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs           = p_bukrs
      i_mwskz           = p_mwskz
      i_waers           = p_waerk
      i_wrbtr           = p_netwr
    TABLES
      t_mwdat           = lt_mwdat
    EXCEPTIONS
      bukrs_not_found   = 1
      country_not_found = 2
      mwskz_not_defined = 3
      mwskz_not_valid   = 4
      ktosl_not_found   = 5
      kalsm_not_found   = 6
      parameter_error   = 7
      knumh_not_found   = 8
      kschl_not_found   = 9
      unknown_error     = 10
      account_not_found = 11
      txjcd_not_valid   = 12
      OTHERS            = 13.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " CALCULATE_TAX
*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_ACCOUNT
*& Genel Veriler  hem satıcı hemde smm muhasebe belgesi için.
*& Satıcı Verileri satıcı muhasebe belgesi için.
*& SMM Verileri SMM muhasebe belgesi için.
*&---------------------------------------------------------------------*
FORM fill_header_account  USING VALUE(p_val) CHANGING ls_hd LIKE bapiache09.
  CLEAR: ls_hd.
** Genel Veriler
  ls_hd-bus_act     = gc_bs_act.            " İşletmeye ilişkin işlem
  ls_hd-username    = sy-uname.             " Kullanıcı Adı
*  ls_hd-header_txt  = 'XXX'.               " Belge başlığı metni
  ls_hd-comp_code   = gv_bukrs.             " Şirket Kodu
  ls_hd-doc_date    = gs_vbrk-fkdat.        " Belge tarihi
  ls_hd-pstng_date  = gs_vbrk-fkdat.        " Belgedeki kayıt tarihi
  ls_hd-trans_date  = gs_vbrk-fkdat.        " Çeviri Tarihi
  ls_hd-fisc_year   = gs_vbrk-fkdat+0(4).   " Mali Yıl
  ls_hd-fis_period  = gs_vbrk-fkdat+4(2).   " Mali Ay
  ls_hd-ref_doc_no  = gs_vbrk-vbeln.        " Referans belge numarası
  CASE p_val.
    WHEN gc_stk_create.
* Satıcı verileri
      ls_hd-doc_type    = gc_stk_doc_type.  " Belge Türü
    WHEN gc_smm_create.
* SMM verileri
      ls_hd-doc_type    = gc_smm_doc_type.  " Belge Türü
  ENDCASE.
ENDFORM.                    " FILL_HEADER_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  FILL_VENDOR_ITEM
*&---------------------------------------------------------------------*
FORM fill_vendor_item  USING itemno CHANGING lt_ap LIKE it_ap[].
  DATA: ls_ap LIKE LINE OF it_ap.

  CLEAR ls_ap.
  ls_ap-itemno_acc = itemno.         " Muhasebe belgesi kalem numarası
  ls_ap-vendor_no  = gv_vendor.      " Satıcının hesap numarası
  ls_ap-pmnttrms   = gv_zterm.       " Ödeme koşulları anahtarı
  ls_ap-comp_code  = gv_bukrs.       " Şirket Kodu
  ls_ap-tax_code   = gc_stk_tax_code." KDV göstergesi
  ls_ap-bline_date = gs_vbrk-fkdat.  " Vade hsp. temel oluşturan tarih
  ls_ap-alloc_nmbr = gs_vbrk-vbeln.  " Tayin numarası
*  ls_ap-item_text  = 'XXX'.     " Kalem metni
  APPEND ls_ap TO lt_ap .
ENDFORM.                    " FILL_VENDOR_ITEM
*&---------------------------------------------------------------------*
*&      Form  CURRENCY_ITEMS
*& V - Satıcı için
*& I - Ana Hesap Satırı için
*& T - Vergi Satırı için
*&---------------------------------------------------------------------*
FORM fill_currency_items  USING VALUE(p_val)
                                      itemno
                                VALUE(p_type)
                                VALUE(p_hesap)
                     CHANGING lt_ca LIKE it_ca[].
  DATA: ls_ca LIKE LINE OF it_ca.
  CLEAR ls_ca.
** Genel Veriler
  ls_ca-itemno_acc   = itemno.
  ls_ca-curr_type    = gt_acccr-curtp.
  ls_ca-currency     = gt_acccr-waers.
  ls_ca-exch_rate    = gt_acccr-kursf.

** Belge tipine göre değişken veriler

  CASE p_type.
    WHEN gc_stk_create.
** Satıcı Kayıtları için
      CASE p_val.
        WHEN 'V'. " Satıcı için
*          CASE gv_ftrtip.
*            WHEN gc_ftrtip_hzmt OR gc_ftrtip_std.
*              ls_ca-amt_doccur   = -1 * gt_acccr-wrbtr.
*            WHEN gc_ftrtip_hzmtiad OR gc_ftrtip_iad.
*               ls_ca-amt_doccur   = gt_acccr-wrbtr.
*          ENDCASE.
          ls_ca-amt_doccur   = -1 * gt_acccr-wrbtr.
        WHEN 'I'. " Ana Hesap Satırı için
          CASE gv_ftrtip.
            WHEN gc_ftrtip_hzmt OR gc_ftrtip_std.
              ls_ca-amt_doccur   = gt_vbrp-netwr.
              ls_ca-amt_base     = gt_vbrp-netwr.
            WHEN gc_ftrtip_hzmtiad OR gc_ftrtip_iad.
              ls_ca-amt_doccur   = -1 * gt_vbrp-netwr.
              ls_ca-amt_base     = -1 * gt_vbrp-netwr.
          ENDCASE.
        WHEN 'T'. " Vergi Satırı için
      ENDCASE.
    WHEN gc_smm_create.
** SMM kayıtları için
      CASE gv_ftrtip.
        WHEN gc_ftrtip_std.
          IF p_hesap EQ '621'.
            ls_ca-amt_doccur   = gt_vbrp-netwr.
          ELSE.
            ls_ca-amt_doccur   = -1 * gt_vbrp-netwr.
          ENDIF.
        WHEN gc_ftrtip_iad.
          IF p_hesap EQ '621'.
            ls_ca-amt_doccur   =  -1 * gt_vbrp-netwr.
          ELSE.
            ls_ca-amt_doccur   = gt_vbrp-netwr.
          ENDIF.
      ENDCASE.
  ENDCASE.
*   ls_ca-amt_base     = -1 * gt_acccr-wrbtr.
  APPEND ls_ca TO it_ca.
ENDFORM.                    " CURRENCY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  BAPI_CLEAR_TABLE
*&---------------------------------------------------------------------*
FORM bapi_clear_table .
  CLEAR:
    ls_hd,
    it_ag, it_ag[],
    it_ap, it_ap[],
    it_ca, it_ca[],
    it_rt, it_rt[],
    it_tx, it_tx[],
    gt_taxtut, gt_taxtut[].
ENDFORM.                    " BAPI_CLEAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  FILL_ACCOUNT_ITEM
*& Genel Veriler  hem satıcı hemde smm muhasebe belgesi için.
*& Satıcı Verileri satıcı muhasebe belgesi için.
*& SMM Verileri SMM muhasebe belgesi için.
*& 153 verileri 153 lü hesap satırı için
*& 621 verileri 621 li hesap satırı için
*&---------------------------------------------------------------------*
FORM fill_account_item  USING    itemno
                           VALUE(p_val)
                           VALUE(p_hesap)
                        CHANGING lt_ag LIKE it_ag[].
  DATA: ls_ag LIKE LINE OF it_ag.
  CLEAR ls_ag.
* Genel Veriler
  ls_ag-itemno_acc  = itemno.
  ls_ag-material    = gt_vbrp-matnr.        " Malzeme numarası
  ls_ag-comp_code   = gv_bukrs.             " Şirket Kodu
  ls_ag-quantity    = gt_vbrp-fklmg.        " Miktar
  ls_ag-base_uom    = gt_vbrp-meins.        " Ölçü Birimi
  ls_ag-alloc_nmbr  = gt_vbrp-vbeln.        " Tayin numarası
  ls_ag-distr_chan  = gs_vbrk-vtweg.
  ls_ag-division    = gs_vbrk-spart.
  ls_ag-salesorg    = gs_vbrk-vkorg.
  ls_ag-customer    = gv_kunnr.
**    ls_ag-item_text   = 'XXX'.              " Kalem metni
**    ls_ag-profit_ctr  = tb_data-prctr.      " Kâr merkezi
*    ls_ag-entry_qnt   = gt_vbrp-fklmg. " Giriş ölçü birimi cinsinden miktar
*    ls_ag-entry_uom   = gt_vbrp-meins. " Giriş ölçü birimi

  CASE p_val.
    WHEN gc_stk_create.
** Satıcı Kaydı için
      ls_ag-gl_account  = gt_account-stk_hkont. " Muh. ana hesabı
      ls_ag-tax_code    = gt_account-mwskz.     " Vergi Kodu
      ls_ag-doc_type    = gc_stk_doc_type.      " Belge Türü
    WHEN gc_smm_create.
** SMM kaydı için
      ls_ag-doc_type    = gc_smm_doc_type.      " Belge Türü
      IF p_hesap EQ '621'.
        ls_ag-gl_account  = gt_account-smm_hkont. " Muh. ana hesabı
      ELSE.
        ls_ag-gl_account  = gt_account-stk_hkont. " Muh. ana hesabı
      ENDIF.
  ENDCASE.



  APPEND ls_ag TO lt_ag.
ENDFORM.                    " FILL_ACCOUNT_ITEM
*&---------------------------------------------------------------------*
*&      Form  FILL_TAX_ITEM
*&---------------------------------------------------------------------*
FORM fill_tax_item  CHANGING lt_tx LIKE it_tx[].
  DATA: ls_tx LIKE LINE OF it_tx.
  CLEAR ls_tx.
*      ls_tx-itemno_acc = gv_itemno.
  ls_tx-gl_account = t_mwdat-hkont.
  ls_tx-tax_code   = gt_account-mwskz.
  ls_tx-acct_key   = t_mwdat-ktosl.
  ls_tx-cond_key   = t_mwdat-kschl.
*      ls_tx-tax_rate   = t_mwdat-msatz.
*      ls_tx-itemno_tax = gv_itemno.
  COLLECT ls_tx INTO it_tx.
ENDFORM.                    " FILL_TAX_ITEM
*&---------------------------------------------------------------------*
*&      Form  INSERT_TABLE
*&---------------------------------------------------------------------*
FORM modify_table  USING    p_vbeln
                        VALUE(p_tip)
                            p_obj_typ
                            p_obj_key
                            p_obj_sys.
  DATA:
    ls_bl01  LIKE zyb_sd_t_bl01,
    lv_bukrs TYPE bukrs,
    lv_belnr TYPE belnr_d,
    lv_gjahr TYPE gjahr.

  CLEAR: ls_bl01, lv_belnr, lv_gjahr, lv_bukrs.

  lv_belnr = p_obj_key+0(10).
  lv_bukrs = p_obj_key+10(4).
  lv_gjahr = p_obj_key+14(4).

  SELECT SINGLE * FROM zyb_sd_t_bl01
    INTO ls_bl01
   WHERE vbeln EQ p_vbeln.

  CASE p_tip.
    WHEN gc_stk_create OR gc_stk_cancel.
      IF ls_bl01 IS INITIAL.
        ls_bl01-vbeln  = p_vbeln.
        ls_bl01-bukrs  = lv_bukrs.
        ls_bl01-belnr1 = lv_belnr.
        ls_bl01-gjahr1 = lv_gjahr.
        INSERT zyb_sd_t_bl01 FROM ls_bl01.
        COMMIT WORK AND WAIT.
      ELSE.
        ls_bl01-bukrs  = lv_bukrs.
        ls_bl01-belnr1 = lv_belnr.
        ls_bl01-gjahr1 = lv_gjahr.
        MODIFY zyb_sd_t_bl01 FROM ls_bl01.
        COMMIT WORK AND WAIT.
      ENDIF.
    WHEN gc_smm_create OR gc_smm_cancel.
      IF NOT ls_bl01 IS INITIAL.
        ls_bl01-belnr2 = lv_belnr.
        ls_bl01-gjahr2 = lv_gjahr.
        MODIFY zyb_sd_t_bl01 FROM ls_bl01.
        COMMIT WORK AND WAIT.
      ELSE.
        ls_bl01-vbeln  = p_vbeln.
        ls_bl01-bukrs  = lv_bukrs.
        ls_bl01-belnr2 = lv_belnr.
        ls_bl01-gjahr2 = lv_gjahr.
        INSERT zyb_sd_t_bl01 FROM ls_bl01.
        COMMIT WORK AND WAIT.
      ENDIF.
  ENDCASE.
  add_message: 'S' gc_msg_id '011' p_vbeln
               lv_belnr lv_gjahr ''.
  IF 1 = 2.  MESSAGE e011(zsd_vf).  ENDIF.
ENDFORM.                    " INSERT_TABLE
*&---------------------------------------------------------------------*
*&      Form  SMM_ACCOUNTING_RECORD
*&---------------------------------------------------------------------*
FORM smm_accounting_record  CHANGING cf_retcode.
** SMM kaydı için datalar toplanır
  PERFORM account_global_data CHANGING cf_retcode.
  CHECK cf_retcode = 0.
** SMM kaydı oluşurulur.
  PERFORM bapi_smm_record CHANGING cf_retcode.
ENDFORM.                    " SMM_ACCOUNTING_RECORD
*&---------------------------------------------------------------------*
*&      Form  BAPI_SMM_RECORD
*&---------------------------------------------------------------------*
FORM bapi_smm_record  CHANGING retcode.
  DATA:
    gv_itemno TYPE posnr_acc,
    l_netwr   LIKE vbrk-netwr,
    i_wrbtr   LIKE bseg-wrbtr,
    lv_ot     LIKE bapiache09-obj_type,
    lv_ok     LIKE bapiache09-obj_key,
    lv_os     LIKE bapiache09-obj_sys.

** Bapi Tabloları temizlenir
  PERFORM bapi_clear_table.

** Başlık Satırı

  PERFORM  fill_header_account USING gc_smm_create CHANGING ls_hd.

* Mahsuplaştırma belgesi Müşteri Satırı okunur.
  CLEAR gt_accit.
  READ TABLE gt_accit WITH KEY koart = gc_koart_mus.

  CHECK sy-subrc = 0.
  CLEAR gt_acccr.
  READ TABLE gt_acccr WITH KEY awtyp = gt_accit-awtyp
                               awref = gt_accit-awref
                               posnr = gt_accit-posnr
                               curtp = gc_curtp_00.

  CHECK sy-subrc = 0.

  CLEAR gv_itemno.
  LOOP AT gt_vbrp WHERE fkimg GT 0.
    ADD 1 TO gv_itemno.

    CLEAR gt_account.
    READ TABLE gt_account WITH KEY vbeln = gt_vbrp-vbeln
                                   posnr = gt_vbrp-posnr.
*&--------------------------------------------------------------------*
*&  -->  153 lü Ana hesap satırı
*&--------------------------------------------------------------------*
    PERFORM fill_account_item USING gv_itemno gc_smm_create '153'
                       CHANGING it_ag[].
*&--------------------------------------------------------------------*
*&  <--  153 lü Ana hesap satırı
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&  --> 153 lü Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*
    PERFORM fill_currency_items USING 'I' gv_itemno gc_smm_create '153'
                             CHANGING it_ca[].
*&--------------------------------------------------------------------*
*&  <-- 153 lü Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*

    ADD 1 TO gv_itemno.

*&--------------------------------------------------------------------*
*&  -->  621 lü Ana hesap satırı
*&--------------------------------------------------------------------*
    PERFORM fill_account_item USING gv_itemno gc_smm_create '621'
                       CHANGING it_ag[].
*&--------------------------------------------------------------------*
*&  <--  621 lü Ana hesap satırı
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&  --> 621 lü Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*
    PERFORM fill_currency_items USING 'I' gv_itemno gc_smm_create '621'
                             CHANGING it_ca[].
*&--------------------------------------------------------------------*
*&  <-- 621 lü Ana hesap satırı için  PB kalemleri
*&--------------------------------------------------------------------*
  ENDLOOP.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_hd
    IMPORTING
      obj_type       = lv_ot
      obj_key        = lv_ok
      obj_sys        = lv_os
    TABLES
      accountgl      = it_ag
      currencyamount = it_ca
      return         = it_rt.

  LOOP AT it_rt WHERE type CA 'EAX'.
    add_message: it_rt-type it_rt-id it_rt-number it_rt-message_v1
                 it_rt-message_v2 it_rt-message_v3 it_rt-message_v4.
  ENDLOOP.

  IF sy-subrc <> 0.
    PERFORM bapi_commit.
    PERFORM modify_table USING gs_vbrk-vbeln gc_smm_create
                               lv_ot lv_ok lv_os.
  ELSE.
    PERFORM bapi_rollback.
    retcode = 1.
  ENDIF.
ENDFORM.                    " BAPI_SMM_RECORD
*&---------------------------------------------------------------------*
*&      Form  CANCELLED_VENDOR_ACC_RECORD
*&---------------------------------------------------------------------*
FORM cancelled_acc_record USING VALUE(p_type) CHANGING cf_retcode.
  DATA: lf_bkpf LIKE bkpf.
  CLEAR lf_bkpf.


  CASE p_type.
    WHEN gc_stk_cancel.
      CHECK wa_bl01-belnr1 IS NOT INITIAL AND
            wa_bl01-gjahr1 IS NOT INITIAL.
      SELECT SINGLE * FROM bkpf
             INTO lf_bkpf
            WHERE bukrs EQ wa_bl01-bukrs
              AND belnr EQ wa_bl01-belnr1
              AND gjahr EQ wa_bl01-gjahr1.
    WHEN gc_smm_cancel.
      CHECK wa_bl01-belnr2 IS NOT INITIAL AND
            wa_bl01-gjahr2 IS NOT INITIAL.
      SELECT SINGLE * FROM bkpf
             INTO lf_bkpf
            WHERE bukrs EQ wa_bl01-bukrs
              AND belnr EQ wa_bl01-belnr2
              AND gjahr EQ wa_bl01-gjahr2.
  ENDCASE.
  PERFORM bapi_cancelled_acc_record USING p_type lf_bkpf
                                 CHANGING cf_retcode.
ENDFORM.                    " CANCELLED_VENDOR_ACC_RECORD
*&---------------------------------------------------------------------*
*&      Form  BAPI_CANCELLED_ACC_RECORD
*&---------------------------------------------------------------------*
FORM bapi_cancelled_acc_record  USING    p_type
                                         lw_bkpf LIKE bkpf
                                CHANGING retcode.
  DATA:
    lv_busact LIKE bapiache09-bus_act,
    lw_revers LIKE bapiacrev,
    lv_ot     LIKE bapiacrev-obj_type,
    lv_ok     LIKE bapiacrev-obj_key,
    lv_os     LIKE bapiacrev-obj_sys.

  CLEAR: lv_busact, lw_revers, lv_ot, lv_ok, lv_os, it_rt, it_rt[].

  PERFORM get_logical_system_get CHANGING lw_revers-obj_sys.

  lv_busact            = lw_bkpf-glvor.
  lw_revers-obj_type   = lw_bkpf-awtyp.
  lw_revers-obj_key    = lw_bkpf-awkey.
  lw_revers-obj_key_r  = lw_bkpf-awkey.
  lw_revers-pstng_date = lw_bkpf-budat.
  lw_revers-comp_code  = lw_bkpf-bukrs.
  lw_revers-reason_rev = gc_reason_rev.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
    EXPORTING
      reversal = lw_revers
      bus_act  = lv_busact
    IMPORTING
      obj_type = lv_ot
      obj_key  = lv_ok
      obj_sys  = lv_os
    TABLES
      return   = it_rt.

  LOOP AT it_rt WHERE type CA 'EAX'.
    add_message: it_rt-type it_rt-id it_rt-number it_rt-message_v1
                 it_rt-message_v2 it_rt-message_v3 it_rt-message_v4.
  ENDLOOP.

  IF sy-subrc <> 0.
    PERFORM bapi_commit.
    PERFORM modify_table USING gs_vbrk-vbeln p_type
                               lv_ot lv_ok lv_os.
  ELSE.
    PERFORM bapi_rollback.
    retcode = 1.
  ENDIF.
ENDFORM.                    " BAPI_CANCELLED_ACC_RECORD
*&---------------------------------------------------------------------*
*&      Form  CREATE_LOG
*&---------------------------------------------------------------------*
FORM create_log.

  DATA:
    lv_extnum  TYPE balnrext,
    lv_vbeln   TYPE vbeln_vf,
    lv_refresh TYPE c.

  CLEAR: lv_extnum, lv_vbeln, lv_refresh.

  CHECK NOT tb_msg[] IS INITIAL.
  lv_vbeln = p_vbeln.
  PERFORM conversion_exit_alpha_output CHANGING lv_vbeln.

*  CONCATENATE lv_vbeln sy-datum sy-uzeit INTO lv_extnum SEPARATED BY '/'.
  lv_extnum = lv_vbeln.

  FREE: tb_lognumbers.

  IF NOT p_job IS INITIAL.
    lv_refresh = 'X'.
  ENDIF.

  CALL FUNCTION 'ZYB_SD_F_MESSAGE_LOGGING'
    EXPORTING
      i_log_object            = gc_log_obj
      i_log_subobject         = gc_log_subobj
      i_extnumber             = lv_extnum
      i_refresh               = lv_refresh
    IMPORTING
      e_new_lognumbers        = tb_lognumbers
    TABLES
      t_log_message           = tb_msg
    EXCEPTIONS
      log_header_inconsistent = 1
      logging_error           = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " CREATE_LOG
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
FORM conversion_exit_alpha_output  CHANGING VALUE(p_val).
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_val
    IMPORTING
      output = p_val.
ENDFORM.                    " CONVERSION_EXIT_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SHOW_LOG
*&---------------------------------------------------------------------*
FORM show_log.
  DATA:
    l_s_display_profile TYPE bal_s_prof,
    ls_logfilter        TYPE bal_s_lfil,
    l_s_logn            TYPE bal_s_logn,
    l_s_extn            TYPE bal_s_extn,
    l_s_logh            TYPE bal_s_logh,
    l_s_obj             TYPE bal_s_obj,
    l_s_sub             TYPE bal_s_sub.

  CHECK NOT tb_msg[] IS INITIAL.
* get display profile
  CALL FUNCTION 'BAL_DSP_PROFILE_STANDARD_GET'
    IMPORTING
      e_s_display_profile = l_s_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* use grid for display if wanted
  l_s_display_profile-use_grid = 'X'.

* set report to allow saving of variants
  l_s_display_profile-disvariant-report = sy-repid.

* when you use also other ALV lists in your report,
* please specify a handle to distinguish between the display
* variants of these different lists, e.g:
  l_s_display_profile-disvariant-handle = 'LOG'.

** set log filter
  CLEAR ls_logfilter.
  LOOP AT tb_lognumbers INTO wa_lognumbers.
* add extnumber
    CLEAR: l_s_extn.
    l_s_extn-sign   = 'I'.
    l_s_extn-option = 'EQ'.
    l_s_extn-low    = wa_lognumbers-extnumber.
    APPEND l_s_extn TO ls_logfilter-extnumber.

* add lognumber
    CLEAR: l_s_logn.
    l_s_logn-sign   = 'I'.
    l_s_logn-option = 'EQ'.
    l_s_logn-low    = wa_lognumbers-lognumber.
    APPEND l_s_logn TO ls_logfilter-lognumber.

* add log handle
    CLEAR: l_s_logh.
    l_s_logh-sign   = 'I'.
    l_s_logh-option = 'EQ'.
    l_s_logh-low    = wa_lognumbers-log_handle.
    APPEND l_s_logh TO ls_logfilter-log_handle.

* add object
    CLEAR: l_s_obj.
    l_s_obj-sign   = 'I'.
    l_s_obj-option = 'EQ'.
    l_s_obj-low    = gc_log_obj.
    APPEND l_s_obj TO ls_logfilter-object.

* add subobject
    CLEAR: l_s_sub.
    l_s_sub-sign   = 'I'.
    l_s_sub-option = 'EQ'.
    l_s_sub-low    = gc_log_subobj.
    APPEND l_s_sub TO ls_logfilter-subobject.
  ENDLOOP.

* call display function module

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile = l_s_display_profile
      i_s_log_filter      = ls_logfilter
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SHOW_LOG
*&---------------------------------------------------------------------*
*&      Form  BAPI_CANCELLED_BILDOC
*&---------------------------------------------------------------------*
FORM bapi_cancelled_bildoc  USING    p_vbeln
                         CHANGING    retcode.

  DATA:
    i_suc LIKE bapivbrksuccess  OCCURS 0 WITH HEADER LINE,
    i_ret LIKE bapireturn1      OCCURS 0 WITH HEADER LINE.

  FREE: i_suc, i_ret.
  CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
    EXPORTING
      billingdocument = p_vbeln
    TABLES
      return          = i_ret
      success         = i_suc.

  LOOP AT i_ret WHERE type  CA 'E,A,X'.
    retcode = 2.
    PERFORM add_message USING i_ret.
  ENDLOOP.

  IF sy-subrc <> 0.
    READ TABLE i_ret WITH KEY type = 'S'.

    IF sy-subrc = 0.
      PERFORM bapi_commit.
      PERFORM add_message USING i_ret.
    ENDIF.
  ELSE.
    PERFORM bapi_rollback.
  ENDIF.
ENDFORM.                    " BAPI_CANCELLED_BILDOC
*&---------------------------------------------------------------------*
*&      Form  BATCH_INPUT_CANCELLED_BILDOC
*&---------------------------------------------------------------------*
FORM batch_input_cancelled_bildoc  USING    p_vbeln
                                   CHANGING retcode.
  DATA: p_fatno TYPE vbeln_vf.

  FREE: bdcdata, messtab.
  CLEAR: p_fatno.

  PERFORM bdc_dynpro USING 'SAPMV60A'          '0102'.
  PERFORM bdc_field  USING 'BDC_CURSOR'        'KOMFK-VBELN(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'        '/00'.
  PERFORM bdc_field  USING 'KOMFK-VBELN(01)'   p_vbeln.

  PERFORM bdc_dynpro USING 'SAPMV60A'          '0103'.
  PERFORM bdc_field  USING 'BDC_CURSOR'        '*TVFKT-VTEXT(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'        '=SICH'.

  CALL TRANSACTION 'VF11' USING bdcdata
  MODE va_mode UPDATE 'S' MESSAGES INTO messtab.


  LOOP AT messtab WHERE msgtyp CA 'EAX'.
    retcode = 2.
    add_message: messtab-msgtyp messtab-msgid messtab-msgnr
                 messtab-msgv1  messtab-msgv2 messtab-msgv3
                 messtab-msgv4.
  ENDLOOP.

  IF sy-subrc <> 0.

    CLEAR : p_fatno.
    LOOP AT messtab WHERE msgtyp = 'S' AND
                          msgid = 'VF' AND
                          msgnr = '311' .

      p_fatno = messtab-msgv1.
      PERFORM conversion_exit_alpha_input CHANGING p_fatno.

      IF p_fatno <> p_vbeln.
        EXIT.
      ENDIF.
    ENDLOOP.

    PERFORM bapi_commit.
    add_message: messtab-msgtyp messtab-msgid messtab-msgnr
                 messtab-msgv1  messtab-msgv2 messtab-msgv3
                 messtab-msgv4.
  ELSE.
    PERFORM bapi_rollback.
  ENDIF.

ENDFORM.                    " BATCH_INPUT_CANCELLED_BILDOC
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro  USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field  USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
FORM conversion_exit_alpha_input  CHANGING VALUE(p_val).
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_val
    IMPORTING
      output = p_val.
ENDFORM.                    " CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_LOGICAL_SYSTEM_GET
*&---------------------------------------------------------------------*
FORM get_logical_system_get  CHANGING p_obj_sys.
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = p_obj_sys
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc <> 0.
    add_message: sy-msgty sy-msgid sy-msgno
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " GET_LOGICAL_SYSTEM_GET
*&---------------------------------------------------------------------*
*&      Form  CHECK_MAHSUP_FATURASI_SIP
*&---------------------------------------------------------------------*
*& ' '  - Oluşturma
*& 'T'  - Ters Kayıt
*&---------------------------------------------------------------------*
FORM check_mahsup_faturasi_sip USING VALUE(p_val) TYPE c
                                              CHANGING ep_retcode.
  DATA: BEGIN OF lt_vbfa OCCURS 0,
          vbeln TYPE vbeln_nach,
        END OF lt_vbfa.

  DATA:
    lv_vbtyp_v TYPE vbtyp_v,
    lv_vbtyp_n TYPE vbtyp_n,
    ls_vbrk    LIKE vbrk.

  CLEAR: lt_vbfa, lt_vbfa[], lv_vbtyp_v, lv_vbtyp_n.

  CASE p_val.
    WHEN space.
      SELECT COUNT(*) FROM nast
         WHERE kappl EQ 'V3'
           AND objky EQ gs_vbrk-vbeln
           AND kschl EQ gc_kschl_icbill
           AND spras EQ 'T'
           AND vstat EQ '1'.

      IF sy-subrc <> 0.
        IF gs_vbrk-vbtyp EQ 'P'.
          lv_vbtyp_v = 'P'.
          lv_vbtyp_n = '5'.
        ENDIF.
        IF gs_vbrk-vbtyp EQ 'O'.
          lv_vbtyp_v = 'O'.
          lv_vbtyp_n = '6'.
        ENDIF.
      ELSE.

        SELECT DISTINCT vbfa~vbeln
            INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
            FROM vbfa
            INNER JOIN vbrk ON vbrk~vbeln EQ vbfa~vbeln
           WHERE vbfa~vbelv   EQ gs_vbrk-vbeln
             AND vbfa~vbtyp_v EQ lv_vbtyp_v
             AND vbfa~vbtyp_n EQ lv_vbtyp_n
             AND vbrk~fksto   EQ space
             AND vbrk~sfakn   EQ space.
        IF NOT lt_vbfa[] IS INITIAL.
          ep_retcode = 1.
          add_message: 'E' gc_msg_id '015' '' '' '' ''.
          IF 1 = 2.  MESSAGE e015(zsd_vf).  ENDIF.
          EXIT.
        ENDIF.
      ENDIF.

      FREE: lt_vbfa.
      SELECT DISTINCT vbfa~vbeln
          INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
          FROM vbfa
          INNER JOIN vbrk ON vbrk~vbeln EQ vbfa~vbeln
         WHERE vbfa~vbelv   EQ gs_vbrk-vbeln
           AND vbfa~vbtyp_v EQ lv_vbtyp_v
           AND vbfa~vbtyp_n EQ lv_vbtyp_n
           AND vbrk~fksto   EQ space
           AND vbrk~sfakn   EQ space.

      IF NOT lt_vbfa[] IS INITIAL.
        ep_retcode = 1.
        add_message: 'E' gc_msg_id '001' '' '' '' ''.
        IF 1 = 2.  MESSAGE e001(zsd_vf).  ENDIF.
        EXIT.
      ENDIF.
    WHEN 'T'.
      SELECT SINGLE * FROM vbrk
          INTO ls_vbrk
         WHERE vbeln EQ gs_vbrk-sfakn.
  ENDCASE.
ENDFORM.                    " CHECK_MAHSUP_FATURASI_SIP
*&---------------------------------------------------------------------*
*&      Form  CREATE_BIL_DOCU_RELATED_ORDER
*&---------------------------------------------------------------------*
FORM create_bil_docu_related_order  CHANGING ep_retcode.
  DATA: ls_nast  LIKE nast,
        lv_again.

  FREE seltab.
  CLEAR seltab_wa.

  sel: 'S_KAPPL'  'EQ' 'V3'             space.
  sel: 'S_OBJKY'  'EQ' gs_vbrk-vbeln    space.
  sel: 'S_KSCHL'  'EQ' gc_kschl_icbill  space.
  sel: 'S_NACHA'  'EQ' '8'              space.

  SELECT SINGLE * FROM nast INTO ls_nast
          WHERE kappl = 'V3'
            AND objky = gs_vbrk-vbeln
            AND kschl = gc_kschl_icbill
            AND nacha = '8'
            AND vsztp BETWEEN 1 AND 2.
  IF ls_nast-vstat = '1'.
    lv_again = 'X'.
  ELSE.
    CLEAR lv_again.
  ENDIF.

  SUBMIT rsnast00 WITH SELECTION-TABLE seltab
                  WITH p_again = lv_again
                  AND RETURN.
ENDFORM.                    " CREATE_BIL_DOCU_RELATED_ORDER
