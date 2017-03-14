A tiny GTK slideshow application written in *Lua* with help of the amazing *lgi* module.

Can be installed with `sudo luarocks install slajd-dev-2.rockspec`.

The text parser goes over lines and checks their first character.

- `#` means *title*
- `&` means *font* and is applied to the whole presentation
- `%` means *color*, its followed by a `b` or `f` and three numbers
  - `b` means background color
  - `f` means foreground color
- `$` means *image* (it's always centered)
- `\n` is a slide splitter
- if the first character doesn't match any of those it means text

Move between slides with `<-` and `->` and reload from file(while open) with `F5`.
