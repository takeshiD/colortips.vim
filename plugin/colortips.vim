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
"
"############### Customization ###############
let g:colortips_enable = get(g:, 'colortips_enable',  1)
" Visibility
let g:colortips_left_visible  = get(g:, 'colortips_left_visible',  1)
let g:colortips_right_visible = get(g:, 'colortips_right_visible', 0)
let g:colortips_fill_visible  = get(g:, 'colortips_fill_visible',  0)
" chars
let g:colortips_left_char   = get(g:, 'colortips_left_char', '■')
let g:colortips_right_char  = get(g:, 'colortips_left_char', '■')

"############### Commands ###############
command! -bar ColortipsEnable  call colortips#enable()
command! -bar ColortipsDisable call colortips#disable()
command! -bar ColortipsToggle  call colortips#toggle()

" Auto Commands
augroup colortips-commands
    autocmd!
    autocmd BufWinEnter,TextChanged,TextChangedI,WinScrolled,Syntax * call colortips#autocommand()
augroup END

