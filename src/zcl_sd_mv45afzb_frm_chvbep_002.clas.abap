class ZCL_SD_MV45AFZB_FRM_CHVBEP_002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_MV45AFZB_FRM_CHVBEP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZB_FRM_CHVBEP_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.
*&*********************************************************************
*& --> İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&*********************************************************************
  FIELD-SYMBOLS: <gs_vbep>      TYPE vbep,
                 <gs_star_vbep> TYPE vbep,
                 <gs_vbap>      TYPE vbap,
                 <gs_vbak>      TYPE vbak,
                 <gt_xvbep>     TYPE tab_xyvbep.

  DATA: lr_data   TYPE REF TO data,
        lv_tesmik TYPE lqua_verme,
        lv_sipmik TYPE menge_d.

  lr_data = co_con->get_vars( 'XVBEP[]' ). ASSIGN lr_data->* TO <gt_xvbep>.
  lr_data = co_con->get_vars( 'VBEP' ).    ASSIGN lr_data->* TO <gs_vbep>.
  lr_data = co_con->get_vars( '*VBEP' ).   ASSIGN lr_data->* TO <gs_star_vbep>.
  lr_data = co_con->get_vars( 'VBAP' ).    ASSIGN lr_data->* TO <gs_vbap>.
  lr_data = co_con->get_vars( 'VBAK' ).    ASSIGN lr_data->* TO <gs_vbak>.

  CHECK: <gs_vbak>-vtweg EQ zif_sd_mv45afzb_frm_chvbep=>c_vtweg_exp.

  IF <gs_star_vbep>-cmeng GT <gs_vbep>-cmeng.
    SELECT SUM( tesmik ) FROM zyb_sd_t_shp02
          INTO lv_tesmik
         WHERE vbeln EQ <gs_vbap>-vbeln
           AND posnr EQ <gs_vbap>-posnr
           AND loekz EQ space.

*  lv_fark = vbap-kwmeng - vbep-cmeng.
    CLEAR lv_sipmik.
    lv_sipmik = <gs_vbep>-cmeng.
    LOOP AT <gt_xvbep> ASSIGNING FIELD-SYMBOL(<gs_xvbep>)
      WHERE vbeln EQ <gs_vbep>-vbeln
        AND posnr EQ <gs_vbep>-posnr
        AND cmeng NE 0
        AND updkz NE 'D'. "updkz_delete.
      IF <gs_xvbep>-etenr NE <gs_vbep>-etenr.
        lv_sipmik = lv_sipmik + <gs_xvbep>-cmeng.
      ENDIF.
    ENDLOOP.

    IF lv_sipmik LT lv_tesmik.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD_VA'
                   id_msgno = '035'
                   id_msgv1 = <gs_vbap>-vbeln
                   id_msgv2 = <gs_vbap>-posnr
                   id_msgv3 = CONV #( lv_tesmik ) ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
