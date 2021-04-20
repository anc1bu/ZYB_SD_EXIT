*&---------------------------------------------------------------------*
*&  Include           ZXVVFU01
*&---------------------------------------------------------------------*
*break anilc.
DATA: ls_vbak  TYPE vbak,
      lv_auart TYPE auart.
FIELD-SYMBOLS: <ls_vbrp> TYPE vbrpvb .

IF vbrk-vbtyp = 'O'.
  SELECT SINGLE * FROM vbak INTO ls_vbak
    WHERE vbeln = cvbrp-aubel.
  IF ls_vbak-augru = '001'.
    xaccit-blart = 'KR'.
  ENDIF.
ENDIF.

IF vbrk-vbtyp = 'O' OR vbrk-vbtyp = 'P'.
  LOOP AT cvbrp ASSIGNING <ls_vbrp>.
    SELECT SINGLE auart FROM vbak
        INTO lv_auart
       WHERE vbeln EQ <ls_vbrp>-aubel.
    IF lv_auart EQ 'ZD04' OR lv_auart EQ 'ZC09'.
      xaccit-blart = 'RD'.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDIF.

xacchd-bktxt = 'Test.'.

** İntaç Tarihi
IF vbrk-vtweg EQ '20'.
  IF NOT vbrk-zzintac IS INITIAL.
    xacchd-cpudt = vbrk-zzintac.
    xacchd-psobt = vbrk-zzintac.
    xaccit-budat = vbrk-zzintac.
    xaccit-zfbdt = vbrk-zzintac.
  ENDIF.
ENDIF.
