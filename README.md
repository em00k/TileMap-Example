# TileMap-Example
ZX Next tilemap example


Tilemap_example.asm loads assets from the SD card

Tilemap_example_allinc.asm has everything incbin into the NEX - which is tilemap.nex

Assemble with supplied sjasmplus 

```
sjasmplus Tilemap_example_allinc.asm --zxnext=cspect
or 
sjasmplus Tilemap_example.asm --zxnext=cspect
```

And run with CSpect with 
```
CSpect -w3 -60 -vsync -zxnext -brk -mmc=.\  tilemap.nex
```
