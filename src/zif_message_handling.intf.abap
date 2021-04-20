interface ZIF_MESSAGE_HANDLING
  public .


  data MO_MESSAGE_LIST type ref to IF_RECA_MESSAGE_LIST .

  methods GET_MESSAGE_LIST
    returning
      value(RO_MESSAGE_LIST) type ref to IF_RECA_MESSAGE_LIST .
endinterface.
