CLASS zcl_sd_rv61afzb_form_bwend_002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_bc_exit_imp .
    INTERFACES zif_sd_rv61afzb_form_bwrtnend .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES ty_xkomv TYPE komv_index .
    TYPES:
      tt_xkomv TYPE STANDARD TABLE OF ty_xkomv .
ENDCLASS.



CLASS ZCL_SD_RV61AFZB_FORM_BWEND_002 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <lt_xkomv> TYPE tt_xkomv,
                 <ls_komk>  TYPE komk,
                 <ls_komp>  TYPE komp.

  DATA:  lr_data  TYPE REF TO data.

  lr_data = co_con->get_vars( 'XKOMV' ). ASSIGN lr_data->* TO <lt_xkomv>.
  lr_data = co_con->get_vars( 'KOMK' ).  ASSIGN lr_data->* TO <ls_komk>.
  lr_data = co_con->get_vars( 'KOMP' ).  ASSIGN lr_data->* TO <ls_komp>.


  CHECK: <ls_komk>-vtweg EQ '10',
         <ls_komp>-charg IS INITIAL,
         <ls_komp>-matnr IS NOT INITIAL,
         "--------->> Anıl CENGİZ 08.03.2021 13:33:15
         "YUR-862
         <ls_komk>-vbtyp NE 'L' AND <ls_komk>-vbtyp NE 'P', "Borç dekontu sürecinde aşağıdaki kontrole girmez.
         <ls_komk>-vbtyp NE 'K' AND <ls_komk>-vbtyp NE 'O'. "Alacak dekontu sürecinde aşağıdaki kontrole girmez.
         "---------<<

  ASSIGN <lt_xkomv>[ kposn = <ls_komp>-kposn
                     kschl = 'ZF06'
                     kinak = ' ' ] TO FIELD-SYMBOL(<ls_komv_zf06>).
  CHECK: <ls_komv_zf06> IS ASSIGNED AND <ls_komv_zf06>-kwert NE 0 . "ZF06 - Pzlma.Prmsyn.Fiyatı" var ise aşağıdaki kontrollere girilir.


  ASSIGN <lt_xkomv>[ kposn = <ls_komp>-kposn
                     kschl = 'ZF04' ] TO FIELD-SYMBOL(<ls_komv_zf04>).
  IF <ls_komv_zf04> IS ASSIGNED.
    IF <ls_komv_zf04>-kwert EQ 0 . "ZF04 - Pazarlama Liste Fyt." var ama değeri 0 ise.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZSD'
                   id_msgno = '093'
                   id_msgv1 = <ls_komp>-kposn ).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lo_msg.
    ENDIF.
  ELSE.
    lo_msg = cf_reca_message_list=>create( ).
    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZSD'
                 id_msgno = '093'
                 id_msgv1 = <ls_komp>-kposn ).
    RAISE EXCEPTION TYPE zcx_bc_exit_imp
      EXPORTING
        messages = lo_msg.
  ENDIF.
ENDMETHOD.
ENDCLASS.
