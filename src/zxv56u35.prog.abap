*&---------------------------------------------------------------------*
*&  Include           ZXV56U35
*&---------------------------------------------------------------------*
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_STATUS) LIKE  VTTK-STTRG
*"             VALUE(I_NEW_STATUS_DATE) LIKE  VTTK-DTABF OPTIONAL
*"             VALUE(I_NEW_STATUS_TIME) LIKE  VTTK-UZABF OPTIONAL
*"             VALUE(I_TVTK) LIKE  TVTK STRUCTURE  TVTK
*"             VALUE(OPT_DIALOG) LIKE  RV56A-SELKZ
*"       TABLES
*"              C_XVTTP STRUCTURE  VTTPVB
*"              C_YVTTP STRUCTURE  VTTPVB
*"              C_XVTTS STRUCTURE  VTTSVB
*"              C_YVTTS STRUCTURE  VTTSVB
*"              C_XVTSP STRUCTURE  VTSPVB
*"              C_YVTSP STRUCTURE  VTSPVB
*"              C_XVBPA STRUCTURE  VBPAVB
*"              C_YVBPA STRUCTURE  VBPAVB
*"              C_XVBADR STRUCTURE  SADRVB
*"              I_XTRLK STRUCTURE  VTRLK
*"              I_XTRLP STRUCTURE  VTRLP
*"       CHANGING
*"             VALUE(C_XVTTK) LIKE  VTTKVB STRUCTURE  VTTKVB
*"       EXCEPTIONS
*"              ERROR

* Shipment end yapıldığında shipment start tarihi otomatik
* günün tarihi gelsin.
IF i_status = '7' AND c_xvttk-dpten IS INITIAL. " Shipment End
  IF NOT i_new_status_date IS INITIAL.
    c_xvttk-dpten = i_new_status_date.
  ELSE.
    c_xvttk-dpten = sy-datum.
  ENDIF.

ENDIF.
