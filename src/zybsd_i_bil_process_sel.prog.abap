*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_BIL_PROCESS_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl01 WITH FRAME TITLE text-t01.
  SELECTION-SCREEN SKIP.
  PARAMETERS:
    p_vbeln LIKE vbrk-vbeln OBLIGATORY,
    p_job   NO-DISPLAY.
  SELECTION-SCREEN END   OF BLOCK bl01 .
