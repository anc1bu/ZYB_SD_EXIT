*&---------------------------------------------------------------------*
*&  Include           ZXV56U18
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FCODE) LIKE  T185F-FCODE
*"     VALUE(I_XVTTK_WA) LIKE  VTTKVB STRUCTURE  VTTKVB
*"     VALUE(I_XVTTS_WA) LIKE  VTTSVB STRUCTURE  VTTSVB OPTIONAL
*"     VALUE(I_XVTTP_WA) LIKE  VTTPVB STRUCTURE  VTTPVB OPTIONAL
*"  TABLES
*"      I_XVTTK_TAB STRUCTURE  VTTKVB
*"      I_XVTTP_TAB STRUCTURE  VTTPVB OPTIONAL
*"      I_XTRLK_TAB STRUCTURE  VTRLK OPTIONAL
*"      I_XTRLP_TAB STRUCTURE  VTRLP OPTIONAL
*"      I_XVTTS_TAB STRUCTURE  VTTSVB OPTIONAL
*"      I_XVTSP_TAB STRUCTURE  VTSPVB OPTIONAL
*"      I_XVBPA_TAB STRUCTURE  VBPAVB OPTIONAL
*"  EXCEPTIONS
*"      FCODE_NOT_PERMITTED
*"----------------------------------------------------------------------
** Ekran üzerinden silinmeye kalktığında girer bapiden girmez.
IF i_fcode EQ 'MM_TRLP'. " delete shippment
  SELECT COUNT(*) FROM zyb_sd_t_shp02
        WHERE svkno EQ i_xvttk_wa-tknum
          AND loekz EQ space.
  IF sy-subrc = 0.
    MESSAGE s102(zyb_sd) WITH i_xvttk_wa-tknum
        RAISING fcode_not_permitted.
  ENDIF.
ENDIF.

IF i_fcode EQ 'MM_SICH'. " Save Shipment
  IF i_xvttk_wa-shtyp EQ 'Z002' OR " İhracat Dahili Nakl.
     i_xvttk_wa-shtyp EQ 'Z003'. " Yurt İçi Nakliye

    IF i_xvttk_wa-stten EQ 'X' AND
     ( i_xvttk_wa-dpten EQ '00000000' OR i_xvttk_wa-upten EQ '000000' ).
      MESSAGE s117(zyb_sd) WITH i_xvttk_wa-tknum
          RAISING fcode_not_permitted.
    ENDIF.

    IF i_xvttk_wa-stten EQ 'X' AND i_xvttk_wa-dpten NE '00000000' AND
       i_xvttk_wa-dpten GT i_xvttk_wa-daten.
      MESSAGE s120(zyb_sd) WITH i_xvttk_wa-tknum
          RAISING fcode_not_permitted.
    ENDIF.

    DATA: pln_datetime  LIKE tzonref-tstamps,
          fiil_datetime LIKE tzonref-tstamps.

    CONVERT DATE i_xvttk_wa-dpten TIME i_xvttk_wa-upten
    INTO TIME STAMP pln_datetime TIME ZONE 'UTC'.

    CONVERT DATE i_xvttk_wa-daten TIME i_xvttk_wa-uaten
    INTO TIME STAMP fiil_datetime TIME ZONE 'UTC'.

    IF i_xvttk_wa-stten EQ 'X' AND pln_datetime GT fiil_datetime.
      MESSAGE s121(zyb_sd) WITH i_xvttk_wa-tknum
          RAISING fcode_not_permitted.
    ENDIF.
  ENDIF.
ENDIF.
"--------->> Anıl CENGİZ 06.01.2021 10:23:43
"YUR-810
TRY.
    NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_EXIT_SMOD_ZXV56U18'
                                                    vars = VALUE #( ( name = 'I_FCODE'     value = REF #( i_fcode ) )
                                                                    ( name = 'I_XVTTK_WA'  value = REF #( i_xvttk_wa ) )
                                                                    ( name = 'I_XVTTS_WA'  value = REF #( i_xvtts_wa ) )
                                                                    ( name = 'I_XVTTP_WA'  value = REF #( i_xvttp_wa ) )
                                                                    ( name = 'I_XVTTK_TAB' value = REF #( i_xvttk_tab[] ) )
                                                                    ( name = 'I_XVTTP_TAB' value = REF #( i_xvttp_tab[] ) )
                                                                    ( name = 'I_XTRLK_TAB' value = REF #( i_xtrlk_tab[] ) )
                                                                    ( name = 'I_XTRLP_TAB' value = REF #( i_xtrlp_tab[] ) )
                                                                    ( name = 'I_XVTTS_TAB' value = REF #( i_xvtts_tab[] ) )
                                                                    ( name = 'I_XVTSP_TAB' value = REF #( i_xvtsp_tab[] ) )
                                                                    ( name = 'I_XVBPA_TAB' value = REF #( i_xvbpa_tab[] ) ) ) ) )->execute( ).
  CATCH zcx_bc_exit_imp INTO DATA(lx_bc_exit_imp).
    CHECK: i_fcode NE 'LOES'.
    DATA: lt_list TYPE bapirettab.
    DATA(lo_msg) = lx_bc_exit_imp->messages.
    lo_msg->get_list_as_bapiret( IMPORTING et_list = lt_list ).
    zcl_sd_toolkit=>hata_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'E' ) ( CORRESPONDING #( wa ) ) ) ).
    zcl_sd_toolkit=>bilgi_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'W' OR type = 'I' ) ( CORRESPONDING #( wa ) ) ) ).
ENDTRY.
"---------<<
