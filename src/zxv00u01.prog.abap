*&---------------------------------------------------------------------*
*&  Include           ZXV00U01
*&---------------------------------------------------------------------*
*break anilc.
CHECK i_likp IS INITIAL AND i_vbak IS NOT INITIAL.

IF i_vbak-vtweg EQ '20'. " İhracat
  e_route = 'IHR001'.
ENDIF.
