*&---------------------------------------------------------------------*
*&  Include           ZYBSD_I_VA_MUH
*& Yapılan Kontroller
*& - Dahili Mahsuplaştırma Belgesi için Z1 Muhattabı Belirleme
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*"     VALUE(FIF_PARVW) TYPE  PARVW_4
*"     VALUE(FIF_NRART) TYPE  NRART
*"     VALUE(FIF_ORIGIN_PARVW) TYPE  PARVW_4
*"     VALUE(FIF_ORIGIN_NRART) TYPE  NRART
*"     VALUE(FIF_ORIGIN_PARTNER) TYPE  SD_PARTNER_PARNR
*"     VALUE(FIF_HERTAB) TYPE  HERTAB
*"     VALUE(FIF_VKORG) TYPE  VKORG
*"     VALUE(FIF_VTWEG) TYPE  VTWEG
*"     VALUE(FIF_SPART) TYPE  SPART
*"     VALUE(FIF_OBJECTTYPE) TYPE  SWO_OBJTYP
*"     VALUE(FIF_PROCESSMODE) TYPE  CHAR1
*"  EXPORTING
*"     REFERENCE(FEF_NEW_PARTNERS) TYPE  XFLAG
*"  TABLES
*"      FET_DETERMINATED_PARTNERS
*"                             STRUCTURE  SDPARTNER_DETERMINATED_PARNR
*&---------------------------------------------------------------------*
DATA:
  ls_partner LIKE  sdpartner_determinated_parnr.
CONSTANTS:
  gc_parvw_z1 TYPE parvw_4 VALUE 'Z1',
  gc_parvw_ag TYPE parvw_4 VALUE 'AG',
  gc_vkorg    TYPE vkorg   VALUE '2100',
  gc_vtweg_10 TYPE vtweg   VALUE '10',
  gc_vtweg_30 TYPE vtweg   VALUE '10'.

*&*********************************************************************
*& --> Dahili Mahsuplaştırma Belgesi için Z1 Muhattabı Belirleme
*&*********************************************************************
CLEAR: ls_partner.
CASE fif_parvw.
  WHEN gc_parvw_z1. "" Dahili Mahsuplaştırma İçin Sipariş Veren
    CHECK fif_vkorg EQ gc_vkorg.
    CHECK fif_vtweg EQ gc_vtweg_10 OR fif_vtweg EQ gc_vtweg_30.
    CHECK fif_nrart EQ fif_origin_nrart.
    CHECK fif_origin_parvw EQ gc_parvw_ag.

    fef_new_partners = 'X'.

    ls_partner-parnr = fif_origin_partner.
    APPEND ls_partner TO fet_determinated_partners.
    CLEAR ls_partner.
  WHEN OTHERS.
ENDCASE.
*&*********************************************************************
*& <-- Dahili Mahsuplaştırma Belgesi için Z1 Muhattabı Belirleme
*&*********************************************************************
