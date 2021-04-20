class ZCL_SD_EXIT_SMOD_RVEXAKK1_001 definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC_EXIT_IMP .
  interfaces ZIF_SD_EXIT_SMOD_RVEXAKK1 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_EXIT_SMOD_RVEXAKK1_001 IMPLEMENTATION.


METHOD zif_bc_exit_imp~execute.

  "Bu sınıfın tamamı refactor edilmelidir. YUR-706 ile kodlar sadece exit alt yapısına alınmıştır.

  FIELD-SYMBOLS: <gs_xakkp> TYPE akkpvb.

  DATA: lr_data          TYPE REF TO data,
        ls_akkp          TYPE akkp,
        tb_kc001         TYPE TABLE OF zyb_sd_t_kc001,
        lt_cek           TYPE TABLE OF zyb_fi_cekdurum,
        ls_cek           TYPE zyb_fi_cekdurum,
        lt_ret           TYPE TABLE OF bapiret2,
        gv_txt           TYPE bezei40,
        ls_kona          TYPE kona,
        lv_wrbtr         TYPE wrbtr,
        lv_wrbtr_txt(15) TYPE c,
        lv_lcnum         TYPE vbkd-lcnum.

  CONSTANTS: gc_ret   TYPE icon_d VALUE '@02@',
             gc_erase TYPE sy-ucomm VALUE 'GELO'.

  lr_data = co_con->get_vars( 'XAKKP' ). ASSIGN lr_data->* TO <gs_xakkp>.

  "VX14N de XAKKP değişkeni tam olarak dolmadığı için LS_AKKP ye çevrilmiştir.
                                                            "20150907
  IF NOT <gs_xakkp>-lcnum IS INITIAL.
    CLEAR ls_akkp.
    SELECT SINGLE * FROM akkp INTO ls_akkp
      WHERE lcnum = <gs_xakkp>-lcnum.
    "--------->> Anıl CENGİZ 26.06.2019 10:38:47
    "YUR-422
    IF sy-subrc IS INITIAL AND ls_akkp-zzknuma IS INITIAL.
**   IF xakkp-zzknuma IS INITIAL.
*    CLEAR lv_lcnum.
*    SELECT SINGLE vbkd~lcnum FROM vbkd
*      INNER JOIN vbap ON vbap~vbeln EQ vbkd~vbeln
*      INTO lv_lcnum
*      WHERE vbkd~lcnum EQ ls_akkp-lcnum
*      AND vbap~abgru EQ space.
*    IF NOT lv_lcnum IS INITIAL.
*      MESSAGE e021(zyb_sd) DISPLAY LIKE 'I'.
*    ENDIF.
    ELSE.
      "---------<<
      IF sy-ucomm NE gc_erase.
        CLEAR ls_kona.
        SELECT SINGLE * FROM kona
          INTO ls_kona
          WHERE knuma EQ ls_akkp-zzknuma.
        IF sy-subrc = 0.
          IF NOT ls_kona-kfrst IS INITIAL .
            MESSAGE e024(zyb_sd) DISPLAY LIKE 'I'.
          ELSE.
            CASE ls_kona-boart.
              WHEN 'ZY01' OR 'ZY04'.
                IF ls_akkp-akart NE 'Z1'. " Çek Kampanyası
                  CLEAR gv_txt.
                  CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                  SEPARATED BY space.
                  MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
                ENDIF.
              WHEN 'ZY02'.
                IF ls_akkp-akart NE 'Z2'. " Kredi Kartı Kampanyası
                  CLEAR gv_txt.
                  CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                  SEPARATED BY space.
                  MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
                ENDIF.
              WHEN 'ZY03'.
                IF ls_akkp-akart NE 'Z3'. " Banka Havalesi Kampanyası
                  CLEAR gv_txt.
                  CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                  SEPARATED BY space.
                  MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
                ENDIF.
              WHEN 'ZY07'.
                IF ls_akkp-akart NE 'Z4'. " Palet Kampanyası
                  CLEAR gv_txt.
                  CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                  SEPARATED BY space.
                  MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
                ENDIF.
                "--------->> Anıl CENGİZ 10.08.2020 12:51:37
                "YUR-706
              WHEN 'ZY08'.
                IF ls_akkp-akart NE 'Z5'. " Palet Kampanyası
                  CLEAR gv_txt.
                  CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                  SEPARATED BY space.
                  MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
                ENDIF.
                "---------<<
              WHEN OTHERS.
                CLEAR gv_txt.
                CONCATENATE 'Kampanya Türü: ' ls_kona-boart INTO gv_txt
                SEPARATED BY space.
                MESSAGE e022(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
            ENDCASE.
          ENDIF.
        ELSE.
          MESSAGE e023(zyb_sd) DISPLAY LIKE 'I'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Mali belge kullanılabilirlik kontrolü
  CLEAR: tb_kc001, tb_kc001[].
  IF <gs_xakkp>-akkst EQ '' AND sy-ucomm EQ 'SICH' OR sy-ucomm EQ 'BACK'.

    CLEAR ls_akkp.
    SELECT SINGLE * FROM akkp
        INTO ls_akkp
       WHERE zzknuma EQ <gs_xakkp>-zzknuma
         AND lcnum   NE <gs_xakkp>-lcnum
         AND kunnr   EQ <gs_xakkp>-kunnr
         AND akkst   EQ 'D'.

    IF <gs_xakkp>-zzknuma IS NOT INITIAL
       AND ls_akkp-lcnum IS NOT INITIAL.
      MESSAGE e020(zyb_sd) WITH <gs_xakkp>-zzknuma ls_akkp-lcnum
          DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.

  IF <gs_xakkp>-akkst EQ 'D'
     AND <gs_xakkp>-updkz NE 'D'
     AND sy-ucomm EQ 'SICH'.
*"--------->> Anıl CENGİZ 10.08.2020 12:03:28
*"YUR-706
*    AND <gs_xakkp>-akart NE 'Z5'.
*    "---------<<
**********************************************************************
*& --> begin ticari promosyon no kontrolü
**********************************************************************
    IF <gs_xakkp>-lcnum IS INITIAL.
      MESSAGE e018(zyb_sd) DISPLAY LIKE 'I'.
    ENDIF.

    IF <gs_xakkp>-zzknuma IS INITIAL.
      MESSAGE e019(zyb_sd) DISPLAY LIKE 'I'.
    ENDIF.
    CLEAR ls_akkp.
    SELECT SINGLE * FROM akkp
        INTO ls_akkp
       WHERE zzknuma EQ <gs_xakkp>-zzknuma
         AND lcnum   NE <gs_xakkp>-lcnum
         AND kunnr   EQ <gs_xakkp>-kunnr
         AND akkst   EQ 'D'.

    IF NOT ls_akkp IS INITIAL.
      MESSAGE e020(zyb_sd) WITH <gs_xakkp>-zzknuma ls_akkp-lcnum
          DISPLAY LIKE 'I'.
    ENDIF.
***********************************************************************
*& <-- end ticari promosyon no kontrolü
**********************************************************************

    SELECT *  FROM zyb_sd_t_kc001
        INTO TABLE tb_kc001
       WHERE knuma_ag EQ <gs_xakkp>-zzknuma
         AND lcnum    EQ <gs_xakkp>-lcnum
         AND loekz    EQ space.

**********************************************************************
*& --> beg Kampanya Para birimi ve mali belge para birimi karşılaştırılması
**********************************************************************
    IF ls_kona-waers NE <gs_xakkp>-waers.
      CLEAR gv_txt.
      CONCATENATE 'Kampanya Para Birimi :' ls_kona-waers INTO gv_txt
            SEPARATED BY space.
      MESSAGE e025(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.
    ENDIF.
***********************************************************************
*& <-- end Kampanya Para birimi ve mali belge para birimi karşılaştırılması
**********************************************************************

**********************************************************************
*& --> beg Çek para birimi ve mali belge para birimi karşılaştırılması
**********************************************************************
    IF NOT tb_kc001[] IS INITIAL .
      LOOP AT tb_kc001 TRANSPORTING NO FIELDS
        WHERE waers NE <gs_xakkp>-waers.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        CLEAR gv_txt.
        CONCATENATE 'Para Birimi:' <gs_xakkp>-waers 'olmalı' INTO gv_txt
              SEPARATED BY space.
        MESSAGE e009(zy_sd) WITH gv_txt DISPLAY LIKE 'I'.
      ENDIF.
    ENDIF.
**********************************************************************
*& <-- end Çek para birimi ve mali belge para birimi karşılaştırılması
**********************************************************************
**********************************************************************
*& --> begin Mali belge tutarı ile çek tutarı karşılaştırması
**********************************************************************
* tahsil edilmiş çeklerin durumları kontrol edilmiyor.
    FREE: lt_cek, lt_ret.
* sadece Çek belge türü için tutar kontrol edilir.
    IF <gs_xakkp>-akart EQ 'Z1'.
      LOOP AT tb_kc001 REFERENCE INTO DATA(lr_kc001)
        WHERE ( blart NE 'C4' AND blart NE 'C5')." AND
        "belnr IS NOT INITIAL.
        CLEAR ls_cek.
        ls_cek-bukrs    = lr_kc001->bukrs.
        ls_cek-gjahr    = lr_kc001->gjahr.
        ls_cek-portfo   = lr_kc001->portfo.
        ls_cek-boeno    = lr_kc001->boeno.
        ls_cek-bank     = lr_kc001->bank.
        ls_cek-accou    = lr_kc001->accou.
        ls_cek-knuma_ag = lr_kc001->knuma_ag.
        ls_cek-lcnum    = lr_kc001->lcnum.
        APPEND ls_cek TO lt_cek.
      ENDLOOP.
      IF lt_cek IS NOT INITIAL.
        CALL FUNCTION 'ZYB_FI_F_CSDURUM'
          TABLES
            t_cek    = lt_cek
            t_return = lt_ret.
        " iptal edilmiş çekler karşılaştırmaya dahil edilmez.
        LOOP AT lt_cek REFERENCE INTO DATA(lr_cek)
          WHERE icon EQ gc_ret.
          DELETE tb_kc001 WHERE knuma_ag EQ lr_cek->knuma_ag
                            AND lcnum    EQ lr_cek->lcnum
                            AND boeno    EQ lr_cek->boeno.
        ENDLOOP.
      ENDIF.

      CLEAR lv_wrbtr.
      LOOP AT tb_kc001 REFERENCE INTO lr_kc001.
        lv_wrbtr = lv_wrbtr + lr_kc001->wrbtr.
      ENDLOOP.

      IF lv_wrbtr NE <gs_xakkp>-wrtak.
        CLEAR gv_txt.
        WRITE lv_wrbtr TO lv_wrbtr_txt. CONDENSE lv_wrbtr_txt.
        CONCATENATE 'Çek Tutarı: ' lv_wrbtr_txt <gs_xakkp>-waers INTO gv_txt
            SEPARATED BY space.
        MESSAGE e013(zyb_sd) WITH gv_txt DISPLAY LIKE 'I'.

      ENDIF.
    ENDIF.
**********************************************************************
*& <-- end Mali belge tutarı ile çek tutarı karşılaştırması
**********************************************************************
  ENDIF.

ENDMETHOD.
ENDCLASS.
