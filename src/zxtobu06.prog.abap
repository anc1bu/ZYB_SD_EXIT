*&---------------------------------------------------------------------*
*&  Include           ZXTOBU06
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"       Taşıt verileri içerisinde değişiklik yapıldığında giriyor
*"
*"
*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_OBJECT_TYPE) TYPE  ITOBTYP
*"     VALUE(I_ACTIVITY_TYPE) LIKE  IREF-ACTYP
*"     REFERENCE(I_DATA_ITOB) LIKE  ITOB STRUCTURE  ITOB
*"     REFERENCE(I_DATA_FLEET) LIKE  FLEET STRUCTURE  FLEET
*"  EXPORTING
*"     REFERENCE(E_UPDATE_FLEET_IDENT) LIKE  FLEET_IDENT STRUCTURE
*"        FLEET_IDENT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
*"  Nakliyede kullanılan araçların plaka kontrolü
*"----------------------------------------------------------------------
DATA: lv_shtxt TYPE ktx01,
      lv_equnr TYPE equnr.

IF i_object_type EQ '02'. " Ekipman

  SELECT SINGLE COUNT(*) FROM /dsd/rp_motrcat
     WHERE eqtyp     EQ i_data_itob-eqtyp
       AND fleet_cat EQ i_data_itob-eqart.
  IF sy-subrc EQ 0.
    IF i_data_fleet-license_num IS INITIAL AND
       i_data_itob-shtxt(2) CO '0123456789'. " Plakaları ayırmak için
      lv_shtxt = i_data_itob-shtxt.
      TRANSLATE lv_shtxt TO UPPER CASE. CONDENSE lv_shtxt NO-GAPS.
      MOVE lv_shtxt TO e_update_fleet_ident-license_num.
    ENDIF.

    IF NOT e_update_fleet_ident-license_num IS INITIAL.

            TRANSLATE e_update_fleet_ident-license_num TO UPPER CASE.
            CONDENSE  e_update_fleet_ident-license_num NO-GAPS.
      CASE i_activity_type.
        WHEN '1'." Yarat
          SELECT SINGLE equi~equnr FROM fleet
              INNER JOIN equi ON equi~objnr EQ fleet~objnr
               INTO lv_equnr
              WHERE fleet~license_num EQ e_update_fleet_ident-license_num
                AND equi~lvorm EQ space.
        WHEN '2'." Değiştir
          SELECT SINGLE equi~equnr FROM fleet
              INNER JOIN equi ON equi~objnr EQ fleet~objnr
               INTO lv_equnr
              WHERE fleet~license_num EQ e_update_fleet_ident-license_num
                AND fleet~objnr NE i_data_fleet-objnr
                AND equi~lvorm EQ space.
      ENDCASE.

      IF NOT lv_equnr IS INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_equnr
          IMPORTING
            output = lv_equnr.
        MESSAGE e001(zsd_vt) WITH e_update_fleet_ident-license_num
                                  lv_equnr RAISING error.
      ENDIF.
    ENDIF.
  ENDIF.

ENDIF.

*"----------------------------------------------------------------------
*"  Nakliyede kullanılan araçların plaka kontrolü
*"----------------------------------------------------------------------
