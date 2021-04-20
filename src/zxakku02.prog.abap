*&---------------------------------------------------------------------*
*&  Include           ZXAKKU02
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              XAKKD STRUCTURE  AKKDVB
*"              XAKKB STRUCTURE  AKKBVB
*"       CHANGING
*"             VALUE(XAKKP) LIKE  AKKPVB STRUCTURE  AKKPVB
*"----------------------------------------------------------------------

xakkp-zzknuma = akkp-zzknuma.

"--------->> Anıl CENGİZ 10.08.2020 11:07:34
"YUR-706
** mali belge kontrolleri
*INCLUDE zyb_sd_i_rvexakk1_check.

TRY.
    NEW zcl_bc_exit_container( is_params = VALUE #( interface = 'ZIF_SD_EXIT_SMOD_RVEXAKK1'
                                                    vars = VALUE #( ( name = 'XAKKD'      value = REF #( xakkd ) )
                                                                    ( name = 'XAKKB'      value = REF #( xakkb ) )
                                                                    ( name = 'XAKKP'      value = REF #( xakkp ) ) ) ) )->execute( ).
  CATCH zcx_bc_exit_imp INTO DATA(lo_bc_exit_imp).
    IF lo_bc_exit_imp->previous IS BOUND.
      DATA(lv_msg) = lo_bc_exit_imp->previous->if_message~get_text( ).
      MESSAGE lv_msg TYPE 'E'.
    ELSE.
      lv_msg = lo_bc_exit_imp->if_message~get_text( ).
      MESSAGE lv_msg TYPE 'E'.
    ENDIF.
ENDTRY.
"---------<<
