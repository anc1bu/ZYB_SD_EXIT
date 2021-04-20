*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_CHECK_XVBAP_FOR_DEL
*&---------------------------------------------------------------------*
*& USEREXIT_CHECK_XVBAP_FOR_DELET USING US_ERROR
*&                                          US_EXIT.
*& Example
*& IF US_ERROR NE SPACE.
*&   MESSAGE ......
*& ENDIF.
*& IF .......
*&   US_EXIT = CHARX.
*& ENDIF.
*&---------------------------------------------------------------------*
** İhracatta Proformadan çıkarılmayan kalem silinemez!!



    DATA: ls_shp02 LIKE zyb_sd_t_shp02 OCCURS 0 WITH HEADER LINE,

          ls_vvbap TYPE vbapvb,
          ls_vvbep TYPE vbepvb.

    CLEAR ls_shp02.
    SELECT SINGLE * FROM zyb_sd_t_shp02
          INTO ls_shp02
         WHERE vbeln EQ xvbap-vbeln
           AND posnr EQ xvbap-posnr
           AND loekz EQ space.

    IF NOT ls_shp02 IS INITIAL.
      IF us_error NE space.
        MESSAGE e034(zsd_va) WITH xvbap-vbeln xvbap-posnr ls_shp02-svkno
            DISPLAY LIKE 'I'.
      ENDIF.
      us_exit = charx.
    ENDIF.

    "--------->> Anıl CENGİZ 13.07.2020 22:50:48
    "YUR-683
    "ZCL_SD_MV45AFZB_FRM_DELVBP_001 içerisine taşındı.
**--->>>MOZDOGAN 25.07.2018 11:21:59
** YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*    data: lv_error type string.
*
*    "--------->> Anıl CENGİZ 16.09.2018 09:35:46
*    "YUR-160 Satış siparişinde sadece YYK olduğunda kalem silince
*    "sistem dump veriyor.
*
*    "--------->> Anıl CENGİZ 29.11.2018 11:20:16
*    "YUR-251
*    " Geçici çözüm olarak Tuncay Bey e silme yetkisi verdik.
*    if sy-uname eq 'TUNCAY.OZSOY'.
*      loop at xvbep assigning field-symbol(<fs_xvbep>)
*        where vbeln eq vbap-vbeln
*        and   posnr eq vbap-posnr.
*
*        append initial line to yvbep
*        assigning field-symbol(<fs_yvbep>).
*        <fs_yvbep> = <fs_xvbep>.
*        <fs_yvbep>-updkz = 'D'.
*        <fs_xvbep>-updkz = 'U'.
*
*      endloop.
*    else.
*      "---------<<
*      loop at xvbap[] transporting no fields
*        where pstyv eq zcl_sd_paletftr_mamulle=>cv_pltklm.
*        exit.
*      endloop.
*      if sy-subrc eq 0.
*        "---------<<
*
*        try.
*            us_exit = new zcl_sd_paletftr_mamulle(
*                            is_vbak = vbak
*                            iv_fcode = fcode
*                            is_vbap = vbap
*                            ir_xvbap = ref #( xvbap[] )
*                            ir_xvbep = ref #( xvbep[] )
*                            ir_yvbep = ref #( yvbep[] )
*                            ir_t180  = ref #( t180 )
*                          )->knt_pltsilme(
*        "-->> commented by mehmet sertkaya 18.09.2018 18:54:25
*        "YUR-160 Satış siparişinde sadece YYK olduğunda
*        "kalem silince sistem dump veriyor
** MV45AF0B_BELEG_LOESCHEN satır:162 aşağıdaki loop bozuluyor
**LOOP AT xvbap WHERE updkz NE updkz_delete
**                      AND uepos IS INITIAL.
**               IMPORTING et_xvbap = xvbap[]
*        "-----------------------------<
*
*          ).
*          catch cx_root into data(lo_cx_root).
*            lv_error = lo_cx_root->if_message~get_text( ).
*        endtry.
*        "--------->> Anıl CENGİZ 29.11.2018 11:20:16
*        "YUR-251
*        " Geçici çözüm olarak Tuncay Bey e silme yetkisi verdik.
*      endif.
*      "---------<<
*    endif.
**---<<<
    "---------<<
