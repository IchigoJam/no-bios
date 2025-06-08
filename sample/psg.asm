  H_TIMI = 0xFD9F

  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

  include "util.asm"
  include "ichigojam_font.asm"
  include "bgmdriver.asm"
bgm001::
  include "bgm1.asm"

init:
  di
  call screen1
  call set_ichigojam_font

  call init_vbl_counter

  ld hl, color
  ld de, 0x2000
  ld bc, 32
  call writevram
  ei

  call screen_clear
  
  ld hl, message
  ld de, 10 + 10 * 32
  call screen_puts

  LD hl, buffer  ; 転送元のRAM
  LD de, 0x1800  ; 転送先のVRAMアドレス [SCREEN 1の name table]
  LD bc, 768     ; 転送サイズ
  di
  call writevram
  ei

play_bgm001::
	ld			hl, bgm001					; 再生するBGMの置かれてるアドレス
	call		bgmdriver_play				; BGM再生開始

loop:
  jr loop

message:
  ds "BGMPLAYER"
  db 0

screen_clear:
  ld hl, buffer
  ld bc, 768
  ld d, 0
screen_clear_loop:
  ld [hl], d
  inc hl
  dec bc
  ld a, b
  or c
  jp nz, screen_clear_loop
  ret

screen_puts:
  ; hl: string (null terminate)
  ; de: pos
  push hl
  ld hl, buffer
  add hl, de
  ld_de_hl
  pop hl
screen_puts_loop:
  ld a, [hl]
  or a
  jr z, screen_puts_ret
  ld_pde_a
  inc de
  inc hl
  jr screen_puts_loop
screen_puts_ret:
  ret

screen_init:
  ld hl, buffer
  ld bc, 768
  ld d, 0
screen_init_loop:
  ld [hl], d
  inc d
  inc hl
  dec bc
  ld a, b
  or c
  jr nz, screen_init_loop
  ret

; 割り込みで呼ばれるハンドラ
vbl_handler:
  push af
  push hl

  in a, [0x99] ; reset event

	call		bgmdriver_interrupt_handler

  ld hl, counter
  ld a, [hl]
  inc a
  ld [hl], a
  sub 30 ; 0.5sec
  jr nz, vbl_handler_skip
  ld a, 0
  ld [hl], a
  ld hl, buffer
  inc [hl]
vbl_handler_skip:
  
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
  LD [H_TIMI], a
  ld [H_TIMI + 1], hl

  ret

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

	include "bgmdriver_work.asm"
