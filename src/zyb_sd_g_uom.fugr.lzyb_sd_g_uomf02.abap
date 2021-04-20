*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_UOMF02.
*----------------------------------------------------------------------*
*"----------------------------------------------------------------------
* Änderungen:
* Marke  Thema   Text
* @001   Retail  RDMPO berücksichtigen
*                Profil erst für Werk, dann ohne Werk
*                lesen; Ref-Werk nicht mehr unterstützt
*-----------------------------------------------------------------------
* Lesen_Profil
*-----------------------------------------------------------------------
FORM lesen_profil.
*@001-Begin
  IF merk_werks <> iwerks OR merk_rdprf <> irdprf.
*   zuerst mit Werk probieren
    REFRESH rdprx.

    SELECT *
    FROM   rdpr
    INTO   TABLE rdprx
    WHERE  werks = iwerks
    AND    rdprf = irdprf.

    IF sy-subrc <> 0.
*     ohne Werk probieren
      SELECT *
      FROM   rdpr
      INTO   TABLE rdprx
      WHERE  werks = space
      AND    rdprf = irdprf.

      IF sy-subrc <> 0.
        MESSAGE e187 RAISING profile_not_found.
      ENDIF.
    ENDIF.
    merk_werks = iwerks.
    merk_rdprf = irdprf.
  ENDIF.

* altes Coding:

**-- in MERK_WERKS,MERK_RDPRF steht die PLANT,PROFILE-Kombination zu de
**-- zuletzt erfolgreich ein Rundungsprofil gelesen wurde
**-- dieses Profil befindet sich in der internen Tabelle IRDPR
*if iwerks ne merk_werks
*or irdprf ne merk_rdprf.
**--> Zugriff auf RDPR mit neuer Kombination
*   select * from rdpr
*   where werks eq iwerks
*   and   rdprf eq irdprf
*   order by primary key.
*      if sy-dbcnt = 1.
*         refresh rdprx.     "alten Puffer zurücksetzen
*      endif.
*      move rdpr to rdprx.
*      append rdprx.
*   endselect.
*   if sy-subrc ne 0.
**--> Eventuell mit Referenzwerk aus T399D nachlesen
*      if iref_werks is initial.      "kann man auch von außen mitgeben
*         if t399d-werks ne iwerks.
*           select single * from t399d where werks eq iwerks.
*           if sy-subrc = 0.
*              move t399d-refwk to iref_werks.
*           endif.
*         else.
*           move t399d-refwk to iref_werks.
*         endif.
*      endif.
*      if not iref_werks is initial.
*         select * from rdpr
*         where werks eq iref_werks
*         and   rdprf eq irdprf
*         order by primary key.
*            if sy-dbcnt = 1.
*               refresh rdprx.
*            endif.
*            move rdpr to rdprx.
*            append rdprx.
*         endselect.
*         if sy-subrc = 0.
**--> ( WERKS, RDPRF )  merken
*            move iwerks  to merk_werks.
*            move irdprf  to merk_rdprf.
*         else.
*            message e187 raising profile_not_found.
*         endif.
*      else.
*         message e187 raising profile_not_found.
*      endif.
*   else.
**--> ( WERKS, RDPRF )  merken
*      move iwerks  to merk_werks.
*      move irdprf  to merk_rdprf.
*   endif.
*endif.
*@001-End
ENDFORM.

* LDO - Note - 532513 - Begin
FORM lesen_profil_new
   TABLES p_t_rdpr  STRUCTURE rdpr
   USING  p_i_werks LIKE      marc-werks
          p_i_rdprf LIKE      marc-rdprf
          p_i_refwk LIKE      t399d-refwk
          p_i_t399d LIKE      t399d.

  STATICS: s_werks  LIKE marc-werks.
  STATICS: s_rdprf  LIKE marc-werks.
  STATICS: s_t399d  LIKE t399d.
  STATICS: s_t_rdpr LIKE rdpr OCCURS 0.

  DATA:    l_t_rdpr LIKE rdpr OCCURS 0.

  DATA:    l_refwk  LIKE t399d-refwk.
  DATA:    l_t399d  LIKE t399d.

  CLEAR p_t_rdpr[].

* Puffer nutzen falls gefüllt ...
  IF s_werks = p_i_werks AND
     s_rdprf = p_i_rdprf.

*   .. und Ergebnis zurückgeben
    p_t_rdpr[] = s_t_rdpr[].
*   .. und Form-Routine beenden.
    EXIT.

  ENDIF.

  SELECT * FROM rdpr INTO TABLE l_t_rdpr
    WHERE werks = p_i_werks
      AND rdprf = p_i_rdprf
    ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.

*   Puffer füllen ..
    s_werks    = p_i_werks.
    s_rdprf    = p_i_rdprf.
    s_t_rdpr[] = l_t_rdpr[].
*   .. und Ergebnis zurückgeben ..
    p_t_rdpr[] = s_t_rdpr[].
*   .. und Form-Routine beenden.
    EXIT.

  ENDIF.

* Bestimmung des Referenzwerks ...
  CLEAR l_refwk.

  IF NOT p_i_refwk IS INITIAL.
*   ... falls es übergeben wurde ...
    l_refwk = p_i_refwk.
  ELSE.
    IF p_i_t399d-werks = p_i_werks.
*     ... oder aus der kompletten Struktur falls übergeben ...
      l_refwk = p_i_t399d-refwk.
    ELSE.
      IF s_t399d-werks = p_i_werks.
*       ... oder aus dem Puffer ...
        l_refwk = s_t399d-refwk.
      ELSE.
        SELECT SINGLE * FROM t399d INTO l_t399d
          WHERE werks = p_i_werks.

        IF sy-subrc = 0.

*         ... oder aus der Datenbank ...
          s_t399d = l_t399d.
          l_refwk = s_t399d-refwk.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Da nichts gefunden wurde eventuell mit dem Referenzwerk lesen ..
  IF NOT l_refwk IS INITIAL.

    SELECT * FROM rdpr INTO TABLE l_t_rdpr
      WHERE werks = l_refwk
        AND rdprf = p_i_rdprf
      ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.

*     Puffer füllen ..
      s_werks    = p_i_werks.
      s_rdprf    = p_i_rdprf.
      s_t_rdpr[] = l_t_rdpr[].
*     .. und Ergebnis zurückgeben ..
      p_t_rdpr[] = s_t_rdpr[].
*     .. und Form-Routine beenden.
      EXIT.

    ENDIF.
  ENDIF.

* Da nichts gefunden wurde OHNE Werk lesen ...
  SELECT * FROM rdpr INTO TABLE l_t_rdpr
    WHERE werks = space
      AND rdprf = p_i_rdprf
    ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.

*   Puffer füllen ..
    s_werks    = p_i_werks.
    s_rdprf    = p_i_rdprf.
    s_t_rdpr[] = l_t_rdpr[].
*   .. und Ergebnis zurückgeben ..
    p_t_rdpr[] = s_t_rdpr[].
*   .. und Form-Routine beenden.
    EXIT.

  ENDIF.

* Immer noch nichts gefunden ...
  MESSAGE e187 RAISING profile_not_found.

ENDFORM.
* LDO - Note - 532513 - Ende
