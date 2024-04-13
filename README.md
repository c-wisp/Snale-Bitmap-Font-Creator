# Snale-Bitmap-Font-Creator
Creates .fnt files out of raster images for usage in Godot 4.X

It's heavily based on Andreas Jönsson's (www.AngelCode.com) Bitmap Font Generator and ElectricBlueberry's Texture-Fonts plugin (https://github.com/ElectronicBlueberry/Texture-Fonts) (go check them out)

It may also work in 3.X, but that isn't the main focus for this project

## Upcoming / Roadmap

- A preferences/help window
- Multipage support
- Minor QOL changes

## How to Use
To get started, simply click 'Open File' and select the raster image (or .fnt file) of your choosing. Doing so will unlock the 'Export Font' button and will reset any data already inputted to the default values.

From here one may specify the face, size, spacing, and arragement of the letters/symbols.

**NOTICE:** When inputting the rows and column ct. and the margins -- the boxes highlighted in blue (including the pixels underneath) are what will be used, anything highlighted in magenta/fuschia will be ignored on export.

### Adding Outlines and/or Drop Shadows
To do this it is recomended to recolor the sprite so that the background is black, the characters themself (not the outline) is either 255 r,g, or b -- reserving this color for it specifically.
And coloring the outline with one of the two remaining colors.

Then one would run this application, filling in the usual data. But before exporting, go into the "edit" window and set the following values:

```
alphaChannel : 3 (unused)
redChannel : 0 (if it is the character color), 1 (if it is the outline/drop shadow color), or 3 (unused)
blueChannel : 0 (if it is the character color), 1 (if it is the outline/drop shadow color), or 3 (unused)
greenChannel : 0 (if it is the character color), 1 (if it is the outline/drop shadow color), or 3 (unused)
```

After that, the file should be ready to export.

### Editing Specific Characters
To edit a singular character, press 'Add SP Char Data' to summon a small array of variables that let you change the size and horizontal offset of the character specified. Pressing 'Delete' on one of these will remove it.

### Kerning
To add or edit kerning pairs, select the 'Kerning Pairs' tab in the bottom right corner of the application. From here one may add as many pairs as needed by pressing 'Add Kerning Pair'. When a pair is created, one will need to fill out the pair name and it's offset.

Examples of these pairs (exclude brackets when actually inputting pairs):

	[ty] (when a 't' precedes a 'y')
	[*i] (when anything precedes an 'i')
	["*"2] (when an asterisk precedes a '2')

### Previewing the Font
To see what the text would look like early, look in the top right for the 'Text Preview' and type in some sample text in it's input. **Note -- The output will only show up once a sufficient amount of data has been entered in for it to load (this includes the sprite, size, spacing, sheet data, and character arrangement)**

## File Reference
The file structure has been largely left unchanged with use of this software (additions will be marked) and the original can be found at https://www.angelcode.com/products/bmfont/doc/file_format.html

### info

This tag holds information on how the font was generated.

```
face		This is the name of the true type font.
size		The size of the true type font.
bold		The font is bold.
italic		The font is italic.
charset		The name of the OEM charset used (when not unicode).
unicode		Set to 1 if it is the unicode charset.
stretchH	The font height stretch in percentage. 100% means no stretch.
smooth		Set to 1 if smoothing was turned on.
aa		The supersampling level used. 1 means no supersampling was used.
padding		The padding for each character (up, right, down, left).
spacing		The spacing for each character (horizontal, vertical).
outline		The outline thickness for the characters.
```

### common

This tag holds information common to all characters.

```
lineHeight	This is the distance in pixels between each line of text.
base		The number of pixels from the absolute top of the line to the base of the characters.
scaleW		The width of the texture, normally used to scale the x pos of the character image.
scaleH		The height of the texture, normally used to scale the y pos of the character image.
pages		The number of texture pages included in the font.
packed		Set to 1 if the monochrome characters have been packed into each of the texture channels. In this case alphaChnl describes what is stored in each channel.
alphaChnl	Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
redChnl		Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
greenChnl	Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
blueChnl	Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
```

### page

This tag gives the name of a texture file. There is one for each page in the font.

```
id		The page id.
file		The texture file name.
*rows		The amount of rows of characters on the texture.
*columns	The amount of columns of characters on the texture.
*marginX	The horizontal spacing between each sprite on the texture.
*marginY	The vertical spacing between each sprite on the texture.
```

### char

This tag describes on character in the font. There is one for each included character in the font.

```
id		The character id.
x		The left position of the character image in the texture.
y		The top position of the character image in the texture.
width		The width of the character image in the texture.
height		The height of the character image in the texture.
xoffset		How much the current position should be offset when copying the image from the texture to the screen.
yoffset		How much the current position should be offset when copying the image from the texture to the screen.
xadvance	How much the current position should be advanced after drawing the character.
page		The texture page where the character image is found.
chnl		The texture channel where the character image is found (1 = blue, 2 = green, 4 = red, 8 = alpha, 15 = all channels).
```

### kerning

The kerning information is used to adjust the distance between certain characters, e.g. some characters should be placed closer to each other than others.

```
first		The first character id.
second		The second character id.
amount		How much the x position should be adjusted when drawing the second character immediately following the first.
```
