FUNCTION-POOL zyb_sd_g_parti.               "MESSAGE-ID ..

* INCLUDE LZYB_SD_G_PARTID...                " Local class definition
DATA:
  gv_class LIKE klah-class,
  gv_klart LIKE klah-klart,
  gv_obtab LIKE tclt-obtab,
  gv_objec LIKE kssk-objek.

DATA:
  gt_val_num  TYPE STANDARD TABLE OF  bapi1003_alloc_values_num  WITH HEADER LINE,
  gt_val_char TYPE STANDARD TABLE OF  bapi1003_alloc_values_char WITH HEADER LINE,
  gt_val_curr TYPE STANDARD TABLE OF  bapi1003_alloc_values_curr WITH HEADER LINE,
  gt_ret      TYPE STANDARD TABLE OF  bapiret2                   WITH HEADER LINE,
  wa_ret      LIKE  bapiret2.
