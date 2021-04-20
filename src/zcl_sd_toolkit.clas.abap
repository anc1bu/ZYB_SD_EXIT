class ZCL_SD_TOOLKIT definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_mtart,
        matnr TYPE matnr,
        mtart TYPE mtart,
        mtbez TYPE mtbez,
      END OF ty_mtart .
  types:
    tth_mtart TYPE HASHED TABLE OF ty_mtart WITH UNIQUE KEY matnr .
  types:
    BEGIN OF ty_maktx,
        matnr TYPE matnr,
        maktx TYPE maktx,
      END OF ty_maktx .
  types:
    tt_maktx   TYPE HASHED TABLE OF ty_maktx WITH UNIQUE KEY matnr .
  types:
    trng_vkorg TYPE RANGE OF vkorg .
  types:
    trng_vtweg TYPE RANGE OF vtweg .
  types:
    BEGIN OF ty_select,
        it_vkorg       TYPE trng_vkorg,
        it_vtweg       TYPE trng_vtweg,
        is_acksipmktob TYPE meins, "Açık Sipariş Miktarı Ölçü Birimi
      END OF ty_select .
  types TY_ENQ type SEQG3 .
  types:
    tt_enq  TYPE STANDARD TABLE OF ty_enq WITH DEFAULT KEY .
  types:
    tts_enq TYPE SORTED TABLE OF ty_enq WITH NON-UNIQUE KEY gtdate gttime gtusec gname garg .
  types:
    BEGIN OF ty_atbez,
        atinn TYPE atinn,
        atbez TYPE atbez,
      END OF ty_atbez .
  types:
    tth_atbez TYPE HASHED TABLE OF ty_atbez WITH UNIQUE KEY atinn .
  types:
    BEGIN OF ty_extwg,
        matnr TYPE matnr,
        mtart TYPE mtart,
        extwg TYPE extwg,
        ewbez TYPE ewbez,
      END OF ty_extwg .
  types:
    tth_extwg TYPE HASHED TABLE OF ty_extwg WITH UNIQUE KEY matnr .
  types:
    BEGIN OF ty_brsch,
        kunnr TYPE kunnr,
        brsch TYPE brsch,
        brtxt TYPE text1_016t,
      END OF ty_brsch .
  types:
    tth_brsch TYPE HASHED TABLE OF ty_brsch WITH UNIQUE KEY kunnr .
  types:
    BEGIN OF ty_cust_cntrl,
        key TYPE zsds_cust_cntrl_key,
        val TYPE zsds_cust_cntrl_fld,
      END OF ty_cust_cntrl .
  types:
    tt_cust_cntrl TYPE HASHED TABLE OF ty_cust_cntrl WITH UNIQUE KEY primary_key COMPONENTS key .
  types:
    BEGIN OF ty_domval.
            INCLUDE TYPE dd07v.
    TYPES: END OF ty_domval .
  types:
    tts_domval TYPE TABLE OF ty_domval WITH DEFAULT KEY .
  types:
    BEGIN OF ty_lcnum,
        vbeln TYPE vbeln,
        lcnum TYPE lcnum,
      END OF ty_lcnum .
  types:
    tth_lcnum TYPE HASHED TABLE OF ty_lcnum WITH UNIQUE KEY vbeln .

  class-data GT_EXTWG type TTH_EXTWG .
  constants C_OPTION_EQ type DDOPTION value 'EQ'. "#EC NOTEXT
  constants C_SIGN_E type DDSIGN value 'E'. "#EC NOTEXT
  constants C_SIGN_I type DDSIGN value 'I'. "#EC NOTEXT
  constants C_MSGTY_E type SYMSGTY value 'E'. "#EC NOTEXT
  constants C_MSGTY_S type SYMSGTY value 'S'. "#EC NOTEXT
  class-data GT_MAKTX type TT_MAKTX .
  constants CV_ATINN_EBAT type ATINN value '0000000810'. "#EC NOTEXT
  constants CV_ATINN_SERI type ATINN value '0000000811'. "#EC NOTEXT
  constants CV_MALIBELGE type CHAR12 value 'LCNUM_CHECK'. "#EC NOTEXT

  type-pools ABAP .
  class-methods ENQUEUE_READ_AKKP
    importing
      !IV_LCNUM type LCNUM
      !IV_VBELN_VA type VBELN_VA optional
      !IV_VBELN_VL type VBELN_VL optional
      !IV_SAME_USER_CNTRL type ABAP_BOOL optional
    raising
      ZCX_BC_EXIT_IMP .
  class-methods VX12N_UPDATE_FLAG
    importing
      value(IV_EXPORT) type ABAP_BOOL optional
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods HATA_GOSTER
    importing
      value(IT_ERROR) type BAPIRETTAB .
  class-methods BILGI_GOSTER
    importing
      value(IT_MSG) type BAPIRETTAB .
  class-methods NAST_PROTOCOL_UPDATE
    importing
      !IS_MSG_LOG type RECAMSG
    raising
      ZCX_SD_TOOLKIT .
  class-methods VBELN_VL_VALID
    importing
      !IV_VBELN_VA type VBELN_VA
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods GET_MAKTX
    importing
      !IV_MATNR type MATNR
    returning
      value(RV_MAKTX) type MAKTX
    raising
      ZCX_SD_TOOLKIT .
  class-methods ENQUEUE_READ
    importing
      !IV_GNAME type EQEGRANAME
    returning
      value(RT_ENQ) type TT_ENQ .
  class-methods GET_EXTWG
    importing
      !IV_MATNR type MATNR
    returning
      value(RS_EXTWG) type TY_EXTWG .
  class-methods GET_MLZ_SINIF_ATWRT
    importing
      !IV_ATINN type ATINN
      !IV_MATNR type MATNR
    returning
      value(RV_EBAT) type ATWRT
    raising
      ZCX_BC_EXIT_IMP .
  class-methods GET_MLZ_SINIF_ATWRT_TANIM
    importing
      !IV_ATINN type ATINN
    returning
      value(RV_ATBEZ) type ATBEZ .
  class-methods GET_CUST_CNTRL
    importing
      !IS_KEY type ZSDS_CUST_CNTRL_KEY
    returning
      value(RS_CUST_CNTRL) type TY_CUST_CNTRL .
  class-methods GET_DOMVAL_SINGLE
    importing
      !IV_DOMNAME type DOMNAME
      !IV_DDLANGUAGE type DDLANGUAGE
      !IV_DOMVALUE_L type DOMVALUE_L
    returning
      value(RV_DOMVAL) type DD07V .
  class-methods GET_DOMVAL_TABLE
    importing
      !IV_DOMNAME type DOMNAME
      !IV_DDLANGUAGE type DDLANGUAGE
    returning
      value(RT_DOMVAL) type DD07V_TAB .
  class-methods GET_BRSCH
    importing
      !IV_KUNNR type KUNNR
    returning
      value(RS_BRSCH) type TY_BRSCH .
  class-methods GET_LCNUM
    importing
      !IV_VBELN_VA type VBELN_VA
    returning
      value(RV_LCNUM) type LCNUM .
  class-methods GET_MTART
    importing
      !IV_MATNR type MATNR
    returning
      value(RS_MTART) type TY_MTART .
protected section.
private section.

  class-data GT_ATBEZ type TTH_ATBEZ .
  class-data GT_MTART type TTH_MTART .
  class-data GT_CUST_CNTRL type TT_CUST_CNTRL .
  class-data GT_DOMVAL type TTS_DOMVAL .
  class-data GT_BRSCH type TTH_BRSCH .
  class-data GT_LCNUM type TTH_LCNUM .

  class-methods BLOCK_POPUP
    importing
      !IT_ERROR type BAPIRETTAB
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods CHECK_LCNUM
    importing
      !IV_LCNUM type LCNUM
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods CHECK_SAME_USER
    importing
      !IV_SAME_USER_CNTRL type ABAP_BOOL
      !IV_GUNAME type UNAME
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods CHECK_VBELN_VA
    importing
      !IV_VBELN_VA type VBELN_VA optional
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods CHECK_VBELN_VL
    importing
      !IV_VBELN_VL type VBELN_VL optional
    returning
      value(RV_RETURN) type ABAP_BOOL .
  class-methods LEAVE_PROGRAM
    importing
      !IT_ERROR type BAPIRETTAB
    returning
      value(RV_RETURN) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_SD_TOOLKIT IMPLEMENTATION.


  METHOD bilgi_goster.

    CHECK it_msg IS NOT INITIAL.
*  check sy-calld is not initial.
    CHECK sy-batch IS INITIAL.
    CHECK sy-binpt IS INITIAL.

    DELETE ADJACENT DUPLICATES FROM it_msg COMPARING ALL FIELDS.

    CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
      EXPORTING
        it_message = it_msg
      EXCEPTIONS
        bal_error  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.


METHOD block_popup.

  DATA: lv_malibelge TYPE abap_bool.

  IMPORT lv_malibelge = lv_malibelge FROM MEMORY ID cv_malibelge.
  FREE MEMORY ID cv_malibelge.
  CHECK: sy-batch EQ abap_true OR
         sy-binpt EQ abap_true OR
         lv_malibelge EQ abap_true.

  ASSIGN it_error[ type = 'E' id = 'ZYB_SD' number = '135' ] TO FIELD-SYMBOL(<is_error>).
  IF sy-subrc EQ 0.
    rv_return = abap_true.
    MESSAGE ID <is_error>-id
      TYPE   <is_error>-type
      NUMBER <is_error>-number
      WITH   <is_error>-message_v1
             <is_error>-message_v2
             <is_error>-message_v3
             <is_error>-message_v4.
  ENDIF.

ENDMETHOD.


METHOD check_lcnum.

  CHECK: iv_lcnum IS NOT INITIAL.

  DATA: lt_enq  TYPE wlf_seqg3_tab,
        lv_garg TYPE eqegraarg.

  lv_garg = |{ sy-mandt }{ iv_lcnum }|.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = 'AKKP'
      garg                  = lv_garg
*     GUNAME                = SY-UNAME
*     LOCAL                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
*   IMPORTING
*     NUMBER                =
*     SUBRC                 =
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc NE 0.
* Implement suitable error handling here
  ELSE.
    LOOP AT lt_enq ASSIGNING FIELD-SYMBOL(<ls_enq>)
      WHERE guname NE sy-uname.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.
  ENDIF.

*  CALL FUNCTION 'ENQUEUE_EVAKKPE'
*    EXPORTING
*      lcnum          = iv_lcnum
*    EXCEPTIONS
*      foreign_lock   = 1
*      system_failure = 2.
*  IF sy-subrc EQ 1 AND sy-msgv1 NE sy-uname.
*    rv_return = abap_true.
*  ENDIF.

ENDMETHOD.


METHOD check_same_user.

  CHECK: iv_same_user_cntrl IS NOT INITIAL,
         sy-uname EQ iv_guname,
         sy-tcode NE 'ZSD009'.

  rv_return = abap_true.

ENDMETHOD.


METHOD check_vbeln_va.

  CHECK: iv_vbeln_va IS NOT INITIAL.

  DATA: lt_enq  TYPE wlf_seqg3_tab,
        lv_garg TYPE eqegraarg.

  lv_garg = |{ sy-mandt }{ iv_vbeln_va }|.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = 'VBAK'
      garg                  = lv_garg
*     GUNAME                = SY-UNAME
*     LOCAL                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
*   IMPORTING
*     NUMBER                =
*     SUBRC                 =
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc NE 0.
* Implement suitable error handling here
  ELSE.
    LOOP AT lt_enq ASSIGNING FIELD-SYMBOL(<ls_enq>)
      WHERE guname NE sy-uname.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.
  ENDIF.

*  CALL FUNCTION 'ENQUEUE_EVVBAKE'
*    EXPORTING
*      mode_vbak      = 'E'
*      mandt          = sy-mandt
*      vbeln          = iv_vbeln_va
*      x_vbeln        = ' '
*      _scope         = '2'
*      _wait          = ' '
*      _collect       = ' '
*    EXCEPTIONS
*      foreign_lock   = 1
*      system_failure = 2
*      OTHERS         = 3.
*  IF sy-subrc EQ 1.
*    IF sy-msgv1 NE sy-uname.
*      rv_return = abap_true.
*    ENDIF.
*  ENDIF.

ENDMETHOD.


METHOD check_vbeln_vl.

  CHECK: iv_vbeln_vl IS NOT INITIAL.

  DATA: lt_enq  TYPE wlf_seqg3_tab,
        lv_garg TYPE eqegraarg.

  lv_garg = |{ sy-mandt }{ iv_vbeln_vl }|.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = 'LIKP'
      garg                  = lv_garg
*     GUNAME                = SY-UNAME
*     LOCAL                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
*   IMPORTING
*     NUMBER                =
*     SUBRC                 =
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc NE 0.
* Implement suitable error handling here
  ELSE.
    LOOP AT lt_enq ASSIGNING FIELD-SYMBOL(<ls_enq>)
      WHERE guname NE sy-uname.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.
  ENDIF.

*  CALL FUNCTION 'ENQUEUE_EVVBLKE'
*    EXPORTING
*      mode_likp      = 'E'
*      mandt          = sy-mandt
*      vbeln          = iv_vbeln_vl
*      x_vbeln        = ' '
*      _scope         = '2'
*      _wait          = ' '
*      _collect       = ' '
*    EXCEPTIONS
*      foreign_lock   = 1
*      system_failure = 2
*      OTHERS         = 3.
*  IF sy-subrc EQ 1 AND sy-msgv1 NE sy-uname.
*    rv_return = abap_true.
*  ENDIF.

ENDMETHOD.


  METHOD enqueue_read.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gclient = sy-mandt    " Client
        gname   = iv_gname    " Granularity name (-> table name)
*       garg    = SPACE    " Granularity value(->values of key fields)
        guname  = space    " User name
*       local   = SPACE    " Single-Character Flag
*       fast    = SPACE    " Redundant table fields are not fully filled
*       gargnowc              = SPACE    " All characters in GARG are literals
*      IMPORTING
*       number  = lv_num    " Number of chosen lock entries
*       subrc   =     " Error code of the enqueue call
      TABLES
        enq     = rt_enq  " List of the chosen lock entries
*  EXCEPTIONS
*       communication_failure = 1
*       system_failure        = 2
*       others  = 3
      .
    IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


METHOD enqueue_read_akkp.

  DATA: lt_enq TYPE wlf_seqg3_tab.

  DATA(lo_msg) = cf_reca_message_list=>create( ).


  TRY.
      DATA(rr_exc_extwg) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                         var   = 'USER'
                                                                         val   = REF #( sy-uname )
                                                                         surec = 'YI_MLBLG_KONTROL' ) ) .
      ASSIGN rr_exc_extwg->* TO FIELD-SYMBOL(<lv_exc_extwg>).

      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient               = sy-mandt
          gname                 = 'AKKP'
*         garg                  = ' '
          guname                = ' '
*         LOCAL                 = ' '
*         FAST                  = ' '
*         GARGNOWC              = ' '
* IMPORTING
*         NUMBER                =
*         SUBRC                 =
        TABLES
          enq                   = lt_enq
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc NE 0.
* Implement suitable error handling here
      ELSE.
        LOOP AT lt_enq ASSIGNING FIELD-SYMBOL(<fs_enq>).
          "--------->> Anıl CENGİZ 23.02.2021 11:15:26
          "YUR-852
*        IF iv_lcnum EQ <fs_enq>-garg+3(10) AND <fs_enq>-guname NE sy-uname.
          IF iv_lcnum EQ <fs_enq>-garg+3(10).
*          MESSAGE e135(zyb_sd) WITH <fs_enq>-garg+3(10) <fs_enq>-guname .
            CHECK: check_vbeln_va( iv_vbeln_va ) EQ abap_true OR
                   check_vbeln_vl( iv_vbeln_vl ) EQ abap_true OR
                   check_lcnum( iv_lcnum ) EQ abap_true OR
                   check_same_user( EXPORTING iv_same_user_cntrl = iv_same_user_cntrl
                                              iv_guname          = <fs_enq>-guname ) EQ abap_true,
                   <lv_exc_extwg> EQ abap_false. "İstisna kullanıcısı değilse.

            lo_msg->add( id_msgty = 'E'
                         id_msgid = 'ZYB_SD'
                         id_msgno = '135'
                         id_msgv1 = <fs_enq>-garg+3(10)
                         id_msgv2 = <fs_enq>-guname
                         id_msgv3 = space
                         id_msgv4 = space ).
            "---------<<
          ENDIF.
*        "--------->> Anıl CENGİZ 23.09.2020 20:29:08
*        "YUR-716
*        IF i_lcnum EQ <fs_enq>-garg+3(10) AND <fs_enq>-guname EQ sy-uname AND sy-tcode EQ <fs_enq>-gtcode.
*          MESSAGE e073(zsd) WITH <fs_enq>-garg+3(10) <fs_enq>-guname .
*        ENDIF.
*        "---------<<
        ENDLOOP.
      ENDIF.

      IF lo_msg->is_empty( ) NE abap_true.
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.

    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.

  ENDTRY.

ENDMETHOD.


METHOD get_brsch.

  DATA: ls_brsch TYPE ty_brsch.

  ASSIGN gt_brsch[ KEY primary_key COMPONENTS kunnr = iv_kunnr ] TO FIELD-SYMBOL(<gs_brsch>).
  IF sy-subrc NE 0.
    SELECT SINGLE kna1~kunnr kna1~brsch
      FROM kna1
      INTO CORRESPONDING FIELDS OF ls_brsch
      WHERE kunnr EQ iv_kunnr.
    IF sy-subrc EQ 0.
      SELECT SINGLE brtxt
        FROM t016t
        INTO ls_brsch-brtxt
        WHERE brsch EQ ls_brsch-brsch
          AND spras EQ 'T'.
      IF sy-subrc EQ 0.
        INSERT ls_brsch INTO TABLE gt_brsch ASSIGNING <gs_brsch>.
      ENDIF.
    ENDIF.
  ENDIF.

  rs_brsch = <gs_brsch>.

ENDMETHOD.


METHOD get_cust_cntrl.

  DATA: lt_cust TYPE STANDARD TABLE OF zsdt_cust_cntrl.

  ASSIGN gt_cust_cntrl[ KEY primary_key COMPONENTS key = is_key ] TO FIELD-SYMBOL(<ls_cust_cntrl>).
  IF sy-subrc EQ 0.
    rs_cust_cntrl = <ls_cust_cntrl>.
  ELSE.

    SELECT *
        FROM zsdt_cust_cntrl
        INTO TABLE lt_cust
        WHERE vkorg = is_key-vkorg
          AND vtweg = is_key-vtweg
          AND ktokd = is_key-ktokd
          AND brsch = is_key-brsch.
    LOOP AT lt_cust ASSIGNING FIELD-SYMBOL(<ls_cust>).
      INSERT VALUE #( key = CORRESPONDING #( <ls_cust> )
                      val = CORRESPONDING #( <ls_cust> ) ) INTO TABLE gt_cust_cntrl.

    ENDLOOP.
    ASSIGN gt_cust_cntrl[ KEY primary_key COMPONENTS key = is_key ] TO <ls_cust_cntrl>.
    IF sy-subrc EQ 0.
      rs_cust_cntrl = <ls_cust_cntrl>.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_domval_single.

  ASSIGN gt_domval[ domname    = iv_domname
                    ddlanguage = iv_ddlanguage
                    domvalue_l = iv_domvalue_l ] TO FIELD-SYMBOL(<gs_domval>).
  IF sy-subrc NE 0.
    APPEND LINES OF get_domval_table( EXPORTING iv_domname    = iv_domname
                                                iv_ddlanguage = iv_ddlanguage ) TO gt_domval.
    ASSIGN gt_domval[ domname    = iv_domname
                      ddlanguage = iv_ddlanguage
                      domvalue_l = iv_domvalue_l ] TO <gs_domval>.
  ENDIF.

  rv_domval = <gs_domval>.

ENDMETHOD.


METHOD get_domval_table.

  DATA: lt_domvalue_a TYPE dd07v_tab,
        lt_domvalue_n TYPE dd07v_tab.

  CALL FUNCTION 'DD_DOFV_GET'
    EXPORTING
      get_state     = 'M'
      langu         = iv_ddlanguage
      prid          = 0
      withtext      = 'X'
      domain_name   = iv_domname
    TABLES
      dd07v_tab_a   = rt_domval
      dd07v_tab_n   = lt_domvalue_n
    EXCEPTIONS
      illegal_value = 1
      op_failure    = 2
      OTHERS        = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMETHOD.


METHOD get_extwg.

  DATA: ls_extwg TYPE ty_extwg.

  ASSIGN gt_extwg[ KEY primary_key COMPONENTS matnr = iv_matnr ] TO FIELD-SYMBOL(<gs_extwg>).
  IF sy-subrc NE 0.
    SELECT SINGLE mara~matnr mara~mtart
                  mara~extwg twewt~ewbez
      FROM mara
      INNER JOIN twewt ON twewt~extwg EQ mara~extwg
      INTO ls_extwg
      WHERE mara~matnr EQ iv_matnr
        AND twewt~spras EQ 'T'.
    IF sy-subrc EQ 0.
      INSERT ls_extwg INTO TABLE gt_extwg ASSIGNING <gs_extwg>.
    ENDIF.
  ENDIF.

  rs_extwg = <gs_extwg>.

ENDMETHOD.


METHOD get_lcnum.

  DATA: ls_lcnum TYPE ty_lcnum.

  ASSIGN gt_lcnum[ KEY primary_key COMPONENTS vbeln = iv_vbeln_va ] TO FIELD-SYMBOL(<gs_lcnum>).
  IF sy-subrc NE 0.
    SELECT SINGLE vbeln lcnum
      FROM vbkd
      INTO ls_lcnum
      WHERE vbeln EQ iv_vbeln_va.
    IF sy-subrc EQ 0.
      INSERT ls_lcnum INTO TABLE gt_lcnum ASSIGNING <gs_lcnum>.
      rv_lcnum = <gs_lcnum>-lcnum.
    ENDIF.
  ELSE.
    rv_lcnum = <gs_lcnum>-lcnum.
  ENDIF.

ENDMETHOD.


  METHOD get_maktx.

    DATA: ls_maktx TYPE ty_maktx.

    CHECK: iv_matnr IS NOT INITIAL.

    ASSIGN gt_maktx[ KEY primary_key COMPONENTS matnr = iv_matnr ] TO FIELD-SYMBOL(<lv_maktx>).
    IF sy-subrc NE 0.
      SELECT SINGLE matnr maktx
        FROM makt
        INTO ls_maktx
        WHERE matnr EQ iv_matnr
          AND spras EQ 'T'.
      IF sy-subrc EQ 0.
        INSERT ls_maktx INTO TABLE gt_maktx ASSIGNING <lv_maktx>.
      ELSE.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZMM'
                     id_msgno = '032' ).
        RAISE EXCEPTION TYPE zcx_sd_toolkit
          EXPORTING
            messages = lo_msg.
      ENDIF.
    ENDIF.

    rv_maktx = <lv_maktx>-maktx.

  ENDMETHOD.


METHOD get_mlz_sinif_atwrt.
  "--------->> Anıl CENGİZ 04.01.2021 12:26:08
  "YUR-805
*  CHECK: iv_matnr NE 'PALET1'.
  TRY.

      DATA(ls_mtart) = get_mtart( iv_matnr ).

      DATA(rr_exc_mtart) = zcl_sd_exc_vld_cntrl=>get_surec_val( VALUE #( typ   = zcl_sd_exc_vld_cntrl=>cv_exc
                                                                         var   = 'MTART'
                                                                         val   = REF #( ls_mtart-mtart )
                                                                         surec = 'YI_FYT_SINIF_KRK_KNTRL' ) ) .
      ASSIGN rr_exc_mtart->* TO FIELD-SYMBOL(<lv_exc_mtart>).
      CHECK: <lv_exc_mtart> IS INITIAL. "İstisna malzeme türü ise aşağıdaki kontrole girmez.
      "---------<<

      SELECT SINGLE atwrt
        FROM ausp
        INTO rv_ebat
        WHERE objek EQ iv_matnr
          AND atinn EQ iv_atinn
          AND mafid EQ 'O'
          AND klart EQ '001'.
      IF sy-subrc NE 0.
        DATA(lo_msg) = cf_reca_message_list=>create( ).
        lo_msg->add( id_msgty = 'E'
                     id_msgid = 'ZSD'
                     id_msgno = '086'
                     id_msgv1 = get_mlz_sinif_atwrt_tanim( iv_atinn ) ).
        RAISE EXCEPTION TYPE zcx_bc_exit_imp
          EXPORTING
            messages = lo_msg.
      ENDIF.

    CATCH zcx_sd_exc_vld_cntrl INTO DATA(lx_sd_exc_vld_cntrl).
      RAISE EXCEPTION TYPE zcx_bc_exit_imp
        EXPORTING
          messages = lx_sd_exc_vld_cntrl->messages.
  ENDTRY.

ENDMETHOD.


METHOD get_mlz_sinif_atwrt_tanim.

  DATA: ls_atbez TYPE ty_atbez.

  ASSIGN gt_atbez[ KEY primary_key COMPONENTS atinn = iv_atinn ] TO FIELD-SYMBOL(<gs_atbez>).
  IF sy-subrc NE 0.
    SELECT SINGLE atinn atbez
      FROM cabnt
      INTO CORRESPONDING FIELDS OF ls_atbez
      WHERE atinn EQ iv_atinn
        AND spras EQ 'T'.
    IF sy-subrc EQ 0.
      INSERT ls_atbez INTO TABLE gt_atbez ASSIGNING <gs_atbez>.
    ENDIF.
  ENDIF.

  rv_atbez = <gs_atbez>-atbez.

ENDMETHOD.


METHOD get_mtart.

  DATA: ls_mtart TYPE ty_mtart.

  ASSIGN gt_mtart[ KEY primary_key COMPONENTS matnr = iv_matnr ] TO FIELD-SYMBOL(<gs_mtart>).
  IF sy-subrc NE 0.
    SELECT SINGLE mara~matnr mara~mtart t134t~mtbez
      FROM mara
      INNER JOIN t134t ON mara~mtart EQ t134t~mtart
      INTO ls_mtart
      WHERE mara~matnr EQ iv_matnr
        AND t134t~spras EQ 'T'.
    INSERT ls_mtart INTO TABLE gt_mtart ASSIGNING <gs_mtart>.
  ENDIF.

  rs_mtart = <gs_mtart>.

ENDMETHOD.


METHOD hata_goster.

  CHECK: it_error IS NOT INITIAL.
*         sy-calld is not initial,
*         sy-batch IS INITIAL,
*         sy-binpt IS INITIAL.

  DELETE ADJACENT DUPLICATES FROM it_error COMPARING ALL FIELDS.

  IF block_popup( it_error ) EQ abap_false.
    CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
      EXPORTING
        it_message = it_error
      EXCEPTIONS
        bal_error  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        DISPLAY LIKE 'E'.
    ELSE.
      IF leave_program( it_error ) EQ abap_true .
        LEAVE PROGRAM .
      ELSE.
        MESSAGE e123(zyb_sd).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD leave_program.

  ASSIGN it_error[ type = 'E' id = 'ZSD' number = '087' ] TO FIELD-SYMBOL(<is_error>). "Sipariş değiştirme gün sayısı aşılmıştır! VA03 kullanın! ( & & )
  IF sy-subrc EQ 0.
    rv_return = abap_true.
    RETURN.
  ENDIF.

  ASSIGN it_error[ type = 'E' id = 'ZSD' number = '094' ] TO <is_error>. "HATA! Müşterinin geçmiş dönemden & & borcu vardır. İşlem yapamazsınız!
  IF sy-subrc EQ 0.
    rv_return = abap_true.
    RETURN.
  ENDIF.

  ASSIGN it_error[ type = 'E' id = 'ZYB_SD' number = '135' ] TO <is_error>. "&1 numaralı mali belge &2 tarafından bloke edilmiştir!
  IF sy-subrc EQ 0.
    rv_return = abap_true.
    RETURN.
  ENDIF.

ENDMETHOD.


  METHOD nast_protocol_update.

    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb              = is_msg_log-msgid
        msg_nr                 = is_msg_log-msgno
        msg_ty                 = is_msg_log-msgty
        msg_v1                 = is_msg_log-msgv1
        msg_v2                 = is_msg_log-msgv2
        msg_v3                 = is_msg_log-msgv3
        msg_v4                 = is_msg_log-msgv4
      EXCEPTIONS
        message_type_not_valid = 1
        no_sy_message          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      DATA(lo_msg) = cf_reca_message_list=>create( ).
      lo_msg->add( id_msgty   =  sy-msgty
                   id_msgid   =  sy-msgid
                   id_msgno   =  sy-msgno
                   id_msgv1   =  sy-msgv1
                   id_msgv2   =  sy-msgv2
                   id_msgv3   =  sy-msgv3
                   id_msgv4   =  sy-msgv4 ).
      RAISE EXCEPTION TYPE zcx_sd_toolkit
        EXPORTING
          messages = lo_msg.
    ENDIF.

  ENDMETHOD.


  METHOD vbeln_vl_valid.

    CHECK: iv_vbeln_va IS NOT INITIAL.

    SELECT SINGLE mandt
      FROM vbfa
      INTO sy-mandt
      WHERE vbelv EQ iv_vbeln_va
        AND vbtyp_v EQ 'C'
        AND vbtyp_n EQ 'J'.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.


  ENDMETHOD.


  METHOD vx12n_update_flag.

    CLEAR rv_return.

    IF iv_export EQ abap_true.

      EXPORT iv_export =
             iv_export TO MEMORY ID 'ZCL_SD_TOOLKIT->ZXAKKO01'.

    ELSE.

      IMPORT iv_export =
             rv_return FROM MEMORY ID 'ZCL_SD_TOOLKIT->ZXAKKO01'.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
