class ZCL_SD_RV45PFZA_SETVBUP definition
  public
  final
  create public .

public section.

  class-data GS_VBUP type VBUP read-only .
  class-data GT_FXVBAP type TAB_XYVBAP read-only .

  methods CONSTRUCTOR
    importing
      value(IS_VBUP) type VBUP optional
      value(IT_FXVBAP) type TAB_XYVBAP optional .
  methods ATAMA
    exporting
      value(ES_VBUP) type VBUP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_RV45PFZA_SETVBUP IMPLEMENTATION.


  METHOD atama.

    TYPES: BEGIN OF ty_lips,
             vbeln TYPE lips-vbeln,
             posnr TYPE lips-posnr,
             vgbel TYPE lips-vgbel,
             vgpos TYPE lips-vgpos,
             lfimg TYPE lips-lfimg,
             vrkme TYPE lips-vrkme,
             matnr TYPE lips-matnr,
           END OF ty_lips.

    DATA: lt_lips     TYPE STANDARD TABLE OF ty_lips,
          ls_lips_col TYPE ty_lips,
          lt_lips_col TYPE STANDARD TABLE OF ty_lips,
          lv_kwmeng   TYPE vbap-kwmeng.

    REFRESH: lt_lips, lt_lips_col. CLEAR: ls_lips_col, lv_kwmeng.

    READ TABLE gt_fxvbap ASSIGNING FIELD-SYMBOL(<fs_fxvbap>)
        WITH KEY posnr = gs_vbup-posnr.

    IF sy-subrc EQ 0 AND <fs_fxvbap>-pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.

      lv_kwmeng = <fs_fxvbap>-kwmeng.

      SELECT ls~vbeln,
        ls~posnr,
        ls~lfimg,
        ls~vrkme,
        ls~matnr FROM lips AS ls
                 INNER JOIN vbuk AS vbk ON vbk~vbeln EQ ls~vbeln
                 INTO CORRESPONDING FIELDS OF TABLE @lt_lips
                 WHERE ls~vgbel EQ @<fs_fxvbap>-vbeln
                 AND ls~vgpos EQ @<fs_fxvbap>-posnr
                 AND ls~vrkme EQ @<fs_fxvbap>-vrkme
                 AND NOT EXISTS ( SELECT matnr
                                    FROM zyb_sd_t_yyk
                                    WHERE matnr EQ ls~matnr ).

      IF lt_lips[] IS NOT INITIAL.
        LOOP AT lt_lips ASSIGNING FIELD-SYMBOL(<fs_lips>).

          MOVE-CORRESPONDING <fs_lips> TO ls_lips_col.
          CLEAR: ls_lips_col-vbeln,
                 ls_lips_col-posnr,
                 ls_lips_col-matnr.
          COLLECT ls_lips_col INTO lt_lips_col.

        ENDLOOP.

        READ TABLE lt_lips_col INTO ls_lips_col INDEX 1.

        SUBTRACT ls_lips_col-lfimg FROM lv_kwmeng.

        IF lv_kwmeng LE 0 .
          es_vbup-lfsta = 'C'.
        ELSEIF lv_kwmeng GT 0.
          es_vbup-lfsta = 'B'.
        ELSEIF lv_kwmeng EQ <fs_fxvbap>-kwmeng.
          es_vbup-lfsta = 'A'.
        ENDIF.
      ELSE.
        es_vbup-lfsta = 'A'.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    gs_vbup = is_vbup.
    gt_fxvbap[] = it_fxvbap[].
  ENDMETHOD.
ENDCLASS.
