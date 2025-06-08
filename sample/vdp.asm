  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

  include "util.asm"
  include "ichigojam_font.asm"

init:
  call screen1
  call set_ichigojam_font

  LD HL, buffer  ; 転送元のRAM
  LD DE, 0x1800  ; 転送先のVRAMアドレス [SCREEN 1の name table]
  LD BC, 768     ; 転送サイズ
  call writevram

  ld hl, color
  ld de, 0x2000
  ld bc, 32
  call writevram
  
end:
  jp end

; 転送元のネームパターン (ROM)
buffer:
  repeat i, 768
    db i
    ;db 'a'
  endr

color:
  repeat i, 32
    db 0xf1
  endr
