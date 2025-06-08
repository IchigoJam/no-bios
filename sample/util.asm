  ; HL 転送元, DE 転送先, BC サイズ
writevram:
  LD A, E       ; low 8bit
  OUT [0x99], A
  LD A, D       ; high 6bit + 書き込み指定（bit 6 = 0）
  AND 0x3F
  OR 0x40       ; bit6 = 1: 書き込みモード
  OUT [0x99], A
writevram_loop:
  ld a, [hl]
  out [0x98], a
  inc hl
  dec bc
  ld a, b
  or c
  jp nz, writevram_loop ; jrだと分岐時2state遅い
  ret

screen1:
  ; pattern name table, 1800h, 1b00h, 768
  ; pattern generator table 0000h, 0800h, 2048
  ; sprite attribute table, 1b00h, 1b80h, 128
  ; color table, 2000h, 2020h, 32
  ; palette table, 2020h, 2040h, 32
  ; sprite generator table, 3800h, 4000h, 2048

  ; VDPレジスタを使って SCREEN1 相当のモードに設定
  LD C, 0x99

  ; レジスタ0: Graphics1モード（SCREEN 1相当）
  LD B, 0b0000_000_0 ; bit3-1 graphics1
  ;LD B, 0b0011_011_0 ;0x36: mode bits = 01（Graphics I）
  OUT [C], B
  LD B, 0 | 0x80
  OUT [C], B

  ; レジスタ1: 表示ON + スプライトサイズ 8x8 + VBL割込有効
  ;LD B, 0b11010000 ; 0xD0 bit7=1[画面ON], bit6=1[スプライトON], bit5=0[16x16=0], bit4=1[INT]
  LD B, 0b0_1_1_00_0_0_0 ; 7:0, 6:show 1, 5:vsync 1, 4-3:graphics1 0, 2:0, 1:sprite8x8, 0:sprite big
  OUT [C], B
  LD B, 1 | 0x80
  OUT [C], B

  ; 名前テーブル #2
  LD B, 0x1800 >> 10   ; アドレス 0x1800 >> 10
  OUT [C], B
  ld b, 0x80 | 2 ; レジスタ#2
  OUT [C], B

  ; カラーテーブル #3, #10
  LD B, 0x2000 >> 6           ; 0x2000 >> 6 = 0x80
  OUT [C], B
  ld b, 0x80 | 3 ; レジスタ#3
  OUT [C], B
  
  ; for MSX2
  ;LD B, 0x2000 >> 14          ; 0x2000 >> 14
  ;OUT [C], B
  ;ld b, 0x80 | 10 ; レジスタ#10
  ;OUT [C], B


  ; パターンジェネレータ #4
  LD B, 0x0000 >> 11    ; 0x0000 >> 11
  OUT [C],B
  ld b, 0x80 | 4 ; レジスタ#4
  OUT [C],B

  ; スプライト属性 #5, #11
  LD B, 0x1b00 >> 7    ; 0x1b00 >> 7
  OUT [C], B
  LD b, 0x80 | 5        ; レジスタ番号5
  OUT [C], B

  ; for MSX2
  ;LD B, 0x1b00 >> 15    ; 0x1b00 >> 15
  ;OUT [C],B
  ;LD b, 0x80 | 11        ; レジスタ番号11
  ;OUT [C], B

  ; スプライトパターン
  LD B, 0x3800 >> 11     ; 0x3800 >> 11
  OUT [C],B
  ld b, 0x80 | 6
  OUT [C],B

  ; レジスタ7: 前景色、周辺色設定
  ; 0:透明 1:黒 2:緑 3:明るい緑 4:暗い青 5:明るい青 6:暗い赤 7:シアン 8:赤　9:明るい赤 a:暗い黄 b:明るい黄 c:暗い緑 d:マゼンダ e:灰色 e:灰色 f:白
  ld b, 0xf1           ; 文字色:白=15、周辺:黒=0 → 0xF1
  out [c], b
  ld b, 7 | 0x80 ; レジスタ#7
  out [c], b

  ret

change_palette:
  di
  ld c, 0x99
  out [c], a
  ld a, 17 | 0x80
  out [c], a
  ei
  ld c, 0x9a
  out [c], b
  out [c], c
  ret

ld_iy_pix macro
  push af
  push hl
  LD A, [IX + 0] ; // disasm failed
  LD L, A
  LD A, [IX + 1] ; // disasm failed
  LD H, A
  ld_iy_hl
  pop hl
  pop af
endm

sub_hl_iy macro
  push bc
  and a
  push iy
  pop bc
  sbc hl, bc
  pop bc
endm

ld_hl_de macro
  push de
  pop hl
endm

ld_de_hl macro
  push hl
  pop de
endm

ld_iy_hl macro
  push hl
  pop iy
endm
  
ld_pde_c macro
  push hl
  ld_hl_de
  ld [hl], c
  pop hl
endm

add_hl_iy macro
  push de
  push iy
  pop de
  add hl, de
  pop de
endm

; putdec5(DE, HL)
; HL → DEに5桁の10進法文字列を出力（先頭0埋め）
; HL = 入力値
; DE = 出力バッファ（5バイト）
; 使用レジスタ：A, B, C, D, E, HL, DE, IX
putdec5:
  ld ix, div_table
  ld b, 5
dec5_1:
  ld c, '0' - 1
  ld_iy_pix
dec5_loop:
  inc c
  sub_hl_iy
  jr nc, dec5_loop
  add_hl_iy
  ld_pde_c

  inc ix
  inc ix
  inc de
  djnz dec5_1
  ret
div_table:
  dw 10000, 1000, 100, 10, 1

; putbin(DE, A)
; A → DEに8桁の2進法文字列を出力
; A = 入力値
; DE = 出力バッファ（8バイト）
; 使用レジスタ：A, B, C, D, E, L, DE
putbin8:
  ld b, 0x80
putbin8_1:
  ld c, '0'
  ld l, a
  and b
  jr z, putbin8_skip
  inc c
putbin8_skip:
  ld_pde_c
  inc de
  srl b
  ld a, l
  jr nc, putbin8_1
  ret

