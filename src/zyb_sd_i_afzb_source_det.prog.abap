*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_AFZB_SOURCE_DET
*& - Depo Yeri Belirleme
*&---------------------------------------------------------------------*
DATA: hata_lgort TYPE c,
      ls_mara    LIKE mara.

CHECK vbak-vbtyp EQ 'C' OR " Sipariş
      vbak-vbtyp EQ 'H' OR " İade
      vbak-vbtyp EQ 'I'.   " Bedelsiz

CLEAR hata_lgort.

IF NOT vbap-lgort IS INITIAL.
  hata_lgort = 'X'.
ENDIF.
*&---------------------------------------------------------------------*
*& --> Depo yeri belirleme
*&---------------------------------------------------------------------*
CLEAR ls_mara.
SELECT SINGLE * FROM mara INTO ls_mara
    WHERE matnr EQ vbap-matnr.
CHECK hata_lgort IS INITIAL.
CASE vbak-auart.
  WHEN gc_au_za02 OR gc_au_za03 OR gc_au_za11.
    vbap-lgort = gc_depo_numune.
  WHEN gc_au_za06.
    vbap-lgort = gc_depo_stddis.
  WHEN gc_au_zr01.
    vbap-lgort = gc_depo_iade.
  WHEN OTHERS.
    IF vbak-vtweg EQ gc_vtweg_ic.
      IF vbap-vstel EQ '1200' AND ls_mara-mtart EQ 'ZYYK'.
        vbap-lgort = gc_depo_adnyyk.
      ENDIF.
      vbap-lgort = gc_depo_mamul.
    ENDIF.
ENDCASE.
*&---------------------------------------------------------------------*
*& <-- Depo yeri belirleme
*&---------------------------------------------------------------------*

*&*********************************************************************
*& --> İhracat depo yeri değer doldurma (Depo yeri bazında sevkiyat
* belirleme uyarlaması yapıldığından eklendi.)
*&*********************************************************************
IF vbak-vtweg EQ gc_vtweg_ihr.
  vbap-lgort = gc_depo_ihr.
ENDIF.
*&*********************************************************************
*& <-- İhracat depo yeri değer doldurma (Depo yeri bazında sevkiyat
* belirleme uyarlaması yapıldığından eklendi.)
*&*********************************************************************
