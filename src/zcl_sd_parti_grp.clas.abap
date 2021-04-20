class ZCL_SD_PARTI_GRP definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_matnr_charg,
        matnr TYPE matnr,
        charg TYPE charg_d,
      END OF ty_matnr_charg .
  types:
    tt_matnr_charg TYPE TABLE OF ty_matnr_charg WITH DEFAULT KEY .
  types:
    BEGIN OF ty_tslmt,
        vbeln TYPE vbeln_vl,
      END OF ty_tslmt .
  types:
    tt_tslmt TYPE TABLE OF ty_tslmt WITH DEFAULT KEY .
  types:
    BEGIN OF ty_mlzblg,
        mblnr TYPE mblnr,
        mjahr TYPE mjahr,
      END OF ty_mlzblg .
  types:
    tt_mlzblg TYPE TABLE OF ty_mlzblg WITH DEFAULT KEY .
  types:
    BEGIN OF ty_constructor,
        stok_tipi TYPE char10,
        parti     TYPE tt_matnr_charg,
        tslmt     TYPE tt_tslmt,
        mlzblg    TYPE tt_mlzblg,
        svkno     TYPE zyb_sd_e_svkno,
      END OF ty_constructor .
  types:
    BEGIN OF ty_params,
        matnr TYPE matnr,
        charg TYPE charg_d,
        objek TYPE cuobn,
        cuobj TYPE cuobj,
        atinn TYPE atinn,
        atwrt TYPE atwrt,
        atflv TYPE atflv,
      END OF ty_params .
  types:
    tt_params TYPE TABLE OF ty_params WITH DEFAULT KEY .
  types:
    BEGIN OF ty_stok.
    TYPES: svkno TYPE zyb_sd_e_svkno,
           vbeln TYPE vbeln_vl,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr.
            INCLUDE TYPE zsds_parti_stok.
    TYPES END OF ty_stok .
  types:
    tt_stok TYPE HASHED TABLE OF ty_stok WITH UNIQUE KEY primary_key COMPONENTS matnr
                                                                                  charg
                                                                                  werks
                                                                                  lgort .
  types TY_KRK_LIST type ZSDT_PARTI_KRK .
  types:
    tt_krk_list TYPE TABLE OF ty_krk_list .
  types:
    BEGIN OF ty_fieldname,
        fieldname TYPE fieldname,
      END OF ty_fieldname .
  types:
    tt_fieldname TYPE STANDARD TABLE OF ty_fieldname .
  types:
    BEGIN OF ty_ref,
        name TYPE char30,
        val  TYPE REF TO data,
      END OF ty_ref .
  types:
    tt_ref TYPE STANDARD TABLE OF ty_ref WITH DEFAULT KEY .

  constants CV_KRK_LIST type CHAR30 value 'KRK_LIST'. "#EC NOTEXT
  constants CV_KRK_LIST_OLD type CHAR30 value 'KRK_LIST_OLD'. "#EC NOTEXT
  constants CV_KRK_LIST_COLLECT type CHAR30 value 'KRK_LIST_COLLECT'. "#EC NOTEXT
  constants CV_STOK type CHAR10 value 'STOK'. "#EC NOTEXT
  constants CV_MLZBLG type CHAR10 value 'MLZBLG'. "#EC NOTEXT
  constants CV_TSLMT type CHAR10 value 'TSLMT'. "#EC NOTEXT
  constants CV_SVKNO type CHAR10 value 'SVKNO'. "#EC NOTEXT
  constants CV_SVKNO_KESIN type CHAR10 value 'SVKNOKSN'. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      value(IS_CONST) type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods STOK_LISTE
    importing
      !IT_GRP_KRITER type TT_FIELDNAME
    changing
      !CR_ITAB type TT_REF
    raising
      ZCX_SD_PARTI_GRP .
protected section.
private section.

  data GV_STOK_TIPI type CHAR10 .
  data GT_PARAMS type TT_PARAMS .
  data GT_STOK type TT_STOK .
  data GR_STOK_KRK_LIST type ref to DATA .
  data GT_KRK_LIST type TT_KRK_LIST .
  data GO_STOK_KRK_LIST_DESCR type ref to CL_ABAP_STRUCTDESCR .
  data GO_STOK_DESCR type ref to CL_ABAP_STRUCTDESCR .
  data GO_PARAMS_DESCR type ref to CL_ABAP_STRUCTDESCR .
  data GR_STOK_KRK_LIST_COLLECT type ref to DATA .
  data GR_STOK_KRK_LIST_OLD type ref to DATA .

  methods GET_MLZBLG_STOK
    importing
      !IS_CONST type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods GET_TSLMT_STOK
    importing
      !IS_CONST type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods GET_SVKNO
    importing
      !IS_CONST type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods GET_SVKNO_KESIN
    importing
      !IS_CONST type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods KONTROLLER
    importing
      !IS_CONST type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
  methods STOK_GRUPLA
    importing
      !IT_GRP_KRITER type TT_FIELDNAME
    returning
      value(RR_REF) type TT_REF
    raising
      ZCX_SD_PARTI_GRP .
  methods FILL_DYNAMIC_TABLE
    raising
      ZCX_SD_PARTI_GRP .
  methods GET_MATNR
    importing
      !IS_CONST type TY_CONSTRUCTOR
    returning
      value(RT_PARAMS) type TT_PARAMS
    raising
      ZCX_SD_PARTI_GRP .
  methods CREATE_DYNAMIC_TABLE
    raising
      ZCX_SD_PARTI_GRP .
  methods GET_KRK
    importing
      !IT_PARAMS type TT_PARAMS
    returning
      value(RT_PARAMS) type TT_PARAMS
    raising
      ZCX_SD_PARTI_GRP .
  methods SET_OBJEK
    importing
      !IV_MATNR type MATNR
      !IV_CHARG type CHARG_D
    returning
      value(RV_OBJEK) type CUOBN .
  methods GET_BATCH_STOK
    importing
      value(IS_CONST) type TY_CONSTRUCTOR
    raising
      ZCX_SD_PARTI_GRP .
ENDCLASS.



CLASS ZCL_SD_PARTI_GRP IMPLEMENTATION.


METHOD constructor.

  kontroller( is_const ).

  create_dynamic_table( ).

  CASE is_const-stok_tipi.
    WHEN cv_stok.
      "Stoktan çıkmadığı durumda kullanılır.
      get_batch_stok( is_const ).
    WHEN cv_mlzblg.
      "Stoktan çıkmış malzeme belgesinin üzerinde çıktı için kullanılır.
      get_mlzblg_stok( is_const ).
    WHEN cv_tslmt.
      "Stoktan çıkmış teslimat belgesi üzerinde çıktı için kullanılır.
      get_tslmt_stok( is_const ).
    WHEN cv_svkno.
      "Sevk no (Yükleme no) üzerindeki paletlerin gruplaması için kullanılır.
      get_svkno( is_const ).
    WHEN cv_svkno_kesin.
      "Sevk no (Yükleme no) üzerinde kesin tıkı olan paletlerin gruplaması için kullanılır.
      get_svkno_kesin( is_const ).
  ENDCASE.

  fill_dynamic_table( ).

ENDMETHOD.


METHOD create_dynamic_table.

  DATA: lt_components     TYPE abap_component_tab,
        lo_stok_key_descr TYPE REF TO cl_abap_structdescr,
        lv_tabfield       TYPE string,
        ls_comp           TYPE abap_componentdescr,
        ls_krk            TYPE zsdt_parti_krk.

  lo_stok_key_descr ?= cl_abap_structdescr=>describe_by_name( 'ZSDS_PARTI_STOK'  ).
  DATA(lv_tabnam)    = lo_stok_key_descr->get_relative_name( ).

  LOOP AT lo_stok_key_descr->components ASSIGNING FIELD-SYMBOL(<ls_components>).

    CONCATENATE lv_tabnam <ls_components>-name INTO lv_tabfield
                                               SEPARATED BY '-'.

    ls_comp-type ?= cl_abap_datadescr=>describe_by_name( lv_tabfield ).
    ls_comp-name  = <ls_components>-name.
    APPEND ls_comp TO lt_components.
    CLEAR: ls_comp.
  ENDLOOP.

  CASE gv_stok_tipi.
    WHEN cv_mlzblg.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( 'MSEG-MBLNR' ).
      ls_comp-name  = 'MBLNR'.
      APPEND ls_comp TO lt_components.
      CLEAR: ls_comp.

      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( 'MSEG-MJAHR' ).
      ls_comp-name  = 'MJAHR'.
      APPEND ls_comp TO lt_components.
      CLEAR: ls_comp.
    WHEN cv_tslmt.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( 'LIKP-VBELN' ).
      ls_comp-name  = 'VBELN'.
      APPEND ls_comp TO lt_components.
      CLEAR: ls_comp.
  ENDCASE.

  DATA(go_str) = cl_abap_structdescr=>create( lt_components ).
  DATA(go_table) = cl_abap_tabledescr=>create( go_str ).
  CREATE DATA gr_stok_krk_list TYPE HANDLE go_table.
  CREATE DATA gr_stok_krk_list_old TYPE HANDLE go_table.
  CREATE DATA gr_stok_krk_list_collect TYPE HANDLE go_table.

ENDMETHOD.


METHOD fill_dynamic_table.

  FIELD-SYMBOLS: <gt_krk_list> TYPE STANDARD TABLE.

  DATA: ev_date        TYPE cawn-atwrt,
        "--------->> Anıl CENGİZ 14.07.2020 10:50:32
        "YUR-687
        lv_matnr       TYPE matnr,
        lv_qty         TYPE menge_d,
        lv_kutsay      TYPE menge_d,
        lv_mvgr2       TYPE mvgr2,
        lv_kunnr_kutus TYPE abap_bool,
        lv_meins       TYPE meins.
  "---------<<

  ASSIGN gr_stok_krk_list->* TO <gt_krk_list>.

  "her bir stok satırı için doldurma yapılır.
  LOOP AT gt_stok ASSIGNING FIELD-SYMBOL(<ls_stok>).

    IF go_stok_descr IS NOT BOUND.
      go_stok_descr ?= cl_abap_structdescr=>describe_by_data( <ls_stok> ).
    ENDIF.
    "Stok kalemi bazında karakteristikler eklenir.
    APPEND INITIAL LINE TO <gt_krk_list> ASSIGNING FIELD-SYMBOL(<ls_krk_list>).
    IF go_stok_krk_list_descr IS NOT BOUND.
      go_stok_krk_list_descr ?= cl_abap_structdescr=>describe_by_data( <ls_krk_list> ).
    ENDIF.

    "Önce karakteristikleri doldur.
    CLEAR: lv_mvgr2.
    LOOP AT gt_params ASSIGNING FIELD-SYMBOL(<ls_params>)
      WHERE matnr EQ <ls_stok>-matnr
        AND charg EQ <ls_stok>-charg.

      IF go_params_descr IS NOT BOUND.
        go_params_descr ?= cl_abap_structdescr=>describe_by_data( <ls_params> ).
      ENDIF.

      ASSIGN gt_krk_list[ atinn = <ls_params>-atinn ] TO FIELD-SYMBOL(<gs_krk_list>).

      LOOP AT go_params_descr->components ASSIGNING FIELD-SYMBOL(<ls_params_components>).
        LOOP AT go_stok_krk_list_descr->components ASSIGNING FIELD-SYMBOL(<ls_krk_list_components>)
           WHERE name EQ <gs_krk_list>-atnam.

          ASSIGN COMPONENT <ls_krk_list_components>-name
            OF STRUCTURE <ls_krk_list> TO FIELD-SYMBOL(<lv_krk_val>).

          CASE <ls_krk_list_components>-type_kind.
            WHEN 'C'.
              ASSIGN COMPONENT 'ATWRT'
                OF STRUCTURE <ls_params> TO FIELD-SYMBOL(<lv_params_val>).
              <lv_krk_val> =  <lv_params_val> .

              IF <ls_krk_list_components>-name = 'KUTU_TIPI'.
                lv_mvgr2 = <lv_krk_val>.
              ENDIF.

            WHEN 'D'.
              ASSIGN COMPONENT 'ATFLV'
                OF STRUCTURE <ls_params> TO <lv_params_val>.

              CALL FUNCTION 'CTCV_CONVERT_FLOAT_TO_DATE'
                EXPORTING
                  float = <lv_params_val>
                IMPORTING
                  date  = ev_date.

              <lv_krk_val> = ev_date.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    "Sonra stoklar doldur.
    CLEAR: lv_matnr, lv_qty.
    LOOP AT go_stok_descr->components ASSIGNING FIELD-SYMBOL(<ls_stok_components>).

      ASSIGN gt_krk_list[ atnam = <ls_stok_components>-name ] TO <gs_krk_list>.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.

      LOOP AT go_stok_krk_list_descr->components ASSIGNING <ls_krk_list_components>
          WHERE name EQ <ls_stok_components>-name.

        ASSIGN COMPONENT <ls_stok_components>-name OF STRUCTURE <ls_stok>
          TO FIELD-SYMBOL(<lv_stok_val>).

        ASSIGN COMPONENT <ls_krk_list_components>-name OF STRUCTURE <ls_krk_list>
          TO <lv_krk_val>.

        <lv_krk_val> = <lv_stok_val>.

        IF <ls_stok_components>-name = 'PLT_SAYI'. "Palet sayısı için her parti bir palet olarak kabul edilmiştir.
          <lv_krk_val> = 1.
        ENDIF.
        "--------->> Anıl CENGİZ 14.07.2020 10:34:50
        "YUR-687
        "Kutu sayısını bulmak için fonksiyona verilecek parametre değişkenleri bulunur.
        IF <ls_stok_components>-name = 'CLABS'.
          lv_qty = <lv_stok_val>.
        ENDIF.

        IF <ls_stok_components>-name = 'MATNR'.
          lv_matnr = <lv_stok_val>.
        ENDIF.

        IMPORT lv_kunnr_kutus = lv_kunnr_kutus FROM MEMORY ID zcl_sd_irsaliye_ciktisi=>cv_memid_kutus.
        "---------<<
        IF <ls_stok_components>-name = 'KUT_SAYI'. "Kutu sayısı her partinin miktarına göre bulunmuştur.
          "--------->> Anıl CENGİZ 21.09.2020 11:19:23
          "YUR-728
          CHECK: lv_mvgr2 NE '999', "Kutu tipi belli olmayanlar için hesaplama yapılmaz.
                 lv_matnr NS '.0',  "Iskarta ürünler için hesaplama yapılmaz.
                 lv_kunnr_kutus EQ abap_true. "Sadece kutu sayısı isteyen müşteriler için hesaplama yapılır.

          lv_meins = 'KUT'.
          IF lv_mvgr2 IS INITIAL AND <ls_stok>-meins EQ 'ST'.
            lv_meins = <ls_stok>-meins.
          ENDIF.
          "---------<<
          CALL FUNCTION 'ZYB_SD_F_CONVERT_TO_ALT_UOM'
            EXPORTING
              p_alt_uom                = lv_meins
              p_uom_qty                = lv_qty
              p_matnr                  = lv_matnr
              p_mvgr2                  = lv_mvgr2
            IMPORTING
              ep_alt_qty               = lv_kutsay
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
            DATA(lo_msg) = cf_reca_message_list=>create( ).

            lo_msg->add( id_msgty  = sy-msgty
                         id_msgid  = sy-msgid
                         id_msgno  = sy-msgno
                         id_msgv1  = sy-msgv1
                         id_msgv2  = sy-msgv2
                         id_msgv3  = sy-msgv3
                         id_msgv4  = sy-msgv4 ).

            RAISE RESUMABLE EXCEPTION TYPE zcx_sd_parti_grp
              EXPORTING
                messages = lo_msg.
          ENDIF.
          <lv_krk_val> = lv_kutsay.
        ENDIF.
        "---------<<
      ENDLOOP.
    ENDLOOP.

  ENDLOOP.

ENDMETHOD.


METHOD get_batch_stok.

  DELETE is_const-parti WHERE charg IS INITIAL.

  DATA(rt_params) = get_matnr( is_const ).

  gt_params = get_krk( VALUE #( FOR wa IN rt_params
                                        ( matnr = wa-matnr
                                          charg = wa-charg
                                          objek = |{ set_objek( EXPORTING iv_matnr = wa-matnr iv_charg = wa-charg ) }| ) ) ) .
  CHECK: gt_params IS NOT INITIAL.

  DELETE ADJACENT DUPLICATES FROM gt_params COMPARING matnr charg.

  SELECT mchb~matnr mchb~charg mchb~werks mchb~lgort mchb~clabs mara~meins
    FROM mchb
    INNER JOIN mara ON mara~matnr = mchb~matnr
    INTO CORRESPONDING FIELDS OF TABLE gt_stok
    FOR ALL ENTRIES IN gt_params
    WHERE mchb~matnr EQ gt_params-matnr
      AND mchb~charg EQ gt_params-charg
      AND mchb~clabs NE 0.

ENDMETHOD.


METHOD get_krk.

  DATA: lt_params TYPE tt_params.

  CHECK: it_params IS NOT INITIAL.

  SELECT inob~cuobj inob~objek ausp~atinn ausp~atwrt ausp~atflv
    FROM inob
    INNER JOIN ausp ON ausp~objek = inob~cuobj
    INTO CORRESPONDING FIELDS OF TABLE lt_params
    FOR ALL ENTRIES IN it_params
    WHERE inob~klart EQ '023'
      AND inob~obtab EQ 'MCH1'
      AND inob~objek EQ it_params-objek
*      AND ausp~atzhl EQ '1' "MSC2N den değiştirdiğimizde sayaç artıyor ama tek o sayaç kaldığı için yani örneğin 1 numaralı kayıt tablodan siliniyor. Yıldızlandı
      AND ausp~mafid EQ 'O'
      AND ausp~klart EQ '023'
      AND ausp~adzhl EQ ' '
      AND EXISTS ( SELECT mandt FROM zsdt_parti_krk WHERE atinn = ausp~atinn ).

  rt_params = VALUE #( FOR wa IN lt_params (
                         matnr = wa-objek+0(18)
                         charg = wa-objek+18(10)
                         objek = wa-objek
                         cuobj = wa-cuobj
                         atinn = wa-atinn
                         atwrt = wa-atwrt
                         atflv = wa-atflv ) ).

ENDMETHOD.


METHOD get_matnr.

  DATA: lt_mch1  TYPE tt_stok.

  CHECK: is_const IS NOT INITIAL.

  DATA(lt_const) = VALUE ty_constructor( stok_tipi = is_const-stok_tipi parti = VALUE #( FOR wa IN is_const-parti WHERE ( matnr = ' ' )
                                                                                                                        ( CORRESPONDING #( wa ) ) ) ).
  IF lt_const IS NOT INITIAL."Malzeme numarası olmayanlara malzeme no ataması yapılır.
    SELECT DISTINCT matnr charg
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE lt_mch1
      FOR ALL ENTRIES IN lt_const-parti
      WHERE charg EQ lt_const-parti-charg.
  ENDIF.

  LOOP AT is_const-parti ASSIGNING FIELD-SYMBOL(<ls_const>).
    APPEND INITIAL LINE TO rt_params ASSIGNING FIELD-SYMBOL(<ls_params>).
    MOVE-CORRESPONDING <ls_const> TO <ls_params>.
    ASSIGN lt_mch1[ charg = <ls_const>-charg ] TO FIELD-SYMBOL(<ls_mch1>).
    IF <ls_mch1> IS ASSIGNED AND <ls_const>-matnr IS INITIAL.
      <ls_params>-matnr = <ls_mch1>-matnr.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD get_mlzblg_stok.

  CHECK: is_const-mlzblg IS NOT INITIAL.

  SELECT mblnr mjahr matnr charg werks lgort menge AS clabs meins
    FROM mseg
    INTO CORRESPONDING FIELDS OF TABLE gt_stok
    FOR ALL ENTRIES IN is_const-mlzblg
    WHERE mblnr EQ is_const-mlzblg-mblnr
      AND mjahr EQ is_const-mlzblg-mjahr.

  DELETE ADJACENT DUPLICATES FROM gt_stok COMPARING charg.

  gt_params = get_krk( VALUE #( FOR wa IN gt_stok
                                        ( matnr = wa-matnr
                                          charg = wa-charg
                                          objek = |{ set_objek( EXPORTING iv_matnr = wa-matnr iv_charg = wa-charg ) }| ) ) ) .

ENDMETHOD.


METHOD get_svkno.

  CHECK: is_const-svkno IS NOT INITIAL.

  SELECT matnr charg
    FROM zyb_sd_t_shp02
    INTO TABLE gt_stok
      WHERE loekz EQ abap_false
        AND svkno EQ is_const-svkno.
  IF sy-subrc EQ 0.
    gt_params = get_krk( VALUE #( FOR wa IN gt_stok
                                          ( matnr = wa-matnr
                                            charg = wa-charg
                                            objek = |{ set_objek( EXPORTING iv_matnr = wa-matnr iv_charg = wa-charg ) }| ) ) ) .
  ELSE.
    RAISE EXCEPTION TYPE zcx_sd_parti_grp
      EXPORTING
        textid = zcx_sd_parti_grp=>zsd_044
        svkno  = is_const-svkno.
  ENDIF.

ENDMETHOD.


METHOD get_svkno_kesin.

  CHECK: is_const-svkno IS NOT INITIAL.

  SELECT svkno matnr charg
    FROM zyb_sd_t_shp02
    INTO CORRESPONDING FIELDS OF TABLE gt_stok
      WHERE loekz EQ abap_false
        AND kesin EQ abap_true
        AND svkno EQ is_const-svkno.
  CHECK sy-subrc EQ 0.
  gt_params = get_krk( VALUE #( FOR wa IN gt_stok
                                        ( matnr = wa-matnr
                                          charg = wa-charg
                                          objek = |{ set_objek( EXPORTING iv_matnr = wa-matnr iv_charg = wa-charg ) }| ) ) ) .

ENDMETHOD.


METHOD get_tslmt_stok.

  CHECK: is_const-tslmt IS NOT INITIAL.

  SELECT vbeln matnr charg werks lgort lgmng AS clabs meins
    FROM lips
    INTO CORRESPONDING FIELDS OF TABLE gt_stok
    FOR ALL ENTRIES IN is_const-tslmt
    WHERE vbeln EQ is_const-tslmt-vbeln
      AND charg NE space.
  IF sy-subrc EQ 0.
    gt_params = get_krk( VALUE #( FOR wa IN gt_stok
                                          ( matnr = wa-matnr
                                            charg = wa-charg
                                            objek = |{ set_objek( EXPORTING iv_matnr = wa-matnr iv_charg = wa-charg ) }| ) ) ) .
  ELSE.
    RAISE EXCEPTION TYPE zcx_sd_parti_grp
      EXPORTING
        textid = zcx_sd_parti_grp=>zsd_043.
  ENDIF.

ENDMETHOD.


METHOD kontroller.

  CASE is_const-stok_tipi.
    WHEN space .
      RAISE EXCEPTION TYPE zcx_sd_parti_grp
        EXPORTING
          textid = zcx_sd_parti_grp=>zsd_041.
    WHEN cv_stok.
      IF is_const-parti IS INITIAL.
        RAISE EXCEPTION TYPE zcx_sd_parti_grp
          EXPORTING
            textid    = zcx_sd_parti_grp=>zsd_038
            stok_tipi = cv_stok.
      ENDIF.
    WHEN cv_mlzblg.
      IF is_const-mlzblg IS INITIAL.
        RAISE EXCEPTION TYPE zcx_sd_parti_grp
          EXPORTING
            textid    = zcx_sd_parti_grp=>zsd_039
            stok_tipi = cv_mlzblg.
      ENDIF.
    WHEN cv_tslmt.
      IF is_const-tslmt IS INITIAL.
        RAISE EXCEPTION TYPE zcx_sd_parti_grp
          EXPORTING
            textid    = zcx_sd_parti_grp=>zsd_040
            stok_tipi = cv_tslmt.
      ENDIF.
    WHEN cv_svkno.
      IF is_const-svkno IS INITIAL.
        RAISE EXCEPTION TYPE zcx_sd_parti_grp
          EXPORTING
            textid    = zcx_sd_parti_grp=>zsd_040
            stok_tipi = cv_svkno.
      ENDIF.
    WHEN cv_svkno_kesin.
      IF is_const-svkno IS INITIAL.
        RAISE EXCEPTION TYPE zcx_sd_parti_grp
          EXPORTING
            textid    = zcx_sd_parti_grp=>zsd_040
            stok_tipi = cv_svkno_kesin.
      ENDIF.
    WHEN OTHERS.
      RAISE EXCEPTION TYPE zcx_sd_parti_grp
        EXPORTING
          textid = zcx_sd_parti_grp=>zsd_041.
  ENDCASE.

  "Hata yok ise global değişkenler doldurulur.
  gv_stok_tipi = is_const-stok_tipi.

  SELECT *
  FROM zsdt_parti_krk "Bu tablo niye var. Boşu boşuna gereksiz karakteristikleri veritabanından okumayalım diye var. Yeni bir kayıt eklendiğinde ZSDS_PARTI_STOK_FLD structure da ekleme yapılmalıdır.
  INTO TABLE gt_krk_list.

ENDMETHOD.


METHOD SET_OBJEK.

  CONCATENATE iv_matnr iv_charg INTO rv_objek RESPECTING BLANKS.

ENDMETHOD.


METHOD stok_grupla.

  FIELD-SYMBOLS: <gt_krk_list>         TYPE STANDARD TABLE,
                 <gt_krk_list_old>     TYPE STANDARD TABLE,
                 <gt_krk_list_collect> TYPE STANDARD TABLE.

  ASSIGN gr_stok_krk_list->*         TO <gt_krk_list>.
  ASSIGN gr_stok_krk_list_old->*     TO <gt_krk_list_old>.
  ASSIGN gr_stok_krk_list_collect->* TO <gt_krk_list_collect>.

  CHECK: <gt_krk_list> IS NOT INITIAL.

  LOOP AT <gt_krk_list> ASSIGNING FIELD-SYMBOL(<ls_krk_list>).
    APPEND <ls_krk_list> TO <gt_krk_list_old>.
    LOOP AT go_stok_krk_list_descr->components ASSIGNING FIELD-SYMBOL(<ls_stok_krk_list_descr>)
      WHERE name NE 'MATNR'
        AND name NE 'CLABS'
        AND name NE 'PLT_SAYI'
        AND name NE 'KUT_SAYI'
        AND name NE 'MEINS'.
      ASSIGN it_grp_kriter[ fieldname = <ls_stok_krk_list_descr>-name ] TO FIELD-SYMBOL(<ls_grp_kriter>).
      IF <ls_grp_kriter> IS NOT ASSIGNED.
        ASSIGN COMPONENT <ls_stok_krk_list_descr>-name OF STRUCTURE <ls_krk_list>
          TO FIELD-SYMBOL(<lv_krk_list_val>).
        CLEAR: <lv_krk_list_val>.
      ENDIF.
      UNASSIGN: <ls_grp_kriter>.
    ENDLOOP.

    COLLECT <ls_krk_list> INTO <gt_krk_list_collect>.

  ENDLOOP.

  rr_ref = VALUE #( ( name = cv_krk_list         val = REF #( <gt_krk_list> ) )
                    ( name = cv_krk_list_old     val = REF #( <gt_krk_list_old> ) )
                    ( name = cv_krk_list_collect val = REF #( <gt_krk_list_collect> ) ) ).

ENDMETHOD.


METHOD stok_liste.

  FIELD-SYMBOLS: <lt_itab_val> TYPE STANDARD TABLE,
                 <lt_ref_val>  TYPE STANDARD TABLE.

  DATA: rr_ref             TYPE tt_ref,
        lr_itab_descr      TYPE REF TO cl_abap_tabledescr,
        lr_itab_comp_descr TYPE REF TO cl_abap_structdescr,
        lr_ref_descr       TYPE REF TO cl_abap_tabledescr,
        lr_ref_comp_descr  TYPE REF TO cl_abap_structdescr.

  CHECK: cr_itab IS NOT INITIAL.

  CALL METHOD me->stok_grupla
    EXPORTING
      it_grp_kriter = it_grp_kriter
    RECEIVING
      rr_ref        = rr_ref.

  LOOP AT cr_itab ASSIGNING FIELD-SYMBOL(<lt_itab>). "Amaç bize referans nasıl bir tablo geliyosa o tabloyu doldurmaktır. Bu sınıf içinde verilerin manüplasyonu yapılmaz.

    ASSIGN <lt_itab>-val->* TO <lt_itab_val>.

    lr_itab_descr ?=  cl_abap_tabledescr=>describe_by_data_ref( <lt_itab>-val ).
    lr_itab_comp_descr ?= lr_itab_descr->get_table_line_type( ).

    LOOP AT rr_ref ASSIGNING FIELD-SYMBOL(<lt_ref>)
     WHERE name = <lt_itab>-name.

      ASSIGN <lt_ref>-val->* TO <lt_ref_val>.

      lr_ref_descr ?=  cl_abap_tabledescr=>describe_by_data_ref( <lt_ref>-val ).
      lr_ref_comp_descr ?= lr_itab_descr->get_table_line_type( ).


      LOOP AT <lt_ref_val> ASSIGNING FIELD-SYMBOL(<ls_ref_val>).
        APPEND INITIAL LINE TO <lt_itab_val> ASSIGNING FIELD-SYMBOL(<ls_table_val>).

        LOOP AT lr_ref_comp_descr->components REFERENCE INTO DATA(lr_ref_components).
          LOOP AT lr_itab_comp_descr->components REFERENCE INTO DATA(lr_itab_components)
            WHERE name EQ lr_ref_components->name.

            ASSIGN COMPONENT lr_ref_components->name OF STRUCTURE <ls_ref_val>
              TO FIELD-SYMBOL(<lv_ref_val>).

            ASSIGN COMPONENT lr_ref_components->name OF STRUCTURE <ls_table_val>
              TO FIELD-SYMBOL(<lv_table_val>).

            <lv_table_val> = <lv_ref_val>.

          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
