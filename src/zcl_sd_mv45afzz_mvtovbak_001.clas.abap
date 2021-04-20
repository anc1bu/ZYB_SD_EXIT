class ZCL_SD_MV45AFZZ_MVTOVBAK_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_MVTOVBAK .

  type-pools ABAP .
  class-methods CHECK_CNTRL
    importing
      !IO_CON type ref to ZCL_BC_EXIT_CONTAINER
    returning
      value(RV_RETURN) type ABAP_BOOL .
protected section.
private section.

  constants CV_AU_ZA09 type AUART value 'ZA09'. "#EC NOTEXT
  constants CV_AU_ZR02 type AUART value 'ZR02'. "#EC NOTEXT
  constants CV_AU_ZC08 type AUART value 'ZC08'. "#EC NOTEXT
  constants CV_AU_ZD03 type AUART value 'ZD03'. "#EC NOTEXT
  data GR_T180 type ref to DATA .
  data GR_VBAK type ref to DATA .
  data GR_VBKD type ref to DATA .
  data GR_CALLBAPI type ref to DATA .
  data GR_KURGV type ref to DATA .

  type-pools ABAP .
  methods CHECK_LCNUM_CHANGE
    importing
      !IO_CON type ref to ZCL_BC_EXIT_CONTAINER
    returning
      value(RV_RETURN) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_MVTOVBAK_001 IMPLEMENTATION.


METHOD check_cntrl.

  FIELD-SYMBOLS: <ls_t180>     TYPE t180,
                 <ls_vbak>     TYPE vbak,
                 <ls_vbkd>     TYPE vbkd,
                 <lv_callbapi> TYPE abap_bool.

  DATA: lr_data TYPE REF TO data.

  lr_data = io_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
  lr_data = io_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = io_con->get_vars( 'VBKD' ).      ASSIGN lr_data->* TO <ls_vbkd>.
  lr_data = io_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.

  CHECK: <ls_t180>-trtyp EQ 'H' OR <ls_t180>-trtyp EQ 'V',
*       <ls_vbak>-zz_knuma_ag is initial,
         <ls_vbak>-vtweg EQ '10' OR <ls_vbak>-vtweg EQ '30',
         <ls_vbak>-auart NE cv_au_za09,
         <ls_vbak>-auart NE cv_au_zr02,
         <ls_vbak>-auart NE cv_au_zc08,
         <ls_vbak>-auart NE cv_au_zd03,
         <ls_vbak>-vkbur NE '1120'.
*        <ls_vbkd>-lcnum is initial,

  rv_return = abap_true.

ENDMETHOD.


METHOD check_lcnum_change.

  TYPES: BEGIN OF ty_akkp,
           akart TYPE akart,
           kunnr TYPE kunnr,
         END OF ty_akkp.

  FIELD-SYMBOLS: <ls_t180>     TYPE t180,
                 <ls_vbak>     TYPE vbak,
                 <ls_vbkd>     TYPE vbkd,
                 <lv_callbapi> TYPE abap_bool,
                 <ls_kurgv>    TYPE kurgv.

  DATA: ls_akkp TYPE ty_akkp,
        lr_data TYPE REF TO data.

  lr_data = io_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
  lr_data = io_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = io_con->get_vars( 'VBKD' ).      ASSIGN lr_data->* TO <ls_vbkd>.
  lr_data = io_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.
  lr_data = io_con->get_vars( 'KURGV' ).     ASSIGN lr_data->* TO <ls_kurgv>.

  SELECT SINGLE akart kunnr
    FROM akkp
    INTO ls_akkp
    WHERE lcnum EQ <ls_vbkd>-lcnum.
  "--------->> Anıl CENGİZ 10.08.2020 13:18:58
  "YUR-706
  IF ls_akkp-akart NE 'Z5'
  "---------<<
     AND ( ls_akkp-kunnr NE <ls_vbak>-kunnr
           OR <ls_vbkd>-lcnum IS INITIAL
           OR <ls_vbak>-zz_knuma_ag IS INITIAL )
     "--------->> Anıl CENGİZ 02.04.2019 10:21:51
     "YUR-364
     AND <lv_callbapi> EQ abap_false.
    "---------<<
    rv_return = abap_true.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.
*&--------------------------------------------------------------------*
*& --> Kampanya Numarası Belirleme
*&--------------------------------------------------------------------*
  FIELD-SYMBOLS: <ls_t180>     TYPE t180,
                 <ls_vbak>     TYPE vbak,
                 <ls_vbkd>     TYPE vbkd,
                 <lv_callbapi> TYPE abap_bool,
                 <ls_kurgv>    TYPE kurgv.

  DATA: gv_knuma TYPE knuma_ag,
        gv_zterm TYPE dzterm,
        gv_lcnum TYPE lcnum,
        gv_boart TYPE boart,
        lr_data  TYPE REF TO data.

  lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <ls_t180>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'VBKD' ).      ASSIGN lr_data->* TO <ls_vbkd>.
  lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <lv_callbapi>.
  lr_data = co_con->get_vars( 'KURGV' ).     ASSIGN lr_data->* TO <ls_kurgv>.

  CHECK: check_cntrl( co_con ) EQ abap_true,
         check_lcnum_change( co_con ) EQ abap_true.

  CLEAR: gv_knuma, gv_zterm, gv_lcnum, gv_boart.
  CALL FUNCTION 'ZYB_SD_F_KMP_SELECT_POPUP'
    EXPORTING
      i_vkorg = <ls_vbak>-vkorg
      i_vtweg = <ls_vbak>-vtweg
      i_kunnr = <ls_vbak>-kunnr
      i_date  = <ls_vbkd>-prsdt
      i_auart = <ls_vbak>-auart
    IMPORTING
      e_knuma = gv_knuma
      e_zterm = gv_zterm
      e_lcnum = gv_lcnum
      e_boart = gv_boart.

* kampanya (ticari promosyon) kodu belirleme
  IF NOT gv_knuma IS INITIAL.
    <ls_vbak>-zz_knuma_ag = gv_knuma.
  ELSE.
    MESSAGE e005(zsd_va) WITH <ls_vbak>-kunnr DISPLAY LIKE 'I'.
  ENDIF.
* ödeme koşulu belirleme
  IF NOT gv_zterm IS INITIAL.
    <ls_kurgv>-zterm = gv_zterm.
  ENDIF.
* mali belge belirleme
  IF NOT gv_lcnum IS INITIAL.
    <ls_vbkd>-lcnum = gv_lcnum.
  ENDIF.

* ödeme biçimi belirleme
  IF NOT gv_boart IS INITIAL.
    CASE gv_boart.
      WHEN 'ZY01'. <ls_vbkd>-zlsch = 'C'. " Çek Kampanyası
      WHEN 'ZY02'. <ls_vbkd>-zlsch = 'K'. " Kredi Kartı Kampanyası
      WHEN 'ZY03'. <ls_vbkd>-zlsch = 'H'. " Banka Havalesi Kampanyası
    ENDCASE.
  ENDIF.

  NEW zcl_sd_thslt_kntrl( VALUE #( datum = <ls_vbak>-erdat
                                   knuma = <ls_vbak>-zz_knuma_ag
                                   vkorg = <ls_vbak>-vkorg
                                   vtweg = <ls_vbak>-vtweg
                                   brsch = zcl_sd_toolkit=>get_brsch( <ls_vbak>-kunnr )-brsch
                                   kunnr = <ls_vbak>-kunnr
                                   vbtyp = <ls_vbak>-vbtyp ) )->execute( ).

ENDMETHOD.
ENDCLASS.
