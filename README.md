# NO-BIOS

- NO-BIOSは、Z80 + VDP(TMS9918) + PPI(8255) によるパソコン向けの最小限ROMです。
- BIOSがないので、画面表示や入力はI/Oを使って、直接制御してください。
- 32KBまでのROMに対応しています。
- 作成したROMファイルは、MSXでも動かせます。

## build

to make ichigojam-font.bin with [Deno](https://deno.com/)
```sh
deno -A makefont.js
```

to make no-bios.rom with [ZMA](https://github.com/hra1129/zma)
```sh
zma no-bios.asm no-bios.rom
```

## install to openMSX

install [openMSX](https://openmsx.org/) for macOS
```sh
brew install openmsx
```

install NO-BIOS to [openMSX](https://openmsx.org/)
```sh
cp NO-BIOS_JP.xml /opt/homebrew/Cellar/openmsx/20.0/openMSX.app/Contents/Resources/share/machines/
cp no-bios.rom /opt/homebrew/Cellar/openmsx/20.0/openMSX.app/Contents/Resources/share/machines/
```

## how to run

with [openMSX](https://openmsx.org/)
```sh
openmsx -machine NO-BIOS_JP -cart sample/keyboard.rom
```

or drop the rom file other emulators

## how to build a sample

build with [ZMA](https://github.com/hra1129/zma)
```sh
cd sample
sh c.sh keyboard
```
- [sample/vdp.asm](sample/vdp.asm) VDPを使って表示するだけ
- [sample/vsync.asm](sample/vsync.asm) 垂直同期割り込みを使用
- [sample/keyboard.asm](sample/keyboard.asm) キーボード入力も使用

## reference

- Assembler - [ZMA](https://github.com/hra1129/zma)
- font - [IchigoJam font](https://github.com/IchigoJam/ichigojam-font) CC BY [IchigoJam](https://ichigojam.net/)
