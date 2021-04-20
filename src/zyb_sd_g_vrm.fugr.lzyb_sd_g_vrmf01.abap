*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_VRMF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TABLE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_GLOBAL_DATA
*&---------------------------------------------------------------------*
form get_global_data .
  free:
  gt_c003, gt_batch.
  select * from zyb_sd_t_c003
      into table gt_c003.

  perform get_batch_detail.
endform.                    " GET_GLOBAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_TIP
*&---------------------------------------------------------------------*
form set_tip using    ls_check like zyb_sd_s_vrm_check
             changing ep_islem
                      ep_sobkz.
  data:
    ls_vbap like vbap.

  clear: ls_vbap, ep_islem, ep_sobkz.

  if not ls_check-bwart is initial.
    case  ls_check-bwart.
      when gc_bwart_grs.      ep_islem = gc_tip_grs.
      when gc_bwart_ictoic.   ep_islem = gc_tip_icvir.
      when gc_bwart_ictodis.  ep_islem = gc_tip_disvir.
      when gc_bwart_distoic.  ep_islem = gc_tip_icvir.
      when gc_bwart_distodis. ep_islem = gc_tip_disvir.
      when others. exit.
    endcase.

    if not ep_islem is initial .
      if not ls_check-sobkz is initial.
        ep_sobkz = ls_check-sobkz.
      elseif ls_check-sobkz is initial.
        ep_sobkz = ls_check-umsok.
      endif.
    endif.
  endif.

  check ep_islem is initial.

  if not ls_check-kdauf is initial and
         ls_check-kdpos is not initial.
    clear ls_vbap.

    select single * from vbap
          into ls_vbap
         where vbeln eq ls_check-kdauf
           and posnr eq ls_check-kdpos.

    if  ls_vbap-sobkz eq gc_sobkz_e.
      ep_islem = gc_tip_disvir.
      ep_sobkz = ls_vbap-sobkz.
    else.
      ep_islem = gc_tip_icvir.
    endif.
  endif.

  check ep_islem is initial.

  if not ls_check-ummat is initial.
    ep_islem = gc_tip_icvir.
  endif.

  if not ls_check-mat_kdauf is initial  and
         ls_check-mat_kdpos is not initial.

    select single * from vbap into ls_vbap
        where vbeln eq ls_check-mat_kdauf
          and posnr eq ls_check-mat_kdpos.
    if ls_vbap-sobkz eq gc_sobkz_e.
    endif.
  endif.
endform.                    " SET_TIP
*&---------------------------------------------------------------------*
*&      Form  MAL_GIRIS_DIS
*&---------------------------------------------------------------------*
form mal_giris_dis  using l_check like wa_check.
  data:
    ls_vbap   like vbap,
    lv_extwg  type extwg,
    lv_opnmik type klmeng,
    lv_mnge   type menge_d,
    hata.

  clear: ls_vbap, hata.

  select single * from vbap
      into ls_vbap
     where vbeln eq l_check-mat_kdauf
       and posnr eq l_check-mat_kdpos.


* malzeme kontrolü
  if ls_vbap-matnr ne l_check-matnr.
    perform add_msg using 'E'
                          'ZSD_VRM'
                          '001'
                          'giriş yapılan'
                          space
                          space
                          space.
    if 1 = 2. message s001(zsd_vrm). endif.
  endif.

* kalite kontrolü
  clear lv_extwg.
  select single extwg from mara
      into lv_extwg
     where matnr eq l_check-matnr.
  if lv_extwg ne gc_first and  lv_extwg ne gc_ihr_export
    "--------->> Anıl CENGİZ 27.04.2019 10:43:41
    "YUR-381
    and lv_extwg ne gc_ihr_ucuncu.
    "---------<<
    perform add_msg using 'E'
                      'ZSD_VRM'
                      '002'
                      'First (6) ve İhracat Export (8)'
                      space
                      space
                      space.
    if 1 = 2. message s002(zsd_vrm). endif.
  endif.

* depo yeri kontrolü. 1202 - yarım palet
  if l_check-lgort eq gc_stddis_depo.
    if not l_check-charg is initial.
      perform check_pltdrm_for_lgort using l_check-matnr
                                           l_check-charg
                                           gc_pltdrm_atnam
                                           'YARIM'.
    endif.
  endif.

* ret nedeni kontrolü
  if not ls_vbap-abgru is initial.
    perform add_msg using 'E'
                      'ZSD_VRM'
                      '003'
                      l_check-mat_kdauf
                      l_check-mat_kdpos
                      'Ret nedeni girilmiş bir kaleme mal girişi yapılamaz'
                      space.
    if 1 = 2. message s003(zsd_vrm). endif.
  endif.

* açık sipariş kontrolü (temel ölçü birimi düzeyinde)
  perform open_sales_order using ls_vbap changing lv_opnmik.

  clear lv_mnge.
  if l_check-meins <> ls_vbap-meins.
    perform md_convert_material_unit using l_check-matnr
                                           l_check-menge
                                           l_check-meins
                                           ls_vbap-meins
                                 changing lv_mnge.
  else.
    lv_mnge = l_check-menge.
  endif.

*  IF lv_mnge GT lv_opnmik.
*    CLEAR gv_txt.
*    WRITE lv_opnmik UNIT ls_vbap-meins TO gv_txt.
*    CONDENSE gv_txt.
*
*    PERFORM add_msg USING 'E'
*                      'ZSD_VRM'
*                      '004'
*                      l_check-mat_kdauf
*                      l_check-mat_kdpos
*                      gv_txt
*                      'Açık miktardan fazla giriş yapılamaz!'.
*    IF 1 = 2. MESSAGE s004(zsd_vrm). ENDIF.
*  ENDIF.
endform.                    " MAL_GIRIS_DIS
*&---------------------------------------------------------------------*
*&      Form  ADD_MSG
*&---------------------------------------------------------------------*
form add_msg  using    value(p_type)
                       value(p_id)
                       value(p_number)
                       value(p_msgv1)
                       value(p_msgv2)
                       value(p_msgv3)
                       value(p_msgv4).
  clear tb_msg.
  tb_msg-type        = p_type.
  tb_msg-id          = p_id.
  tb_msg-number      = p_number.
  tb_msg-message_v1  = p_msgv1.
  tb_msg-message_v2  = p_msgv2.
  tb_msg-message_v3  = p_msgv3.
  tb_msg-message_v4  = p_msgv4.
  append tb_msg.
endform.                    " ADD_MSG
*&---------------------------------------------------------------------*
*&      Form  OPEN_SALES_ORDER
*&---------------------------------------------------------------------*
form open_sales_order  using    l_vbap type vbap
                       changing ep_mik.
  data: ls_vbup  type vbup,
        lv_rfmng type rfmng,
        lv_kalab type labst.

  clear: ep_mik, ls_vbup, lv_rfmng, lv_kalab.

  select sum( kalab )  from mska
        into lv_kalab
       where vbeln eq l_vbap-vbeln
         and posnr eq l_vbap-posnr.
*  SELECT SINGLE * FROM vbup
*      INTO ls_vbup
*     WHERE vbeln EQ l_vbap-vbeln
*       AND posnr EQ l_vbap-posnr.

*SELECT SUM( rfmng ) FROM vbfa
*      INTO lv_rfmng
*     WHERE vbelv   EQ l_vbap-vbeln
*       AND posnv   EQ l_vbap-posnr
*       AND vbtyp_n EQ 'J'.

*  ep_mik   = l_vbap-klmeng - lv_rfmng.
  ep_mik   = l_vbap-klmeng - lv_kalab.
endform.                    " OPEN_SALES_ORDER
*&---------------------------------------------------------------------*
*&      Form  MD_CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
form md_convert_material_unit  using    p_matnr
                                        p_menge
                                        p_in_me
                                        p_out_me
                               changing ep_menge.
  clear: ep_menge.

  call function 'MD_CONVERT_MATERIAL_UNIT'
    exporting
      i_matnr              = p_matnr
      i_in_me              = p_in_me
      i_out_me             = p_out_me
      i_menge              = p_menge
    importing
      e_menge              = ep_menge
    exceptions
      error_in_application = 1
      error                = 2
      others               = 3.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.
endform.                    " MD_CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*&      Form  KARAKTERISTIK_KONTROL
*&---------------------------------------------------------------------*
form karakteristik_kontrol  using  value(p_tip)
                                        ls_check like wa_check.
  data: lt_c003       like  zyb_sd_t_c003 occurs 0 with header line,
        lv_kyn_atwrt  type atwrt,
        lv_kyn_atflv  type atflv,
        lv_kyn_pltagr type zyb_sd_e_pltagr,
        lv_kyn_txt    type bezei40,
        lv_hdf_atwrt  type atwrt,
        lv_hdf_atflv  type atflv,
        lv_hdf_pltagr type zyb_sd_e_pltagr,
        lv_hdf_txt    type bezei40,
        subrc         like sy-subrc.


  clear: lt_c003, lt_c003[].

  lt_c003[] = gt_c003[].

* sadece parti sınıfı atalı malzemelerde karakteristikler kontrol edilir.
  perform batch_control using ls_check changing subrc.
  check subrc = 0.

  case p_tip.
    when gc_tip_grs.
      sort lt_c003 by malgrs.
      delete lt_c003 where malgrs eq space.

* Palet Durum Kontrolü
      if not ls_check-charg is initial.
        perform palet_durum_check using ls_check-matnr ls_check-charg.
      endif.
    when gc_tip_icvir.
      sort lt_c003 by virman_ic.
      delete lt_c003 where virman_ic eq space.

* Palet Durum Kontrolü
      if not ls_check-charg is initial.
        perform palet_durum_check using ls_check-matnr ls_check-charg.
      endif.
      if not ls_check-umcha is initial.
        perform palet_durum_check using ls_check-ummat ls_check-umcha.
      endif.

    when gc_tip_disvir.
      sort lt_c003 by virman_dis.
      delete lt_c003 where virman_dis eq space.

* Palet Durum Kontrolü
      if not ls_check-charg is initial.
        perform palet_durum_check using ls_check-matnr ls_check-charg.
      endif.
      if not ls_check-umcha is initial.
        perform palet_durum_check using ls_check-ummat ls_check-umcha.
      endif.
  endcase.

  loop at lt_c003.
    clear: lv_kyn_atwrt , lv_kyn_atflv, lv_hdf_atwrt, lv_hdf_atflv.

    case p_tip.
      when gc_tip_grs.

* Palet Tipi Kontrol
        if gs_batch-atwrt eq 'TAM'.
          if lt_c003-atnam eq gc_palet_atnam.
            perform check_sales_order using lt_c003-atnam
                                            ls_check-matnr
                                            ls_check-charg
                                            ls_check-mat_kdauf
                                            ls_check-mat_kdpos
                                            'Palet Tipi'.
          endif.
        endif.

* Kutu Tipi Kontrol
        if lt_c003-atnam eq gc_kutu_atnam.
          perform check_sales_order using lt_c003-atnam
                                          ls_check-matnr
                                          ls_check-charg
                                          ls_check-mat_kdauf
                                          ls_check-mat_kdpos
                                          'Kutu Tipi'.
        endif.

* Kutu Etiketi Kontrol
        if lt_c003-atnam eq gc_kutet_atnam.
          perform check_sales_order using lt_c003-atnam
                                          ls_check-matnr
                                          ls_check-charg
                                          ls_check-mat_kdauf
                                          ls_check-mat_kdpos
                                          'Kutu Etiketi'.
        endif.

* Karo Alt Bilgisi Kontrol

        if lt_c003-atnam eq gc_karoalt_atnam.
          perform check_sales_order using lt_c003-atnam
                                          ls_check-matnr
                                          ls_check-charg
                                          ls_check-mat_kdauf
                                          ls_check-mat_kdpos
                                          'Karo Alt Bilgisi'.
        endif.

      when gc_tip_icvir.
      when gc_tip_disvir.

* partiler farklı ise karakteristik kontrolü
        if not ls_check-charg is initial and
           not ls_check-umcha is initial  and
           ls_check-charg ne ls_check-umcha.
          clear gs_batch.
          read table gt_batch into gs_batch with key matnr = ls_check-matnr
                                                     charg = ls_check-charg
                                                     atnam = lt_c003-atnam.
          if sy-subrc = 0.
            case gs_batch-atfor.
              when 'CHAR'.            lv_kyn_atwrt = gs_batch-atwrt.
              when 'NUMC' or 'DATS'.  lv_kyn_atflv = gs_batch-atflv.
            endcase.
          endif.

          clear gs_batch.
          read table gt_batch into gs_batch with key matnr = ls_check-ummat
                                                     charg = ls_check-umcha
                                                     atnam = lt_c003-atnam.
          if sy-subrc = 0.
            case gs_batch-atfor.
              when 'CHAR'.            lv_hdf_atwrt = gs_batch-atwrt.
              when 'NUMC' or 'DATS'.  lv_hdf_atflv = gs_batch-atflv.
            endcase.
          endif.

          if ( not lv_kyn_atwrt is initial or not lv_hdf_atwrt is initial )
              and lv_kyn_atwrt ne lv_hdf_atwrt.

            clear: lv_kyn_txt, lv_hdf_txt, gv_txt.

            lv_kyn_txt = lv_kyn_atwrt. condense lv_kyn_txt.
            concatenate 'Kaynak Parti: ' lv_kyn_txt into lv_kyn_txt
                                                 separated by space.
            lv_hdf_txt = lv_hdf_atwrt. condense lv_hdf_txt.

            concatenate 'Hedef Parti: ' lv_hdf_txt into lv_hdf_txt
                                                 separated by space.
            concatenate lv_kyn_txt lv_hdf_txt into gv_txt separated by space.

            perform add_msg using 'E'
                      'ZSD_VRM'
                      '010'
                      gs_batch-atbez
                      gv_txt
                      space
                      space.
            if 1 = 2. message s010(zsd_vrm). endif.
          endif.

          if ( not lv_kyn_atflv is initial or not lv_hdf_atflv is initial )
              and lv_kyn_atflv ne lv_hdf_atflv.

            clear: lv_kyn_txt, lv_hdf_txt, gv_txt.

            if lt_c003-atnam eq gc_pltagr_atnam.
              clear: lv_kyn_pltagr, lv_hdf_pltagr.

              perform convert_fload_to_packed using lv_kyn_atflv
                                           changing lv_kyn_pltagr.

              perform convert_fload_to_packed using lv_hdf_atflv
                                           changing lv_hdf_pltagr.

              write lv_kyn_pltagr unit gs_batch-unit to lv_kyn_txt.
              condense lv_kyn_txt.
              write lv_hdf_pltagr unit gs_batch-unit to lv_hdf_txt.
              condense lv_hdf_txt.
            endif.

            concatenate 'Kaynak Parti: ' lv_kyn_txt into lv_kyn_txt
                                                 separated by space.

            concatenate 'Hedef Parti: ' lv_hdf_txt into lv_hdf_txt
                                                 separated by space.

            concatenate lv_kyn_txt lv_hdf_txt into gv_txt separated by space.

            perform add_msg using 'E'
                      'ZSD_VRM'
                      '010'
                      gs_batch-atbez
                      gv_txt
                      space
                      space.
            if 1 = 2. message s010(zsd_vrm). endif.
          endif.
        endif.

* Hedef Parti Sipariş Bilgileri Kontrolü
        if not ls_check-umcha is initial.

* Yarım paletlerde palet tipi kontrolü yapılmaz.
          clear gs_batch.
          read table gt_batch into gs_batch with key matnr = ls_check-ummat
                                                     charg = ls_check-umcha
                                                     atnam = gc_pltdrm_atnam.
          if sy-subrc = 0 .
            if gs_batch-atwrt eq 'YARIM' and lt_c003-atnam eq gc_palet_atnam.
              clear lt_c003-atnam.
            endif.
          endif.

* Palet Tipi Kontrol
          if lt_c003-atnam eq gc_palet_atnam.
            perform check_sales_order using lt_c003-atnam
                                            ls_check-ummat
                                            ls_check-umcha
                                            ls_check-kdauf
                                            ls_check-kdpos
                                            'Palet Tipi'.
          endif.

* Kutu Tipi Kontrol
          if lt_c003-atnam eq gc_kutu_atnam.
            perform check_sales_order using lt_c003-atnam
                                            ls_check-ummat
                                            ls_check-umcha
                                            ls_check-kdauf
                                            ls_check-kdpos
                                            'Kutu Tipi'.
          endif.

* Kutu Etiketi Kontrol
          if lt_c003-atnam eq gc_kutet_atnam.
            perform check_sales_order using lt_c003-atnam
                                            ls_check-ummat
                                            ls_check-umcha
                                            ls_check-kdauf
                                            ls_check-kdpos
                                            'Kutu Etiketi'.
          endif.

* Karo Alt Bilgisi Kontrol
          if lt_c003-atnam eq gc_karoalt_atnam.
            perform check_sales_order using lt_c003-atnam
                                            ls_check-ummat
                                            ls_check-umcha
                                            ls_check-kdauf
                                            ls_check-kdpos
                                            'Karo Alt Bilgisi'.
          endif.
        endif.
    endcase.
  endloop.
endform.                    " KARAKTERISTIK_KONTROL
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_DETAIL
*&---------------------------------------------------------------------*
form get_batch_detail.


  loop at tb_check into wa_check.

    if not wa_check-charg is initial.
      perform batch_read using wa_check-matnr
                               wa_check-werks
                               wa_check-charg.
    endif.
    if not wa_check-umcha is initial and
           wa_check-umcha ne wa_check-charg.
      perform batch_read using wa_check-ummat
                               wa_check-umwrk
                               wa_check-umcha.
    endif.
  endloop.
endform.                    " GET_BATCH_DETAIL
*&---------------------------------------------------------------------*
*&      Form  BATCH_READ
*&---------------------------------------------------------------------*
form batch_read  using    p_matnr
                          p_werks
                          p_charg.
  data:
    val_num  type standard table of  bapi1003_alloc_values_num  with header line,
    val_char type standard table of  bapi1003_alloc_values_char with header line,
    val_curr type standard table of  bapi1003_alloc_values_curr with header line,
    lt_ret   type standard table of  bapiret2 with header line.

  clear: val_num, val_num[], val_char, val_char[], val_curr,
         val_curr[], lt_ret, lt_ret[].

  call function 'ZYB_SD_F_BATCH_READ'
    exporting
      i_matnr  = p_matnr
      i_werks  = p_werks
      i_charg  = p_charg
    tables
      val_num  = val_num
      val_char = val_char
      val_curr = val_curr
      return   = lt_ret.

  clear gs_batch.
  if not val_num[] is initial.
    loop at val_num.
      clear gs_batch.
      gs_batch-matnr = p_matnr.
      gs_batch-charg = p_charg.
      gs_batch-atnam = val_num-charact.
      gs_batch-atbez = val_num-charact_descr.

      select single atfor from cabn
          into gs_batch-atfor
         where atnam eq gs_batch-atnam.

      gs_batch-atflv = val_num-value_from.
      gs_batch-unit  = val_num-unit_from.
      append gs_batch to gt_batch.
    endloop.
  endif.
  if not val_char[] is initial.
    loop at val_char.
      clear gs_batch.
      gs_batch-matnr = p_matnr.
      gs_batch-charg = p_charg.
      gs_batch-atnam = val_char-charact.
      gs_batch-atbez = val_char-charact_descr.

      select single atfor from cabn
          into gs_batch-atfor
         where atnam eq gs_batch-atnam.

      gs_batch-atwrt = val_char-value_neutral.
      append gs_batch to gt_batch.
    endloop.
  endif.
endform.                    " BATCH_READ
*&---------------------------------------------------------------------*
*&      Form  DIS_VIRMAN_CHECK
*&---------------------------------------------------------------------*
form dis_virman_check  using ls_check like wa_check.
  data:
    ls_vbap   type vbap,
    lv_opnmik type klmeng,
    lv_mnge   type menge_d,
    lv_blkmik type menge_d,
    lv_auart  type auart.

* Bloke Stok için
  data:
    tb_blk    like zyb_sd_s_bloke occurs 0 with header line,
    tb_sdkey  like zyb_sd_s_sdkey occurs 0 with header line,
    tb_matkey like zyb_sd_s_matkey occurs 0 with header line.

* Üretim Siparişi İçin
  data:
    lt_orinf like ordinf_cu occurs 0 with header line.
  clear ls_vbap.

* kaynak hedef malzeme karşılaştırma
  if ls_check-matnr ne ls_check-ummat.
    perform add_msg using 'E'
                          'ZSD_VRM'
                          '007'
                          space
                          space
                          space
                          space.
    if 1 = 2. message s007(zsd_vrm). endif.
  endif.

* hedef malzeme sipariş kontrolü
  clear lv_auart.
  select single auart from vbak
        into lv_auart
       where vbeln eq ls_check-kdauf.

  select single * from vbap
      into ls_vbap
     where vbeln eq ls_check-kdauf
       and posnr eq ls_check-kdpos.

  if ls_check-ummat ne ls_vbap-matnr.
    perform add_msg using 'E'
                          'ZSD_VRM'
                          '001'
                          'virman yapılan'
                          space
                          space
                          space.
    if 1 = 2. message s001(zsd_vrm). endif.
  endif.

* depo yeri kontrolü. 1202 - yarım palet

* hedef sipariş üzerinde ret nedeni olamaz.
  if not ls_vbap-abgru is initial.
    perform add_msg using 'E'
                      'ZSD_VRM'
                      '008'
                      wa_check-kdauf
                      wa_check-kdpos
                      'Ret nedeni girilmiş bir kaleme virman yapılamaz!'
                      space.
    if 1 = 2. message s008(zsd_vrm). endif.
  endif.

* hedef sipariş açık miktar kadar virman yapılabilir.
* açık sipariş kontrolü (temel ölçü birimi düzeyinde)

  perform open_sales_order using ls_vbap changing lv_opnmik.

  clear lv_mnge.
  if ls_check-meins <> ls_vbap-meins.
    perform md_convert_material_unit using ls_check-matnr
                                           ls_check-menge
                                           ls_check-meins
                                           ls_vbap-meins
                                 changing lv_mnge.
  else.
    lv_mnge = wa_check-menge.
  endif.
* rf user eklenecek rfuserde sipariş kalemi altındaki stok miktarı
* kontrolü olmayacak.
  if lv_mnge gt lv_opnmik and lv_auart ne gc_auart_thmn and
     ( sy-uname eq 'FALTINA' or sy-uname eq 'FALTINAY' ).
    clear gv_txt.
    write lv_opnmik unit ls_vbap-meins to gv_txt.
    condense gv_txt.

    perform add_msg using 'E'
                      'ZSD_VRM'
                      '009'
                      ls_check-kdauf
                      ls_check-kdpos
                      gv_txt
                      'Açık miktardan fazla virman yapılamaz!'.
    if 1 = 2. message s009(zsd_vrm). endif.
  endif.

*** Hatalı çalışıyor ise aşağıdaki kod bloğu kapatılacak
** Bloke Stok (Kaynak kaleme ait)
  free: tb_blk.
  clear: tb_sdkey, tb_sdkey[], tb_matkey, tb_matkey[].

  if not ls_check-mat_kdauf is initial and
     not ls_check-mat_kdpos is initial.
    tb_sdkey-vbeln = ls_check-mat_kdauf.
    tb_sdkey-posnr = ls_check-mat_kdpos.
    append tb_sdkey.
  else.
    tb_matkey-matnr = ls_check-matnr.
    tb_matkey-charg = ls_check-charg.
    append tb_matkey.
  endif.

"YUR-134
*  call function 'ZYB_SD_F_BLOKE_STOK'
  call function 'ZYB_SD_F_BLOKE_STOK_N'
    tables
      bloke_tab        = tb_blk
      sd_key_tab       = tb_sdkey
      material_key_tab = tb_matkey.

  clear lv_mnge.
  lv_mnge = ls_check-menge.
  loop at tb_blk where vbeln eq ls_check-mat_kdauf
                   and posnr eq ls_check-mat_kdpos
                   and charg eq ls_check-charg.
    clear lv_blkmik.
    if tb_blk-meins <> ls_check-meins.
      perform md_convert_material_unit using tb_blk-matnr
                                             tb_blk-menge
                                             tb_blk-meins
                                             ls_check-meins
                                   changing lv_blkmik.
    else.
      lv_blkmik = tb_blk-menge.
    endif.
    lv_mnge = lv_mnge - lv_blkmik.
    if lv_mnge le 0.
      exit.
    endif.
  endloop.

  if lv_mnge le 0.
    perform add_msg using 'E'
                      'ZSD_VRM'
                      '013'
                      ls_check-charg
                      space
                      space
                      space.

    if 1 = 2. message s013(zsd_vrm). endif.
  endif.

* Üretim Siparişi Kontrolü (hedef sipariş için)
* açık olan üretim siparişi var ise virman yapılamaz (Melis istedi)
  free: lt_orinf.
  call function 'CO_61_CHECK_ORD_TO_SDOC'
    exporting
      vbeln_imp          = ls_check-kdauf
      vbelp_imp          = ls_check-kdpos
    tables
      orinf_tab          = lt_orinf
    exceptions
      order_comp         = 1
      order_exists       = 2
      order_inwork       = 3
      insufficient_input = 4
      others             = 5.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

  data: lv_objnr type j_objnr,
        ls_jest  like jest,
        hata     type c.

  ranges: r_stat for jest-stat.
* üretim siparişi sistem tamamlama durumları
  clear: r_stat, r_stat[].
  r_stat = 'IEQ'.
  r_stat-low = 'I0001'.
  collect r_stat.
  r_stat-low = 'I0013'.
  collect r_stat.
  r_stat-low = 'I0043'.
  collect r_stat.
  r_stat-low = 'I0045'.
  collect r_stat.
  r_stat-low = 'I0046'.
  collect r_stat.
  r_stat-low = 'I0076'.
  collect r_stat.

  clear hata.
  if not lt_orinf[] is initial.
    loop at lt_orinf where flg_comp ne 'X'.
      clear: lv_objnr, ls_jest.
      select single objnr from aufk
            into lv_objnr
           where aufnr eq lt_orinf-aufnr.

      select single * from jest
          into ls_jest
         where objnr eq lv_objnr
           and stat  in r_stat.
      if sy-subrc <> 0.
        hata = 'X'.
        exit.
      endif.
    endloop.

    if hata = 'X'.
      perform add_msg using 'E'
                      'ZSD_VRM'
                      '014'
                      ls_check-kdauf
                      ls_check-kdpos
                      space
                      space.
      if 1 = 2. message s014(zsd_vrm). endif.
    endif.
  endif.


** Depo birimi kontrolü
  perform storage_unit_check using ls_check-matnr
                                   ls_check-werks
                                   ls_check-lgort
                                   ls_check-charg
                                   ls_check-menge
                                   ls_check-meins
                                   space.
endform.                    " DIS_VIRMAN_CHECK
*&---------------------------------------------------------------------*
*&      Form  CONVERT_FLOAD_TO_PACKED
*&---------------------------------------------------------------------*
form convert_fload_to_packed  using    p_atflv
                              changing value(ep_val).
  clear ep_val.
  call function 'MURC_ROUND_FLOAT_TO_PACKED'
    exporting
      if_float  = p_atflv
    importing
      ef_packed = ep_val
    exceptions
      overflow  = 1
      others    = 2.
endform.                    " CONVERT_FLOAD_TO_PACKED
*&---------------------------------------------------------------------*
*&      Form  CHECK_SALES_ORDER
*&---------------------------------------------------------------------*
form check_sales_order  using    p_atnam
                                 p_matnr
                                 p_charg
                                 p_vbeln
                                 p_posnr
                             value(p_txt).
  data: ls_vbap like vbap.
  clear ls_vbap.

  select single * from vbap
      into ls_vbap
     where vbeln eq p_vbeln
       and posnr eq p_posnr.

  clear gs_batch.
  read table gt_batch into gs_batch with key matnr = p_matnr
                                             charg = p_charg
                                             atnam = p_atnam.

  if sy-subrc = 0.
    case p_atnam.
      when gc_palet_atnam.
        if ls_vbap-mvgr1 <> gs_batch-atwrt.
          clear gv_txt.
          concatenate '(' 'Partideki: '    gs_batch-atwrt
                          'Siparişteki: '  ls_vbap-mvgr1 ')'
                  into gv_txt separated by space.

          perform add_msg using 'E'
                    'ZSD_VRM'
                    '006'
                    p_vbeln
                    p_posnr
                    p_txt
                    gv_txt.
          if 1 = 2. message s006(zsd_vrm). endif.
        endif.
      when gc_kutu_atnam.
        if ls_vbap-mvgr2 <> gs_batch-atwrt.
          clear gv_txt.
          concatenate '(' 'Partideki: '    gs_batch-atwrt
                          'Siparişteki: '  ls_vbap-mvgr2 ')'
                  into gv_txt separated by space.

          perform add_msg using 'E'
                    'ZSD_VRM'
                    '006'
                    p_vbeln
                    p_posnr
                    p_txt
                    gv_txt.
          if 1 = 2. message s006(zsd_vrm). endif.
        endif.
      when gc_kutet_atnam.
        if ls_vbap-mvgr3 <> gs_batch-atwrt.
          clear gv_txt.
          concatenate '(' 'Partideki: '    gs_batch-atwrt
                          'Siparişteki: '  ls_vbap-mvgr3 ')'
                  into gv_txt separated by space.

          perform add_msg using 'E'
                    'ZSD_VRM'
                    '006'
                    p_vbeln
                    p_posnr
                    p_txt
                    gv_txt.
          if 1 = 2. message s006(zsd_vrm). endif.
        endif.
      when gc_karoalt_atnam.
        if ls_vbap-mvgr4 <> gs_batch-atwrt.
          clear gv_txt.
          concatenate '(' 'Partideki: '    gs_batch-atwrt
                          'Siparişteki: '  ls_vbap-mvgr4 ')'
                  into gv_txt separated by space.

          perform add_msg using 'E'
                    'ZSD_VRM'
                    '006'
                    p_vbeln
                    p_posnr
                    p_txt
                    gv_txt.
          if 1 = 2. message s006(zsd_vrm). endif.
        endif.
    endcase.

  else.

    perform add_msg using 'E'
              'ZSD_VRM'
              '005'
              p_vbeln
              p_posnr
              p_txt
              space.
    if 1 = 2. message s005(zsd_vrm). endif.
  endif.
endform.                    " CHECK_SALES_ORDER
*&---------------------------------------------------------------------*
*&      Form  PALET_DURUM_CHECK
*&---------------------------------------------------------------------*
form palet_durum_check  using    p_matnr
                                 p_charg.
  clear gs_batch.
  read table gt_batch into gs_batch with key matnr = p_matnr
                                             charg = p_charg
                                             atnam = gc_pltdrm_atnam.
  if sy-subrc <> 0.
    perform add_msg using 'E'
                      'ZSD_VRM'
                      '012'
                      space
                      space
                      space
                      space.
    if 1 = 2. message s012(zsd_vrm). endif.
  endif.
endform.                    " PALET_DURUM_CHECK
*&---------------------------------------------------------------------*
*&      Form  CHECK_PLTDRM_FOR_LGORT
*&---------------------------------------------------------------------*
form check_pltdrm_for_lgort  using    p_matnr
                                      p_charg
                                      p_atnam
                                value(p_drm).
  clear gs_batch.
  read table gt_batch into gs_batch with key matnr = p_matnr
                                             charg = p_charg
                                             atnam = gc_pltdrm_atnam.
  if sy-subrc = 0.
    if gs_batch-atwrt ne p_drm.
      perform add_msg using 'E'
                        'ZSD_VRM'
                        '011'
                        p_drm
                        space
                        space
                        space.
      if 1 = 2. message s011(zsd_vrm). endif.
    endif.
  endif.
endform.                    " CHECK_PLTDRM_FOR_LGORT
*&---------------------------------------------------------------------*
*&      Form  IC_VIRMAN_CHECK
*&---------------------------------------------------------------------*
form ic_virman_check  using    l_check like wa_check.
* depo yeri kontrolü. 1202 - yarım palet
  if l_check-umlgo eq gc_stddis_depo.
    if not l_check-umcha is initial.
      perform check_pltdrm_for_lgort using l_check-ummat
                                           l_check-umcha
                                           gc_pltdrm_atnam
                                           'YARIM'.
    endif.
  endif.

** Depo birimi kontrolü
  perform storage_unit_check using l_check-matnr
                                   l_check-werks
                                   l_check-lgort
                                   l_check-charg
                                   l_check-menge
                                   l_check-meins
                                   space.

endform.                    " IC_VIRMAN_CHECK
*&---------------------------------------------------------------------*
*&      Form  BATCH_CONTROL
*&---------------------------------------------------------------------*
form batch_control using ls_check like wa_check
                changing p_subrc.
  p_subrc = 0.

  perform batch_class_read using ls_check-matnr changing p_subrc.
  check p_subrc is initial.

  if ls_check-ummat is not initial  and ls_check-matnr ne ls_check-ummat.
    perform batch_class_read using ls_check-ummat changing p_subrc.
    if not p_subrc is initial.
      exit.
    endif.
  endif.
endform.                    " BATCH_CONTROL
*&---------------------------------------------------------------------*
*&      Form  BATCH_CLASS_READ
*&---------------------------------------------------------------------
form batch_class_read  using    p_matnr
                       changing ep_subrc.
  data:
    lv_class like klah-class,
    lv_klart like klah-klart,
    lv_obtab like tclt-obtab,
    lv_objec like kssk-objek.

  clear: lv_class, lv_klart, lv_obtab, lv_objec.

  call function 'QMSP_MATERIAL_BATCH_CLASS_READ'
    exporting
      i_matnr                = p_matnr
*     i_charg                = ls_check-charg
*     i_werks                = ls_werks
      i_mara_level           = space
      i_no_dialog            = 'X'
    importing
      e_class                = lv_class
      e_klart                = lv_klart
      e_obtab                = lv_obtab
      e_objec                = lv_objec
    exceptions
      no_class               = 1
      internal_error_classif = 2
      no_change_service      = 3
      others                 = 4.

  if sy-subrc <> 0.
    ep_subrc = sy-subrc.
    exit.
  else.
    if lv_class ne gc_batch_class.
      ep_subrc = 1.
      exit.
    endif.
  endif.
endform.                    " BATCH_CLASS_READ
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_BATCH_READ
*&---------------------------------------------------------------------*
form enqueue_batch_read  using    p_matnr
                                  p_werks
                                  p_charg
                                  p_kzdch
                      changing   ep_lock.
  data: lv_garg  type seqg3-garg,
        lv_gname type seqg3-gname,
        lt_seqg3 like seqg3 occurs 0 with header line.
*- plant level
  data: begin of %a_mcha,
*       Lock argument for table MCHA
          mandt type mcha-mandt,
          matnr type mcha-matnr,
          werks type mcha-werks,
          charg type mcha-charg,
        end of %a_mcha.

  data: begin of %a_mch1,
*       Lock argument for table MCH1
          mandt type mch1-mandt,
          matnr type mch1-matnr,
          charg type mch1-charg,
        end of %a_mch1.

  constants:
    lc_matnr_dummy type matnr value '000000000000000000'.

  check not p_matnr is initial.
  check not p_werks is initial.
  check not p_charg is initial.
  check not p_kzdch is initial.

  clear ep_lock.

  clear: lv_garg, lv_gname.
  case p_kzdch.
    when '0'. " üretim yeri düzeyinde
      lv_gname = 'MCHA'.
      call 'C_ENQ_WILDCARD' id 'HEX0' field %a_mcha.
      %a_mcha-mandt = sy-mandt.
      %a_mcha-matnr = p_matnr.
      %a_mcha-werks = p_werks.
      %a_mcha-charg = p_charg.

      lv_garg = %a_mcha.
    when '2'. " client bazında
      lv_gname = 'MCH1'.
* Initialization of lock argument:
      call 'C_ENQ_WILDCARD' id 'HEX0' field %a_mch1.

      %a_mch1-mandt = sy-mandt.
      %a_mch1-matnr = lc_matnr_dummy.
      %a_mch1-charg = p_charg.
      lv_garg = %a_mch1.

    when others. " malzeme bazında
      lv_gname = 'MCH1'.
* Initialization of lock argument:
      call 'C_ENQ_WILDCARD' id 'HEX0' field %a_mch1.

      %a_mch1-mandt = sy-mandt.
      %a_mch1-matnr = p_matnr.
      %a_mch1-charg = p_charg.
      lv_garg = %a_mch1.
  endcase.

  free: lt_seqg3.
  call function 'ENQUEUE_READ'
    exporting
      gclient               = sy-mandt
      gname                 = lv_gname
      garg                  = lv_garg
      guname                = space
    tables
      enq                   = lt_seqg3
    exceptions
      communication_failure = 1
      system_failure        = 2
      others                = 3.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

  read table lt_seqg3 index 1.
  if sy-subrc = 0.
    ep_lock = 1.
  endif.
endform.                    " ENQUEUE_BATCH_READ
*&---------------------------------------------------------------------*
*&      Form  STORAGE_UNIT_CHECK
*&---------------------------------------------------------------------*
*      " Depo birimi oluşturulan kalemler için virman işlemi yapılamaz
*----------------------------------------------------------------------*
form storage_unit_check  using    p_matnr
                                  p_werks
                                  p_lgort
                                  p_charg
                                  p_menge
                                  p_meins
                            value(p_out) type c.
  data:
    lv_lenum_verme    type lqua_verme,
    lv_wo_lenum_verme type lqua_verme,
    ls_mara           type mara,
    lv_mnge           type menge_d,
    lt_lqua           like lqua occurs 0 with header line.

  clear ls_mara.
  select single * from mara into ls_mara
        where matnr eq p_matnr.

  clear: lt_lqua, lt_lqua[].
  select * from lqua into table lt_lqua
    where matnr eq p_matnr
      and werks eq p_werks
      and lgort eq p_lgort
      and charg eq p_charg.

  clear: lv_lenum_verme, lv_wo_lenum_verme.
  loop at lt_lqua where lgtyp(1) ne '9'.

    clear lv_mnge.
    if lt_lqua-meins <> ls_mara-meins.
      perform md_convert_material_unit using lt_lqua-matnr
                                             lt_lqua-verme
                                             lt_lqua-meins
                                             ls_mara-meins
                                   changing lv_mnge.
    else.
      lv_mnge = lt_lqua-verme.
    endif.

* Depo birimli miktar
    if lt_lqua-lenum is not initial.
      lv_lenum_verme = lv_lenum_verme + lv_mnge.

    else.
* Depo birimsiz miktar
      lv_wo_lenum_verme = lv_wo_lenum_verme + lv_mnge.
    endif.
  endloop.

  clear lv_mnge.
  if p_meins <> ls_mara-meins.
    perform md_convert_material_unit using p_matnr
                                           p_menge
                                           p_meins
                                           ls_mara-meins
                                 changing lv_mnge.
  else.
    lv_mnge = p_menge.
  endif.
  if lv_lenum_verme gt 0 and ( lv_mnge gt lv_wo_lenum_verme ).
    if p_out is initial.
      perform add_msg using 'E'
                      'ZSD_VRM'
                      '015'
                      p_matnr
                      p_charg
                      space
                      space.
      if 1 = 2. message s015(zsd_vrm). endif.
    else.
      message e015(zsd_vrm) with p_matnr p_charg.
    endif.

  endif.
endform.                    " STORAGE_UNIT_CHECK
