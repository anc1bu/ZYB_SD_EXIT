class ZCL_SD_MV45AFZZ_PREPTKOMP definition
  public
  final
  create public .

public section.

  data GR_VBAK type ref to DATA .
  data GR_VBAP type ref to DATA .
  data GR_TKOMP type ref to DATA .
  data GR_VBKD type ref to DATA .
  data GR_TKOMK type ref to DATA .

  methods CONSTRUCTOR
    importing
      !IR_VBAK type ref to DATA optional
      !IR_VBAP type ref to DATA optional
      !IR_VBKD type ref to DATA optional
      !IR_TKOMP type ref to DATA optional
      !IR_TKOMK type ref to DATA optional
      !IS_T180 type T180 optional .
  methods VERI_ATAMA .
  methods FYT_LST_ATAMA .
protected section.
private section.

  class-data GS_T180 type T180 .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_PREPTKOMP IMPLEMENTATION.


  METHOD constructor.
    gr_vbak = ir_vbak.
    gr_vbap = ir_vbap.
    gr_vbkd = ir_vbkd.
    gr_tkomp = ir_tkomp.
    gr_tkomk = ir_tkomk.
    gs_t180 = is_t180.
  ENDMETHOD.


METHOD fyt_lst_atama.

ENDMETHOD.


  METHOD veri_atama.

    DATA: lv_extwg TYPE extwg,
          lv_herkl TYPE herkl,
          lv_mtart TYPE mtart.

    FIELD-SYMBOLS: <gfs_vbak>  TYPE vbak,
                   <gfs_vbap>  TYPE vbap,
                   <gfs_tkomp> TYPE komp,
                   <gfs_tkomk> TYPE komk.


    ASSIGN gr_vbak->* TO <gfs_vbak>.
    ASSIGN gr_vbap->* TO <gfs_vbap>.
    ASSIGN gr_tkomp->* TO <gfs_tkomp>.
    ASSIGN gr_tkomk->* TO <gfs_tkomk>.

* kampanya numarası tkomp structure ındaki alana atanır.
    <gfs_tkomp>-knuma_ag = <gfs_vbak>-zz_knuma_ag.

* Harici mal grubu tkomp structure ındaki alana atanır.
    CLEAR lv_extwg.
    SELECT SINGLE mtart extwg FROM mara
          INTO ( lv_mtart , lv_extwg )
         WHERE matnr EQ <gfs_vbap>-matnr.
    IF NOT lv_extwg IS INITIAL.
      <gfs_tkomp>-extwg = lv_extwg.
    ENDIF.
    <gfs_tkomp>-mtart = lv_mtart.
* Kaynak ülke doldurma
    CLEAR lv_herkl.
    SELECT SINGLE herkl FROM marc
          INTO lv_herkl
         WHERE matnr = <gfs_vbap>-matnr
           AND werks = <gfs_vbap>-werks.

    <gfs_tkomp>-herkl = lv_herkl.

    "--------->> Anıl CENGİZ 26.07.2018 11:37:29
    " YUR-73 Atıl Stoklar için Yurtiçi Virman Programı Değişikliği
    <gfs_tkomp>-zzlgort = <gfs_vbap>-lgort.
    "---------<<

    fyt_lst_atama( ).

  ENDMETHOD.
ENDCLASS.
