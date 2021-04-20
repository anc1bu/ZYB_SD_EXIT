FUNCTION zyb_sd_f_read_shipment.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_TKNUM) TYPE  TKNUM
*"  EXPORTING
*"     REFERENCE(E_NAKLIYE) TYPE  ZYB_SD_S_NAKILYE
*"----------------------------------------------------------------------
  DATA: ls_vttk  LIKE vttk,
        ls_tsege LIKE tsege,
        lv_datlo LIKE sy-datlo,
        lv_timlo LIKE sy-timlo.

  CLEAR   ls_vttk.

  SELECT SINGLE * FROM vttk
      INTO ls_vttk
      WHERE tknum EQ i_tknum.

  SELECT SINGLE * FROM tsege
      INTO ls_tsege
     WHERE head_hdl EQ ls_vttk-handle
       AND even EQ 'WSHDR0001' " Yükleme
       AND even_verty EQ '0'. " Plan
  MOVE-CORRESPONDING ls_vttk TO e_nakliye.

  IF NOT ls_tsege-even_tstfr IS INITIAL.
    PERFORM convert_from_timestamp USING ls_tsege-even_tstfr
                                         ls_tsege-even_zonfr
                                CHANGING lv_datlo
                                         lv_timlo.
  ENDIF.
  e_nakliye-lmndat  = lv_datlo.
  e_nakliye-lmnuzt  = lv_timlo.
  e_nakliye-vehicle = ls_vttk-/bev1/rpmowa.
  e_nakliye-bookref = ls_vttk-tndr_trkid.
  e_nakliye-kontip  = ls_vttk-add01.
  e_nakliye-navlun  = ls_vttk-add02.
  e_nakliye-exti2   = ls_vttk-exti2.  "seda
  e_nakliye-tpbez   = ls_vttk-tpbez.  "seda

  PERFORM konteyner_sayisi USING i_tknum
                        CHANGING e_nakliye-kntsys.

  SELECT SINGLE name1 name2 FROM lfa1
        INTO (e_nakliye-tdlnr_nm1, e_nakliye-tdlnr_nm2 )
       WHERE lifnr EQ ls_vttk-tdlnr.

  SELECT SINGLE bezei FROM t173t
      INTO e_nakliye-vsart_txt
     WHERE vsart EQ e_nakliye-vsart
       AND spras EQ 'T'.

  SELECT SINGLE eqktx FROM eqkt
      INTO e_nakliye-eqktx
    WHERE equnr EQ e_nakliye-vehicle
      AND spras EQ 'T'.

  SELECT SINGLE bezei FROM vtadd01t
      INTO e_nakliye-kontip_txt
     WHERE add_info EQ e_nakliye-kontip
       AND spras EQ 'T'.

  SELECT SINGLE bezei FROM vtadd02t
      INTO e_nakliye-navlun_txt
     WHERE add_info EQ e_nakliye-navlun
       AND spras EQ 'T'.


ENDFUNCTION.
