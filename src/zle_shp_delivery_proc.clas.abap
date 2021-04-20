class ZLE_SHP_DELIVERY_PROC definition
  public
  final
  create public .

*"* public components of class ZLE_SHP_DELIVERY_PROC
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
*"* protected components of class ZLE_SHP_DELIVERY_PROC
*"* do not include other source files here!!!
private section.
*"* private components of class ZLE_SHP_DELIVERY_PROC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZLE_SHP_DELIVERY_PROC IMPLEMENTATION.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES .

* Example: Deactivate the function 'Copy picked quantity as delivery
* quantity'
  data: ls_cua_exclude type shp_cua_exclude.

  ls_cua_exclude-function = 'KOMU_T'.
  append ls_cua_exclude to ct_cua_exclude.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES .

  data: ls_field_attributes type shp_screen_attributes,
        ls_xvbup            type vbupvb.

* Example 1: The field 'Actual goods-movement date' should not be
* changed by the user
  ls_field_attributes-name  = 'LIKP-WADAT_IST'.
  ls_field_attributes-input = 0.
  append ls_field_attributes to ct_field_attributes.

* Example 2: The material description should not be changed for a
* certain group of materials after completion of the picking process
  if is_lips-matnr cs 'ZZ'.
    read table it_xvbup into ls_xvbup with key mandt = is_lips-mandt
                                               vbeln = is_lips-vbeln
                                               posnr = is_lips-posnr
                        binary search.
    if ls_xvbup-kosta eq 'C'.
      ls_field_attributes-name  = 'LIKP-WADAT_IST'.
      ls_field_attributes-input = 0.
      append ls_field_attributes to ct_field_attributes.
    endif.
  endif.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES


method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION .

  data: ls_log type shp_badi_error_log.

* Example: Refuse deletion of an item if it contains a certain material
  if is_xlips-matnr cs 'ZZ'.

    cf_item_not_deletable = 'X'.

*   Output of message ZZ001:
*   'Item &1 contains material &2; item can not be deleted'
    ls_log-msgid = 'ZZ'.
    ls_log-msgno = '001'.
    ls_log-msgty = 'E'.
    ls_log-msgv1 = is_xlips-posnr.
    ls_log-msgv2 = is_xlips-matnr.
    append ls_log to ct_log.

  endif.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION .

* Example: Delete delivery dependend data from the global memory of an
* own function group
  call function 'ZZ_DELETE_CUSTOMER_DATA'
    exporting
      if_vbeln = is_likp-vbeln.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK .

  data: lf_not_only_zero type c,
        ls_finchdel      type finchdel.

  field-symbols: <ls_xlikp> type likpvb,
                 <ls_xlips> type lipsvb.

* Example: Delete delivery (creation mode, collective processing) or
* refuse saving it (dialogue mode) if it contains only items with
* delivery quantity 0.

* Loop at all created deliveries
  loop at it_xlikp assigning <ls_xlikp> where updkz ne 'D'.
    clear lf_not_only_zero.

*   Check delivery quantity of all items belonging to current delivery
    loop at it_xlips assigning <ls_xlips>
                     where vbeln eq <ls_xlikp>-vbeln
                       and updkz ne 'D'.
      if <ls_xlips>-lfimg ne 0.
        lf_not_only_zero = 'X'.
        exit.
      endif.
    endloop.
    if lf_not_only_zero eq space.
*     All items of the delivery have delivery quantity 0:
*     Write message ZZ002 with type E to error log
*     (forces deletion of the delivery or prevents delivery from saving)
      clear ls_finchdel.
      ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
      ls_finchdel-pruefung = '99'.
      ls_finchdel-msgty    = 'E'.
      ls_finchdel-msgid    = 'ZZ'.
      ls_finchdel-msgno    = '002'.
*     Note: CT_FINCHDEL is a hashed table
      insert ls_finchdel into table ct_finchdel.
    endif.
  endloop.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK


method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY .

* Example: Initialize the data in the global memory of an own
* function group
  call function 'ZZ_INITIALIZE_CUSTOMER_DATA'.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY


method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION .

* Example: Delete item dependend data from the global memory of an own
* function group
  call function 'ZZ_DELETE_ITEM_CUSTOMER_DATA'
    exporting
      if_vbeln = is_xlips-vbeln
      if_posnr = is_xlips-posnr.

endmethod.                    "IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY .

* Example: Read delivery dependend data in the global memory of an own
* function group
  call function 'ZZ_READ_CUSTOMER_DATA'
    exporting
      if_vbeln = cs_likp-vbeln.

endmethod.                    "IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT .

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE .

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE
ENDCLASS.
