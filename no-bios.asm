  ; NO-BIOS

  org 0x0000

  jp init

  ; VDPポート番号
  space 0x6 - $
  db 0x98 ; VDP READ
  db 0x98 ; VDP WRITE

  ; 割り込み禁止
init:
  di

  ; I/O初期化
  ; PPI 8255 (PortA: slot, PortB: in keyboard, PortC: out keyboard and caps)
  ld a, 0b1_00_0_0_0_1_0 ; PortA: out, PortB: in, PortC: out
  out [0xab], a ; パラレルポート8255(PPI)のモード設定

  ; 各スロットのページ設定 (NO-BIOS/ROM1-1/ROM1-2/RAM)
  ld a, 0b11_01_01_00  ; P3=3, P2=1, P1=1, P0=0
  out [0xa8], a ; パラレルポート ポートA で制御

  ; スタックポインタ初期化
  ld sp, 0xf380 ; 0xf380-0xffff の3200byteはシステム予約

  ; タイマー割り込みの初期設定
  H_TIMI = 0xfd9f
  ld hl, H_TIMI
  ld [hl], 0xc9 ; 何もせずリターン

  ; 割り込み許可
  ei

  ; ROMの実行アドレスへジャンプ
  ld hl, [0x4002]
  push hl
  ret

  ; 割り込み処理
  space 0x38 - $
  jp H_TIMI
