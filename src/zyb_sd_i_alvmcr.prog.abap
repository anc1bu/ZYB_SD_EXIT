*&---------------------------------------------------------------------*
*&  Include           ZYB_SD_I_ALVMCR
*&---------------------------------------------------------------------*
* alv de görünen tanımları değiştirir.
  DEFINE text_change.
    clear ls_fcat.
    ls_fcat-seltext_s    = &2.
    ls_fcat-reptext_ddic = &2.
    ls_fcat-seltext_l    = &3.
    ls_fcat-seltext_m    = ls_fcat-seltext_s.
    modify ct_fcat from ls_fcat
           transporting seltext_s seltext_m seltext_l reptext_ddic ddictxt
           where fieldname = &1.
  END-OF-DEFINITION.
* Alan üzerinde geldiğinde imlecin el şeklini (link) almasını sağlar
  DEFINE hotspot .
    clear ls_fcat .
    ls_fcat-hotspot = 'X'.
    modify ct_fcat from ls_fcat
           transporting hotspot where fieldname = &1.
  END-OF-DEFINITION.
* alv de alanın gözükmemesini sağlar.
  DEFINE no_out.
    clear ls_fcat .
    ls_fcat-no_out = 'X'.
    modify ct_fcat from ls_fcat
           transporting no_out where fieldname = &1.
  END-OF-DEFINITION.
* Alanın checkbox olarak görünmesini sağlar.
  DEFINE checkbox.
    clear ls_fcat .
    ls_fcat-checkbox = 'X'.
    modify ct_fcat from ls_fcat
           transporting checkbox where fieldname = &1.
  END-OF-DEFINITION.
* ALV’ de belirtilen alanın alt toplamı alınarak görüntülenir.
  DEFINE do_sum.
    clear ls_fcat .
    ls_fcat-do_sum = 'X'.
    modify ct_fcat from ls_fcat
           transporting do_sum where fieldname = &1.
  END-OF-DEFINITION.
* Alanın sütun pozisyonu ayarlamak için kullanılır. Veri tipi INT4(10)
  DEFINE col_pos.
    clear ls_fcat .
    ls_fcat-col_pos = &2.
    modify ct_fcat from ls_fcat
           transporting col_pos where fieldname = &1.
  END-OF-DEFINITION.
*&-------------------------------------------------------------*
*& Sütun rengini değiştirmek için kullanılır‘X’ kullanılır ise
*& ön tanımlı tipler kullanılır.
*& Eğer karakter ‘C’(renk kodu) ile başlarsa,  alabileceği üç
*& rakamın anlamı şöyledir.
*& 1. x: renk kodu
*& 2. y: yoğunluk görünüm
*& 3. z: ters çevrilmiş
*& renk görünümü
*& veri tipi : char4
*& SPACE, ‘X’ or ‘Cxyz’ (x:’1′-‘9′; y,z: ‘0’=off ‘1’=on)
*&-------------------------------------------------------------*
  DEFINE emphasize.
    clear ls_fcat .
    ls_fcat-emphasize = &2.
    modify ct_fcat from ls_fcat
           transporting emphasize where fieldname = &1.
  END-OF-DEFINITION.
*&-------------------------------------------------------------*
*& Alanın görüntülenen sütun genişliğini ayarlamak için kullanılır.
*& ABAP Dictionary’ de tanımlı bir alan ise doldurmaya gerek yoktur.
*& Alan uzunluğu Domain üzerinden devralınır. Veri tipi : NUMC6
*&-------------------------------------------------------------*
  DEFINE outputlen.
    clear ls_fcat .
    ls_fcat-outputlen = &2.
    modify ct_fcat from ls_fcat
           transporting outputlen where fieldname = &1.
  END-OF-DEFINITION.
*&-------------------------------------------------------------*
*& Hizalama için kullanılır. CHAR ve NUMC veri tipine sahip
*& alanlara uygulanabilir.
*& ‘R’: Sağa dayalı· ‘L’: Sola dayalı· ‘R’: Ortalanmış
*&-------------------------------------------------------------*
  DEFINE just.
    clear ls_fcat .
    ls_fcat-just = &2.
    modify ct_fcat from ls_fcat
           transporting just where fieldname = &1.
  END-OF-DEFINITION.
*&-------------------------------------------------------------*
*& NUMC veri tipi için kullanılabilir. Alanın sıfırdan büyük
*& rakamının solunda sıfır var ise görüntülenir.
*& SPACE, ‘X’
*&-------------------------------------------------------------*
  DEFINE lzero.
    clear ls_fcat .
    ls_fcat-lzero = 'X'.
    modify ct_fcat from ls_fcat
           transporting lzero where fieldname = &1.
  END-OF-DEFINITION.
*&-------------------------------------------------------------*
*& Sıfır alanlar boş olarak görüntülenir.
*&-------------------------------------------------------------*
  DEFINE no_zero.
    clear ls_fcat .
    ls_fcat-no_zero = 'X'.
    modify ct_fcat from ls_fcat
           transporting no_zero where fieldname = &1.
  END-OF-DEFINITION.
