*&---------------------------------------------------------------------*
*&  Include           ZXVVFU02
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(XACCIT) LIKE  ACCIT STRUCTURE  ACCIT
*"     VALUE(VBRK) LIKE  VBRK STRUCTURE  VBRK
*"     REFERENCE(DOC_NUMBER) LIKE  VBRK-VBELN OPTIONAL
*"  EXPORTING
*"     VALUE(XACCIT) LIKE  ACCIT STRUCTURE  ACCIT
*"  TABLES
*"      CVBRP STRUCTURE  VBRPVB OPTIONAL
*"      CKOMV STRUCTURE  KOMV
*"----------------------------------------------------------------------
break anilc.
IF vbrk-vtweg = '20' AND vbrk-taxk1 NE '2'
  AND NOT ( vbrk-vbtyp = 'O' OR vbrk-vbtyp = 'P'
  "--------->> Anıl CENGİZ 24.07.2018 15:36:53
  "YUR-70 İhracat Komisyon Primi Gelen Faturalarda Hesap Değişikliği v.0 (DT: YUR-36) - Uyarlama
  OR vbrk-vbtyp = 'S'
  "---------<<
  ) .
  IF vbrk-zzintac IS INITIAL.
    MESSAGE e014(zsd_vf).
  ENDIF.
ENDIF.
