**&---------------------------------------------------------------------*
*&  Include           ZXVVFU04
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(XACCIT) LIKE  ACCIT STRUCTURE  ACCIT
*"             VALUE(XKOMV) LIKE  KOMV STRUCTURE  KOMV
*"             VALUE(VBRK) LIKE  VBRK STRUCTURE  VBRK
*"             VALUE(XVBRP) LIKE  VBRPVB STRUCTURE  VBRPVB
*"       EXPORTING
*"             VALUE(XACCIT) LIKE  ACCIT STRUCTURE  ACCIT
*"----------------------------------------------------------------------

*break xdanisman.
DATA: lt_bl02 LIKE TABLE OF zyb_sd_t_bl02.

FIELD-SYMBOLS: <fs> TYPE zyb_sd_t_bl02.

SELECT * FROM zyb_sd_t_bl02
    INTO TABLE lt_bl02.


READ TABLE lt_bl02 ASSIGNING <fs>
                   WITH KEY bukrs = xaccit-bukrs
                            hkont = xaccit-hkont
                            ktgrm = xvbrp-ktgrm.
IF sy-subrc = 0.
  IF NOT <fs>-kostl IS INITIAL.
    xaccit-kostl = <fs>-kostl.
  ENDIF.
ENDIF.
