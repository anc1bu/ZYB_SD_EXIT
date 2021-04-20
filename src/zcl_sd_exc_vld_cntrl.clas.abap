class ZCL_SD_EXC_VLD_CNTRL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_params,
        typ   TYPE zsdd_exc_vld_cntrl_type,
        var   TYPE char10,
        val   TYPE REF TO data,
        surec TYPE zsdd_exc_vld_cntrl_surec,
      END OF ty_params .

  constants CV_EXC type ZSDD_EXC_VLD_CNTRL_TYPE value 'EXC'. "#EC NOTEXT
  constants CV_VLD type ZSDD_EXC_VLD_CNTRL_TYPE value 'VLD'. "#EC NOTEXT

  class-methods GET_SUREC_VAL
    importing
      !IS_PARAMS type TY_PARAMS
    returning
      value(RR_RETURN) type ref to DATA
    raising
      ZCX_SD_EXC_VLD_CNTRL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXC_VLD_CNTRL IMPLEMENTATION.


METHOD get_surec_val.

  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.

  DATA: p_tabname    TYPE tabname,
        lo_tab_descr TYPE REF TO cl_abap_structdescr,
        lo_val_descr TYPE REF TO cl_abap_refdescr,
        descr_ref    TYPE REF TO cl_abap_typedescr,
        lr_table     TYPE REF TO data,
        lv_where     TYPE string,
        lv_type      TYPE string,
        lv_name      TYPE string.

  CONCATENATE 'ZSDT' is_params-typ is_params-var INTO p_tabname SEPARATED BY '_'.

  CREATE DATA lr_table TYPE TABLE OF (p_tabname) .

  ASSIGN lr_table->* TO <lt_table>.

  "Classı çağıran isteğin değer komponenti alınır. (Örneğin kullanıcı ise USNAM, Depo yeri ise LGORT gibi ).
  descr_ref ?= cl_abap_typedescr=>describe_by_data_ref( is_params-val ).
  DATA(lv_absolute_name) = descr_ref->absolute_name.

  SPLIT lv_absolute_name AT '\TYPE=' INTO lv_type lv_name.

  ASSIGN is_params-val->* TO FIELD-SYMBOL(<lv_val>).

  lv_where = | { lv_name } EQ '{ <lv_val> }' |.

  SELECT *
    FROM (p_tabname)
    INTO CORRESPONDING FIELDS OF TABLE <lt_table>
    WHERE (lv_where).

  "Tablonun komponentleri alınır.
  lo_tab_descr ?= cl_abap_structdescr=>describe_by_name( p_tabname  ).

  LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<ls_table>).
    LOOP AT lo_tab_descr->components ASSIGNING FIELD-SYMBOL(<ls_tab_components>)
      WHERE name = is_params-surec.

      ASSIGN COMPONENT is_params-surec OF STRUCTURE <ls_table> TO FIELD-SYMBOL(<lv_surec_val>).

      rr_return = REF #( <lv_surec_val> ).

    ENDLOOP.
    IF sy-subrc EQ 4.
      "Buraya düşüyorsa okuduğumuz tabloda süreç kolonu yok demektir. Olur öle şeyler çok kafana takmican güzelcene tabloya eklicen alanı. Eklerken Data Element falan yap kafamız ağrımasın.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '042'
                   id_msgv1 = p_tabname
                   id_msgv2 = is_params-surec  ).
      RAISE EXCEPTION TYPE zcx_sd_exc_vld_cntrl
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ENDLOOP.
  IF sy-subrc EQ 4.
    "Değer bulunmadıysa bu kontrol ilişkisi yok demektir o yüzden abap_false atadık.
    rr_return = REF #( abap_false ).
  ENDIF.
ENDMETHOD.
ENDCLASS.
