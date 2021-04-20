class ZCL_IM_DELIVERY_PUBLISH definition
  public
  final
  create public .

public section.

  interfaces IF_EX_DELIVERY_PUBLISH .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_DELIVERY_PUBLISH IMPLEMENTATION.


  method IF_EX_DELIVERY_PUBLISH~PUBLISH_AFTER_SAVE.
    CALL FUNCTION 'EXPIMP_TABLES_REFRESH'.
  endmethod.


  method IF_EX_DELIVERY_PUBLISH~PUBLISH_BEFORE_COMMIT.
  endmethod.
ENDCLASS.
