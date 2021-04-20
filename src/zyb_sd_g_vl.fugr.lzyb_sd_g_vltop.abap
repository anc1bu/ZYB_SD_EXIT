FUNCTION-POOL ZYB_SD_G_VL.                  "MESSAGE-ID ..

* INCLUDE LZYB_SD_G_VLD...                   " Local class definition

DATA:
  it_shp01 LIKE zyb_sd_t_shp01 OCCURS 0 WITH HEADER LINE,
  it_shp02 LIKE zyb_sd_t_shp02 OCCURS 0 WITH HEADER LINE.

CONSTANTS:
  gc_lfart_ihrpro TYPE lfart VALUE 'ZT06'.
