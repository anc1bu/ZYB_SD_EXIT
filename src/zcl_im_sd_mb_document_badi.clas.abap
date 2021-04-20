class ZCL_IM_SD_MB_DOCUMENT_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_DOCUMENT_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_SD_MB_DOCUMENT_BADI IMPLEMENTATION.


  METHOD IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_BEFORE_UPDATE.
*    BREAK: YTOLA,MKARABOCU,XEDEMIRHAN,EDEMIRHAN.
*    data : IS_MKPF type mkpf.
*    loop at XMKPF into IS_MKPF.
*    CALL FUNCTION 'ZMM_MIGO_UPDATE'
*      IN UPDATE TASK
*      EXPORTING
*        IS_MKPF = IS_MKPF
*      TABLES
*        IT_MSEG = XMSEG.
*    endloop.
  ENDMETHOD.


  METHOD if_ex_mb_document_badi~mb_document_update.
    DATA: l_mkpf TYPE mkpf,
          l_mseg TYPE mseg.

    DATA: ls_shp02  TYPE zyb_sd_t_shp02,
          ls_vbap   TYPE vbap,
          lv_menge  TYPE menge_d,
          lv_charg  TYPE charg_d,
          lv_kalsnf TYPE zkalite_snf.

** 101 E yapıldığı durumda ZYB_SD_T_SHP02 tablosunda partisi
** boş kayıt var ise tablo güncellenir.
** palet log tablosunda kalite sınıfı dolu ise 101 e yapıldıktan sonra
** palet serbest stoğa atanıp 309 yapılır.
** 102 E yapıldığında ise ZYB_SD_T_SHP02 tablosundaki parti silinir.
**--> 21.09.2017
** Yeni güncelleme ile palet log tablosu yerine hareket nedeni kontrol
** edilmektedir.
**<--
    LOOP AT xmkpf INTO l_mkpf.
      LOOP AT xmseg INTO l_mseg WHERE mblnr EQ l_mkpf-mblnr
                                  AND mjahr EQ l_mkpf-mjahr .

        IF ( l_mseg-bwart EQ '101' AND l_mseg-sobkz EQ 'E' ) OR
           ( l_mseg-bwart EQ '102' AND l_mseg-sobkz EQ 'E' ).

          CLEAR ls_vbap.
          SELECT SINGLE * FROM vbap
              INTO ls_vbap
              WHERE vbeln EQ l_mseg-mat_kdauf
                AND posnr EQ l_mseg-mat_kdpos.
** -->21.09.2017
*          IF NOT l_mseg-charg IS INITIAL.
*            CLEAR lv_kalsnf.
*            SELECT SINGLE kalite_sinif FROM zyb_pp_palet_log
*                INTO lv_kalsnf WHERE palet_no EQ l_mseg-charg.
*            IF  NOT lv_kalsnf IS INITIAL.
*              CONTINUE.
*            ENDIF.
*          ELSE.
*            CONTINUE.
*          ENDIF.

          IF l_mseg-charg IS INITIAL.
            CONTINUE.
          ELSE.
            IF l_mseg-grund IS NOT INITIAL." hareket nedeni
              CONTINUE.
            ENDIF.
          ENDIF.
** <--21.09.2017
          CLEAR lv_menge.
          IF ls_vbap-vrkme NE l_mseg-meins.
            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                i_matnr  = l_mseg-matnr
                i_in_me  = l_mseg-meins
                i_out_me = ls_vbap-vrkme
                i_menge  = l_mseg-menge
              IMPORTING
                e_menge  = lv_menge.
          ELSE.
            lv_menge = l_mseg-menge.
          ENDIF.

          CLEAR lv_charg.
          CASE l_mseg-bwart.
            WHEN '101'.
              CLEAR lv_charg.
            WHEN '102'.
              lv_charg = l_mseg-charg.
          ENDCASE.

          SELECT SINGLE * FROM zyb_sd_t_shp02
              INTO ls_shp02
             WHERE vbeln  EQ l_mseg-mat_kdauf
               AND posnr  EQ l_mseg-mat_kdpos
               AND charg  EQ lv_charg
               AND tesmik EQ lv_menge
               AND loekz  EQ space.

          IF NOT ls_shp02 IS INITIAL.
            IF l_mseg-bwart  EQ '101'.
              ls_shp02-charg = l_mseg-charg.
              ls_shp02-lgort = l_mseg-lgort.
            ELSEIF l_mseg-bwart EQ '102'.
              CLEAR: ls_shp02-charg,
                     ls_shp02-lgort.
            ENDIF.

            ls_shp02-aenam = sy-uname.
            ls_shp02-aedat = sy-datum.
            ls_shp02-aezet = sy-uzeit.
            MODIFY zyb_sd_t_shp02 FROM ls_shp02.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
