class ZCL_SD_MV45AFZZ_MOVETOVBAK definition
  public
  final
  create public .

public section.

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !IS_VBKD type VBKD
      !IS_VBAK type VBAK
      !IV_CALL_BAPI type ABAP_BOOL .
  methods CHECK_LCNUM_CHANGE
    returning
      value(RV_RETURN) type ABAP_BOOL .
protected section.
private section.

  types:
    begin of ty_params,
           vbkd      type vbkd,
           vbak      type vbak,
           call_bapi type abap_bool,
         end of ty_params .

  class-data GS_PARAMS type TY_PARAMS .
ENDCLASS.



CLASS ZCL_SD_MV45AFZZ_MOVETOVBAK IMPLEMENTATION.


method check_lcnum_change.

  data: lv_kunnr type kunnr.
  clear: lv_kunnr.

  select single kunnr
    from akkp
    into lv_kunnr
    where lcnum eq gs_params-vbkd-lcnum.
  if ( lv_kunnr ne gs_params-vbak-kunnr
     or gs_params-vbkd-lcnum is initial
     or gs_params-vbak-zz_knuma_ag is initial )
"--------->> Anıl CENGİZ 02.04.2019 10:21:51
"YUR-364
"Geçici bir çözüm yapıldı. Burdaki mantığın toparlanması lazım.
"perform ve if lere göre yapılan atamalarda kurallar netleştirilip
" kod yeniden yazılmalı.
    and gs_params-call_bapi eq abap_false.
"---------<<

    rv_return = abap_true.
  endif.

endmethod.


method CONSTRUCTOR.

gs_params-vbkd = is_vbkd.
gs_params-vbak = is_vbak.
gs_params-call_bapi = iv_call_bapi.

endmethod.
ENDCLASS.
