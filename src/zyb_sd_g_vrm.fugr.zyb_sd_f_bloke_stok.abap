FUNCTION zyb_sd_f_bloke_stok.
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
  TABLES: tcuch.
  DATA:
    BEGIN OF it_sd_key OCCURS 0,
      vbeln TYPE vbeln_va,
      posnr TYPE posnr_va,
    END OF it_sd_key,
    lt_vbfa       LIKE vbfa OCCURS 0 WITH HEADER LINE,
    lt_vbup       LIKE vbup OCCURS 0 WITH HEADER LINE,
    lt_mska       LIKE mska OCCURS 0 WITH HEADER LINE,
    lt_lips       LIKE lips OCCURS 0 WITH HEADER LINE,
    ls_lips       LIKE lips,
    lt_shp01      LIKE zyb_sd_t_shp01 OCCURS 0 WITH HEADER LINE,
    lt_tmp01_pln  LIKE zyb_sd_t_shp01 OCCURS 0 WITH HEADER LINE,
    lt_tmp01_fiil LIKE zyb_sd_t_shp01 OCCURS 0 WITH HEADER LINE,
    lt_shp02      LIKE zyb_sd_t_shp02 OCCURS 0 WITH HEADER LINE,
    ls_shp02      LIKE zyb_sd_t_shp02.

  DATA: BEGIN OF it_sd_flow OCCURS 0,
          vbelv TYPE vbeln_von,
          posnv TYPE posnr_von,
          vbeln TYPE vbeln_nach,
          posnn TYPE posnr_nach,
          matnr TYPE matnr,
          charg TYPE charg_d,
          lgmng TYPE lgmng,
        END OF it_sd_flow.

  DATA: BEGIN OF lt_likp OCCURS 0 ,
        vbeln TYPE vbeln_vl,
        END OF lt_likp.

  DATA: lv_lock TYPE subrc.
  CLEAR: gs_blk.
  FREE: gt_blk.
  CLEAR: it_sd_key, it_sd_key[], it_sd_flow, it_sd_flow[], tcuch.

  SELECT SINGLE * FROM tcuch.

  IF sd_key_tab[] IS INITIAL AND material_key_tab[] IS INITIAL.
    EXIT.
  ENDIF.

  LOOP AT sd_key_tab.
    it_sd_key-vbeln = sd_key_tab-vbeln.
    it_sd_key-posnr = sd_key_tab-posnr.
    COLLECT it_sd_key.
  ENDLOOP.

  IF material_key_tab[] IS NOT INITIAL.
* Fiili partiler çekilir.
    FREE: lt_tmp01_fiil.
    SELECT * FROM zyb_sd_t_shp01
        INTO TABLE lt_tmp01_fiil
        FOR ALL ENTRIES IN material_key_tab
        WHERE charg_fiili EQ material_key_tab-charg.

* Planlanan Partiler çekilir.
    FREE: lt_tmp01_pln.
    SELECT * FROM zyb_sd_t_shp01
        INTO TABLE lt_tmp01_pln
       FOR ALL ENTRIES IN material_key_tab
       WHERE charg       EQ material_key_tab-charg
         AND charg_fiili EQ space.

    FREE: lt_likp.

IF NOT lt_tmp01_fiil[] IS INITIAL.
    SELECT DISTINCT * FROM likp
        INNER JOIN vbuk ON vbuk~vbeln EQ likp~vbeln
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN lt_tmp01_fiil
        WHERE likp~vbeln EQ lt_tmp01_fiil-vbeln
          AND vbuk~wbstk EQ 'C'.
ENDIF.

IF NOT lt_tmp01_pln[] IS INITIAL.
    SELECT DISTINCT * FROM likp
        INNER JOIN vbuk ON vbuk~vbeln EQ likp~vbeln
        APPENDING CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN lt_tmp01_pln
        WHERE likp~vbeln EQ lt_tmp01_pln-vbeln
          AND vbuk~wbstk EQ 'C'.
ENDIF.

  SORT lt_likp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING vbeln.

    FREE: lt_shp01.
    LOOP AT lt_tmp01_fiil.
      CLEAR lt_shp01.
      CLEAR lt_likp.
      READ TABLE lt_likp WITH  KEY vbeln = lt_tmp01_fiil-vbeln.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING lt_tmp01_fiil TO lt_shp01.
      lt_shp01-charg = lt_shp01-charg_fiili.
      COLLECT lt_shp01.
    ENDLOOP.

    SORT lt_tmp01_fiil BY charg_fiili.
    LOOP AT lt_tmp01_pln.
      CLEAR lt_shp01.

      CLEAR lt_likp.
      READ TABLE lt_likp WITH  KEY vbeln = lt_tmp01_pln-vbeln.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING lt_tmp01_pln TO  lt_shp01.
* planlanan parti fiili olarak çekilmiş ise listeye eklenmez
      CLEAR lt_tmp01_fiil.
      READ TABLE lt_tmp01_fiil WITH KEY charg_fiili = lt_tmp01_pln-charg.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      COLLECT lt_shp01.
    ENDLOOP.

    LOOP AT material_key_tab.
      CLEAR gs_blk.
      LOOP AT lt_shp01 WHERE charg EQ material_key_tab-charg.
        CLEAR gs_blk.
        gs_blk-matnr = material_key_tab-matnr.
        gs_blk-charg = lt_shp01-charg.
        gs_blk-menge = lt_shp01-tesmik.
        gs_blk-bloke = charx.
        SELECT SINGLE meins FROM mara
            INTO gs_blk-meins
           WHERE matnr EQ gs_blk-matnr.
        COLLECT gs_blk INTO gt_blk.
      ENDLOOP.
      IF sy-subrc <> 0.
* Lock lu partiler okunur bloke olarak gösterilir.
        PERFORM enqueue_batch_read USING material_key_tab-matnr
                                         material_key_tab-werks
                                         material_key_tab-charg
                                         tcuch-kzdch
                                CHANGING lv_lock.
        IF lv_lock <> 0.
          MOVE-CORRESPONDING material_key_tab TO gs_blk.
          gs_blk-lock  = 'X'.
          COLLECT gs_blk INTO gt_blk.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF NOT it_sd_key IS INITIAL.
    FREE: lt_mska.
    SELECT * FROM mska
        INTO TABLE lt_mska
       FOR ALL ENTRIES IN it_sd_key
        WHERE vbeln EQ it_sd_key-vbeln
          AND posnr EQ it_sd_key-posnr
          AND kalab GT 0.

    FREE: lt_vbfa.
    SELECT * FROM vbfa
        INTO TABLE lt_vbfa
      FOR ALL ENTRIES IN it_sd_key
        WHERE vbelv EQ it_sd_key-vbeln
          AND posnv EQ it_sd_key-posnr
          AND vbtyp_n EQ 'J'
          AND vbtyp_v EQ 'C'.

    IF sy-subrc = 0.
      FREE: lt_vbup.
      SELECT * FROM vbup
          INTO TABLE lt_vbup
          FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln EQ lt_vbfa-vbeln
            AND posnr EQ lt_vbfa-posnn
            AND wbsta NE 'C'.
*            AND kosta IN (' ','B', 'C').

      FREE: lt_lips.
      SELECT * FROM lips
          INTO TABLE lt_lips
          FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln EQ lt_vbfa-vbeln
            AND posnr EQ lt_vbfa-posnn.
    ENDIF.

    LOOP AT lt_vbfa.
      READ TABLE lt_vbup WITH KEY vbeln = lt_vbfa-vbeln
                                  posnr = lt_vbfa-posnn.
      IF sy-subrc = 0.
        CASE lt_vbup-kosta.
          WHEN 'B' OR 'C'.
            CLEAR lt_lips.
            READ TABLE lt_lips WITH KEY vbeln = lt_vbfa-vbeln
                                        posnr = lt_vbfa-posnn.
            IF sy-subrc = 0.
              CLEAR: it_sd_flow.
              it_sd_flow-vbelv  = lt_vbfa-vbelv.
              it_sd_flow-posnv  = lt_vbfa-posnv.
              it_sd_flow-vbeln  = lt_lips-vbeln.
              it_sd_flow-posnn  = lt_lips-posnr.
              it_sd_flow-matnr  = lt_lips-matnr.
              it_sd_flow-charg  = lt_lips-charg.
              it_sd_flow-lgmng  = lt_lips-lgmng.
              COLLECT it_sd_flow.
            ENDIF.

          WHEN 'A' OR space.
            IF lt_vbup-kosta IS INITIAL.
              CLEAR lt_lips.
              READ TABLE lt_lips WITH KEY vbeln = lt_vbfa-vbeln
                                          posnr = lt_vbfa-posnn.
              IF sy-subrc = 0.
                IF NOT lt_lips-komkz IS INITIAL.
                  CONTINUE.
                ELSE.
                  CLEAR it_sd_flow.
                  it_sd_flow-vbelv = lt_vbfa-vbelv.
                  it_sd_flow-posnv  = lt_vbfa-posnv.
                  it_sd_flow-vbeln  = lt_lips-vbeln.
                  it_sd_flow-posnn  = lt_lips-posnr.
                  it_sd_flow-matnr  = lt_lips-matnr.
                  it_sd_flow-charg  = lt_lips-charg.
                  it_sd_flow-lgmng  = lt_lips-lgmng.
                  COLLECT it_sd_flow.
                  CONTINUE.
                ENDIF.
              ENDIF.
            ENDIF.

            FREE: lt_shp01.
            SELECT * FROM zyb_sd_t_shp01
                INTO TABLE lt_shp01
               WHERE vbeln       EQ lt_vbfa-vbeln
                 AND posnr       EQ lt_vbfa-posnn
                 AND charg_fiili EQ space.

            SELECT SINGLE * FROM lips
              INTO ls_lips
             WHERE vbeln EQ lt_vbfa-vbeln
               AND posnr EQ lt_vbfa-posnn.

            LOOP AT lt_shp01.
              CLEAR: it_sd_flow.
              it_sd_flow-vbelv  = lt_vbfa-vbelv.
              it_sd_flow-posnv  = lt_vbfa-posnv.
              it_sd_flow-vbeln  = lt_shp01-vbeln.
              it_sd_flow-posnn  = lt_shp01-posnr.
              it_sd_flow-matnr  = ls_lips-matnr.
              it_sd_flow-charg  = lt_shp01-charg.
              it_sd_flow-lgmng  = lt_shp01-tesmik.
              COLLECT it_sd_flow.
            ENDLOOP.

          WHEN OTHERS.
        ENDCASE.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    FREE: lt_shp02.
    SELECT * FROM zyb_sd_t_shp02
        INTO TABLE lt_shp02
        FOR ALL ENTRIES IN it_sd_key
       WHERE vbeln    EQ it_sd_key-vbeln
         AND posnr    EQ it_sd_key-posnr
         AND loekz    EQ space
         AND durum    NE 'D'. " Teslimat

    LOOP AT lt_shp02.
      CLEAR: it_sd_flow.
      it_sd_flow-vbelv  = lt_shp02-vbeln.
      it_sd_flow-posnv  = lt_shp02-posnr.
      it_sd_flow-vbeln  = lt_shp02-vbeln_vl.
      it_sd_flow-posnn  = lt_shp02-posnr_vl.
      it_sd_flow-matnr  = lt_shp02-matnr.
      it_sd_flow-charg  = lt_shp02-charg.
      it_sd_flow-lgmng  = lt_shp02-tesmik.
      COLLECT it_sd_flow.
    ENDLOOP.

    LOOP AT it_sd_flow.
      CLEAR gs_blk.
      gs_blk-vbeln = it_sd_flow-vbelv.
      gs_blk-posnr = it_sd_flow-posnv.
      gs_blk-matnr = it_sd_flow-matnr.
      gs_blk-charg = it_sd_flow-charg.
      gs_blk-menge = it_sd_flow-lgmng.
      gs_blk-bloke = charx.

      CLEAR ls_shp02.
      SELECT SINGLE * FROM zyb_sd_t_shp02
          INTO ls_shp02
         WHERE vbeln EQ it_sd_flow-vbelv
           AND posnr EQ it_sd_flow-posnv
           AND charg EQ it_sd_flow-charg
           AND vbeln_vl EQ it_sd_flow-vbeln
           AND posnr_vl EQ it_sd_flow-posnn
           AND loekz  EQ space.

      gs_blk-vbeln_vf = ls_shp02-vbeln_vf.
      gs_blk-tknum    = ls_shp02-svkno.

      SELECT SINGLE meins FROM mara
          INTO gs_blk-meins
         WHERE matnr EQ gs_blk-matnr.
      COLLECT gs_blk INTO gt_blk.
    ENDLOOP.

* Lock lu kayıtlarda listelenir.
    LOOP AT lt_mska.
      CLEAR gs_blk.
* Lock lu partiler okunur bloke olarak gösterilir.
      PERFORM enqueue_batch_read USING lt_mska-matnr
                                       lt_mska-werks
                                       lt_mska-charg
                                       tcuch-kzdch
                              CHANGING lv_lock.
      IF lv_lock <> 0.
        gs_blk-vbeln = lt_mska-vbeln.
        gs_blk-posnr = lt_mska-posnr.
        gs_blk-matnr = lt_mska-matnr.
        gs_blk-charg = lt_mska-charg.
        gs_blk-lock  = 'X'.
        COLLECT gs_blk INTO gt_blk.
      ENDIF.
    ENDLOOP.

  ENDIF.

  bloke_tab[] = gt_blk[].
ENDFUNCTION.
