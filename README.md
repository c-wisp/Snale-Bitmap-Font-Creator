# Snale-Bitmap-Font-Creator
Creates .fnt files out of raster images for usage in Godot 4.X

It's heavily based on Andreas Jönsson's (www.AngelCode.com) Bitmap Font Generator (go check them out)

It may also work in 3.X, but that isn't the main focus for this project

## How to Use
To get started, simply click 'Open File' and select the raster image (or .fnt file) of your choosing. Doing so will unlock the 'Export Font' button and will reset any data already inputted to the default values.

From here one may specify the face, size, spacing, and arragement of the letters/symbols.

**NOTICE:** When inputting the rows and column ct. and the margins -- the boxes highlighted in blue (including the pixels underneath) are what will be used, anything highlighted in magenta/fuschia will be ignored on export.

### Editing Specific Characters
To edit a singular character, press 'Add SP Char Data' to summon a small array of variables that let you change the size and horizontal offset of the character specified. Pressing 'Delete' on one of these will remove it.

### Kerning
not supported atm, come back later

### Previewing the Font
To see what the text would look like early, look in the top right for the 'Text Preview' and type in some sample text in it's input. **Note -- The output will only show up once a sufficient amount of data has been entered in for it to load (this includes the sprite, size, spacing, sheet data, and character arrangement)**

## In Case of Emergency (Manual Creation)
If this software every ceases functionality partial or complete, here is a base reference for every variable used and how they should be formatted. Doing things this way is a tad slow (which was the main reason of making this) but it technically works.

This information can also be found on https://www.angelcode.com/products/bmfont/doc/file_format.html

[basically ctrl-c+v of BFGenerator's web ref]
