# colortips.vim
color tips for vim

## Requirements
This plugin require following two features.
* `textprop` feature(Vim 8.1.0579 or newer)
* Terminal-Emulator, Shell, Terminal-Multiplexer support **true-color**

## Installation
### dein.vim
Add folowing text to your `.vimrc`.

```vim
dein#add('takeshid/colortips.vim')
```

## Features
Display colorcode tips such as following representaions.
* `#1a2b3c`
* `#123`
* `rgb(r,b,g)`
* `rgba(r,g,b,a)`

## Customization
### Tip Position
```vim
let g:colortips_pos = 'left'
```
> TODO : add image
```vim
let g:colortips_pos = 'right'
```
> TODO : add image

### Select representation
```vim
let g:colortips_tips = 1 " Default 1 (1:on, 0:off)
```
> TODO : add image

```vim
let g:colortips_fill = 1 " Default 0 (1:on, 0:off)
```
> TODO : add image
