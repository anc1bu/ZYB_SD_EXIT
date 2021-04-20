FUNCTION zcheck_rounding_profile.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT399D) LIKE  T399D STRUCTURE  T399D DEFAULT SPACE
*"     VALUE(PLANT) LIKE  RDPR-WERKS
*"     VALUE(PROFILE) LIKE  RDPR-RDPRF
*"     VALUE(QUANTITY_IN) LIKE  RDPR-BDMNG
*"     VALUE(REF_PLANT) LIKE  RDPR-WERKS DEFAULT SPACE
*"     VALUE(KZ_USE_IRDPR) OPTIONAL
*"     VALUE(KZ_ROUND_DOWN) OPTIONAL
*"  EXPORTING
*"     VALUE(QUANTITY_OUT) LIKE  RDPR-VORMG
*"  TABLES
*"      IRDPR STRUCTURE  RDPR OPTIONAL
*"  EXCEPTIONS
*"      PROFILE_NOT_FOUND
*"----------------------------------------------------------------------
* Änderungen:
* Marke  Thema   Text
* @001   Retail  Profil kann in IRDPR übergeben werden
* @002   Retail  Rundungsprofil darf nicht abrunden
* @003   Retail  RDMPO berücksichtigen
*                Profil erst für Werk, dann ohne Werk
*                lesen; Ref-Werk nicht mehr unterstützt
* @004   Retail  Division durch 0 verhindern
*-----------------------------------------------------------------------

  MOVE plant         TO iwerks.
  MOVE ref_plant     TO iref_werks.
  MOVE profile       TO irdprf.
  MOVE quantity_in   TO imenge.
  MOVE it399d        TO t399d.

*@001-Begin
  IF kz_use_irdpr IS INITIAL.

* LDO - Note - 532513 - Begin
* Lesen des Rundungsprofils
*   PERFORM LESEN_PROFIL.
*   CLEAR IRDPR. REFRESH IRDPR.
*   LOOP AT RDPRX INTO IRDPR.
*     APPEND IRDPR.
*   ENDLOOP.

*   Lesen des Rundungsprofils
*    PERFORM lesen_profil_new
*     TABLES rdprx
*      USING iwerks irdprf iref_werks t399d.

*    CLEAR   irdpr.
*    REFRESH irdpr.
*
*    LOOP AT rdprx INTO irdpr.
*      APPEND irdpr.
*    ENDLOOP.
* LDO - Note - 532513 - Ende

  ELSE.
*--> Merken übergebene Tabelle
    CLEAR rdprx. REFRESH rdprx.
    LOOP AT irdpr INTO rdprx.
      APPEND rdprx.
    ENDLOOP.
*--> ( WERKS, RDPRF )  merken
    MOVE iwerks  TO merk_werks.
    MOVE irdprf  TO merk_rdprf.
  ENDIF.
**--- Lesen des Rundungsprofils
*perform lesen_profil.
*@001-End

*@002-Begin
*--- wenn der Schwellwert der ersten Stufe schon nicht erreicht ist,
*--- dann bleibt die Eingabemenge unverändert.
  READ TABLE irdpr INDEX 1.
*@003-Begin
  IF NOT irdpr-rdmpo IS INITIAL.
*   ein dynamisches Rundungsprofil! nicht verarbeiten!
*   wird im FuBau 'md_einzelrundung' gemacht
    quantity_out = quantity_in.
    EXIT.
  ELSEIF imenge < irdpr-bdmng.
* if imenge < irdpr-bdmng.
*@003-End
    omenge = imenge.
  ELSE.
*@002-End
*--- die Stufen des Rundungsprofils stehen in der internen Tabelle IRDPR
*--- nun wird die Vorschlagsmenge ausgehend von der
*--- Eingangsmenge IMENGE berechnet.
    DESCRIBE TABLE irdpr LINES xline.
    CLEAR omenge.
    DO.
      READ TABLE irdpr INDEX xline.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      IF imenge GE irdpr-vormg.
*@004-Begin
        IF irdpr-vormg <> 0.
          help = imenge DIV irdpr-vormg.
        ELSE.
          CLEAR help.
        ENDIF.
*       help = imenge div irdpr-vormg.
*@004-END
        omenge = omenge + help * irdpr-vormg.
        imenge = imenge - help * irdpr-vormg.
      ENDIF.
      IF imenge LE 0.
        EXIT.
      ENDIF.
      IF imenge GE irdpr-bdmng AND
         kz_round_down IS INITIAL.
        omenge = omenge + irdpr-vormg.
        EXIT.
      ENDIF.
      xline = xline - 1.
      IF xline LE 0.
        EXIT.
      ENDIF.
    ENDDO.

*@002-Begin
    IF omenge < quantity_in AND
       kz_round_down IS INITIAL.
      omenge = omenge + irdpr-vormg.
    ENDIF.
*@002-End
  ENDIF.
  MOVE omenge TO quantity_out.
ENDFUNCTION.
