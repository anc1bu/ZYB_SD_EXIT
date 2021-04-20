class ZCL_IM_CL_SD_COND_SAVE_A definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SD_COND_SAVE_A .

  class-methods CHECK
    importing
      !IT_VAKE type COND_VAKEVB_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_SD_COND_SAVE_A IMPLEMENTATION.


  METHOD check.
*    "--------->> add by mehmet sertkaya 14.09.2018 10:14:03
*    " YUR-156 VB22 ekranında "fiyatlandırma tarihi" ne göre
*    " çoklu fiyat girilebilmesi
*    TYPES: BEGIN OF ty_key_932,
*             zzlgort TYPE lgort_d,
*             pltyp TYPE pltyp,
*           END OF ty_key_932,
*
*           BEGIN OF ty_key_933,
*             pltyp TYPE pltyp,
*           END OF ty_key_933,
*
*           BEGIN OF ty_key_934,
*             kunag TYPE kunag,
*             pltyp TYPE pltyp,
*           END OF ty_key_934,
*
*           BEGIN OF ty_key_935,
*             prodh3 TYPE prodh3,
*             vrkme TYPE vrkme,
*             pltyp TYPE pltyp,
*           END OF ty_key_935.
*
*
*    DATA : ls_vake        TYPE LINE OF cond_vakevb_t,
*           ls_a932        TYPE a932,
*           lt_a932        TYPE TABLE OF a932,
*           ls_a933        TYPE a933,
*           lt_a933        TYPE TABLE OF a933,
*           lv_pltyp       TYPE pltyp,
*           lt_pltyp       TYPE TABLE OF pltyp,
*           lv_max_zzprsdt TYPE prsdt,
*           lt_vake_all    TYPE cond_vakevb_t,
*           lt_vake        TYPE cond_vakevb_t,
*           lt_kotabnr     TYPE TABLE OF kotabnr,
*           lv_kotabnr     TYPE kotabnr,
*    "--------->> Anıl CENGİZ 12.11.2018 11:53:09
*    "YUR-227 Yurtiçi Satışlarında Kampanya İlave İskonto Talebi v.0
*           ls_a934        TYPE a934,
*           lt_a934        TYPE TABLE OF a934,
*           ls_a935        TYPE a935,
*           lt_a935        TYPE TABLE OF a935,
*           ls_key_932 TYPE ty_key_932,
*           lt_key_932 TYPE STANDARD TABLE OF ty_key_932,
*           ls_key_933 TYPE ty_key_933,
*           lt_key_933 TYPE STANDARD TABLE OF ty_key_933,
*           ls_key_934 TYPE ty_key_934,
*           lt_key_934 TYPE STANDARD TABLE OF ty_key_934,
*           ls_key_935 TYPE ty_key_935,
*           lt_key_935 TYPE STANDARD TABLE OF ty_key_935.
*    "---------<<
*    lt_vake_all = it_vake.
*
*    LOOP AT lt_vake_all INTO ls_vake WHERE updkz NE ''.
*      COLLECT ls_vake-kotabnr INTO lt_kotabnr.
*    ENDLOOP.
*    FIELD-SYMBOLS <lt_konp> TYPE cond_konpdb_t.
*
*    CHECK sy-tcode EQ 'VB21' OR
*          sy-tcode EQ 'VB22'.
*
*    ASSIGN ('(SAPMV13A)XKONP[]') TO <lt_konp>.
*
*    CHECK sy-subrc EQ 0.
*    LOOP AT lt_kotabnr INTO lv_kotabnr.
*      REFRESH : lt_vake.
*      LOOP AT lt_vake_all INTO ls_vake WHERE kotabnr EQ lv_kotabnr.
*        APPEND ls_vake TO lt_vake.
*      ENDLOOP.
*
*
*      LOOP AT lt_vake INTO ls_vake.
*
*        CASE ls_vake-kotabnr.
*          WHEN '932'.
*            LOOP AT lt_vake INTO ls_vake.
*              READ TABLE <lt_konp> WITH KEY knumh = ls_vake-knumh
*                                          loevm_ko = 'X'
*                                          TRANSPORTING NO FIELDS.
*              CHECK sy-subrc NE 0.
*              MOVE-CORRESPONDING ls_vake TO ls_a932.
*              ls_a932-knuma_ag  = ls_vake-vakey(10).
*              ls_a932-vkorg     = ls_vake-vakey+10(4).
*              ls_a932-vtweg     = ls_vake-vakey+14(2).
*              ls_a932-zzlgort   = ls_vake-vakey+16(4).
*              ls_a932-zzprsdt   = ls_vake-vakey+20(8).
*              ls_a932-pltyp     = ls_vake-vakey+28(2).
*              APPEND ls_a932 TO lt_a932.
*              MOVE-CORRESPONDING ls_a932 TO ls_key_932.
*              COLLECT ls_key_932 INTO lt_key_932.
*            ENDLOOP.
*            SORT lt_a932 BY pltyp zzlgort zzprsdt.
*            LOOP AT lt_key_932 ASSIGNING FIELD-SYMBOL(<fs_key_932>).
*              LOOP AT lt_a932 INTO ls_a932
*                WHERE pltyp EQ <fs_key_932>-pltyp
*                AND zzlgort EQ <fs_key_932>-zzlgort.
*                IF ls_a932-zzprsdt NE ls_a932-datab.
*                  MESSAGE e001(ls) WITH text-e01 text-e02
*<fs_key_932>-pltyp.
*                ENDIF.
*                IF lv_max_zzprsdt LT ls_a932-zzprsdt.
*                  lv_max_zzprsdt = ls_a932-zzprsdt.
*                ENDIF.
*              ENDLOOP.
*              LOOP AT lt_a932 INTO ls_a932
*                    WHERE pltyp   EQ <fs_key_932>-pltyp AND
*                          zzlgort EQ <fs_key_932>-zzlgort AND
*                          zzprsdt NE lv_max_zzprsdt.
*                IF lv_max_zzprsdt LE ls_a932-datbi .
*                  MESSAGE e001(ls) WITH text-e03 text-e04
*<fs_key_932>-pltyp.
*                ENDIF.
*              ENDLOOP.
*              CLEAR: lv_max_zzprsdt.
*            ENDLOOP.
*          WHEN '933'.
*            LOOP AT lt_vake INTO ls_vake.
*              READ TABLE <lt_konp> WITH KEY knumh = ls_vake-knumh
*                                          loevm_ko = 'X'
*                                          TRANSPORTING NO FIELDS.
*              CHECK sy-subrc NE 0.
*              MOVE-CORRESPONDING ls_vake TO ls_a933.
*              ls_a933-knuma_ag  = ls_vake-vakey(10).
*              ls_a933-vkorg     = ls_vake-vakey+10(4).
*              ls_a933-vtweg     = ls_vake-vakey+14(2).
*              ls_a933-zzprsdt   = ls_vake-vakey+16(8).
*              ls_a933-pltyp     = ls_vake-vakey+24(2).
*              APPEND ls_a933 TO lt_a933.
*              MOVE-CORRESPONDING ls_a933 TO ls_key_933.
*              COLLECT ls_key_933 INTO lt_key_933.
*            ENDLOOP.
*            SORT lt_a933 BY pltyp zzprsdt.
*            LOOP AT lt_key_933 ASSIGNING FIELD-SYMBOL(<fs_key_933>).
*              CLEAR lv_max_zzprsdt.
*              LOOP AT lt_a933 INTO ls_a933
*                WHERE pltyp EQ <fs_key_933>-pltyp.
*                IF ls_a933-zzprsdt NE ls_a933-datab.
*                  MESSAGE e001(ls) WITH text-e01 text-e02
*<fs_key_933>-pltyp.
*                ENDIF.
*                IF lv_max_zzprsdt LE ls_a933-zzprsdt.
*                  lv_max_zzprsdt = ls_a933-zzprsdt.
*                ENDIF.
*              ENDLOOP.
*              LOOP AT lt_a933 INTO ls_a933
*                    WHERE pltyp   EQ <fs_key_933>-pltyp AND
*                          zzprsdt NE lv_max_zzprsdt.
*                IF lv_max_zzprsdt LE ls_a933-datbi .
*                  MESSAGE e001(ls) WITH text-e03 text-e04
*<fs_key_933>-pltyp.
*                ENDIF.
*              ENDLOOP.
*              CLEAR: lv_max_zzprsdt.
*            ENDLOOP.
*            "--------->> Anıl CENGİZ 12.11.2018 11:47:26
*         "YUR-227 Yurtiçi Satışlarında Kampanya İlave İskonto Talebi v.0
*          WHEN '934'. "Yeni yaratılan bayi iskontosu için eklendi.
*            LOOP AT lt_vake INTO ls_vake.
*              READ TABLE <lt_konp> WITH KEY knumh = ls_vake-knumh
*                                          loevm_ko = 'X'
*                                          TRANSPORTING NO FIELDS.
*              CHECK sy-subrc NE 0.
*              MOVE-CORRESPONDING ls_vake TO ls_a934.
*              ls_a934-knuma_ag  = ls_vake-vakey(10).
*              ls_a934-vkorg     = ls_vake-vakey+10(4).
*              ls_a934-vtweg     = ls_vake-vakey+14(2).
*              ls_a934-zzprsdt   = ls_vake-vakey+16(8).
*              ls_a934-pltyp     = ls_vake-vakey+24(2).
*              ls_a934-kunag     = ls_vake-vakey+26(10).
*              APPEND ls_a934 TO lt_a934.
*              MOVE-CORRESPONDING ls_a934 TO ls_key_934.
*              COLLECT ls_key_934 INTO lt_key_934.
*            ENDLOOP.
*            SORT lt_a934 BY pltyp kunag zzprsdt.
*            LOOP AT lt_key_934 ASSIGNING FIELD-SYMBOL(<fs_key_934>).
*              CLEAR lv_max_zzprsdt.
*              LOOP AT lt_a934 INTO ls_a934
*                WHERE pltyp EQ <fs_key_934>-pltyp
*                AND kunag EQ <fs_key_934>-kunag.
*                IF ls_a934-zzprsdt NE ls_a934-datab.
*                  MESSAGE e001(ls) WITH text-e01 text-e02
*<fs_key_934>-pltyp.
*                ENDIF.
*                IF lv_max_zzprsdt LE ls_a934-zzprsdt.
*                  lv_max_zzprsdt = ls_a934-zzprsdt.
*                ENDIF.
*              ENDLOOP.
*              LOOP AT lt_a934 INTO ls_a934
*                    WHERE pltyp   EQ <fs_key_934>-pltyp AND
*                          kunag EQ <fs_key_934>-kunag AND
*                          zzprsdt NE lv_max_zzprsdt.
*                IF lv_max_zzprsdt LE ls_a934-datbi .
*                  MESSAGE e001(ls) WITH text-e03 text-e04
*<fs_key_934>-pltyp.
*                ENDIF.
*              ENDLOOP.
*              CLEAR: lv_max_zzprsdt.
*            ENDLOOP.
*          WHEN '935'. "Yeni yaratılan seri iskontosu için eklendi.
*            LOOP AT lt_vake INTO ls_vake.
*              READ TABLE <lt_konp> WITH KEY knumh = ls_vake-knumh
*                                          loevm_ko = 'X'
*                                          TRANSPORTING NO FIELDS.
*              CHECK sy-subrc NE 0.
*              MOVE-CORRESPONDING ls_vake TO ls_a935.
*              ls_a935-knuma_ag  = ls_vake-vakey(10).
*              ls_a935-vkorg     = ls_vake-vakey+10(4).
*              ls_a935-vtweg     = ls_vake-vakey+14(2).
*              ls_a935-zzprsdt   = ls_vake-vakey+16(8).
*              ls_a935-pltyp     = ls_vake-vakey+24(2).
*              ls_a935-prodh3    = ls_vake-vakey+26(4).
*              ls_a935-vrkme     = ls_vake-vakey+30(3).
*              APPEND ls_a935 TO lt_a935.
*              MOVE-CORRESPONDING ls_a935 TO ls_key_935.
*              COLLECT ls_key_935 INTO lt_key_935.
*            ENDLOOP.
*            SORT lt_a935 BY pltyp prodh3 vrkme zzprsdt.
*            LOOP AT lt_key_935 ASSIGNING FIELD-SYMBOL(<fs_key_935>).
*              CLEAR lv_max_zzprsdt.
*              LOOP AT lt_a935 INTO ls_a935
*                WHERE pltyp EQ <fs_key_935>-pltyp
*                AND prodh3 EQ <fs_key_935>-prodh3
*                AND vrkme EQ <fs_key_935>-vrkme.
*                IF ls_a935-zzprsdt NE ls_a935-datab.
*                  MESSAGE e001(ls) WITH text-e01 text-e02
*<fs_key_935>-pltyp.
*                ENDIF.
*                IF lv_max_zzprsdt LE ls_a935-zzprsdt.
*                  lv_max_zzprsdt = ls_a935-zzprsdt.
*                ENDIF.
*              ENDLOOP.
*              LOOP AT lt_a935 INTO ls_a935
*                    WHERE pltyp   EQ <fs_key_935>-pltyp AND
*                          prodh3 EQ <fs_key_935>-prodh3 AND
*                          vrkme EQ <fs_key_935>-vrkme AND
*                          zzprsdt NE lv_max_zzprsdt.
*                IF lv_max_zzprsdt LE ls_a935-datbi .
*                  MESSAGE e001(ls) WITH text-e03 text-e04
*<fs_key_935>-pltyp.
*                ENDIF.
*              ENDLOOP.
*              CLEAR: lv_max_zzprsdt.
*            ENDLOOP.
*            "---------<<
*          WHEN OTHERS.
*        ENDCASE.
*      ENDLOOP.
*    ENDLOOP.
*    "-----------------------------<<
  ENDMETHOD.


  METHOD if_ex_sd_cond_save_a~condition_save_exit.
**    check( ct_vake ).
  ENDMETHOD.
ENDCLASS.
