zma $1.asm $1.rom
# deno --allow-read --allow-import https://ichigojam.github.io/MIX/rom2sh.js $1.rom | sh
#openmsx -machine C-BIOS_MSX2_JP -cart $1.rom
#openmsx -machine C-BIOS_MSX1_JP -cart $1.rom
openmsx -machine NO-BIOS_JP -cart $1.rom
