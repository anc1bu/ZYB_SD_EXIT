FUNCTION-POOL ZYB_SD_G_VF.                  "MESSAGE-ID ..

* INCLUDE LZYB_SD_G_VFD...                   " Local class definition

DATA:
  cf_retcode TYPE sy-subrc.

* Job
  DATA:
    l_number         TYPE tbtcjob-jobcount,
    l_name           TYPE tbtcjob-jobname,
    print_parameters TYPE pri_params,
    number           TYPE tbtcjob-jobcount.

  DATA:
    gv_sdlstrttm   LIKE tbtcjob-sdlstrttm,
    gv_released(1).

  DATA:
    tb_joblog LIKE tbtc5  OCCURS 0 WITH HEADER LINE.
