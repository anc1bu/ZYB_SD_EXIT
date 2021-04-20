class ZCL_SD_MV45AFZB_FRM_DELVBP_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_DELVBP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_DELVBP_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <lt_xvbap>   TYPE tab_xyvbap,
                 <gs_xvbap>   TYPE vbapvb,
                 <lt_xvbep>   TYPE tab_xyvbep,
                 <lt_yvbep>   TYPE tab_xyvbep,
                 <ls_vbak>    TYPE vbak,
                 <ls_vbap>    TYPE vbap,
                 <lv_us_exit> TYPE char1,
                 <lv_fcode>   TYPE fcode,
                 <ls_t180>    TYPE t180.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'XVBAP[]' ). ASSIGN lr_data->* TO <lt_xvbap>.
  lr_data = co_con->get_vars( 'XVBAP' ).   ASSIGN lr_data->* TO <gs_xvbap>.
  lr_data = co_con->get_vars( 'XVBEP' ).   ASSIGN lr_data->* TO <lt_xvbep>.
  lr_data = co_con->get_vars( 'YVBEP' ).   ASSIGN lr_data->* TO <lt_yvbep>.
  lr_data = co_con->get_vars( 'VBAK' ).    ASSIGN lr_data->* TO <ls_vbak>.
  lr_data = co_con->get_vars( 'VBAP' ).    ASSIGN lr_data->* TO <ls_vbap>.
  lr_data = co_con->get_vars( 'US_EXIT' ). ASSIGN lr_data->* TO <lv_us_exit>.
  lr_data = co_con->get_vars( 'FCODE' ).   ASSIGN lr_data->* TO <lv_fcode>.
  lr_data = co_con->get_vars( 'T180' ).    ASSIGN lr_data->* TO <ls_t180>.

*--->>>MOZDOGAN 25.07.2018 11:21:59
* YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
*  DATA: lv_error TYPE string.

  "--------->> Anıl CENGİZ 16.09.2018 09:35:46
  "YUR-160 Satış siparişinde sadece YYK olduğunda kalem silince
  "sistem dump veriyor.
  "--------->> Anıl CENGİZ 13.07.2020 23:05:30
  "YUR-683
*  "--------->> Anıl CENGİZ 29.11.2018 11:20:16
*  "YUR-251
*  " Geçici çözüm olarak Tuncay Bey e silme yetkisi verdik.
*  IF sy-uname EQ 'TUNCAY.OZSOY'.
*    LOOP AT <lt_xvbep> ASSIGNING FIELD-SYMBOL(<ls_xvbep>)
*      WHERE vbeln EQ <ls_vbap>-vbeln
*      AND   posnr EQ <ls_vbap>-posnr.
*
*      APPEND INITIAL LINE TO <lt_yvbep>
*      ASSIGNING FIELD-SYMBOL(<ls_yvbep>).
*      <ls_yvbep> = <ls_xvbep>.
*      <ls_yvbep>-updkz = 'D'.
*      <ls_xvbep>-updkz = 'U'.
*
*    ENDLOOP.
*  ELSE.
*  "---------<<
  "---------<<
  LOOP AT <lt_xvbap> TRANSPORTING NO FIELDS
    WHERE pstyv EQ zcl_sd_paletftr_mamulle=>cv_pltklm.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    "---------<<
    <lv_us_exit> = NEW zcl_sd_paletftr_mamulle( is_vbak = <ls_vbak>
                                                iv_fcode = <lv_fcode>
                                                is_vbap = <ls_vbap>
                                                ir_xvbap = REF #( <lt_xvbap> )
                                                ir_xvbep = REF #( <lt_xvbep> )
                                                ir_yvbep = REF #( <lt_yvbep> )
                                                ir_t180  = REF #( <ls_t180> ) )->knt_pltsilme(
   "-->> commented by mehmet sertkaya 18.09.2018 18:54:25
   "YUR-160 Satış siparişinde sadece YYK olduğunda
   "kalem silince sistem dump veriyor
* MV45AF0B_BELEG_LOESCHEN satır:162 aşağıdaki loop bozuluyor
*LOOP AT xvbap WHERE updkz NE updkz_delete
*                      AND uepos IS INITIAL.
*               IMPORTING et_xvbap = xvbap[]
   "-----------------------------<
     ).

*------------------------------------------------------------------------------------------------------------------------------
    "--------->> Anıl CENGİZ 11.08.2020 14:21:21
    "YUR-708
    TRY.
        DATA(rr_exc_user) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                     var = 'USER'
                                                                     val = REF #( sy-uname )
                                                                     surec = 'YI_PLT_SILME' ) ) .
        ASSIGN rr_exc_user->* TO FIELD-SYMBOL(<lv_exc_user>).
        IF <lv_exc_user> EQ abap_true. "istisna kullanıcısı ise aşağıdaki kontrole girmez.
          CLEAR <lv_us_exit>.
        ENDIF.

      CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lx_sd_exc_vld_cntrl->messages.
    ENDTRY.
    "---------<<

    "--------->> Anıl CENGİZ 13.07.2020 23:04:17
    "YUR-683
    IF <lv_us_exit> EQ space.
      LOOP AT <lt_xvbep> ASSIGNING FIELD-SYMBOL(<ls_xvbep>)
        WHERE posnr EQ <gs_xvbap>-posnr.

        READ TABLE <lt_yvbep> INTO DATA(ls_yvbep)
          WITH KEY posnr = <gs_xvbap>-posnr
                   etenr = <ls_xvbep>-etenr.
        IF ls_yvbep-posnr NE <gs_xvbap>-posnr OR
           ls_yvbep-etenr NE <ls_xvbep>-etenr.
          "--------->> Anıl CENGİZ 31.08.2020 14:50:28
          "YUR-715
          SELECT SINGLE mandt
            FROM vbep
            INTO sy-mandt
            WHERE vbeln EQ <ls_xvbep>-vbeln
              AND posnr EQ <ls_xvbep>-posnr
              AND etenr EQ <ls_xvbep>-etenr.
          IF sy-subrc EQ 0.
            APPEND INITIAL LINE TO <lt_yvbep> ASSIGNING FIELD-SYMBOL(<ls_yvbep>).
            <ls_yvbep> = <ls_xvbep>.
            <ls_yvbep>-updkz = 'D'.
            <ls_xvbep>-updkz = 'U'.
          ENDIF.
*          APPEND INITIAL LINE TO <lt_yvbep> ASSIGNING FIELD-SYMBOL(<ls_yvbep>).
*          <ls_yvbep> = <ls_xvbep>.
*          <ls_yvbep>-updkz = 'D'.
*          <ls_xvbep>-updkz = 'U'.,
          "---------<<
        ENDIF.
      ENDLOOP.
    ENDIF.
    "---------<<
  ENDIF.
*  ENDIF.
*---<<<

ENDMETHOD.
ENDCLASS.
