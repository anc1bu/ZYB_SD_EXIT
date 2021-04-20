FUNCTION zyb_sd_f_kmp_find.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG
*"     VALUE(I_VTWEG) TYPE  VTWEG
*"     VALUE(I_KUNNR) TYPE  KUNNR OPTIONAL
*"     VALUE(I_DATE) TYPE  DATUM DEFAULT SY-DATUM
*"     VALUE(I_HELP) TYPE  XFELD OPTIONAL
*"     VALUE(I_AUART) TYPE  AUART OPTIONAL
*"  EXPORTING
*"     REFERENCE(KMPLIST) TYPE  ZYB_SD_TY_KMPLIST
*"  EXCEPTIONS
*"      NOT_FOUND
*"      FORMAT_ERROR
*"----------------------------------------------------------------------
  DATA: retcode LIKE sy-subrc.
  "--------->> Anıl CENGİZ 10.08.2020 12:38:53
  "YUR-706
*    IF i_kunnr IS INITIAL.
  IF i_kunnr IS INITIAL AND i_help EQ abap_false.
    "---------<<
    MESSAGE s899(fb) WITH 'Müşteri Bulunamadı!' DISPLAY LIKE 'E' RAISING format_error.
  ENDIF.

  CLEAR: kmplist, kmplist[].
  PERFORM clear_table.

  wa_list-vkorg    = i_vkorg.
  wa_list-kunnr    = i_kunnr.
  wa_list-date     = i_date.
  IF i_vtweg IS INITIAL.
    wa_list-vtweg    = '10'.
    APPEND  wa_list TO tb_list.
    "--------->> Anıl CENGİZ 10.08.2020 12:38:53
    "YUR-706
*    wa_list-vtweg    = '30'.
*    APPEND  wa_list TO tb_list.
    "---------<<
  ELSE.
    wa_list-vtweg = i_vtweg.
    APPEND  wa_list TO tb_list.
  ENDIF.
*  CLEAR wa_list.

**  PERFORM promosyon_tur_bul.
*  PERFORM read_condition_record.
*
*  IF it_901[] IS INITIAL.
*    RAISE not_found.
*  ENDIF.
  IF i_help IS INITIAL.
    PERFORM read_akkp.
  ENDIF.
  PERFORM read_kona.

  " Kampanya ZP04 koşu üzerinden belirlenmeyecek. Bunun yerine mali belge kullanılacak.
*------------->
*  LOOP AT it_901.
  IF it_akkp[] IS NOT INITIAL.
    LOOP AT it_akkp.
      IF it_akkp-zzknuma IS NOT INITIAL.
        CLEAR: wa_kmplist, retcode.
* kampanya bilgileri aliniyor.
        PERFORM set_values USING it_akkp it_kona i_auart"it_901
                           CHANGING wa_kmplist
                                    retcode.
        IF  retcode = 0 OR ( i_help IS NOT INITIAL AND retcode NE 1 ).
          APPEND wa_kmplist TO kmplist.
        ENDIF.
      ELSE.
        LOOP AT it_kona.
          PERFORM set_values USING it_akkp it_kona i_auart "it_901
                             CHANGING wa_kmplist
                                      retcode.
          IF  retcode = 0 OR ( i_help IS NOT INITIAL AND retcode NE 1 ).
            APPEND wa_kmplist TO kmplist.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT it_kona.
      PERFORM set_values USING it_akkp it_kona i_auart"it_901
                         CHANGING wa_kmplist
                                  retcode.
      IF  retcode = 0 OR ( i_help IS NOT INITIAL AND retcode NE 1 ).
        APPEND wa_kmplist TO kmplist.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  ENDLOOP.
*<-----------
*  IF kmplist[] IS INITIAL.
*    MESSAGE s899(fb) WITH 'Kampanya Bulunamadı!' DISPLAY LIKE 'E' RAISING not_found.
*  ENDIF.
ENDFUNCTION.
