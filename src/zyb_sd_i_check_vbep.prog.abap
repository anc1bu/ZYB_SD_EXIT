*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_CHECK_VBEP
*& - İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&---------------------------------------------------------------------*
* Data
data:
  lv_tesmik like zyb_sd_t_shp02-tesmik,
  lv_sipmik type menge_d,
  ls_xvbep  like xvbep.

data lv_error_msg type  bapiret2-message.

*&*********************************************************************
*& --> İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&*********************************************************************
if *vbep-cmeng gt vbep-cmeng.
  select sum( tesmik ) from zyb_sd_t_shp02
        into lv_tesmik
       where vbeln eq vbap-vbeln
         and posnr eq vbap-posnr
         and loekz eq space.

*  lv_fark = vbap-kwmeng - vbep-cmeng.
  clear lv_sipmik.
  lv_sipmik = vbep-cmeng.
  loop at xvbep into ls_xvbep
                    where vbeln eq vbep-vbeln
                      and posnr eq vbep-posnr
                      and cmeng ne 0
                      and updkz ne updkz_delete.
    if ls_xvbep-etenr ne vbep-etenr.
      lv_sipmik = lv_sipmik + ls_xvbep-cmeng.
    endif.
  endloop.

  if lv_sipmik lt lv_tesmik.
    message e035(zsd_va) with vbap-vbeln vbap-posnr lv_tesmik
        display like 'I'.
  endif.
endif.
*&*********************************************************************
*& <-- İhracat yüklemesi olan bir kalemin miktarı yükleme miktarından
*&     daha fazla azaltılamaz
*&*********************************************************************



try.

    new zcl_sd_mv45afzb_check_vbep( is_vbep     = vbep
                                    is_vbap     = vbap
                                    is_old_vbap = *vbap
                                    is_vbak     = vbak
                                    is_t180     = t180
                                    it_xvbep    = xvbep[]
                                   )->controls( ).

  catch zcx_sd_exit into data(lo_cx_sd_exit).
    lv_error_msg = lo_cx_sd_exit->if_message~get_text( ).
    message lv_error_msg type zcx_sd_exit=>c_error
      display like 'I'.
endtry.
