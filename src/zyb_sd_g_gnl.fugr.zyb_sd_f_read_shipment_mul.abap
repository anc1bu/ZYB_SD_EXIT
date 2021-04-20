FUNCTION zyb_sd_f_read_shipment_mul.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_TKNUM STRUCTURE  BAPIDLV_RANGE_TKNUM
*"      ET_NAKLIYE STRUCTURE  ZYB_SD_S_NAKLIYE_MUL
*"----------------------------------------------------------------------
  DATA: lt_vttk  TYPE STANDARD TABLE OF vttk,
        ls_vttk  LIKE vttk,
        lt_tsege LIKE tsege OCCURS 0 WITH HEADER LINE,
        ls_tsege LIKE tsege,
        lv_datlo LIKE sy-datlo,
        lv_timlo LIKE sy-timlo.

  CLEAR: lt_vttk, lt_vttk[], lt_tsege, lt_tsege[].

  CHECK NOT it_tknum[] IS INITIAL.

  SELECT * FROM vttk
      INTO TABLE lt_vttk
    FOR ALL ENTRIES IN it_tknum
      WHERE tknum = it_tknum-shipmentnum_low.

  CHECK NOT lt_vttk[] IS INITIAL.
  SELECT * FROM tsege
      INTO TABLE  lt_tsege
    FOR ALL ENTRIES IN lt_vttk
     WHERE head_hdl EQ lt_vttk-handle
       AND even EQ 'WSHDR0001' " Yükleme
       AND even_verty EQ '0'. " Plan

  LOOP AT lt_vttk INTO ls_vttk.
    CLEAR et_nakliye.
    MOVE-CORRESPONDING ls_vttk TO et_nakliye.

    CLEAR ls_tsege.
   READ TABLE lt_tsege INTO ls_tsege WITH KEY head_hdl = ls_vttk-handle.
    IF sy-subrc = 0.

      IF NOT ls_tsege-even_tstfr IS INITIAL.
        PERFORM convert_from_timestamp USING ls_tsege-even_tstfr
                                             ls_tsege-even_zonfr
                                    CHANGING lv_datlo
                                             lv_timlo.
      ENDIF.
    ENDIF.

    PERFORM konteyner_sayisi USING ls_vttk-tknum
                          CHANGING et_nakliye-kntsys.

    et_nakliye-lmndat  = lv_datlo.
    et_nakliye-lmnuzt  = lv_timlo.
    et_nakliye-vehicle = ls_vttk-/bev1/rpmowa.
    et_nakliye-bookref = ls_vttk-tndr_trkid.
    et_nakliye-kontip  = ls_vttk-add01.
    et_nakliye-navlun  = ls_vttk-add02.

    SELECT SINGLE name1 name2 FROM lfa1
          INTO (et_nakliye-tdlnr_nm1, et_nakliye-tdlnr_nm2 )
         WHERE lifnr EQ ls_vttk-tdlnr.

    SELECT SINGLE bezei FROM t173t
        INTO et_nakliye-vsart_txt
       WHERE vsart EQ et_nakliye-vsart
         AND spras EQ 'T'.

    SELECT SINGLE eqktx FROM eqkt
        INTO et_nakliye-eqktx
      WHERE equnr EQ et_nakliye-vehicle
        AND spras EQ 'T'.

    SELECT SINGLE bezei FROM vtadd01t
        INTO et_nakliye-kontip_txt
       WHERE add_info EQ et_nakliye-kontip
         AND spras EQ 'T'.

    SELECT SINGLE bezei FROM vtadd02t
        INTO et_nakliye-navlun_txt
       WHERE add_info EQ et_nakliye-navlun
         AND spras EQ 'T'.
    APPEND et_nakliye.
  ENDLOOP.
ENDFUNCTION.
