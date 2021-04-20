FUNCTION zyb_sd_f_vl_del.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LIKP) TYPE  LIKP
*"     VALUE(I_LIPS) TYPE  LIPSVB OPTIONAL
*"----------------------------------------------------------------------
  FREE: it_shp01, it_shp02.
  CLEAR: it_shp01, it_shp02.
  CASE i_likp-lfart.
    WHEN gc_lfart_ihrpro.
      IF i_lips IS INITIAL.
        SELECT * FROM zyb_sd_t_shp02
            INTO TABLE it_shp02
              WHERE vbeln_vl EQ i_likp-vbeln
                AND loekz    EQ space.
      ELSE.
        SELECT * FROM zyb_sd_t_shp02
            INTO TABLE it_shp02
              WHERE vbeln_vl EQ i_lips-vbeln
                AND posnr_vl EQ i_lips-posnr
                AND loekz    EQ space.
      ENDIF.
      LOOP AT it_shp02.
        it_shp02-loekz = 'X'.
        it_shp02-aenam = sy-uname.
        it_shp02-aedat = sy-datum.
        it_shp02-aezet = sy-uzeit.
        MODIFY it_shp02.
      ENDLOOP.
      IF sy-subrc = 0.
        MODIFY zyb_sd_t_shp02 FROM TABLE it_shp02.
        COMMIT WORK AND WAIT.
      ENDIF.
    WHEN OTHERS.
      IF i_lips IS INITIAL.
        DELETE FROM zyb_sd_t_shp01 WHERE vbeln EQ i_likp-vbeln.

        SELECT * FROM zyb_sd_t_shp02
                 INTO TABLE it_shp02
                 WHERE vbeln_vl EQ i_likp-vbeln
                   AND loekz    EQ space
                   AND durum    EQ 'D'.
      ELSE.
        DELETE FROM zyb_sd_t_shp01 WHERE vbeln EQ i_lips-vbeln
                                     AND posnr EQ i_lips-posnr.

        SELECT * FROM zyb_sd_t_shp02
            INTO TABLE it_shp02
              WHERE vbeln_vl EQ i_lips-vbeln
                AND posnr_vl EQ i_lips-posnr
                AND loekz    EQ space
                AND durum    EQ 'D'.
      ENDIF.

      COMMIT WORK AND WAIT.


      LOOP AT it_shp02.
        CLEAR: it_shp02-vbeln_vl, it_shp02-posnr_vl.
        it_shp02-durum = 'C'.
        it_shp02-aenam = sy-uname.
        it_shp02-aedat = sy-datum.
        it_shp02-aezet = sy-uzeit.
        MODIFY it_shp02.
      ENDLOOP.
      IF sy-subrc = 0.
        MODIFY zyb_sd_t_shp02 FROM TABLE it_shp02.
        COMMIT WORK AND WAIT.
      ENDIF.
  ENDCASE.


ENDFUNCTION.
