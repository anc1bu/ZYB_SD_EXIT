*----------------------------------------------------------------------*
***INCLUDE LZYB_SD_G_GNLF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CONVERT_MENGE
*&---------------------------------------------------------------------*
FORM convert_menge  USING p_matnr
                          p_mvgr1
                          p_mvgr2
                          p_menge
                          p_alt_uom
                 CHANGING ep_miktar
                          ep_meins.
  DATA :lv_x.
  CLEAR: ep_miktar, ep_meins.
  IF p_mvgr1 IS INITIAL.
    lv_x = ''.
  ELSE.
    lv_x = 'X'.
  ENDIF.
  CALL FUNCTION 'ZYB_SD_F_CONVERT_TO_ALT_UOM'
    EXPORTING
      plt_tam                  = lv_x
      p_alt_uom                = p_alt_uom
      p_cur_qty                = p_menge
      p_matnr                  = p_matnr
      p_mvgr1                  = p_mvgr1
      p_mvgr2                  = p_mvgr2
    IMPORTING
      ep_uom_qty               = ep_miktar
      ep_uom                   = ep_meins
    EXCEPTIONS
      unit_not_found           = 1
      format_error             = 2
      uom_not_consistent       = 3
      obligatory               = 4
      type_not_consistent      = 5
      not_convertible_material = 6
      not_customize_material   = 7
      empty_palet              = 8
      OTHERS                   = 9.

  IF sy-subrc <> 0.
    PERFORM add_msg USING 'E'
                      sy-msgid
                      sy-msgno
                      sy-msgv1
                      sy-msgv2
                      sy-msgv3
                      sy-msgv4.
  ENDIF.
*  IF sy-subrc = 0.
*    ep_meins = 'ST'.
*  ENDIF.

*  CALL FUNCTION 'ZYB_SD_F_CONVERT_TO_ALT_UOM'
*    EXPORTING
*      p_alt_uom      = p_alt_uom
*      p_cur_qty      = p_menge
*      p_matnr        = p_matnr
*      p_matnr_amb    = p_mat_amb
*      p_rounding     = 'X'
*    IMPORTING
*      ep_alt_qty     = ep_miktar
*      "EP_UMREN       =
*      "EP_UMREZ       =
*    EXCEPTIONS
*      unit_not_found = 1
*      OTHERS         = 2.
*  IF sy-subrc = 0.
*    ep_meins = p_alt_uom.
*  ENDIF.

ENDFORM.                    " CONVERT_MENGE
*&---------------------------------------------------------------------*
*&      Form  ADD_MSG
*&---------------------------------------------------------------------*
FORM add_msg  USING p_type   TYPE bapi_mtype
                    p_id     TYPE symsgid
                    p_number TYPE symsgno
                    p_msgv1 "  TYPE symsgv
                    p_msgv2 " TYPE symsgv
                    p_msgv3 " TYPE symsgv
                    p_msgv4 ." TYPE symsgv.

  CLEAR : gs_ret.
  gs_ret-type        = p_type.
  gs_ret-id          = p_id.
  gs_ret-number      = p_number.
  gs_ret-message_v1  = p_msgv1.
  gs_ret-message_v2  = p_msgv2.
  gs_ret-message_v3  = p_msgv3.
  gs_ret-message_v4  = p_msgv4.

  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type   = gs_ret-type
      cl     = gs_ret-id
      number = gs_ret-number
      par1   = gs_ret-message_v1
      par2   = gs_ret-message_v2
      par3   = gs_ret-message_v3
      par4   = gs_ret-message_v4
    IMPORTING
      return = gs_ret.


  APPEND gs_ret TO gt_ret.
ENDFORM.                    " ADD_MSG

*----------------------------------------------------------------------*
*  Lese Tabelle T682I (Zugriffsfolgen) -> PX_T_T682I fuellen
*----------------------------------------------------------------------*
* --> pi_kvewe      Verwendung
*     pi_kappl      Applikation
*     pi_kozgf      Name der Zugriffsfolge
* <-> px_t_t8682i   Zugriffe der Zugriffsfolge, generierte Form
*----------------------------------------------------------------------*
FORM t682i_fuellen TABLES px_t_t682i STRUCTURE t682i
                   USING  pi_kvewe LIKE t682i-kvewe
                          pi_kappl LIKE t682i-kappl
                          pi_kozgf LIKE t682i-kozgf.

* Lese T682I mit Baustein --> PX_T_T682I ------------------------------*
  CALL FUNCTION 'SD_T682I_SINGLE_READ'
    EXPORTING
      kvewe_i      = pi_kvewe
      kappl_i      = pi_kappl
      kozgf_i      = pi_kozgf
      count_i      = 50
    TABLES
      t682i_tab_io = px_t_t682i
    EXCEPTIONS
      OTHERS       = 1.

* Fehlerbehandlung ----------------------------------------------------*
  IF sy-subrc NE 0.
*   PE_SUBRC = SY-SUBRC.
*   REFRESH PX_T_T682I.
    EXIT.
  ENDIF.

ENDFORM.                                  " T682I_FUELLEN
*----------------------------------------------------------------------*
* Konditionsart Definition (mit Zugriffsfolge) lesen,  *T685 füllen
*----------------------------------------------------------------------*
* --> pi_kvewe   Verwendung
* --> pi_kappl   Applikation
* --> pi_kschl   Konditionsart
* <-- pe_kschl   Return-Code: 0 = *t685 gefüllt
* Gl: *t685      Definitionsdaten (Zugriffsfolge) zur Konditionsart
*----------------------------------------------------------------------*
FORM t685_fuellen USING pi_kvewe TYPE t685-kvewe
                        pi_kappl TYPE t685-kappl
                        pi_kschl TYPE t685-kschl
                        pe_subrc TYPE sy-subrc
                        pe_t685  TYPE t685.

* Return-Code initialisieren ------------------------------------------*
  CLEAR pe_subrc.

* Tabelle T685 mit Baustein lesen -------------------------------------*
  CALL FUNCTION 'SD_T685_SINGLE_READ'
    EXPORTING
      kvewe_i = pi_kvewe
      kappl_i = pi_kappl
      kschl_i = pi_kschl
    IMPORTING
      t685_o  = pe_t685
    EXCEPTIONS
      OTHERS  = 1.

* Fehlerbehandlung ----------------------------------------------------*
  IF sy-subrc NE 0.
    CLEAR pe_t685.
    pe_subrc = sy-subrc.
    EXIT.
  ENDIF.

ENDFORM.
*----------------------------------------------------------------------*
*  Lese Tabelle T682Z (Zugriffsfolgen) -> PX_T_682Z fuellen
*----------------------------------------------------------------------*
* --> pi_kvewe      Verwendung
*     pi_kappl      Applikation
*     pi_kozgf      Name der Zugriffsfolge
* <-> px_t_t8682z   Zugriffe der Zugriffsfolge
*----------------------------------------------------------------------*
FORM t682z_fuellen TABLES px_t_t682z STRUCTURE t682z
                   USING  pi_kvewe LIKE t682z-kvewe
                          pi_kappl LIKE t682z-kappl
                          pi_kozgf LIKE t682z-kozgf.

* Lese T682Z mit Baustein --> PX_T_T682Z ------------------------------*
  CALL FUNCTION 'SD_T682Z_SINGLE_READ'
    EXPORTING
      kvewe_i      = pi_kvewe
      kappl_i      = pi_kappl
      kozgf_i      = pi_kozgf
      count_i      = 50
    TABLES
      t682z_tab_io = px_t_t682z
    EXCEPTIONS
      OTHERS       = 1.

* Fehlerbehandlung ----------------------------------------------------*
  IF sy-subrc NE 0.
*   PE_SUBRC = SY-SUBRC.
*   REFRESH PX_T_T682Z.
    EXIT.
  ENDIF.

ENDFORM.                                  " T682Z_FUELLEN

*----------------------------------------------------------------------*
*  Struktur *KONP fuellen
*----------------------------------------------------------------------*
* --> pi_knumh              Konditionssatznummer
*     pi_kappl, pi_kschl    Applikation, Konditionsart
*     pi_loevm_check        Kz. 'Löschkennzeichen prüfen'
*     pe_subrc              Return-Code: 0 = *KONP enthält Kond.Daten
*----------------------------------------------------------------------*
FORM konp_fuellen USING pi_knumh LIKE konp-knumh
                        pi_kappl LIKE konp-kappl
                        pi_kschl LIKE konp-kschl
                        pi_loevm_check LIKE sy-marky
                        pe_i_konp TYPE konp
                        pe_subrc LIKE sy-subrc.

* Initialize return code
  CLEAR: pe_subrc.

* Get condition position KONP
  CALL FUNCTION 'WV_KONP_GET'
    EXPORTING
      pi_knumh        = pi_knumh
      pi_kappl        = pi_kappl
      pi_kschl        = pi_kschl
    IMPORTING
      pe_i_konp       = pe_i_konp
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

* Error handling
  IF sy-subrc NE 0.
    CLEAR pe_i_konp.
    pe_subrc = 99.
    EXIT.
  ENDIF.

* Analyse flag PI_LOEVM_CHECK
  IF pi_loevm_check EQ gc_yes.
    IF pe_i_konp-loevm_ko EQ gc_yes.
      CLEAR pe_i_konp.
      pe_subrc = 99.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                              " KONP_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
FORM conversion_exit_alpha_input  CHANGING VALUE(p_val).
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_val
    IMPORTING
      output = p_val.
ENDFORM.                    " CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*&      Form  CONVERT_FROM_TIMESTAMP
*&---------------------------------------------------------------------*
FORM convert_from_timestamp  USING    p_tstfr
                                      p_zonfr
                             CHANGING ep_datlo
                                      ep_timlo.
  CLEAR: ep_datlo, ep_timlo.
  CALL FUNCTION 'IB_CONVERT_FROM_TIMESTAMP'
    EXPORTING
      i_timestamp = p_tstfr
      i_tzone     = p_zonfr
    IMPORTING
      e_datlo     = ep_datlo
      e_timlo     = ep_timlo.
ENDFORM.                    " CONVERT_FROM_TIMESTAMP
*&---------------------------------------------------------------------*
*&      Form  KONTEYNER_SAYISI
*&---------------------------------------------------------------------*
FORM konteyner_sayisi  USING    p_tknum
                       CHANGING ep_kntsys.
DATA: lv_kntsys TYPE zyb_sd_e_kntsys.

  CLEAR lv_kntsys.
  SELECT COUNT( DISTINCT kontno )
      INTO lv_kntsys
      FROM zyb_sd_t_shp02
      WHERE svkno  EQ p_tknum
        AND loekz  EQ space
        AND durum  EQ 'D'
        AND kontno NE space.

    IF NOT lv_kntsys IS INITIAL.
      ep_kntsys = lv_kntsys.
    ENDIF.
ENDFORM.                    " KONTEYNER_SAYISI
