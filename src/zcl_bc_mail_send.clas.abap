CLASS zcl_bc_mail_send DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_recipient TYPE uiys_iusr .
    TYPES ty_sender TYPE uiys_iusr .
    TYPES ty_subject TYPE so_obj_des .
    TYPES: BEGIN OF ty_dlist,
             dname TYPE so_obj_nam,
           END OF ty_dlist.
    TYPES: BEGIN OF ty_attach,
             att_type    TYPE soodk-objtp,
             att_subject TYPE sood-objdes,
             att_content TYPE solix_tab,
           END OF ty_attach.
    TYPES:
      tt_recipients TYPE TABLE OF ty_recipient WITH DEFAULT KEY,
      tt_dlist      TYPE TABLE OF ty_dlist WITH DEFAULT KEY.
    TYPES         tt_attach TYPE TABLE OF ty_attach.
    TYPES tt_body TYPE bcsy_text .
    TYPES:
      BEGIN OF ty_params,
        iv_subject    TYPE ty_subject,
        is_sender     TYPE ty_sender,
        is_recipient  TYPE ty_recipient,
        it_recipients TYPE tt_recipients,
        it_dlist      TYPE tt_dlist,
        it_body       TYPE tt_body,
        iv_commit     TYPE abap_bool,
      END OF ty_params .

    CLASS-METHODS send_attachment
      IMPORTING
        !is_params       TYPE ty_params
        !it_attach       TYPE tt_attach
      RETURNING
        VALUE(rv_result) TYPE os_boolean
      RAISING
        zcx_bc_mail_send .
protected section.
private section.

  class-data GS_PARAMS type TY_PARAMS .
  class-data GO_SEND_REQUEST type ref to CL_BCS .
  class-data GO_DOCUMENT type ref to CL_DOCUMENT_BCS .

  class-methods SET_PARAMS
    raising
      ZCX_BC_MAIL_SEND .
  class-methods SET_RECIPIENTS
    raising
      CX_ADDRESS_BCS
      CX_SEND_REQ_BCS .
  class-methods SET_SENDER
    raising
      CX_SEND_REQ_BCS
      CX_ADDRESS_BCS .
  class-methods CHECK_PARAMS
    importing
      value(IS_PARAMS) type TY_PARAMS
    raising
      ZCX_BC_MAIL_SEND .
ENDCLASS.



CLASS ZCL_BC_MAIL_SEND IMPLEMENTATION.


METHOD check_params.
  "Alıcılardan en az birisi dolu olmalıdır.
  IF is_params-is_recipient IS INITIAL AND
     is_params-it_recipients IS INITIAL AND
     is_params-it_dlist IS INITIAL.
    DATA(lo_msg) = cf_reca_message_list=>create( ).

    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZBC'
                 id_msgno = '000' ).

    RAISE EXCEPTION TYPE zcx_bc_mail_send
      EXPORTING
        messages = lo_msg.
  ELSE.
    gs_params-is_recipient  = is_params-is_recipient.
    gs_params-it_recipients = is_params-it_recipients.
    gs_params-it_dlist      = is_params-it_dlist.
  ENDIF.
  "Gönderici dolu olmalıdır.
  IF is_params-is_sender IS INITIAL.
    lo_msg = cf_reca_message_list=>create( ).

    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZBC'
                 id_msgno = '013' ).

    RAISE EXCEPTION TYPE zcx_bc_mail_send
      EXPORTING
        messages = lo_msg.
  ELSE.
    gs_params-is_sender = is_params-is_sender.
  ENDIF.
  "Başlıksız mail gönderilmez.
  IF is_params-iv_subject IS INITIAL.
    lo_msg = cf_reca_message_list=>create( ).

    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZBC'
                 id_msgno = '014' ).

    RAISE EXCEPTION TYPE zcx_bc_mail_send
      EXPORTING
        messages = lo_msg.

  ELSE.
    gs_params-iv_subject = is_params-iv_subject.
  ENDIF.
  "Mesaj gövdesi olmadan mail gönderilmez.
  IF is_params-it_body IS INITIAL.
    lo_msg = cf_reca_message_list=>create( ).

    lo_msg->add( id_msgty = 'E'
                 id_msgid = 'ZBC'
                 id_msgno = '015' ).

    RAISE EXCEPTION TYPE zcx_bc_mail_send
      EXPORTING
        messages = lo_msg.
  ELSE.
    gs_params-it_body = is_params-it_body.
  ENDIF.

ENDMETHOD.


METHOD send_attachment.

  check_params( is_params ).

  set_params( ).
  TRY.
      "Send attachment
      LOOP AT it_attach ASSIGNING FIELD-SYMBOL(<ls_attach>).
        go_document->add_attachment( EXPORTING
                                       i_attachment_type    = <ls_attach>-att_type
                                       i_attachment_subject = <ls_attach>-att_subject
                                       i_att_content_hex    = <ls_attach>-att_content ).
      ENDLOOP.
      "Pass the document to send request
      go_send_request->set_document( go_document ).
      IF go_send_request->send( ) NE abap_true.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZBC'
                     id_msgno = '010' ).

        RAISE EXCEPTION TYPE zcx_bc_mail_send
          EXPORTING
            messages = lo_msg.
      ELSE.
        IF is_params-iv_commit EQ abap_true.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    CATCH cx_send_req_bcs INTO DATA(lx_send_req_bcs).
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZBC'
                   id_msgno = '016'
                   id_msgv1 = lx_send_req_bcs->error_type
                   id_msgv2 = lx_send_req_bcs->msgv2
                   id_msgv3 = lx_send_req_bcs->msgv3
                   id_msgv4 = lx_send_req_bcs->msgv4 ).

      RAISE EXCEPTION TYPE zcx_bc_mail_send
        EXPORTING
          messages = lo_msg.

    CATCH cx_document_bcs INTO DATA(lx_document_bcs).
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = 'E'
                   id_msgid = 'ZBC'
                   id_msgno = '017'
                   id_msgv1 = lx_document_bcs->error_type
                   id_msgv2 = lx_document_bcs->msgv2
                   id_msgv3 = lx_document_bcs->msgv3
                   id_msgv4 = lx_document_bcs->msgv4 ).

      RAISE EXCEPTION TYPE zcx_bc_mail_send
        EXPORTING
          messages = lo_msg.

  ENDTRY.

ENDMETHOD.


METHOD set_params.
*Prepare Mail Object
  TRY.
      DATA(lo_send_request) = cl_bcs=>create_persistent( ).

      go_send_request = lo_send_request.
* Message body and subject
      DATA(lo_document) = cl_document_bcs=>create_document(
                                             EXPORTING
                                               i_type    = 'RAW'
                                               i_text    = gs_params-it_body
                                               i_subject = gs_params-iv_subject ).

      go_document = lo_document.

      set_sender( ).

      set_recipients( ).

    CATCH cx_send_req_bcs INTO DATA(lx_send_req_bcs).
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = lx_send_req_bcs->msgty
                   id_msgid = lx_send_req_bcs->msgid
                   id_msgno = lx_send_req_bcs->msgno
                   id_msgv1 = lx_send_req_bcs->msgv1
                   id_msgv2 = lx_send_req_bcs->msgv2
                   id_msgv3 = lx_send_req_bcs->msgv3
                   id_msgv4 = lx_send_req_bcs->msgv4 ).

      RAISE EXCEPTION TYPE zcx_bc_mail_send
        EXPORTING
          messages = lo_msg.

    CATCH cx_document_bcs INTO DATA(lx_document_bcs).
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = lx_document_bcs->msgty
                   id_msgid = lx_document_bcs->msgid
                   id_msgno = lx_document_bcs->msgno
                   id_msgv1 = lx_document_bcs->msgv1
                   id_msgv2 = lx_document_bcs->msgv2
                   id_msgv3 = lx_document_bcs->msgv3
                   id_msgv4 = lx_document_bcs->msgv4 ).

      RAISE EXCEPTION TYPE zcx_bc_mail_send
        EXPORTING
          messages = lo_msg.



    CATCH cx_address_bcs INTO DATA(lx_address_bcs).
      lo_msg = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty = lx_address_bcs->msgty
                   id_msgid = lx_address_bcs->msgid
                   id_msgno = lx_address_bcs->msgno
                   id_msgv1 = lx_address_bcs->msgv1
                   id_msgv2 = lx_address_bcs->msgv2
                   id_msgv3 = lx_address_bcs->msgv3
                   id_msgv4 = lx_address_bcs->msgv4 ).
      RAISE EXCEPTION TYPE zcx_bc_mail_send
        EXPORTING
          messages = lo_msg.

  ENDTRY.

ENDMETHOD.


METHOD set_recipients.

  DATA: lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.
  "set recipients
  IF gs_params-is_recipient IS NOT INITIAL.
    IF gs_params-is_recipient-email IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( gs_params-is_recipient-email ).
    ELSEIF gs_params-is_recipient-iusrid IS NOT INITIAL.
      lo_recipient = cl_sapuser_bcs=>create( gs_params-is_recipient-iusrid ).
    ELSE.
      lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
    ENDIF.

    go_send_request->add_recipient( EXPORTING
                                      i_recipient = lo_recipient
                                      i_express   = abap_true ).
  ELSEIF gs_params-it_recipients[] IS NOT INITIAL.
    LOOP AT gs_params-it_recipients ASSIGNING FIELD-SYMBOL(<ls_recipients>).
      IF <ls_recipients>-iusrid IS NOT INITIAL.
        lo_recipient = cl_sapuser_bcs=>create( <ls_recipients>-iusrid ).
      ELSEIF <ls_recipients>-email IS NOT INITIAL.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( <ls_recipients>-email ).
      ENDIF.
      go_send_request->add_recipient( EXPORTING
                                       i_recipient = lo_recipient
                                       i_express   = abap_true ).
    ENDLOOP.
  ELSEIF gs_params-it_dlist[] IS NOT INITIAL.
    LOOP AT gs_params-it_dlist ASSIGNING FIELD-SYMBOL(<ls_list>).
      lo_recipient = cl_distributionlist_bcs=>getu_persistent( i_dliname = <ls_list>-dname
                                                               i_private = '' ).
      go_send_request->add_recipient( EXPORTING
                                        i_recipient  = lo_recipient
                                        i_express    =  abap_true ).
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD set_sender.

  DATA: lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL.
* Set sender
  IF gs_params-is_sender-email IS NOT INITIAL.
    lo_sender = cl_cam_address_bcs=>create_internet_address( gs_params-is_sender-email ).
  ELSEIF gs_params-is_sender-iusrid IS NOT INITIAL.
    lo_sender = cl_sapuser_bcs=>create( gs_params-is_sender-iusrid ).
  ELSE.
    lo_sender = cl_sapuser_bcs=>create( sy-uname ).
  ENDIF.
  go_send_request->set_sender( lo_sender ).

ENDMETHOD.
ENDCLASS.
