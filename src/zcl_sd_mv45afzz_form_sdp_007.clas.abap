class ZCL_SD_MV45AFZZ_FORM_SDP_007 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZZ_FORM_SDP .

  types:
    tth_findoc TYPE HASHED TABLE OF zsdt_findoc_expc WITH UNIQUE KEY auart .
  types TT_KMPLIST type ZYB_SD_T_KMPLIST .

  data GT_FINDOC type TTH_FINDOC .
  data GT_KMPLIST type TT_KMPLIST .
protected section.
PRIVATE SECTION.

  CONSTANTS gc_mtart_yyk TYPE mtart VALUE 'ZYYK'.           "#EC NOTEXT
  CONSTANTS gc_mtart_ztic TYPE mtart VALUE 'ZTIC'.          "#EC NOTEXT
  CONSTANTS cv_delete TYPE updkz VALUE 'D'.                 "#EC NOTEXT
  CONSTANTS cv_vtweg_ic TYPE vtweg VALUE '10'.              "#EC NOTEXT
  CONSTANTS cv_borcdknt TYPE vbtyp VALUE 'L'.               "#EC NOTEXT
  CONSTANTS cv_iadesip TYPE vbtyp VALUE 'H'.                "#EC NOTEXT
  CONSTANTS cv_create TYPE trtyp VALUE 'H'.                 "#EC NOTEXT
  CONSTANTS cv_change TYPE trtyp VALUE 'V'.                 "#EC NOTEXT
  CONSTANTS cv_vtweg_dis TYPE vtweg VALUE '20'.             "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_FORM_SDP_007 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gt_xvbap> TYPE tab_xyvbap,
                 <gt_xvbkd> TYPE tab_xyvbkd,
                 <gt_xvbup> TYPE tab_xyvbup,
                 <gs_vbak>  TYPE vbak.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP' ).     ASSIGN lr_data->* TO <gt_xvbap>.
  lr_data = co_con->get_vars( 'XVBKD' ).     ASSIGN lr_data->* TO <gt_xvbkd>.
  lr_data = co_con->get_vars( 'XVBUP' ).     ASSIGN lr_data->* TO <gt_xvbup>.
  lr_data = co_con->get_vars( 'VBAK' ).      ASSIGN lr_data->* TO <gs_vbak>.


  DATA: lv_amount TYPE netwr,
        lv_expc   TYPE zsdt_findoc_expc.

  CHECK: <gs_vbak>-vkbur NE '1120',
         "--------->> Anıl CENGİZ 16.09.2019 15:01:30
         "YUR-487 Alacak dekontu ise kontrole girme.
         <gs_vbak>-vbtyp NE 'K',
         <gs_vbak>-vtweg EQ cv_vtweg_ic.
  "---------<<
  "İstisna tablosunda yoksa.
  ASSIGN gt_findoc[ KEY primary_key COMPONENTS auart = <gs_vbak>-auart ] TO FIELD-SYMBOL(<gs_findoc>).
  IF sy-subrc NE 0.
    SELECT SINGLE *
      FROM zsdt_findoc_expc
      INTO lv_expc
      WHERE auart EQ <gs_vbak>-auart .
    IF sy-subrc EQ 0.
      INSERT lv_expc INTO TABLE gt_findoc ASSIGNING <gs_findoc>.
      RETURN.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.
  "--------->> Anıl CENGİZ 23.09.2019 09:38:29
  "YUR-447
  "GS_PARAMS statik olduğu için ekrandan çıkmadan yeniden sipariş açıldığında OPEN_VALUE açık değer güncellenmiyor.
  "Tekrar güncellenmesi için temizlendi.
  REFRESH: gt_kmplist.
  "---------<<
  ASSIGN gt_kmplist[ knuma_ag = <gs_vbak>-zz_knuma_ag ] TO FIELD-SYMBOL(<gs_kmplist>).
  IF sy-subrc NE 0.
    ASSIGN <gt_xvbkd>[ posnr = '000000' ]-prsdt TO FIELD-SYMBOL(<gv_prsdt>).
    IF sy-subrc EQ 0.
      CALL FUNCTION 'ZYB_SD_F_KMP_FIND'
        EXPORTING
          i_vkorg      = <gs_vbak>-vkorg
          i_vtweg      = <gs_vbak>-vtweg
          i_kunnr      = <gs_vbak>-kunnr
          i_date       = <gv_prsdt>
          i_auart      = <gs_vbak>-auart
        IMPORTING
          kmplist      = gt_kmplist
        EXCEPTIONS
          not_found    = 1
          format_error = 2
          OTHERS       = 3.
      IF gt_kmplist[] IS NOT INITIAL.
        ASSIGN gt_kmplist[ knuma_ag = <gs_vbak>-zz_knuma_ag ] TO <gs_kmplist>.
        IF sy-subrc NE 0.
          DATA(lo_msg) = cf_reca_message_list=>create( ).
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD'
                       id_msgno = '079' "ZSD_VA 036 yerine yazdıldı.
                       id_msgv1 = <gs_vbak>-zz_knuma_ag ).
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lo_msg.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT <gt_xvbap> ASSIGNING FIELD-SYMBOL(<gs_xvbap>)
    WHERE abgru IS INITIAL
    "--------->> Anıl CENGİZ 29.06.2020 12:38:48
    "YUR-675
    AND updkz NE 'D'.
    "---------<<
    ADD <gs_xvbap>-netwr TO lv_amount.
    ADD <gs_xvbap>-mwsbp TO lv_amount.
    "--------->> add by mehmet sertkaya 26.08.2019 11:23:17
    "YUR-447 - Açığa Sipariş Girme Hatası
    DATA ls_db TYPE vbap.

    ASSIGN <gt_xvbup>[ vbeln = <gs_xvbap>-vbeln
                       posnr = <gs_xvbap>-posnr ] TO FIELD-SYMBOL(<gs_xvbup>).
    IF sy-subrc EQ 0.
      IF <gs_xvbup>-cmppi EQ 'A'.
        SELECT SINGLE * INTO ls_db FROM vbap
                        WHERE vbeln EQ <gs_xvbap>-vbeln AND
                              posnr EQ <gs_xvbap>-posnr .
        IF sy-subrc EQ 0.
          ADD ls_db-netwr TO <gs_kmplist>-open_value.
          ADD ls_db-mwsbp TO <gs_kmplist>-open_value.
        ENDIF.
      ENDIF.
    ENDIF.
    "-----------------------------<<
  ENDLOOP.
  IF lv_amount GT <gs_kmplist>-open_value.
    lo_msg = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '079' "ZSD_VA 036 yerine yazdıldı.
                 id_msgv1 = <gs_vbak>-zz_knuma_ag
                 id_msgv2 = CONV #( <gs_kmplist>-open_value )
                 id_msgv3 = CONV #( lv_amount ) ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.

ENDMETHOD.
ENDCLASS.
