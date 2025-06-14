  org 0x4000
  dw 0x4241, init, 0, 0, 0, 0, 0, 0

init:
  ;psg.writeReg(8, 10); // volume A
  ;const tone = 0x1AC;
  ;psg.writeReg(0, tone);
  ;psg.writeReg(1, tone >> 8);

  ld a, 7
  ld e, 0b00111000
  call writepsg

  ld a, 8
  ld e, 10
  call writepsg

  ;tone = 0x1ac
  tone = 0xac
  
  ld a, 0
  ld e, tone & 0xff
  call writepsg

  ld a, 1
  ld e, tone >> 8
  call writepsg

  halt
loop:
  jr loop

writepsg: ; A: port, E: data 
	out	[0xa0], a
	ld	a, e
  out	[0xa1], a
	ret
