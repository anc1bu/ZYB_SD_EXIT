FUNCTION zsdf_ebat_search_help.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
* EXIT immediately, if you do not want to handle this step
  IF callcontrol-step <> 'SELONE' AND
     callcontrol-step <> 'SELECT' AND
     " AND SO ON
     callcontrol-step <> 'DISP'.
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP SELONE  (Select one of the elementary searchhelps)
*"----------------------------------------------------------------------
* This step is only called for collective searchhelps. It may be used
* to reduce the amount of elementary searchhelps given in SHLP_TAB.
* The compound searchhelp is given in SHLP.
* If you do not change CALLCONTROL-STEP, the next step is the
* dialog, to select one of the elementary searchhelps.
* If you want to skip this dialog, you have to return the selected
* elementary searchhelp in SHLP and to change CALLCONTROL-STEP to
* either to 'PRESEL' or to 'SELECT'.
  IF callcontrol-step = 'SELONE'.
*   PERFORM SELONE .........
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP PRESEL  (Enter selection conditions)
*"----------------------------------------------------------------------
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF callcontrol-step = 'PRESEL'.
*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF callcontrol-step = 'SELECT'.
*   PERFORM STEP_SELECT TABLES RECORD_TAB SHLP_TAB
*                       CHANGING SHLP CALLCONTROL RC.
*   IF RC = 0.
*     CALLCONTROL-STEP = 'DISP'.
*   ELSE.
*     CALLCONTROL-STEP = 'EXIT'.
*   ENDIF.
    EXIT. "Don't process STEP DISP additionally in this call.
  ENDIF.
*"----------------------------------------------------------------------
* STEP DISP     (Display values)
*"----------------------------------------------------------------------
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF callcontrol-step = 'DISP'.
*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
*    TYPES: BEGIN OF ty_atwrt,
*             atwrt TYPE atwrt,
*           END OF ty_atwrt,
*           tt_awrt TYPE STANDARD TABLE OF ty_atwrt.
*    DATA: lt_atwrt TYPE tt_awrt.
*    REFRESH: record_tab.
*    SELECT atwrt
*      FROM cawn
*      INTO TABLE lt_atwrt
*      WHERE atinn EQ 0000000810.
*
*    LOOP AT lt_atwrt REFERENCE INTO DATA(lr_atwrt).
*      APPEND INITIAL LINE TO record_tab ASSIGNING FIELD-SYMBOL(<record_tab>).
*      <record_tab>-string  = CONV #( lr_atwrt->atwrt ).
*    ENDLOOP.
*    EXIT.

    DATA : BEGIN OF lt_ddshretval OCCURS 0.
            INCLUDE STRUCTURE ddshretval.
    DATA : END OF lt_ddshretval.

    DATA: BEGIN OF lt_ebat OCCURS 0 ,
            key  TYPE zebat,
            text TYPE zebat,
          END OF lt_ebat.

    REFRESH: lt_ebat,
             lt_ddshretval.



*  select ATWRT AS KEY ATWRT AS TEXT from CAWN
*    INTO CORRESPONDING FIELDS OF TABLE LT_EBAT
*    WHERE ATINN = '0000000810'
*  GROUP BY ATWRT.

    SELECT atwrt AS key atwrt AS text FROM ausp
      INTO CORRESPONDING FIELDS OF TABLE lt_ebat
      WHERE atinn = '0000000810'
    GROUP BY atwrt.


    CHECK lt_ebat[] IS NOT INITIAL.
*
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield         = 'EBAT'
        pvalkey          = '25'
        dynpprog         = sy-cprog
        dynpnr           = sy-dynnr
        dynprofield      = 'EBAT'
        value_org        = 'S'
        display          = 'F'
        callback_program = sy-repid
      TABLES
        value_tab        = lt_ebat
        return_tab       = record_tab.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDIF.
ENDFUNCTION.
