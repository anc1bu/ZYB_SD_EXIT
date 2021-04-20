class ZCL_SD_MV13AF0K_FORM_KONDS_004 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV13AF0K_FORM_KONDS .

  class-methods EXECUTE
    importing
      !IT_XVAKE type COND_VAKEVB_T
      !IT_KONP type COND_KONPDB_T optional
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV13AF0K_FORM_KONDS_004 IMPLEMENTATION.


METHOD execute.

  CHECK: sy-tcode EQ 'ZSD007' OR
         sy-tcode EQ 'VK11' OR
         sy-tcode EQ 'VK12' OR
         sy-tcode EQ 'VB21' OR
         sy-tcode EQ 'VB22'.

  DATA(lo_msg) = cf_reca_message_list=>create( ).

*10	950	Tic.prom./Müşteri/Malzeme
*MANDT  MANDT CLNT  3 0 Üst birim
*KAPPL  KAPPL CHAR  2 0 Uygulama
*KSCHL  KSCHA CHAR  4 0 Koşul türü
*KNUMA_AG KNUMA_AG  CHAR  10  0 Ticari promosyon
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZPRSDT  PRSDT DATS  8 0 Fiyatlandırma ve döviz kuruna ilişkin tarih
*KUNNR  KUNNR_V CHAR  10  0 Müşteri numarası
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*KFRST  KFRST CHAR  1 0 Onay durumu
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*20	951	Tic.prom./Malzeme
*MANDT  MANDT CLNT  3 0 Üst birim
*KAPPL  KAPPL CHAR  2 0 Uygulama
*KSCHL  KSCHA CHAR  4 0 Koşul türü
*KNUMA_AG KNUMA_AG  CHAR  10  0 Ticari promosyon
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZPRSDT  PRSDT DATS  8 0 Fiyatlandırma ve döviz kuruna ilişkin tarih
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*KFRST  KFRST CHAR  1 0 Onay durumu
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*30	949	Tic.prom./Ebat/Depo/SÖB/Kalite
*KNUMA_AG KNUMA_AG  CHAR  10  0 Ticari promosyon
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZPRSDT  PRSDT DATS  8 0 Fiyatlandırma ve döviz kuruna ilişkin tarih
*ZZEBAT ZSD_EBAT  CHAR  30  0 Ebat
*ZZLGORT  LGORT_D CHAR  4 0 Depo yeri
*VRKME  VRKME UNIT  3 0 Satış ölçü birimi
*EXTWG  EXTWG CHAR  18  0 Harici mal grubu
*KFRST  KFRST CHAR  1 0 Onay durumu
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*40	908	Müşteri/Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*KUNNR  KUNNR_V CHAR  10  0 Müşteri numarası
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*50	936	Depo yeri/Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*ZZLGORT  LGORT_D CHAR  4 0 Depo yeri
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

*60	909	Malzeme
*VKORG  VKORG CHAR  4 0 Satış organizasyonu
*VTWEG  VTWEG CHAR  2 0 Dağıtım kanalı
*MATNR  MATNR CHAR  18  0 Malzeme numarası
*DATBI  KODATBI DATS  8 0 Koşul kayıtları geçerlilik sonu

  DATA(lt_kotabnr) = VALUE zcl_sd_mv13af0k_form_konds_001=>tt_kotabnr( ( kotabnr = '950')
                                                                       ( kotabnr = '951')
                                                                       ( kotabnr = '949')
                                                                       ( kotabnr = '908')
                                                                       ( kotabnr = '936')
                                                                       ( kotabnr = '909') ).

  TRY.
      LOOP AT lt_kotabnr INTO DATA(lv_kotabnr).
        DATA(lt_vake) = VALUE cond_vakevb_t( FOR wa IN it_xvake WHERE ( kotabnr EQ lv_kotabnr AND
                                                                        kschl EQ 'ZF06' ) ( CORRESPONDING #( wa ) ) ).
        LOOP AT lt_vake REFERENCE INTO DATA(lr_vake).
          ASSIGN it_konp[ knumh = lr_vake->knumh
                          loevm_ko = abap_true ] TO FIELD-SYMBOL(<is_konp>).
          CHECK: sy-subrc NE 0.

          CASE lr_vake->kotabnr.
            WHEN '950'.
              DATA(lv_matnr) = lr_vake->vakey+34(18).
            WHEN '951'.
              lv_matnr = lr_vake->vakey+24(18).
*          WHEN '949'.
            WHEN '908'.
              lv_matnr = lr_vake->vakey+16(18).
            WHEN '936'.
              lv_matnr = lr_vake->vakey+10(18).
            WHEN '909'.
              lv_matnr = lr_vake->vakey+6(18).
          ENDCASE.

          CHECK: lv_matnr NE zcl_sd_paletftr_mamulle=>cv_pltmlzno.

          DATA(ls_extwg) = zcl_sd_toolkit=>get_extwg( lv_matnr ).


          IF ls_extwg-extwg IS INITIAL AND lr_vake->kotabnr EQ '949'.
            ls_extwg-extwg = lr_vake->vakey+61(18).
          ENDIF.

          CHECK: ls_extwg-extwg IS NOT INITIAL.

          DATA(rr_vld_extwg) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                             var   = 'EXTWG'
                                                                             val   = REF #( ls_extwg-extwg )
                                                                             surec = 'YI_ZF06_GRIS' ) ) .
          ASSIGN rr_vld_extwg->* TO FIELD-SYMBOL(<lv_vld_extwg>).

          IF <lv_vld_extwg> NE abap_true. "Geçerli kalite değil ise.
            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZSD'
                         id_msgno = '088'
                         id_msgv1 = zcl_sd_toolkit=>get_extwg( lv_matnr )-extwg
                         id_msgv2 = |ZF06|
                         id_msgv3 = space
                         id_msgv4 = space ). "& kalite için & fiyatı giremezsiniz!

          ENDIF.

          IF lr_vake->kotabnr NE '949'.
            DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                               var   = 'MTART'
                                                                               val   = REF #( ls_extwg-mtart )
                                                                               surec = 'YI_ZF06_GRIS' ) ) .
            ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

            IF <lv_vld_mtart> NE abap_true. "Geçerli malzeme türü değil ise.
              lo_msg->add( id_msgty = 'E'
                           id_msgid = 'ZSD'
                           id_msgno = '089'
                           id_msgv1 = ls_extwg-mtart
                           id_msgv2 = |ZF06|
                           id_msgv3 = space
                           id_msgv4 = space ). "& malzeme türü için & fiyatı giremezsiniz!

            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF lo_msg->has_messages_of_msgty( 'E' ) EQ abap_true .
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.
    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.

  ENDTRY.

ENDMETHOD.


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

  FIELD-SYMBOLS: <gt_xvake> TYPE cond_vakevb_t,
                 <lt_konp>  TYPE cond_konpdb_t.

  DATA: lr_data TYPE REF TO data,
        lt_konp TYPE cond_konpdb_t.

  lr_data = co_con->get_vars( 'XVAKE[]' ). ASSIGN lr_data->* TO <gt_xvake>.

  ASSIGN ('(SAPMV13A)XKONP[]') TO <lt_konp>.
  IF sy-subrc EQ 0.
    lt_konp = <lt_konp>.
  ENDIF.

  execute( EXPORTING it_xvake = <gt_xvake>
                     it_konp = lt_konp ).

ENDMETHOD.
ENDCLASS.
