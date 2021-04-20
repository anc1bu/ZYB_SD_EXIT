*&---------------------------------------------------------------------*
*&  Include           ZXV6PU08
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              C_VKDFIF STRUCTURE  VKDFIF
*"----------------------------------------------------------------------
DATA: l_vkdfif LIKE vkdfif,
      ls_nak   LIKE zyb_sd_s_nakilye,
      lv_shtyp TYPE shtyp.
CLEAR l_vkdfif.

LOOP AT c_vkdfif INTO l_vkdfif.
  CLEAR lv_shtyp.
  CASE l_vkdfif-vbtyp.
    WHEN 'J'. " Teslimat

      CASE l_vkdfif-vtweg.
        WHEN '10'. lv_shtyp = 'Z003'.
        WHEN '20'. lv_shtyp = 'Z001'.
        WHEN OTHERS.
      ENDCASE.

      SELECT SINGLE vttp~tknum FROM vttp
        INNER JOIN vttk ON  vttk~tknum EQ vttp~tknum
            INTO l_vkdfif-tknum
           WHERE vttp~vbeln EQ l_vkdfif-vbeln
             AND vttk~shtyp EQ lv_shtyp.

      IF NOT l_vkdfif-tknum IS INITIAL.
        CLEAR ls_nak.
        CALL FUNCTION 'ZYB_SD_F_READ_SHIPMENT'
          EXPORTING
            i_tknum   = l_vkdfif-tknum
          IMPORTING
            e_nakliye = ls_nak.
      ENDIF.

      l_vkdfif-vehicle     = ls_nak-vehicle.
      l_vkdfif-eqktx       = ls_nak-eqktx.
      l_vkdfif-vsart       = ls_nak-vsart.
      l_vkdfif-vsart_txt   = ls_nak-vsart_txt.

      SELECT SINGLE lifex FROM likp
          INTO c_vkdfif-lifex
         WHERE vbeln EQ l_vkdfif-vbeln.
    WHEN OTHERS.
  ENDCASE.

* Mail Adresi
  SELECT SINGLE smtp_addr FROM adr6
           INTO l_vkdfif-smtp_addr
          WHERE addrnumber EQ l_vkdfif-adrnr.

  MODIFY c_vkdfif FROM l_vkdfif.
ENDLOOP.
