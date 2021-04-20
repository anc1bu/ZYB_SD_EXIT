class ZCL_MM_EXIT_SMOD_MBCF0002_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EXIT_SMOD_MBCF0002 .

  constants CV_MEMORY_ID type CHAR12 value 'MBCF0002_002'. "#EC NOTEXT

  class-methods ZMB_MIGO_BADI
    importing
      !IV_MSEG type MSEG
    raising
      ZCX_BC_EXIT_IMP .
protected section.
private section.

  constants CV_NAKIL type BWART value '311'. "#EC NOTEXT
  constants CV_ALACAK type SHKZG value 'H'. "#EC NOTEXT
  constants CV_BORC type SHKZG value 'S'. "#EC NOTEXT

  type-pools ABAP .
  class-methods CHECK_MRP_INDICATOR
    importing
      !IV_MSEG type MSEG
    returning
      value(RV_RETURN) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_MBCF0002_002 IMPLEMENTATION.


METHOD check_mrp_indicator.

  CLEAR: rv_return.

  SELECT SINGLE mandt
    FROM mard
    INTO sy-mandt
    WHERE matnr EQ iv_mseg-matnr
      AND werks EQ iv_mseg-werks
      AND lgort EQ iv_mseg-lgort
      AND diskz EQ '1'.
  IF sy-subrc EQ 0.
    rv_return = abap_true.
  ENDIF.

ENDMETHOD.


METHOD ZIF_BC_EXIT_IMP~EXECUTE.

  FIELD-SYMBOLS: <ls_mseg> TYPE mseg,
                 <ls_mkpf> TYPE mkpf.

  DATA: lr_data   TYPE REF TO data.

  lr_data  = co_con->get_vars( 'I_MSEG'  ). ASSIGN lr_data->* TO <ls_mseg>.
  lr_data  = co_con->get_vars( 'I_MKPF'  ). ASSIGN lr_data->* TO <ls_mkpf>.

*TRY.
  CALL METHOD me->zmb_migo_badi
    EXPORTING
      iv_mseg = <ls_mseg>.
* CATCH zcx_bc_exit_imp .
*ENDTRY.

ENDMETHOD.


METHOD zmb_migo_badi.

  DATA: rt_wmdvex                TYPE TABLE OF bapiwmdve,
        rt_wmdvsx                TYPE TABLE OF bapiwmdvs,
        rt_return                TYPE bapireturn,
        lv_kullnblr_virman_kntrl TYPE abap_bool.
  "--------->> Anıl CENGİZ 07.09.2020 13:27:56
  "YUR-717
*  CHECK: iv_mseg-shkzg EQ cv_alacak,
  CHECK: ( iv_mseg-shkzg EQ cv_alacak OR ( iv_mseg-shkzg EQ cv_borc AND iv_mseg-smbln IS NOT INITIAL ) ),
  "---------<<
         iv_mseg-insmk NE '3', "Blokeli stokta değil ise.
         iv_mseg-werks EQ zif_mm_exit_smod_mbcf0002~cv_werks_delivering.
  "--------->> Anıl CENGİZ 26.06.2020 15:32:59
  "YUR-671
  IF iv_mseg-lgort IS NOT INITIAL AND
     iv_mseg-umlgo IS NOT INITIAL.
    CHECK: iv_mseg-lgort NE iv_mseg-umlgo.
  ENDIF.
  "---------<<
  "--------->> Anıl CENGİZ 07.09.2020 13:30:22
  "YUR-717
  IF iv_mseg-smbln IS INITIAL.
    DATA(lv_lgort) = iv_mseg-lgort.
  ELSE.
    lv_lgort = iv_mseg-umlgo.
  ENDIF.
  "---------<<
  DATA(rr_exc_bwart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                     var = 'BWART'
                                                                     val = REF #( iv_mseg-bwart )
                                                                     surec = 'YI_KULLB_STK_KNT' ) ) .
  ASSIGN rr_exc_bwart->* TO FIELD-SYMBOL(<lv_exc_bwart>).
  CHECK: <lv_exc_bwart> IS INITIAL. "istisna hareket türü ise aşağıdaki kontrole girmez.
*------------------------------------------------------------------------------------------------------------------------------
  DATA(rr_vld_lgort) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ = zcl_sd_exc_vld_cntrl=>cv_vld
                                                               var = 'LGORT'
                                                               val = REF #( lv_lgort ) "iv_mseg-lgort "Nakil işlemlerinde kaynak depolar için kontrol çalışacaktır. UMLGO değil.
                                                               surec = 'YI_KULLB_STK_KNT' ) ) .
  ASSIGN rr_vld_lgort->* TO FIELD-SYMBOL(<lv_vld_lgort>).
  CHECK: <lv_vld_lgort> IS NOT INITIAL. "Geçerli depolar için aşağıdaki kontrol çalışacaktır.
*------------------------------------------------------------------------------------------------------------------------------
  IMPORT lv_kullnblr_virman_kntrl = lv_kullnblr_virman_kntrl
          FROM MEMORY ID zcl_mm_exit_smod_mbcf0002_002=>cv_memory_id.
  CHECK: lv_kullnblr_virman_kntrl IS INITIAL, "ZSD009 veya ZYB_SD_F_TOPLAMA fonksiyonundan geliyorsa aşağıdaki kontrole girmez.
"--------->> Anıl CENGİZ 12.04.2021 10:45:26
"YUR-887
         NOT check_mrp_indicator( iv_mseg ) EQ abap_true.
  "---------<<
  TRY.
      CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
        EXPORTING
          plant      = iv_mseg-werks
          material   = iv_mseg-matnr
          unit       = iv_mseg-meins
          check_rule = 'A'
          stge_loc   = lv_lgort "iv_mseg-lgort
        IMPORTING
          return     = rt_return
        TABLES
          wmdvsx     = rt_wmdvsx
          wmdvex     = rt_wmdvex.

      ASSIGN rt_wmdvex[ 1 ] TO FIELD-SYMBOL(<ls_wmdvex>).
      IF <ls_wmdvex>-com_qty LT iv_mseg-menge.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZMM'
                     id_msgno = '019'
                     id_msgv1 = lv_lgort  ). "iv_mseg-lgort
        RAISE EXCEPTION TYPE zcx_mm_exit
          EXPORTING
            messages = lo_msg.
      ENDIF.

    CATCH zcx_mm_exit INTO DATA(lx_mm_exit).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_mm_exit->messages.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
