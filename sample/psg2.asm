  H_TIMI = 0xFD9F

  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

  include "util.asm"
  include "ichigojam_font.asm"

init:
  di
  call screen1
  call set_ichigojam_font

  ld hl, counter
  ld a, 0
  ld [hl], a
  ld hl, musiccounter
  ld [hl], a

  call init_vbl_counter

  ld hl, color
  ld de, 0x2000
  ld bc, 32
  call writevram
  ei

  call screen_clear
  
  ld hl, message
  ld de, 12 + 10 * 32
  call screen_puts

  LD hl, buffer  ; 転送元のRAM
  LD de, 0x1800  ; 転送先のVRAMアドレス [SCREEN 1の name table]
  LD bc, 768     ; 転送サイズ
  di
  call writevram
  ei

  call sound_init
  ld e, 10
  call sound_vol1

loop:
  jr loop

message:
  ds "PSG TEST"
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

writepsg: ; A: port, E: data 
	out	[0xa0], a
	ld	a, e
  out	[0xa1], a
	ret

  ; https://www.tatsu-syo.info/TMR/MSXFPSG.html
tonetable: ; 12 * 8 = 96
  dw 3420,3229,3047,2876,2715,2562,2419,2283,2155,2034,1920,1812
  dw 1710,1614,1524,1438,1357,1281,1209,1141,1077,1017, 960, 906
  dw  855, 807, 762, 719, 679, 641, 605, 571, 539, 508, 480, 453
  dw  428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240, 226
  dw  214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120, 113
  dw  107, 101,  95,  90,  85,  80,  76,  71,  67,  64,  60,  57
  dw   53,  50,  48,  45,  42,  40,  38,  36,  34,  32,  30,  28
  dw   27,  25,  24,  22,  21,  20,  19,  18,  17,  16,  15,  14

sound_init:
  ld a, 7
  ld e, 0b00111000
  call writepsg
  ret

  ; e = volume (0-15, 16 = envelope)
sound_vol1:
  ld a, 8
  call writepsg
  ret

  ; a = tone (0 - 95)
sound_tone:
  ld hl, tonetable
  add a, a
  add_hl_a
  ld_de_phl

  ld a, 0
  call writepsg

  ld a, 1
  ld e, d
  call writepsg
  ret

; vsync

; 割り込みで呼ばれるハンドラ
vbl_handler:
  push af
  push hl

  in a, [0x99] ; reset event

  ld hl, counter
  ld a, [hl]
  inc a
  ld [hl], a
  sub 30 ; 0.5sec
  jr nz, vbl_handler_skip
  ld a, 0
  ld [hl], a

  ; 0.5sec loop
  ld hl, musiccounter
  ld a, [hl]
  inc [hl]
  ld hl, music
  add_hl_a
  ld a, [hl]
  cp 0xff
  jr z, musicloop_rest

  call sound_tone

  jr vbl_handler_skip

musicloop_rest:
  ld hl, musiccounter
  ld [hl], 0

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

music:
  oct = 4 * 12
  ; C:0, D:2, E:4, F:5, G:7, A:9, B:11
  db oct + 0, oct + 2, oct + 4, oct + 4
  db oct + 0, oct + 2, oct + 4, oct + 4
  db oct + 7, oct + 4, oct + 2, oct + 0
  db oct + 2, oct + 4, oct + 2, oct + 2

  db oct + 0, oct + 2, oct + 4, oct + 4
  db oct + 0, oct + 2, oct + 4, oct + 4
  db oct + 7, oct + 4, oct + 2, oct + 0
  db oct + 2, oct + 4, oct + 0, oct + 0

  db oct + 7, oct + 7, oct + 4, oct + 7
  db oct + 9, oct + 9, oct + 7, oct + 7

  db oct + 4, oct + 4, oct + 2, oct + 2
  db oct + 0, oct + 0, oct + 0, oct + 0
  
  db 0xff

  org 0xc000 ; RAM

; 転送元のRAM領域
buffer:
  space 768
H_TIMI_BACKUP:
  space 5          ; 元のH.TIMI（5バイト）
counter:
  db 0             ; カウンタ変数
musiccounter:
  db 0
