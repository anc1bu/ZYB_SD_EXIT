class ZCL_SD_TASIMA_IRSALIYE definition
  public
  final
  create public .

public section.

  class-methods MEMORY_VSART
    importing
      !IV_VSART type VSARTTR optional
    returning
      value(RV_VSART) type VSARTTR .
protected section.
private section.

  constants C_TASIMA type CHAR15 value 'memid_tasima'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_SD_TASIMA_IRSALIYE IMPLEMENTATION.


METHOD memory_vsart.

  IF iv_vsart IS NOT INITIAL.
    EXPORT vsart = iv_vsart TO MEMORY ID c_tasima.
  ELSE.
    IMPORT vsart = rv_vsart FROM MEMORY ID c_tasima.
*    CHECK rv_vsart IS NOT INITIAL.
*    FREE MEMORY ID c_tasima.
  ENDIF.

ENDMETHOD.
ENDCLASS.
