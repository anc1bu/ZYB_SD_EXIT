FUNCTION zyb_sd_f_batch_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MATNR
*"     VALUE(I_WERKS) TYPE  WERKS_D DEFAULT 1000
*"     VALUE(I_CHARG) TYPE  CHARG_D
*"  TABLES
*"      VAL_NUM STRUCTURE  BAPI1003_ALLOC_VALUES_NUM
*"      VAL_CHAR STRUCTURE  BAPI1003_ALLOC_VALUES_CHAR
*"      VAL_CURR STRUCTURE  BAPI1003_ALLOC_VALUES_CURR
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  PERFORM refresh_data.

  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      i_matnr                = i_matnr
      i_charg                = i_charg
      i_werks                = i_werks
      i_mara_level           = 'X'
      i_no_dialog            = 'X'
    IMPORTING
      e_class                = gv_class
      e_klart                = gv_klart
      e_obtab                = gv_obtab
      e_objec                = gv_objec
    EXCEPTIONS
      no_class               = 1
      internal_error_classif = 2
      no_change_service      = 3
      OTHERS                 = 4.

  IF sy-subrc = 0.

    CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
      EXPORTING
        objectkey       = gv_objec
        objecttable     = gv_obtab
        classnum        = gv_class
        classtype       = gv_klart
      TABLES
        allocvaluesnum  = val_num
        allocvalueschar = val_char
        allocvaluescurr = val_curr
        return          = gt_ret.

    LOOP AT gt_ret WHERE type CS 'EAX'.
      PERFORM add_msg USING gt_ret
                   CHANGING wa_ret.
      APPEND wa_ret TO return.
    ENDLOOP.
  ELSE.
    CLEAR wa_ret.
    wa_ret-id         = sy-msgid.
    wa_ret-type       = sy-msgty.
    wa_ret-number     = sy-msgno.
    wa_ret-message_v1 = sy-msgv1.
    wa_ret-message_v1 = sy-msgv2.
    wa_ret-message_v1 = sy-msgv3.
    wa_ret-message_v1 = sy-msgv4.
    APPEND wa_ret TO return.
  ENDIF.
ENDFUNCTION.
