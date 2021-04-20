class ZCL_SD_MV45AFZZ_MOVETOVBAP definition
  public
  final
  create public .

public section.

  methods VERI_ATAMA
    changing
      value(CS_VBAP) type VBAPVB optional
      value(CS_VBKD) type VBKD optional
      value(CT_VBKD) type VA_VBKDVB_T optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_MOVETOVBAP IMPLEMENTATION.


  METHOD veri_atama.

    DATA: ls_vbkd TYPE vbkd.

    IF cs_vbap-updkz = 'I'.
      READ TABLE ct_vbkd INTO ls_vbkd WITH KEY posnr = '000000'.
      IF sy-subrc EQ 0.
        cs_vbkd-prsdt = ls_vbkd-prsdt.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
