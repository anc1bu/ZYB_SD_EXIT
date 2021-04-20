class ZCL_MM_EXIT_SMOD_MBCF0002_005 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EXIT_SMOD_MBCF0002 .

  class-methods ZMB_MIGO_BADI
    importing
      !IV_MSEG type MSEG
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.

  constants CV_NAKIL type BWART value '311'. "#EC NOTEXT

  type-pools ABAP .
  class-methods CHECK_CHARG
    importing
      !IV_CHARG type CHARG_D
    returning
      value(RV_RETURN) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_MBCF0002_005 IMPLEMENTATION.


METHOD check_charg.

  DATA: lv_charg    TYPE charg_d,
        lv_teslimat TYPE vbeln_vl.

*   İç Piyasa
  SELECT charg_plan vbeln
    FROM zyb_sd_t_shp01
    INTO ( lv_charg , lv_teslimat )
    WHERE charg_plan  EQ iv_charg
      AND charg_fiili EQ space.
  ENDSELECT.
  IF lv_charg IS NOT INITIAL.
    rv_return = abap_true. "Palet teslimata planlanmış ise
  ELSE.
    CLEAR lv_charg.
    CLEAR lv_teslimat.

    SELECT charg_fiili vbeln
     FROM zyb_sd_t_shp01
     INTO ( lv_charg , lv_teslimat )
     WHERE charg_fiili EQ iv_charg.
    ENDSELECT.
    IF lv_charg IS NOT INITIAL.
      rv_return = abap_true. "Palet fiili olarak teslimata çekilmiş ise
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

  FIELD-SYMBOLS: <ls_mseg> TYPE mseg,
                 <ls_mkpf> TYPE mkpf.

  DATA: lr_data   TYPE REF TO data.

  lr_data  = co_con->get_vars( 'I_MSEG'  ). ASSIGN lr_data->* TO <ls_mseg>.
  lr_data  = co_con->get_vars( 'I_MKPF'  ). ASSIGN lr_data->* TO <ls_mkpf>.

*TRY.
  CALL METHOD me->zmb_migo_badi
    EXPORTING
      iv_mseg = <ls_mseg>.
* CATCH zcx_bc_exit_imp .
*ENDTRY.

ENDMETHOD.


METHOD zmb_migo_badi.

  DATA: lv_charg  TYPE charg_d,
        lv_durum  TYPE abap_bool,
        lv_durum2 TYPE abap_bool,
        lv_budat  TYPE datum,
        lv_erdat  TYPE datum,
        lv_mesaj  TYPE text50.

  CHECK: iv_mseg-werks EQ zif_mm_exit_smod_mbcf0002~cv_werks_delivering,
         ( iv_mseg-bwart = '102' OR "SAS ters kyt.için MG
           iv_mseg-bwart = '702' OR "MÇ Depo envanteri
           iv_mseg-bwart = '711' OR "MÇ Depo env.farkı
           iv_mseg-bwart = '411' OR "SN dp.yr->dp.yerine
           iv_mseg-bwart = '991' ). "SN dp.yr->dp.yerine


  SELECT SINGLE mandt
    FROM zyb_wm_t_ist_usr
    INTO sy-mandt
    WHERE field1 EQ '1'
      AND bname EQ sy-uname.
  CHECK: sy-subrc NE 0.



  IF check_charg( iv_mseg-charg ) EQ abap_true.

    CLEAR lv_charg.
    DATA: lv_teslimat TYPE vbeln_vl.



    CLEAR: lv_durum2, lv_budat, lv_erdat.
    SELECT SINGLE budat_mkpf
      FROM mseg
      INTO lv_budat
      WHERE charg EQ iv_mseg-charg
        AND bwart EQ '653'. "MT Thds.klnb.iade
    IF lv_budat IS NOT INITIAL.
      SELECT SINGLE erdat
        FROM likp
        INTO lv_erdat
        WHERE vbeln EQ lv_teslimat.
      IF lv_erdat < lv_budat.
        lv_durum2 = 'X'.
      ENDIF.
    ENDIF.
    IF lv_durum2 = space.
*        CONCATENATE iv_mseg-charg ' Parti ' lv_teslimat
*             ' Numaralı teslimata Bağlıdır.'
*             INTO lv_mesaj.

      lv_mesaj = |{ iv_mseg-charg } parti { lv_teslimat } numaralı teslimata bağlıdır! |.
      MESSAGE lv_mesaj TYPE 'E'.
    ENDIF.

  ELSE.

    CLEAR lv_charg.
    CLEAR lv_teslimat.
*    İhracat
    DATA: lv_svkno TYPE zyb_sd_e_svkno.

    SELECT svkno chargpln vbeln_vl
      FROM zyb_sd_t_shp02
      INTO ( lv_svkno, lv_charg , lv_teslimat )
      WHERE chargpln EQ iv_mseg-charg
        AND loekz    EQ space
        AND ( durum EQ 'A' OR
              durum EQ 'B' OR
              durum EQ 'C' ).
    ENDSELECT.
    IF lv_charg IS NOT INITIAL.
      "--------->> Anıl CENGİZ 23.10.2020 15:47:54
      "YUR-758
*       CONCATENATE iv_mseg-charg ' Parti '
*           'Proforma Aşamasında.'
*           INTO lv_mesaj.
      lv_mesaj = | { iv_mseg-charg } numaralı parti { lv_svkno } yüklemesinde proforma aşamasındadır! |.
      "---------<<
      MESSAGE lv_mesaj TYPE 'E'.
    ENDIF.
    CLEAR lv_charg.
    CLEAR lv_teslimat.
    DATA: lv_posnr_vl TYPE posnr.
    DATA: lv_x TYPE charg_d.

    SELECT  charg vbeln_vl posnr_vl INTO ( lv_charg , lv_teslimat, lv_posnr_vl )
       FROM zyb_sd_t_shp02
       WHERE charg = iv_mseg-charg AND loekz = '' AND ( durum = 'D' OR durum = 'E' ).
    ENDSELECT.
    IF lv_charg IS NOT INITIAL.
      "bug dan ötürü ekistra kontrol
      SELECT SINGLE charg INTO ( lv_x ) FROM lips WHERE vbeln = lv_teslimat AND uecha = lv_posnr_vl AND charg = lv_charg.
      IF lv_x IS INITIAL.
        SELECT SINGLE charg INTO ( lv_x ) FROM lips WHERE vbeln = lv_teslimat AND posnr = lv_posnr_vl AND charg = lv_charg.
        IF lv_x IS NOT INITIAL.
          CLEAR lv_durum2.
          CLEAR: lv_durum2, lv_budat, lv_erdat.

          SELECT SINGLE budat_mkpf INTO lv_budat  FROM mseg WHERE charg = iv_mseg-charg AND bwart = '653'. "MT Thds.klnb.iade

          IF lv_budat IS NOT INITIAL.
            SELECT SINGLE erdat INTO lv_erdat FROM likp WHERE vbeln = lv_teslimat.

            IF lv_erdat < lv_budat.
              lv_durum2 = 'X'.
            ENDIF.
          ENDIF.
          IF lv_durum2 = ''.
            CONCATENATE iv_mseg-charg ' Parti ' lv_teslimat
          ' Numaralı teslimata Bağlıdır.'
          INTO lv_mesaj.

            MESSAGE lv_mesaj TYPE 'E'.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: lv_durum2, lv_budat, lv_erdat.
        SELECT SINGLE budat_mkpf INTO lv_budat  FROM mseg WHERE charg = iv_mseg-charg AND bwart = '653'.
        IF lv_budat IS NOT INITIAL.
          SELECT SINGLE erdat INTO lv_erdat FROM likp WHERE vbeln = lv_teslimat.
          IF lv_erdat < lv_budat.
            lv_durum2 = 'X'.
          ENDIF.
        ENDIF.
        IF lv_durum2 = ''.
          CONCATENATE iv_mseg-charg ' Parti ' lv_teslimat
            ' Numaralı teslimata Bağlıdır.'
            INTO lv_mesaj.
          MESSAGE lv_mesaj TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMETHOD.
ENDCLASS.
