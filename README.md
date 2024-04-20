# colortips.vim
color tips for vim

## Requirements
This plugin require following two features.
* Vim9 or newer(need vim9script)
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

![colortips demo](images/colortips_demo.png)

## Enable
```vim
let g:colortips_enable = 1 " default
```

## Commands
```vim
:ColorTipsEnable
:ColorTipsDisable
:ColorTipsToggle
```

## Customization
### Tip Position Visible
#### only left tips(Default)
```vim
let g:colortips_left_visible = 1
let g:colortips_right_visible = 0
let g:colortips_fill_visible = 0
```

#### add right tips
```vim
let g:colortips_left_visible = 1
let g:colortips_right_visible = 1
let g:colortips_fill_visible = 0
```

#### add also fill
```vim
let g:colortips_left_visible = 1
let g:colortips_right_visible = 1
let g:colortips_fill_visible = 1
```

### Tips Character
### Default
```vim
let g:colortips_left_char = '■'
let g:colortips_right_char = '■'
```
