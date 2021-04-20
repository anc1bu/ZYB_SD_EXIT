*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_SAVE_DOCUMENT_PREPARE
*&---------------------------------------------------------------------*
break anilc.
data: ls_xlips like line of ct_xlips,
      ls_xlikp like line of ct_xlikp,
      ls_xvbfa like line of ct_xvbfa,
      ls_xvbpa like line of ct_xvbpa,
      lv_ok    type xfeld,
      ls_knvi  type knvi.
"İhracat satışlarında hareket türü 901 olarak değiştirilir. 15*-157
"çalişir.
clear lv_ok.
read table ct_xlikp into ls_xlikp index 1.

select single * from knvi into ls_knvi where kunnr = ls_xlikp-kunag
                                         and aland = 'TR'
                                         and tatyp = 'MWST'
                                         and taxkd = '2'.
if sy-subrc ne 0.
  loop at ct_xvbpa into ls_xvbpa
    where parvw = 'WE'
      and ( land1 ne 'TR').
    lv_ok = 'X'.
  endloop.
endif.

data: lv_prsfd type prsfd.

if lv_ok is not initial.
  loop at ct_xlips into ls_xlips where bwart ne space.

    clear lv_prsfd.
    select single prsfd from tvap into lv_prsfd
      where pstyv eq ls_xlips-pstyv.
    if ( lv_prsfd is initial or lv_prsfd eq 'B' ) and
         ls_xlips-bwart eq 'Z81'.
      continue.
    endif.
    "--------->> add by mehmet sertkaya 22.07.2019 13:52:00
    "YUR-446 RE: İade Siparişi // 410000320 de VF04 problemi.
    select single count(*) from vbak
          where vbeln eq ls_xlips-vgbel and
                augru eq '004'.
    if sy-subrc eq 0.
      continue.
    endif.
    "-----------------------------<<

    ls_xlips-bwart = '901'.
    loop at ct_xvbfa into ls_xvbfa
      where vbelv   = ls_xlips-vbelv
      and posnv   = ls_xlips-posnv
      and vbtyp_n = 'J'.
      ls_xvbfa-bwart = '901'.
      modify ct_xvbfa from ls_xvbfa.
    endloop.

    modify ct_xlips from ls_xlips.
  endloop.
endif.

data: lv_ambsay type lfimg.

if is_v50agl-warenausgang eq 'X'.
  loop at ct_xlikp into ls_xlikp where updkz ne 'D'.
    clear lv_ambsay.
    loop at ct_xlips into ls_xlips where posar ca 'CE'.
      lv_ambsay = lv_ambsay + ls_xlips-lfimg.
    endloop.
    if lv_ambsay gt 0.
      ls_xlikp-anzpk = lv_ambsay.
      modify ct_xlikp from ls_xlikp transporting anzpk.
    endif.
  endloop.
endif.
