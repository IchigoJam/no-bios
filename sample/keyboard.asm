  H_TIMI = 0xFD9F

  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

  include "util.asm"
  include "ichigojam_font.asm"

init:
  call screen1

  di
  call set_ichigojam_font
  ei

  call key_init

  call init_vbl_counter

  ld hl, color
  ld de, 0x2000
  ld bc, 32
  di
  call writevram
  ei

  call init_screen

loop:
  ; test
  ;call puttest
  ;call puttest2
  
  ld hl, [counter]
  ld de, buffer
  call putdec5

  call putkeys
  jr loop

init_screen:
  ; init screen
  ld hl, buffer
  ld bc, 768
  ld d, 0
init_screen_loop:
  ld [hl], d
  inc d
  inc hl
  dec bc
  ld a, b
  or c
  jp nz, init_screen_loop
  ret

puttest:
  ld hl, [counter]
  ld a, l
  ld de, buffer + 32
  call putbin8
  ret

puttest2:
  ld hl, [counter]
  ld a, l
  and 0xf
  add a, '0'
  ld hl, buffer + (23 * 32)
  ld [hl], a
  ret

putkeys:
  ld de, buffer + 32 * 2
  ld hl, key_map
  ld b, key_n
main_loop:
  ld a, [hl]
  push hl
  push de
  push bc
  call putbin8
  pop bc
  pop de
  ld hl, 32
  add hl, de
  
  ld_de_hl ; ?? このマクロを使うと実行できなくなる
  ;push hl
  ;pop de

  pop hl
  inc hl
  djnz main_loop
  ret

; 割り込みで呼ばれるハンドラ
vbl_handler:
  push af
  push hl

  in a, [0x99] ; reset event

  ld hl, counter
  inc [hl]
  jr nz, vbl_handler_skip
  inc hl
  inc [hl]
vbl_handler_skip:

  push de
  push bc
  LD hl, buffer  ; 転送元のRAM
  LD de, 0x1800  ; 転送先のVRAMアドレス [SCREEN 1の name table]
  LD bc, 768     ; 転送サイズ
  call writevram

  call key_scan

  pop bc
  pop de

  pop hl
  pop af

  call H_TIMI_BACKUP      ; 元の H.TIMI を呼び出す（忘れずに！）
  ei
  ret

; 割り込みハンドラを設定
init_vbl_counter:
  ; 旧フックをバックアップ
  ld hl, H_TIMI
  ld de, H_TIMI_BACKUP
  ld bc, 5
  ldir

  ; H.TIMI フックを書き換え
  ld hl, vbl_handler
  ld a, 0xc3
  ld [H_TIMI], a
  ld [H_TIMI + 1], hl
  ret

color:
  repeat i, 32
    db 0xf1
  endr

key_init:
  ld b, 8
  ld hl, key_map
key_init_loop:
  ld [hl], 0xff
  djnz key_init_loop
  ret

; keymap https://note.com/msx_z80_program/n/na899d210d27c
; keymap https://www.msx.org/wiki/Keyboard_Matrices#JIS_Matrix
key_n = 12
key_scan:
  ld hl, key_map
  ld b, key_n
  ld d, 0
scan_loop:
  ld a, d
  ld c, 0xAA        ; 行選択ポート ポートC 下位4bit = kbd
  out [c], a        ; 行選択
  ld c, 0xA9        ; 入力ポート ポートB
  in a, [c]         ; キー状態読み取り
  ld [hl], a        ; 結果をバッファへ（1=離してる, 0=押してる）
  inc d
  inc hl
  djnz scan_loop
  ret

  org 0xc000 ; RAM

buffer:
  space 768
H_TIMI_BACKUP:
  space 5             ; 元のH.TIMI（5バイト）
counter:
  dw 0             ; カウンタ変数 2byte
key_map:
  space key_n
