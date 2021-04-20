class ZCL_MM_EX_CACL_VAL_CHANGE_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_MM_EX_CACL_VAL_CHANGE .

  class-methods CLASS_CONSTRUCTOR .
protected section.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_ebat,
      atwrt TYPE atwrt,
    END OF ty_ebat .
  TYPES:
    tth_ebat TYPE HASHED TABLE OF ty_ebat WITH UNIQUE KEY atwrt .

  CLASS-DATA gt_ebat TYPE tth_ebat .

  TYPES:
    BEGIN OF ty_seri,
      atwrt TYPE atwrt,
    END OF ty_seri .
  TYPES:
    tth_seri TYPE HASHED TABLE OF ty_seri WITH UNIQUE KEY atwrt .

  CLASS-DATA gt_seri TYPE tth_seri .
ENDCLASS.



CLASS ZCL_MM_EX_CACL_VAL_CHANGE_001 IMPLEMENTATION.


METHOD class_constructor.

  IF gt_ebat IS INITIAL.
    SELECT atwrt
      FROM zmalzeme_10
      INTO TABLE gt_ebat.
  ENDIF.

  IF gt_seri IS INITIAL.
    SELECT atwrt
      FROM zmalzeme_11
      INTO TABLE gt_seri.
  ENDIF.

ENDMETHOD.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <gv_characteristic_internal> TYPE atinn,
                 <gv_characteristic_id>       TYPE atnam,
                 <gs_communication_structure> TYPE ctms_01,
                 <gs_atwrt>                   TYPE atwrt,
                 <gs_sy>                      TYPE sy.

  DATA: lr_data TYPE REF TO data.

  lr_data = co_con->get_vars( 'I_CHARACTERISTIC_INTERNAL' ).  ASSIGN lr_data->* TO <gv_characteristic_internal>.
  lr_data = co_con->get_vars( 'I_CHARACTERISTIC_ID' ).        ASSIGN lr_data->* TO <gv_characteristic_id>.
  lr_data = co_con->get_vars( 'IS_COMMUNICATION_STRUCTURE' ). ASSIGN lr_data->* TO <gs_communication_structure>.
  lr_data = co_con->get_vars( 'C_ATWRT' ).                    ASSIGN lr_data->* TO  <gs_atwrt>.
  lr_data = co_con->get_vars( 'SY' ).                         ASSIGN lr_data->* TO  <gs_sy>.


  CHECK: ( <gv_characteristic_id> EQ zif_mm_ex_cacl_val_change~cv_atnam_ebat OR <gv_characteristic_id> EQ zif_mm_ex_cacl_val_change~cv_atnam_seri ),
         <gs_communication_structure>-klart EQ zif_mm_ex_cacl_val_change~cv_klart_mlzm,
         <gs_communication_structure>-class EQ zif_mm_ex_cacl_val_change~cv_class_mlzm,
         <gs_communication_structure>-objid EQ zif_mm_ex_cacl_val_change~cv_objid_mara.

  CASE <gv_characteristic_id>.
    WHEN zif_mm_ex_cacl_val_change~cv_atnam_ebat.

      ASSIGN gt_ebat[ KEY primary_key COMPONENTS atwrt = <gs_atwrt> ] TO FIELD-SYMBOL(<gs_ebat>).
      IF sy-subrc NE 0.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '090'
                     id_msgv1 = <gs_atwrt>
                     id_msgv2 = 'ZMALZEME_10'
                     id_msgv3 = space
                     id_msgv4 = space ).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.

    WHEN zif_mm_ex_cacl_val_change~cv_atnam_seri.

      ASSIGN gt_seri[ KEY primary_key COMPONENTS atwrt = <gs_atwrt> ] TO FIELD-SYMBOL(<gs_seri>).
      IF sy-subrc NE 0.
        lo_msg = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '090'
                     id_msgv1 = <gs_atwrt>
                     id_msgv2 = 'ZMALZEME_11'
                     id_msgv3 = space
                     id_msgv4 = space ).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.

  ENDCASE.

ENDMETHOD.
ENDCLASS.
