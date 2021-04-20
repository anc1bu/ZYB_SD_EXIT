*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_MD_MAT2
*&---------------------------------------------------------------------*
***********************************************************************
* YUR-5 Barkodda Yapılan Manuel İşlemler (Çisa Bilişim)
* ZSD006 arkasında bulunan tablonun doldurulması.

*DATA : lv_atinn TYPE cabn-atinn.
DATA : lv_objek TYPE ausp-objek.
DATA : lt_ausp TYPE STANDARD TABLE OF ausp.
DATA : ls_ausp TYPE ausp.
DATA : ls_t_md001 TYPE zyb_t_md001.
DATA : ls_sd_t_md001 TYPE zyb_sd_t_md001.
DATA : ls_sd_t_md002 TYPE zyb_sd_t_md002.
DATA : lt_sd_t_md002 LIKE STANDARD TABLE OF ls_sd_t_md002.
DATA : ls_sd_t_md003 TYPE zyb_sd_t_md003.
DATA : lt_sd_t_md003 TYPE STANDARD TABLE OF zyb_sd_t_md003.
DATA : BEGIN OF ls_mat,
         matnr TYPE mara-matnr,
       END OF ls_mat.
DATA : lt_mat LIKE STANDARD TABLE OF ls_mat.
DATA : lt_mat_found LIKE STANDARD TABLE OF ls_mat.
DATA : lv_mat TYPE matnr.
DATA : lv_extwg TYPE  matnr.
DATA : lt_kalite TYPE STANDARD TABLE OF zyb_pp_t_kalite.
DATA : ls_kalite TYPE zyb_pp_t_kalite.

IF wmvke-vtweg = '10'. "Yurtiçi ise
  CLEAR : lt_mat,ls_mat.
  SPLIT wmara-matnr AT '.' INTO TABLE lt_mat.

  READ TABLE lt_mat INTO ls_mat INDEX 1.
  CONCATENATE ls_mat '%' INTO lv_mat.

  SELECT matnr
    FROM mara
    INTO TABLE lt_mat_found
         WHERE matnr LIKE lv_mat.

*  DELETE lt_mat_found WHERE matnr EQ wmara-matnr.

  SELECT *
    FROM zyb_sd_t_md003
    INTO TABLE lt_sd_t_md003
         WHERE altkl EQ wmara-extwg.

  LOOP AT lt_mat_found INTO ls_mat.
    CLEAR : lv_mat,lv_extwg.
    SPLIT ls_mat-matnr AT '.' INTO lv_mat lv_extwg.

    CHECK lv_extwg IS NOT INITIAL.

    READ TABLE lt_sd_t_md003 TRANSPORTING NO FIELDS
          WITH KEY kalit = lv_extwg.

    IF sy-subrc IS INITIAL.
      CLEAR ls_kalite.
      ls_kalite-matnr1 = ls_mat-matnr.
      ls_kalite-matnr2 = wmara-matnr.
      ls_kalite-extwg = wmara-extwg.
      APPEND ls_kalite TO lt_kalite.
    ENDIF.
  ENDLOOP.
  IF lt_kalite[] IS NOT INITIAL.
    CALL FUNCTION 'ZSD_MM_SAVE_TAB2'
      IN UPDATE TASK
      TABLES
        t_kalite = lt_kalite.
  ENDIF.
ENDIF.

IF wmvke-vtweg  = '20'. "Yurtdışı ise
  CLEAR : lt_mat,ls_mat.
  SPLIT wmara-matnr AT '.' INTO TABLE lt_mat.

  READ TABLE lt_mat INTO ls_mat INDEX 1.
  CONCATENATE ls_mat '%' INTO lv_mat.

  SELECT matnr
    FROM mara
    INTO TABLE lt_mat_found
         WHERE matnr LIKE lv_mat.

*  DELETE lt_mat_found WHERE matnr EQ wmara-matnr.

  SELECT *
    FROM zyb_sd_t_md003
    INTO TABLE lt_sd_t_md003
         WHERE altkl EQ wmara-extwg.

  LOOP AT lt_mat_found INTO ls_mat.
    CLEAR : lv_mat,lv_extwg.
    SPLIT ls_mat-matnr AT '.' INTO lv_mat lv_extwg.

    CHECK lv_extwg IS NOT INITIAL.

    READ TABLE lt_sd_t_md003 TRANSPORTING NO FIELDS
          WITH KEY kalit = lv_extwg.

    IF sy-subrc IS INITIAL.
      CLEAR ls_kalite.
      ls_kalite-matnr1 = wmara-matnr.
      ls_kalite-matnr2 = ls_mat-matnr.
      ls_kalite-extwg = lv_extwg.
      APPEND ls_kalite TO lt_kalite.
    ENDIF.
  ENDLOOP.
  IF lt_kalite[] IS NOT INITIAL.
    CALL FUNCTION 'ZSD_MM_SAVE_TAB2'
      IN UPDATE TASK
      TABLES
        t_kalite = lt_kalite.
  ENDIF.
ENDIF.

*"--------->> Anıl CENGİZ 07.01.2020 01:15:38
*"YUR-523
*TRY.
*    NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_MM_EXIT_SMOD_ZXMG0U02'
*                                                    vars = VALUE #( ( name = 'WMARA' value = REF #( wmara ) )
*                                                                    ( name = 'WMVKE' value = REF #( wmvke ) ) ) ) )->execute( ).
*  CATCH zcx_bc_exit_imp INTO DATA(lo_bc_exit_imp).
*    IF lo_bc_exit_imp->previous IS BOUND.
*      DATA(lv_msg) = lo_bc_exit_imp->previous->if_message~get_text( ).
*      MESSAGE lv_msg TYPE 'E'.
*    ELSE.
*      lv_msg = lo_bc_exit_imp->if_message~get_text( ).
*      MESSAGE lv_msg TYPE 'E'.
*    ENDIF.
*ENDTRY.
*"---------<<
