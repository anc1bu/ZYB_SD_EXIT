class ZCL_SD_EXIT_SMOD_V50Q0001_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_V50Q0001 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_V50Q0001_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  FIELD-SYMBOLS: <if_flag_inbound> TYPE char1,
                 <if_proctype>     TYPE char1,
                 <ct_postab>       TYPE lipov_t.

  DATA: lr_data TYPE REF TO data,
        lt_likp TYPE TABLE OF likp.

  lr_data = co_con->get_vars( 'IF_FLAG_INBOUND' ). ASSIGN lr_data->* TO <if_flag_inbound>.
  lr_data = co_con->get_vars( 'IF_PROCTYPE' ).     ASSIGN lr_data->* TO <if_proctype>.
  lr_data = co_con->get_vars( 'CT_POSTAB' ).       ASSIGN lr_data->* TO <ct_postab>.

  TRY .
      SELECT vbeln lifex xblnr znakkg zzsvkirs
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        FOR ALL ENTRIES IN <ct_postab>
        WHERE vbeln EQ <ct_postab>-vbeln.
      IF sy-subrc EQ 0.
        LOOP AT <ct_postab> ASSIGNING FIELD-SYMBOL(<ls_postab>).
          ASSIGN lt_likp[ vbeln = <ls_postab>-vbeln ] TO FIELD-SYMBOL(<ls_likp>).
          IF <ls_likp> IS ASSIGNED.
            <ls_postab>-zeirsno  = <ls_likp>-lifex.
            <ls_postab>-tasima   = <ls_likp>-xblnr.
            <ls_postab>-znakkg   = <ls_likp>-znakkg.
            "--------->> Anıl CENGİZ 15.04.2020 10:28:36
            "YUR-625
            <ls_postab>-zzsvkirs = <ls_likp>-zzsvkirs.
            "---------<<
          ELSE.
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.

*      CATCH .
*        RAISE EXCEPTION TYPE zcl_sd_exit_smod_v50q0001
*        RAISE EXCEPTION TYPE zcx_bc_exit_imp
*          EXPORTING
*            messages = lo_msg.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
