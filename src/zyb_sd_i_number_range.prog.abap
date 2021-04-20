*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_NUMBER_RANGE
*&---------------------------------------------------------------------*
 DATA: ls_vbrk LIKE vbrk,
       ls_vbrp LIKE vbrp,
       lt_004  LIKE zyb_sd_t_shp04 OCCURS 0 WITH HEADER LINE.

 DATA: BEGIN OF lt_sip OCCURS 0,
         aubel TYPE vbeln_va,
       END OF lt_sip.

*** Nakliye Faturalarının durumlarının güncellenmesi

 IF NOT ( xvbrk-vbtyp EQ 'N' OR xvbrk-vbtyp EQ 'S' ) AND
         xvbrk-fktyp EQ 'A' AND xvbrk-vbtyp EQ 'O' AND
         xvbrk-vtweg NE '20'.

   LOOP AT xvbrk INTO ls_vbrk.
     LOOP AT xvbrp INTO ls_vbrp WHERE vbeln EQ ls_vbrk-vbeln.
       CLEAR lt_sip.
       lt_sip-aubel = ls_vbrp-aubel.
       COLLECT lt_sip.
     ENDLOOP.
   ENDLOOP.

   IF NOT lt_sip[] IS INITIAL.
     FREE: lt_004.
     SELECT * FROM zyb_sd_t_shp04
         INTO TABLE lt_004
        FOR ALL ENTRIES IN lt_sip
         WHERE sal_number EQ lt_sip-aubel.

     LOOP AT lt_004.
       lt_004-nakftdrm = 'C'.
       MODIFY lt_004.
     ENDLOOP.
     IF sy-subrc = 0.
       MODIFY zyb_sd_t_shp04 FROM TABLE lt_004.
     ENDIF.
   ENDIF.
 ENDIF.

 "--------->> Anıl CENGİZ 07.06.2018 14:36:17
 "YUR-28 Palet Satış Ekranı (DT:YUR-24) v.0 - Programlama
 zcl_sd_palet=>ftr_terskayit(
   EXPORTING it_xvbrk = xvbrk[] it_xvbrp = xvbrp[] ).
 "---------<<

 "--------->> Anıl CENGİZ 06.08.2018 17:41:44
 "YUR-66 Palet Faturasının Ürün Faturası İle Beraber Kesilmesi
 NEW zcl_sd_rv60afzz_nr( it_xvbrk = xvbrk[]
                         it_xvbrp = xvbrp[] )->kontroller( ).
 "---------<<
