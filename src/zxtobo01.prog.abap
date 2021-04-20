*----------------------------------------------------------------------*
***INCLUDE ZXTOBO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  "--------->> Anıl CENGİZ 16.10.2019 21:33:22
  "YUR-495
  IF sy-tcode EQ 'IE03'.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'FLEET-ZZSOFORADI' OR 'FLEET-ZZSOFORTEL'.
          screen-input = 0.
        WHEN OTHERS.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  "---------<<

  IF sy-tcode EQ 'IE01' or sy-tcode EQ 'IE02'.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'FLEET-ZZSOFORADI' OR 'FLEET-ZZSOFORTEL'.
*          screen-input = 0.
          screen-required = 1. "Fozdamar 14.11.2019 zorunlu olsun. gerekçe e-irsaliye.
        WHEN OTHERS.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " STATUS_2000  OUTPUT
