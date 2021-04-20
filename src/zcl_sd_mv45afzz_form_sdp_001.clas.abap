CLASS zcl_sd_mv45afzz_form_sdp_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_mv45afzz_form_sdp .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_avlcheck,
        matnr  TYPE matnr,
        lgort  TYPE lgort_d,
        avlqty TYPE mng01,
        kwmeng TYPE kwmeng,
      END OF ty_avlcheck,
      tth_avlcheck TYPE HASHED TABLE OF ty_avlcheck WITH UNIQUE KEY primary_key COMPONENTS matnr lgort,
      tts_enq      TYPE zcl_sd_toolkit=>tts_enq.

    DATA: gt_avlcheck TYPE tth_avlcheck .

    METHODS check_availability
      IMPORTING
        !ir_vbap         TYPE REF TO vbapvb
      RETURNING
        VALUE(rv_kbmeng) TYPE kbmeng .
    METHODS check_mtart
      IMPORTING
        !iv_matnr TYPE matnr
      RETURNING
        VALUE(rc) TYPE sy-subrc .
    METHODS set_availability
      IMPORTING
        VALUE(it_xvbap) TYPE tab_xyvbap
        !it_yvbap       TYPE tab_xyvbap .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_001 IMPLEMENTATION.


  METHOD check_availability.

    DATA: lt_wmdvex TYPE wsao_disp_atp_tab,
          lt_wmdvsx TYPE TABLE OF bapiwmdvs.

    CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
      EXPORTING
        plant      = ir_vbap->werks
        material   = ir_vbap->matnr
        unit       = ir_vbap->vrkme
        check_rule = 'A'
        stge_loc   = ir_vbap->lgort
*       BATCH      =
*       CUSTOMER   =
*       DOC_NUMBER =
*       ITM_NUMBER =
*       WBS_ELEM   =
*       STOCK_IND  =
*       DEC_FOR_ROUNDING         =
*       DEC_FOR_ROUNDING_X       =
*       READ_ATP_LOCK            =
*       READ_ATP_LOCK_X          =
*       MATERIAL_EVG             =
*       SGT_RCAT   =
*  IMPORTING
*       ENDLEADTME =
*       AV_QTY_PLT =
*       DIALOGFLAG =
*       RETURN     =
      TABLES
        wmdvsx     = lt_wmdvsx
        wmdvex     = lt_wmdvex.

    ASSIGN lt_wmdvex[ 1 ] TO FIELD-SYMBOL(<ls_wmdvvex>).
    IF <ls_wmdvvex> IS ASSIGNED.
      rv_kbmeng = <ls_wmdvvex>-com_qty.
    ENDIF.

  ENDMETHOD.


  METHOD check_mtart.

    SELECT SINGLE mandt
      FROM mara
      INTO sy-mandt
      WHERE matnr EQ iv_matnr
        AND mtart NOT IN ( zif_sd_mv45afzz_form_sdp~gcv_mtart_yyk , zif_sd_mv45afzz_form_sdp~gcv_mtart_ztic )
        AND matkl NE 'Y0603' .

    rc = sy-subrc . "YYK, ZTIC ve Y0603 değilse return code 0 dönülür.

  ENDMETHOD.


  METHOD set_availability.

    DATA: ls_yvbap  TYPE vbap,
          lv_kwmeng TYPE kwmeng.

    DELETE it_xvbap WHERE pstyv EQ 'Z026'.

    LOOP AT it_xvbap REFERENCE INTO DATA(lr_xvbap).

      CLEAR: lv_kwmeng, ls_yvbap.

      DATA(lv_kbmeng) = check_availability( lr_xvbap ).

      ASSIGN gt_avlcheck[ KEY primary_key COMPONENTS lgort = lr_xvbap->lgort
                                                     matnr = lr_xvbap->matnr  ] TO FIELD-SYMBOL(<ls_avlcheck>).
      IF sy-subrc EQ 0.
        READ TABLE it_yvbap WITH KEY posnr = lr_xvbap->posnr INTO ls_yvbap.
        IF sy-subrc EQ 0.
          IF ls_yvbap-lgort EQ lr_xvbap->lgort.
            ADD ls_yvbap-kbmeng TO <ls_avlcheck>-avlqty.
          ELSE.
            ASSIGN gt_avlcheck[ KEY primary_key COMPONENTS lgort = ls_yvbap-lgort
                                                           matnr = ls_yvbap-matnr  ] TO FIELD-SYMBOL(<ls_avlcheck1>).
            IF sy-subrc EQ 0.
              ADD ls_yvbap-kbmeng TO <ls_avlcheck1>-avlqty.
            ELSE.
              DATA(ls_avlcheck) = VALUE ty_avlcheck( lgort  = ls_yvbap-lgort
                                                     matnr  = ls_yvbap-matnr
                                                     avlqty = ls_yvbap-kwmeng ).
              INSERT ls_avlcheck INTO TABLE gt_avlcheck.
            ENDIF.
          ENDIF.
        ELSE.
          IF lr_xvbap->updkz NE 'I'.
            ADD lr_xvbap->kbmeng TO <ls_avlcheck>-avlqty.
          ENDIF.
        ENDIF.
        IF lr_xvbap->updkz NE 'D'.
          ADD lr_xvbap->kwmeng TO <ls_avlcheck>-kwmeng.
        ENDIF.
      ELSE.
        READ TABLE it_yvbap WITH KEY posnr = lr_xvbap->posnr INTO ls_yvbap.
        IF sy-subrc EQ 0.
          IF ls_yvbap-lgort EQ lr_xvbap->lgort.
            ADD ls_yvbap-kbmeng TO lv_kbmeng.
          ELSE.
            ASSIGN gt_avlcheck[ KEY primary_key COMPONENTS lgort = ls_yvbap-lgort
                                                           matnr = ls_yvbap-matnr  ] TO FIELD-SYMBOL(<ls_avlcheck3>).
            IF sy-subrc EQ 0.
              ADD ls_yvbap-kbmeng TO <ls_avlcheck3>-avlqty.
            ELSE.
              CLEAR: lv_kwmeng.
              IF lr_xvbap->updkz NE 'D'.
                lv_kwmeng =  ls_yvbap-kwmeng.
              ENDIF.
              ls_avlcheck = VALUE ty_avlcheck( lgort  = ls_yvbap-lgort
                                               matnr  = ls_yvbap-matnr
                                               avlqty = lv_kwmeng ).
              INSERT ls_avlcheck INTO TABLE gt_avlcheck.
            ENDIF.
          ENDIF.
        ELSE.
          IF lr_xvbap->updkz NE 'I'.
            ADD lr_xvbap->kbmeng TO lv_kbmeng.
          ENDIF.
        ENDIF.
        CLEAR: lv_kwmeng.
        IF lr_xvbap->updkz NE 'D'.
          lv_kwmeng = lr_xvbap->kwmeng.
        ENDIF.
        ls_avlcheck = VALUE ty_avlcheck( lgort  = lr_xvbap->lgort
                                         matnr  = lr_xvbap->matnr
                                         avlqty = lv_kbmeng
                                         kwmeng = lv_kwmeng ).
        INSERT ls_avlcheck INTO TABLE gt_avlcheck.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD zif_bc_exit_imp~execute.

    FIELD-SYMBOLS: <gt_xvbap>    TYPE tab_xyvbap,
                   <gt_yvbap>    TYPE tab_xyvbap,
                   <gt_xvbep>    TYPE tab_xyvbep,
                   <gv_callbapi> TYPE abap_bool,
                   <gs_vbak>     TYPE vbak,
                   <gs_t180>     TYPE t180,
                   <gv_fcode>    TYPE char20.

    DATA: lt_error  TYPE bapirettab,
          lv_kwmeng TYPE kwmeng,
          lr_data   TYPE REF TO data,
          ls_yvbap  TYPE vbap.

    lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <gt_xvbap>.
    lr_data = co_con->get_vars( 'YVBAP' ).     ASSIGN lr_data->* TO <gt_yvbap>.
    lr_data = co_con->get_vars( 'XVBEP' ).     ASSIGN lr_data->* TO <gt_xvbep>.
    lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.
    lr_data = co_con->get_vars( 'CALL_BAPI' ). ASSIGN lr_data->* TO <gv_callbapi>.
    lr_data = co_con->get_vars( 'T180' ).      ASSIGN lr_data->* TO <gs_t180>.
    lr_data = co_con->get_vars( 'FCODE' ).     ASSIGN lr_data->* TO <gv_fcode>.

    CHECK: sy-cprog(6)     NE 'RVKRED',
           <gs_vbak>-vtweg NE zif_sd_mv45afzz_form_sdp~gcv_vtweg_exp, "Sadece yutiçi sevkiyatlarda.
           <gs_vbak>-vbtyp NE zif_sd_mv45afzz_form_sdp~gcv_borcdknt, "Borç dekont talebi değilse.
           "--------->> Anıl CENGİZ 17.02.2020 13:22:22
           "YUR-592
           <gs_vbak>-vbtyp NE zif_sd_mv45afzz_form_sdp~gcv_iadesip,
           <gv_fcode> NE 'LOES'.
    "---------<<
    "--------->> Anıl CENGİZ 01.07.2020 13:07:01
    "YUR-676
    "Siparişin içindeki kalemlere göre kullanılabilir stoklar ayarlanır.
    set_availability( EXPORTING it_xvbap = <gt_xvbap>
                                it_yvbap = <gt_yvbap> ).
    "---------<<
    "--------->> Anıl CENGİZ 23.11.2020 16:49:25
    "YUR-775
    DATA(lt_enq) = zcl_sd_toolkit=>enqueue_read( 'ATPENQ' ).
    DATA(lt_xvbep) = VALUE tab_xyvbep( FOR wa IN <gt_xvbep> ( vbeln = wa-vbeln posnr = wa-posnr wmeng = wa-wmeng bmeng = wa-bmeng ) ).
    "---------<<
    LOOP AT <gt_xvbap> REFERENCE INTO DATA(lr_xvbap)
      WHERE abgru EQ space
        AND updkz NE zif_sd_mv45afzz_form_sdp~gcv_delete
        "--------->> Anıl CENGİZ 27.07.2018 13:58:21
        " YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
        AND pstyv NE zcl_sd_paletftr_mamulle=>cv_pltklm.
      "---------<<
      "Malzeme türü YYK veya ZTIC olmamalı.
      CHECK: check_mtart( lr_xvbap->matnr ) IS INITIAL.
      "--------->> Anıl CENGİZ 10.04.2020 15:10:51
      "YUR-635
      ASSIGN <gt_xvbep>[ posnr = lr_xvbap->posnr ] TO FIELD-SYMBOL(<ls_vbep>).
      IF <ls_vbep> IS ASSIGNED.
        CHECK: <ls_vbep>-ettyp NE 'F0', "Konsinye geri çekişte kullanılabilirliğe bakılmaz.
               <ls_vbep>-ettyp NE 'F1',
               "--------->> Anıl CENGİZ 08.03.2021 09:29:26
               "YUR-861
               <ls_vbep>-ettyp NE 'Z6'. "Diğer satışlarda kullanılabilirliğe bakılmaz. "ZA05
               "---------<<
      ENDIF.
      "---------<<
      "--------->> Anıl CENGİZ 01.07.2020 09:48:06
      "YUR-676
*    "--------->> Anıl CENGİZ 29.01.2020 18:51:36
*    "YUR-581
*    DATA(lv_kbmeng) = check_availability( lr_vbap ).
**    IF lr_vbap->kwmeng NE lr_vbap->kbmeng.
**      MESSAGE e019(zsd_va)
**        WITH lr_vbap->vbeln lr_vbap->posnr lr_vbap->matnr.
**    ENDIF.

*    IF <ls_t180>-trtyp EQ cv_change AND lr_xvbap->kwmeng NE lr_xvbap->kbmeng.
*      DATA(lo_msg) = cf_reca_message_list=>create( ).
*      lo_msg->add( id_msgty = 'E'
*                   id_msgid = 'ZSD_VA'
*                   id_msgno = '019'
*                   id_msgv1 = lr_xvbap->vbeln
*                   id_msgv2 = lr_xvbap->posnr
*                   id_msgv3 = lr_xvbap->matnr ).
*      EXIT.
*    ENDIF.
      "---------<<
      ASSIGN gt_avlcheck[ KEY primary_key COMPONENTS lgort = lr_xvbap->lgort
                                                     matnr = lr_xvbap->matnr ] TO FIELD-SYMBOL(<ls_avlcheck>).
      "--------->> Anıl CENGİZ 08.06.2020 16:43:50
      "YUR-663 - İç Piyasa Siparişlerinde Depo Yeri Değiştirildiğinde Kullanılabilirliğe Bakmıyor
*      ASSIGN <lt_yvbap>[ posnr = lr_vbap->posnr ] TO FIELD-SYMBOL(<ls_yvbap>).
*    READ TABLE <lt_yvbap> WITH KEY posnr = lr_xvbap->posnr INTO ls_yvbap.
*    IF sy-subrc EQ 0.
*      IF ls_yvbap-lgort EQ lr_xvbap->lgort.
*        <ls_avlcheck>-avlqty = <ls_avlcheck>-avlqty + ls_yvbap-kwmeng.
*      ENDIF.
*    ELSE.
*      SELECT SINGLE *
*        FROM vbap
*        INTO ls_yvbap
*        WHERE vbeln EQ lr_xvbap->vbeln
*          AND posnr EQ lr_xvbap->posnr.
*      IF sy-subrc EQ 0.
*        <ls_avlcheck>-avlqty = <ls_avlcheck>-avlqty + ls_yvbap-kwmeng.
*      ENDIF.
*    ENDIF.
      "---------<<

      IF <ls_avlcheck>-kwmeng GT <ls_avlcheck>-avlqty. "Kaydetmeden önce bir kez daha kullanılabilirliğe bakılır.

        IF <gv_callbapi> EQ abap_true.
          MESSAGE e019(zsd_va)
            WITH lr_xvbap->vbeln lr_xvbap->posnr lr_xvbap->matnr.
        ELSE.
          DATA(lo_msg) = cf_reca_message_list=>create( ).
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD_VA'
                       id_msgno = '019'
                       id_msgv1 = lr_xvbap->vbeln
                       id_msgv2 = lr_xvbap->posnr
                       id_msgv3 = lr_xvbap->matnr ).
        ENDIF.

      ENDIF.
      "---------<<
*      "--------->> Anıl CENGİZ 23.11.2020 16:50:02
*      "YUR-775
*
*      DATA(lts_enq) = VALUE zcl_sd_toolkit=>tts_enq( FOR wa IN lt_enq WHERE ( gtarg+6(18) EQ lr_xvbap->matnr AND gtarg+38(4) EQ lr_xvbap->lgort AND guname NE sy-uname )
*                                                                            ( CORRESPONDING #( wa ) ) ).
*
*      ASSIGN lts_enq[ 1 ] TO FIELD-SYMBOL(<ls_enq>).
*      IF sy-subrc EQ 0.
*        IF lo_msg IS NOT BOUND.
*          lo_msg = cf_reca_message_list=>create( ).
*        ENDIF.
*        lo_msg->add( id_msgty = 'E'
*                     id_msgid = 'ZSD'
*                     id_msgno = '085'
*                     id_msgv1 = lr_xvbap->matnr
*                     id_msgv2 = lr_xvbap->lgort
*                     id_msgv3 = <ls_enq>-guname ).
*      ENDIF.
*      "---------<<
    ENDLOOP.

    IF lo_msg IS BOUND.
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
