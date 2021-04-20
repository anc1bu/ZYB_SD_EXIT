*&---------------------------------------------------------------------*
*&  Include           ZXMCVU04
*&---------------------------------------------------------------------*

"--------->> Anıl CENGİZ 02.06.2018 15:56:19
"YUR-28
IF i_xmclips-pstyv = zcl_sd_palet=>cv_pltklm.
  NEW zcl_sd_palet( )->mc_fytbul(
                         EXPORTING
                           iv_vkorg = i_xmclikp-vkorg
                           iv_vtweg = i_xmclips-vtweg
                           iv_matnr = i_xmclips-matnr
                           iv_datum = i_xmclikp-wadat_ist
                         CHANGING
                           cv_mclipsusr = e_xmclipsusr ).
ENDIF.
"---------<<
