" Requirements check
let s:textprop_enable = has('textprop')
let s:termguicolor_enable = has('termguicolors')
let s:error_prefix = '[Error! colortips.vim]'
if !s:textprop_enable
    echoerr '[colortips] textprop feature is disable.'
endif
if !s:termguicolor_enable
    echoerr '[colortips] termguicolors feature is disable.'
endif

if !(s:textprop_enable*s:termguicolor_enable)
    echoerr '[colortips] not loaded'
    finish
endif

" protect double load
if exists('g:loaded_colortips')
    finish
endif
let g:loaded_colortips = 1

" Auto Commands
augroup colortips-commands
    autocmd!
    autocmd BufEnter,TextChanged,TextChangedI,Syntax * call colortips#enable()
augroup END

