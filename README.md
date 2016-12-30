Tiny GTK slideshow application written in *Lua* with help of the amazing *lgi* module.

Can be installed with `sudo luarocks install slajd-dev-1.rockspec`.

It can read *Lua* and *text* files. Examples of those are included in the `/examples` folder.

The text parser goes over read lines and checks their first character.

- `#` means *title*
- `%` means *color*, its followed by a `b` or `f` and three numbers
  - `b` means background color
  - `f` means foreground color
- `$` means *image* (it's always centered)
- `\n` is an empty line, next slide
- if the first character doesn't match any of those it means text
