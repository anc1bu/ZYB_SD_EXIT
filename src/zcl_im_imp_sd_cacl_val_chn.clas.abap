class ZCL_IM_IMP_SD_CACL_VAL_CHN definition
  public
  final
  create public .

public section.

  interfaces IF_EX_CACL_VALUE_CHANGE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_IMP_SD_CACL_VAL_CHN IMPLEMENTATION.


METHOD if_ex_cacl_value_change~modify_input.
  "--------->> Anıl CENGİZ 14.12.2020 16:16:48
  "YUR-788
  TRY.
      NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_MM_EX_CACL_VAL_CHANGE'
                                                      vars = VALUE #( ( name = 'I_CHARACTERISTIC_INTERNAL'  value = REF #( i_characteristic_internal ) )
                                                                      ( name = 'I_CHARACTERISTIC_ID'        value = REF #( i_characteristic_id ) )
                                                                      ( name = 'IS_COMMUNICATION_STRUCTURE' value = REF #( is_communication_structure ) )
                                                                      ( name = 'C_ATWRT'                    value = REF #( c_atwrt ) )
                                                                      ( name = 'SY'                         value = REF #( sy ) ) ) ) )->execute( ).
    CATCH zcx_bc_exit_imp INTO DATA(lx_bc_exit_imp).
      DATA: lt_list TYPE bapirettab.
      DATA(lo_msg) = lx_bc_exit_imp->messages.
      lo_msg->get_list_as_bapiret( IMPORTING et_list = lt_list ).
      zcl_sd_toolkit=>hata_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'E' ) ( CORRESPONDING #( wa ) ) ) ).
      zcl_sd_toolkit=>bilgi_goster( VALUE #( FOR wa IN lt_list WHERE ( type = 'W' OR type = 'I' ) ( CORRESPONDING #( wa ) ) ) ).
  ENDTRY.
  "---------<<
ENDMETHOD.
ENDCLASS.
