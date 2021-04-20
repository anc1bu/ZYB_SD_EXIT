*&---------------------------------------------------------------------*
*&  Include           ZXV6PU13
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      C_VMCFA STRUCTURE  VMCFAO
*"----------------------------------------------------------------------
DATA: ls_vbrk LIKE vbrk,
      l_vmcfa LIKE vmcfao.

CLEAR ls_vbrk.

LOOP AT c_vmcfa INTO l_vmcfa.
  CLEAR ls_vbrk.
  SELECT SINGLE * FROM vbrk INTO ls_vbrk
      WHERE vbeln EQ l_vmcfa-vbeln.

  l_vmcfa-xblnr = ls_vbrk-xblnr.
  l_vmcfa-zztknum = ls_vbrk-zztknum.
  l_vmcfa-zzintac = ls_vbrk-zzintac.
  MODIFY c_vmcfa FROM l_vmcfa.
ENDLOOP.
