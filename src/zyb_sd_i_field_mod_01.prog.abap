*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_FIELD_MOD_01
*&---------------------------------------------------------------------*
"--------->> Anıl CENGİZ 28.09.2020 11:17:18
"YUR-739
*DATA : ls_yb_t_englle TYPE zsd_yb_t_englle,
*       ls_vbfa        TYPE vbfa.
*SELECT SINGLE * FROM zsd_yb_t_englle INTO ls_yb_t_englle
*  WHERE vkorg EQ vbak-vkorg
*  AND vtweg EQ vbak-vtweg.
*IF sy-subrc IS INITIAL. "sadece yurtiçi siparişleri için
*  CLEAR ls_vbfa.
*  SELECT SINGLE * FROM vbfa INTO ls_vbfa
*    WHERE vbelv = vbak-vbeln
*    AND vbtyp_n = 'J'.
*  IF ls_vbfa-vbeln IS NOT INITIAL.
*    CASE screen-name.
*      WHEN 'VBKD-VSART'   OR 'RV45A-ETDAT' OR
*           'RV45A-KETDAT' OR 'VBKD-BSTKD' OR
*           'KUWEV-KUNNR'.
*        screen-input = 0.
*        MODIFY SCREEN.
*      WHEN OTHERS.
*    ENDCASE.
*  ENDIF.
*ENDIF.
"---------<<
