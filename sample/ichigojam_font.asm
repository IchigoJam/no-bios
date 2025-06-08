set_ichigojam_font:
  ld hl, ichigojam_font
  ld de, 0x0
  ld bc, 2048
  call writevram
  ret

ichigojam_font:
  binary_link "ichigojam_font.bin"
