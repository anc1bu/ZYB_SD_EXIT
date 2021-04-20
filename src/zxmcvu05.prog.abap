*&---------------------------------------------------------------------*
*&  Include           ZXMCVU05
*&---------------------------------------------------------------------*

"--------->> Anıl CENGİZ 21.05.2018 10:07:54
"YUR-28 Palet Satış Ekranı (DT:YUR-24) v.0 - Programlama
IF i_xmcvbrk-sfakn IS NOT INITIAL.
  e_xmcvbrkusr-zzpltftr = i_xmcvbrk-sfakn.
ELSE.
  e_xmcvbrkusr-zzpltftr = i_xmcvbrk-vbeln.
ENDIF.
"---------<<
