*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_BLOCKAGE_CONTROL
*&---------------------------------------------------------------------*
*<<<added by ömer sakar on 22.12.2016 CS0006184
"Kalem bazında Teslimat blokajı ataması(xvbep-lifsp güncelliyoruz)
"Kalem bazında Fatura blokajı ataması(vbap-faksp güncelliyoruz)
*break xdanisman.
*CASE vbak-auart.
*  WHEN 'ZA02' OR 'ZA03' OR 'ZA11'.
*    LOOP AT xvbep .
*      xvbep-lifsp = 'Z4'.
*      xvbep-updkz = 'U'.
*      MODIFY xvbep .
*      CLEAR : xvbep.
*    ENDLOOP.
*  WHEN 'ZA14'.
*    LOOP AT xvbep .
*      xvbep-lifsp = 'Z3'.
*      xvbep-updkz = 'U'.
*      MODIFY xvbep .
*      CLEAR : xvbep.
*    ENDLOOP.
*  WHEN 'ZR01'.
*    LOOP AT xvbep .
*      xvbep-lifsp = 'Z5'.
*      xvbep-updkz = 'U'.
*      MODIFY xvbep .
*      CLEAR : xvbep.
*    ENDLOOP.
*ENDCASE.

CASE vbak-auart.
  WHEN 'ZA02' OR 'ZA03' OR 'ZA11'.
   if svbep-tabix = 0.
     vbep-lifsp = 'Z4'.
   endif.
  WHEN 'ZA14'.
    if svbep-tabix = 0.
     vbep-lifsp = 'Z3'.
   endif.
  WHEN 'ZR01'.
    if svbep-tabix = 0.
     vbep-lifsp = 'Z5'.
   endif.
ENDCASE.


*>>>added by ömer sakar on 22.12.2016 CS0006184
