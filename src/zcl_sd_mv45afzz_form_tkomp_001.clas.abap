class ZCL_SD_MV45AFZZ_FORM_TKOMP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_TKOMP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_TKOMP_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_vbak>  TYPE vbak,
                 <gs_vbap>  TYPE vbap,
                 <gs_tkomp> TYPE komp,
                 <gs_t180>  TYPE t180.

  DATA: lr_data  TYPE REF TO data.

  lr_data = co_con->get_vars( 'VBAK' ).  ASSIGN lr_data->* TO <gs_vbak>.
  lr_data = co_con->get_vars( 'VBAP' ).  ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( 'TKOMP' ). ASSIGN lr_data->* TO <gs_tkomp>.
  lr_data = co_con->get_vars( 'T180' ).  ASSIGN lr_data->* TO <gs_t180>.

  CHECK: <gs_t180>-trtyp NE 'A'.
* kampanya numarası tkomp structure ındaki alana atanır.
  <gs_tkomp>-knuma_ag = <gs_vbak>-zz_knuma_ag.
* Harici mal grubu tkomp structure ındaki alana atanır.
  SELECT SINGLE mtart extwg
    FROM mara
    INTO ( <gs_tkomp>-mtart , <gs_tkomp>-extwg  )
    WHERE matnr EQ <gs_tkomp>-matnr.

* Kaynak ülke doldurma
  SELECT SINGLE herkl FROM marc
        INTO <gs_tkomp>-herkl
       WHERE matnr = <gs_tkomp>-matnr
         AND werks = <gs_tkomp>-werks.

  "--------->> Anıl CENGİZ 26.07.2018 11:37:29
  " YUR-73 Atıl Stoklar için Yurtiçi Virman Programı Değişikliği
  <gs_tkomp>-zzlgort = <gs_vbap>-lgort.
  "---------<<
  "--------->> Anıl CENGİZ 30.11.2020 17:39:39
  "YUR-773
  <gs_tkomp>-zzebat = zcl_sd_toolkit=>get_mlz_sinif_atwrt( EXPORTING iv_atinn = zcl_sd_toolkit=>cv_atinn_ebat
                                                                     iv_matnr = <gs_tkomp>-matnr ).

  <gs_tkomp>-zzseri = zcl_sd_toolkit=>get_mlz_sinif_atwrt( EXPORTING iv_atinn = zcl_sd_toolkit=>cv_atinn_seri
                                                                     iv_matnr = <gs_tkomp>-matnr ).
  "---------<<
ENDMETHOD.
ENDCLASS.
