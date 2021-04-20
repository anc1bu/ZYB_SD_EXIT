*&---------------------------------------------------------------------*
*&  Include           ZXVVFU08
*&---------------------------------------------------------------------*
*break anilc.
DATA: lv_augru  LIKE vbak-augru,
      lv_lifnr  LIKE kna1-lifnr,
      lv_kostl  LIKE accit-kostl,
      wa_xaccit LIKE accit.

DATA: t_vbfa   TYPE vbfa OCCURS 0 WITH HEADER LINE.
DATA: t_mseg_1 TYPE mseg OCCURS 0 WITH HEADER LINE.
DATA: t_mseg_2 TYPE mseg OCCURS 0 WITH HEADER LINE.
DATA: s_bkpf   TYPE bkpf.
DATA: _awkey   TYPE bkpf-awkey.

DATA : lv_wrbtr TYPE wrbtr,
       tmm,
       paz,
       ls_vbak  LIKE vbak.

CLEAR paz.
LOOP AT cvbrp.
  CLEAR ls_vbak.
  SELECT SINGLE * FROM vbak
        INTO ls_vbak
       WHERE vbeln = cvbrp-aubel.
  IF ls_vbak-auart EQ 'ZA09' OR ls_vbak-auart EQ 'ZC08' OR
     ls_vbak-auart EQ 'ZD03' OR ls_vbak-auart EQ 'ZR02'.
    paz = 'X'.
    EXIT.
  ENDIF.
ENDLOOP.

IF cvbrk-vbtyp EQ 'O'
*IF ( cvbrk-vbtyp EQ 'O' OR cvbrk-vbtyp EQ 'P' )
  AND cvbrk-vtweg EQ '10'
*  AND cvbrk-zz_lcnum IS NOT INITIAL
  AND paz EQ space
  AND doc_number EQ '$000000001' .
  lv_wrbtr = cvbrk-netwr + cvbrk-mwsbk.

    CALL FUNCTION 'ZDK_SD_FM_KAMPANYA'
      EXPORTING
        i_knuma = cvbrp-knuma_ag
        i_lcnum = cvbrk-lcnum
        i_wrbtr = lv_wrbtr
        i_blgtr = 'IAD'
        i_bukrs = cvbrk-bukrs
        i_waers = cvbrk-waerk
        i_kunnr = cvbrk-kunrg
*       I_XKNUM =
*       I_XLNUM =
        i_vbeln = cvbrk-vbeln
        i_xblnr = cvbrk-xblnr
      IMPORTING
        e_tmm   = tmm.
    IF tmm IS INITIAL OR tmm = 'E'.
      MESSAGE e011(zsd_va).
    ENDIF.
ENDIF.

IF cvbrk-vbtyp = 'O' OR cvbrk-vbtyp = 'P'.
  SELECT SINGLE augru FROM vbak INTO lv_augru
  WHERE vbeln = cvbrp-aubel.
  IF ( lv_augru = '001' AND cvbrk-vbtyp = 'O' ) OR
     ( lv_augru = '006' AND cvbrk-vbtyp = 'O' ) OR
     ( lv_augru = '008' AND cvbrk-vbtyp = 'P' ).
    SELECT SINGLE lifnr FROM kna1 INTO lv_lifnr
      WHERE kunnr = cvbrk-kunag.
    IF lv_lifnr IS INITIAL.
      MESSAGE e008(zsd_va) WITH cvbrk-kunag.
    ENDIF.
    LOOP AT xaccit INTO wa_xaccit
      WHERE bschl = '11'.
      IF sy-subrc IS INITIAL.
        wa_xaccit-bschl = '31'.
        wa_xaccit-lifnr = lv_lifnr.
        wa_xaccit-blart = 'KR'.
        CLEAR: wa_xaccit-kunnr.
        MODIFY xaccit FROM wa_xaccit INDEX sy-tabix
        TRANSPORTING bschl lifnr blart kunnr.
      ELSE.
        MESSAGE e010(zsd_va).
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDIF.
