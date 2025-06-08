const url = "https://ichigojam.github.io/ichigojam-font/ichigojam-font.json";
const font = await (await fetch(url)).json();

const bin = new Uint8Array(256 * 8);
for (let i = 0; i < font.length; i++) {
  const f = font[i];
  for (let j = 0; j < 8; j++) {
    bin[i * 8 + j] = parseInt(f.substring(j * 2, j * 2 + 2), 16);
  }
}
await Deno.writeFile("ichigojam_font.bin", bin);
