  H_TIMI = 0xFD9F

  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

  include "util.asm"
  include "ichigojam_font.asm"

init:
  call screen1
  call set_ichigojam_font

  call init_vbl_counter

  ld hl, color
  ld de, 0x2000
  ld bc, 32
  call writevram

  ; init screen
  ld hl, buffer
  ld bc, 768
  ld d, 0
loop2:
  ld [hl], d
  inc d
  inc hl
  dec bc
  ld a, b
  or c
  jp nz, loop2

end:
  LD hl, buffer  ; 転送元のRAM
  LD de, 0x1800  ; 転送先のVRAMアドレス [SCREEN 1の name table]
  LD bc, 768     ; 転送サイズ
  call writevram

  jp end

; --- 割り込みで呼ばれるハンドラ
vbl_handler:
  push af
  push hl

  ld hl, counter
  ld a, [hl]
  inc a
  ld [hl], a
  sub 30 ; 0.5sec
  jr nz, skip
  ld a, 0
  ld [hl], a
  ld hl, buffer
  inc [hl]
skip:
  
  pop hl
  pop af
  jp H_TIMI_BACKUP      ; 元の H.TIMI を呼び出す（忘れずに！）

; --- 初期化ルーチン
init_vbl_counter:
  DI

  ; 旧フックをバックアップ
  ld hl, H_TIMI
  ld de, H_TIMI_BACKUP
  ld bc, 5
  ldir

  ; H.TIMI フックを書き換え
  LD HL, vbl_handler
  ld a, 0xc3
  LD [H_TIMI], a
  ld [H_TIMI + 1], hl

  EI
  RET

color:
  repeat i, 32
    db 0xf1
  endr

  org 0xc000 ; RAM

; 転送元のRAM領域
buffer:
  space 768
H_TIMI_BACKUP:
  space 5          ; 元のH.TIMI（5バイト）
counter:
  db 0             ; カウンタ変数
