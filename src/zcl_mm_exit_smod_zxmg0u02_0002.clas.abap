class ZCL_MM_EXIT_SMOD_ZXMG0U02_0002 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EXIT_SMOD_ZXMG0U02 .
protected section.
private section.

  types TY_MD002 type ZYB_SD_T_MD002 .
  types:
    tt_md002 TYPE STANDARD TABLE OF ty_md002 .
  types:
    BEGIN OF ty_params,
      tablename TYPE tablename,
      where     TYPE string,
    END OF ty_params .

  data GT_MD002 type TT_MD002 .
ENDCLASS.



CLASS ZCL_MM_EXIT_SMOD_ZXMG0U02_0002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gs_mara> TYPE mara,
                 <gs_mvke> TYPE mvke.

  DATA: lr_data  TYPE REF TO data,
        lv_extwg TYPE extwg.

  lr_data = co_con->get_vars( 'WMARA' ). ASSIGN lr_data->* TO <gs_mara>.
  lr_data = co_con->get_vars( 'WMVKE' ). ASSIGN lr_data->* TO <gs_mvke>.

  CHECK: <gs_mvke>-vtweg EQ '10'.

  TRY.
      DATA(rr_exc_extwg) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                         var   = 'EXTWG'
                                                                         val   = REF #( <gs_mara>-extwg )
                                                                         surec = 'YI_REF_MLZ' ) ) .
      ASSIGN rr_exc_extwg->* TO FIELD-SYMBOL(<lv_exc_extwg>).

      CHECK: <lv_exc_extwg> EQ abap_false. "İstisna kalite değilse.

      DATA(rr_vld_extwg) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                         var   = 'EXTWG'
                                                                         val   = REF #( <gs_mara>-extwg )
                                                                         surec = 'YI_REF_MLZ' ) ) .
      ASSIGN rr_vld_extwg->* TO FIELD-SYMBOL(<lv_vld_extwg>).

      CHECK: <lv_vld_extwg> EQ abap_true. "Geçerli kalite ise.

      DATA(rr_vld_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_vld
                                                                         var   = 'MTART'
                                                                         val   = REF #( <gs_mara>-mtart )
                                                                         surec = 'YI_REF_MLZ' ) ) .
      ASSIGN rr_vld_mtart->* TO FIELD-SYMBOL(<lv_vld_mtart>).

      CHECK: <lv_vld_mtart> EQ abap_true. "Geçerli malzeme türü ise.

      DATA(lo_msg) = cf_reca_message_list=>create( ).

      IF <gs_mvke>-pmatn IS INITIAL.
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '082'
                     id_msgv1 = space
                     id_msgv2 = space
                     id_msgv3 = space
                     id_msgv4 = space ). "Referans fyt.mlz. kodu boş olamaz!
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ELSE.

        SPLIT <gs_mvke>-pmatn AT '.' INTO: DATA(lv_pmatn_matnr) DATA(lv_pmatn_extwg).
        SPLIT <gs_mvke>-matnr AT '.' INTO: DATA(lv_matnr_matnr) DATA(lv_matnr_extwg).
        IF lv_pmatn_matnr NE lv_matnr_matnr.
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD'
                       id_msgno = '083'
                       id_msgv1 = space
                       id_msgv2 = space
                       id_msgv3 = space
                       id_msgv4 = space ). "Referans fyt.mlz. alanında noktadan önceki kod aynı olmalıdır!
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lo_msg.
        ENDIF.
        IF lv_pmatn_extwg NE '1'.
          lo_msg->add( id_msgty = 'E'
                       id_msgid = 'ZSD'
                       id_msgno = '084'
                       id_msgv1 = space
                       id_msgv2 = space
                       id_msgv3 = space
                       id_msgv4 = space ). "Referans fyt.mlz. kalitesi BIRINCI olmalıdır!
          RAISE EXCEPTION TYPE zcx_bc_exit_imp
            EXPORTING
              messages = lo_msg.
        ENDIF.
      ENDIF.
    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.

  ENDTRY.

ENDMETHOD.
ENDCLASS.
