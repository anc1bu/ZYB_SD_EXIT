function zyb_sd_f_bloke_stok_n.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      BLOKE_TAB STRUCTURE  ZYB_SD_S_BLOKE
*"      SD_KEY_TAB STRUCTURE  ZYB_SD_S_SDKEY OPTIONAL
*"      MATERIAL_KEY_TAB STRUCTURE  ZYB_SD_S_MATKEY OPTIONAL
*"----------------------------------------------------------------------
*&**********************************************************************
*& Yurt içi olduğunda sipariş numarası / kalem numarası verilmez.
*& Yurt dışı olduğunda sipariş numarası / kalem numarası verilir.
*&**********************************************************************
*  TABLES: tcuch.
  data:
    begin of it_sd_key occurs 0,
      vbeln type vbeln_va,
      posnr type posnr_va,
    end of it_sd_key,
    lt_vbfa       like vbfa occurs 0 with header line,
    lt_vbup       like vbup occurs 0 with header line,
    lt_mska       like mska occurs 0 with header line,
    lt_lips       like lips occurs 0 with header line,
    ls_lips       like lips,
    lt_shp01      like zyb_sd_t_shp01 occurs 0 with header line,
    lt_shp01_s    like sorted table of zyb_sd_t_shp01
                  with non-unique key charg with header line,
    lt_tmp01_pln  like zyb_sd_t_shp01 occurs 0 with header line,
    lt_tmp01_fiil like zyb_sd_t_shp01 occurs 0 with header line,
    lt_shp02      like zyb_sd_t_shp02 occurs 0 with header line,
    ls_shp02      like zyb_sd_t_shp02.

  data: begin of it_sd_flow occurs 0,
          vbelv type vbeln_von,
          posnv type posnr_von,
          vbeln type vbeln_nach,
          posnn type posnr_nach,
          matnr type matnr,
          charg type charg_d,
          lgmng type lgmng,
        end of it_sd_flow.

  data: begin of lt_likp occurs 0 ,
          vbeln type vbeln_vl,
        end of lt_likp.

  data: lv_lock type subrc.

  data : lt_shp01x type sorted table of zyb_sd_t_shp01
                  with non-unique key vbeln posnr
                  with header line.

  data : lt_matnr type table of mara-matnr,
         begin of ls_mara,
           matnr type mara-matnr,
           meins type mara-meins,
         end of ls_mara,
         lt_mara like sorted table of ls_mara
                 with non-unique key matnr
                 with header line.

  clear: gs_blk, it_sd_key, it_sd_flow, tcuch, lt_likp, lt_shp01.
  refresh: gt_blk, it_sd_key[], it_sd_flow[], lt_likp[], lt_shp01[].

  select single * from tcuch.

  if sd_key_tab[] is initial and material_key_tab[] is initial.
    exit.
  endif.

  loop at sd_key_tab.
    it_sd_key-vbeln = sd_key_tab-vbeln.
    it_sd_key-posnr = sd_key_tab-posnr.
    collect it_sd_key.
  endloop.

  if material_key_tab[] is not initial.

    "Malzeme bilgileri toparlanır ve ölçü birimi çekilir.
    loop at material_key_tab.
      collect material_key_tab-matnr into lt_matnr.
    endloop.
    if lt_matnr[] is not initial .
      select matnr meins into table lt_mara
         from mara
         for all entries in lt_matnr
         where matnr eq lt_matnr-table_line.
    endif.
    "Fiili paletler çekilir.
    free: lt_tmp01_fiil.
    select * from zyb_sd_t_shp01
        into table lt_tmp01_fiil
        for all entries in material_key_tab
        where charg_fiili eq material_key_tab-charg.
    "Planlanan paletler çekilir.
    free: lt_tmp01_pln.
    select * from zyb_sd_t_shp01
        into table lt_tmp01_pln
       for all entries in material_key_tab
       where charg       eq material_key_tab-charg
         and charg_fiili eq space.
    "Fiili paletlere ait teslimatlar çekilir.
    if not lt_tmp01_fiil[] is initial.
      select distinct * from likp
          inner join vbuk on vbuk~vbeln eq likp~vbeln
          into corresponding fields of table lt_likp
          for all entries in lt_tmp01_fiil
          where likp~vbeln eq lt_tmp01_fiil-vbeln
            and vbuk~wbstk eq 'C'.
    endif.
    "Planlanan paletlere ait teslimatlar çekilir.
    if not lt_tmp01_pln[] is initial.
      select distinct * from likp
          inner join vbuk on vbuk~vbeln eq likp~vbeln
          appending corresponding fields of table lt_likp
          for all entries in lt_tmp01_pln
          where likp~vbeln eq lt_tmp01_pln-vbeln
            and vbuk~wbstk eq 'C'.
    endif.

    sort lt_likp by vbeln.
    delete adjacent duplicates from lt_likp comparing vbeln.
    "Fiili paletlere ait mal çıkışı olmuş teslimat bilgileri toparlanır.
    loop at lt_tmp01_fiil.
      read table lt_likp with  key vbeln = lt_tmp01_fiil-vbeln
                 binary search.
      if sy-subrc = 0.
        continue.
      endif.
      move-corresponding lt_tmp01_fiil to lt_shp01.
      lt_shp01-charg = lt_shp01-charg_fiili.
      collect lt_shp01.
    endloop.
    "Planlanan paletlere ait mal çıkışı olmuş teslimat bilgileri toparlanır.
    loop at lt_tmp01_pln.
      read table lt_likp with  key vbeln = lt_tmp01_pln-vbeln
                         binary search.
      if sy-subrc = 0.
        continue.
      endif.
      "Planlanan palet fiili olarak çekilmiş ise listeye eklenmez
      read table lt_tmp01_fiil with key charg_fiili = lt_tmp01_pln-charg
                               binary search.
      if sy-subrc = 0.
        continue.
      endif.
      move-corresponding lt_tmp01_pln to  lt_shp01.
      collect lt_shp01.
    endloop.

    sort lt_shp01 by charg.
    lt_shp01_s[] = lt_shp01[].
"Palet palet işlemeye başla.
    loop at material_key_tab.
      loop at lt_shp01_s into lt_shp01_s
              where charg eq material_key_tab-charg.
        gs_blk-matnr = material_key_tab-matnr.
        gs_blk-charg = lt_shp01_s-charg.
        gs_blk-menge = lt_shp01_s-tesmik.
        gs_blk-bloke = charx.
        read table lt_mara with table key matnr = gs_blk-matnr.
        if sy-subrc eq 0.
          gs_blk-meins = lt_mara-meins.
        endif.
        collect gs_blk into gt_blk.
        clear gs_blk.
      endloop.
      if sy-subrc <> 0.
* Lock lu partiler okunur bloke olarak gösterilir.
        perform enqueue_batch_read using material_key_tab-matnr
                                         material_key_tab-werks
                                         material_key_tab-charg
                                         tcuch-kzdch
                                changing lv_lock.
        if lv_lock <> 0.
          move-corresponding material_key_tab to gs_blk.
          gs_blk-lock  = 'X'.
          collect gs_blk into gt_blk.
        endif.
      endif.
    endloop.
  endif.

  if not it_sd_key is initial.
    free: lt_mska.
    select * from mska
        into table lt_mska
       for all entries in it_sd_key
        where vbeln eq it_sd_key-vbeln
          and posnr eq it_sd_key-posnr
          and kalab gt 0.

    free: lt_vbfa.
    select * from vbfa
        into table lt_vbfa
      for all entries in it_sd_key
        where vbelv eq it_sd_key-vbeln
          and posnv eq it_sd_key-posnr
          and vbtyp_n eq 'J'
          and vbtyp_v eq 'C'.

    if sy-subrc = 0.
      free: lt_vbup.
      select * from vbup
          into table lt_vbup
          for all entries in lt_vbfa
          where vbeln eq lt_vbfa-vbeln
            and posnr eq lt_vbfa-posnn
            and wbsta ne 'C'.
*            AND kosta IN (' ','B', 'C').

      free: lt_lips.
      select * from lips
          into table lt_lips
          for all entries in lt_vbfa
          where vbeln eq lt_vbfa-vbeln
            and posnr eq lt_vbfa-posnn.
    endif.

    sort lt_vbup by vbeln posnr.
    sort lt_lips by vbeln posnr.


    if lt_vbfa[] is not initial.
      select * into table lt_shp01x from zyb_sd_t_shp01
         for all entries in lt_vbfa
         where vbeln = lt_vbfa-vbeln and
               posnr = lt_vbfa-posnn and
               charg_fiili eq space.

    endif.
    loop at lt_vbfa.
      read table lt_vbup with key vbeln = lt_vbfa-vbeln
                                  posnr = lt_vbfa-posnn
                                  binary search.
      if sy-subrc = 0.
        case lt_vbup-kosta.
          when 'B' or 'C'.
            clear lt_lips.
            read table lt_lips with key vbeln = lt_vbfa-vbeln
                                        posnr = lt_vbfa-posnn
                                        binary search.
            if sy-subrc = 0.
              clear: it_sd_flow.
              it_sd_flow-vbelv  = lt_vbfa-vbelv.
              it_sd_flow-posnv  = lt_vbfa-posnv.
              it_sd_flow-vbeln  = lt_lips-vbeln.
              it_sd_flow-posnn  = lt_lips-posnr.
              it_sd_flow-matnr  = lt_lips-matnr.
              it_sd_flow-charg  = lt_lips-charg.
              it_sd_flow-lgmng  = lt_lips-lgmng.
              collect it_sd_flow.
            endif.

          when 'A' or space.
            if lt_vbup-kosta is initial.
              clear lt_lips.
              read table lt_lips with key vbeln = lt_vbfa-vbeln
                                          posnr = lt_vbfa-posnn
                                          binary search.
              if sy-subrc = 0.
                if not lt_lips-komkz is initial.
                  continue.
                else.
                  clear it_sd_flow.
                  it_sd_flow-vbelv = lt_vbfa-vbelv.
                  it_sd_flow-posnv  = lt_vbfa-posnv.
                  it_sd_flow-vbeln  = lt_lips-vbeln.
                  it_sd_flow-posnn  = lt_lips-posnr.
                  it_sd_flow-matnr  = lt_lips-matnr.
                  it_sd_flow-charg  = lt_lips-charg.
                  it_sd_flow-lgmng  = lt_lips-lgmng.
                  collect it_sd_flow.
                  continue.
                endif.
              endif.
            endif.

            free: lt_shp01.

            loop at lt_shp01x where vbeln       eq lt_vbfa-vbeln
                                and posnr       eq lt_vbfa-posnn  .
              append lt_shp01x to lt_shp01.
            endloop.
*            SELECT * FROM zyb_sd_t_shp01
*                INTO TABLE lt_shp01
*               WHERE vbeln       EQ lt_vbfa-vbeln
*                 AND posnr       EQ lt_vbfa-posnn
*                 AND charg_fiili EQ space.

            clear ls_lips.
            read table lt_lips into ls_lips
                          with key vbeln = lt_vbfa-vbeln
                                        posnr = lt_vbfa-posnn
                                        binary search.

*            SELECT SINGLE * FROM lips
*              INTO ls_lips
*             WHERE vbeln EQ lt_vbfa-vbeln
*               AND posnr EQ lt_vbfa-posnn.

            loop at lt_shp01.
              clear: it_sd_flow.
              it_sd_flow-vbelv  = lt_vbfa-vbelv.
              it_sd_flow-posnv  = lt_vbfa-posnv.
              it_sd_flow-vbeln  = lt_shp01-vbeln.
              it_sd_flow-posnn  = lt_shp01-posnr.
              it_sd_flow-matnr  = ls_lips-matnr.
              it_sd_flow-charg  = lt_shp01-charg.
              it_sd_flow-lgmng  = lt_shp01-tesmik.
              collect it_sd_flow.
            endloop.

          when others.
        endcase.
      else.
        continue.
      endif.
    endloop.

    free: lt_shp02.
    select * from zyb_sd_t_shp02
        into table lt_shp02
        for all entries in it_sd_key
       where vbeln    eq it_sd_key-vbeln
         and posnr    eq it_sd_key-posnr
         and loekz    eq space
         and durum    ne 'D'. " Teslimat

    loop at lt_shp02.
      clear: it_sd_flow.
      it_sd_flow-vbelv  = lt_shp02-vbeln.
      it_sd_flow-posnv  = lt_shp02-posnr.
      it_sd_flow-vbeln  = lt_shp02-vbeln_vl.
      it_sd_flow-posnn  = lt_shp02-posnr_vl.
      it_sd_flow-matnr  = lt_shp02-matnr.
      it_sd_flow-charg  = lt_shp02-charg.
      it_sd_flow-lgmng  = lt_shp02-tesmik.
      collect it_sd_flow.
    endloop.

    data : lt_shp02x type sorted table of zyb_sd_t_shp02
                    with non-unique key vbeln
                                        posnr
                                        charg
                                        vbeln_vl
                                        posnr_vl
                    with header line.
    if it_sd_flow[] is not initial.
      select * into table lt_shp02x from zyb_sd_t_shp02
         for all entries in it_sd_flow
         where vbeln     eq it_sd_flow-vbelv and
               posnr     eq it_sd_flow-posnv and
               charg     eq it_sd_flow-charg and
               vbeln_vl  eq it_sd_flow-vbeln and
               posnr_vl  eq it_sd_flow-posnn and
               loekz     eq space.
    endif.
    loop at it_sd_flow.
      clear gs_blk.
      gs_blk-vbeln = it_sd_flow-vbelv.
      gs_blk-posnr = it_sd_flow-posnv.
      gs_blk-matnr = it_sd_flow-matnr.
      gs_blk-charg = it_sd_flow-charg.
      gs_blk-menge = it_sd_flow-lgmng.
      gs_blk-bloke = charx.

      clear ls_shp02.
      read table lt_shp02x into ls_shp02
        with table key vbeln    = it_sd_flow-vbelv
                       posnr    = it_sd_flow-posnv
                       charg    = it_sd_flow-charg
                       vbeln_vl = it_sd_flow-vbeln
                       posnr_vl = it_sd_flow-posnn.


      gs_blk-vbeln_vf = ls_shp02-vbeln_vf.
      gs_blk-tknum    = ls_shp02-svkno.

      read table lt_mara with table key matnr = gs_blk-matnr.
      if sy-subrc eq 0.
        gs_blk-meins = lt_mara-meins.
      endif.

      collect gs_blk into gt_blk.
    endloop.

* Lock lu kayıtlarda listelenir.
    loop at lt_mska.
      clear gs_blk.
* Lock lu partiler okunur bloke olarak gösterilir.
      perform enqueue_batch_read using lt_mska-matnr
                                       lt_mska-werks
                                       lt_mska-charg
                                       tcuch-kzdch
                              changing lv_lock.
      if lv_lock <> 0.
        gs_blk-vbeln = lt_mska-vbeln.
        gs_blk-posnr = lt_mska-posnr.
        gs_blk-matnr = lt_mska-matnr.
        gs_blk-charg = lt_mska-charg.
        gs_blk-lock  = 'X'.
        collect gs_blk into gt_blk.
      endif.
    endloop.

  endif.

  bloke_tab[] = gt_blk[].
endfunction.
