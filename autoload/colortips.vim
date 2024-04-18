" Author: takeshid

function! colortips#enable() abort
    call s:color_highlight()
endfunction

function! colortips#disable() abort
endfunction

function! colortips#toggle() abort
endfunction

function! colortips#update() abort
endfunction

let g:pattern_hex3 = '#[0-9a-fA-F]\{3\}\ze[^0-9a-fA-F]'
let g:pattern_hex6 = '#[0-9a-fA-F]\{6\}'
let g:pattern_rgb  = 'rgb(\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*)'
let g:pattern_rgba = 'rgba(\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\(\d\+\.\?\d*\|\d*\.\?\d\+\)\s*)'

function! colortips#pattern() abort
    let l:pattern_list = [
                \ g:pattern_hex3,
                \ g:pattern_hex6,
                \ g:pattern_rgb,
                \ g:pattern_rgba,
                \]
   return '\(' .. join(l:pattern_list, '\|') .. '\)'
endfunction

function! s:compose_color(fg, bg, alpha) abort
    let l:fg_norm = mapnew(a:fg, {_,x -> x/256.0})
    let l:bg_norm = mapnew(a:bg, {_,x -> x/256.0})
    let l:composed = [
                \ (l:bg_norm[0]*(1-a:alpha) + fg_norm[0]*a:alpha)*255,
                \ (l:bg_norm[1]*(1-a:alpha) + fg_norm[1]*a:alpha)*255,
                \ (l:bg_norm[2]*(1-a:alpha) + fg_norm[2]*a:alpha)*255,
                \]
    return mapnew(l:composed, {_,x -> float2nr(x)})
endfunction

function! s:hex2list(hexcolor) abort
    let l:r = str2nr(a:hexcolor[1:2],16)
    let l:g = str2nr(a:hexcolor[3:4],16)
    let l:b = str2nr(a:hexcolor[5:6],16)
    return [l:r, l:g, l:b]
endfunction

function! s:parse_colorcode(colorcode) abort
    " Hex pattern: expect '#00ff00' or '#0f0'
    if a:colorcode[0] ==? '#'
        if len(a:colorcode[1:]) == 6
            return a:colorcode
        elseif len(a:colorcode[1:]) == 3
            return printf('#0%s0%s0%s',a:colorcode[1],a:colorcode[2],a:colorcode[3])
        endif
    endif
    " RGB pattern: expect rgb(255,0,0)
    if a:colorcode[:3] ==? 'rgb('
        let l:rgb = split(a:colorcode[4:-2], ',')
        let l:r = s:between(str2nr(l:rgb[0]), 0, 255)
        let l:g = s:between(str2nr(l:rgb[1]), 0, 255)
        let l:b = s:between(str2nr(l:rgb[2]), 0, 255)
        return printf('#%02x%02x%02x', l:r, l:g, l:b)
    endif
    " RGBA pattern: expect rgba(255,0,0,0.6)
    if a:colorcode[:4] ==? 'rgba('
        let l:rgba = split(a:colorcode[5:-2], ',')
        let l:r = s:between(str2nr(l:rgba[0]), 0, 255)
        let l:g = s:between(str2nr(l:rgba[1]), 0, 255)
        let l:b = s:between(str2nr(l:rgba[2]), 0, 255)
        let l:fg = [l:r,l:g,l:b]
        let l:alpha = s:between(str2float(l:rgba[3]), 0, 1.0)
        let l:bg_hex = get(hlget('Normal')[0], 'guibg', '#ffffff')
        let l:bg = s:hex2list(l:bg_hex)
        let l:ret = s:compose_color(l:fg, l:bg, l:alpha)
        return printf('#%02x%02x%02x', l:ret[0], l:ret[1], l:ret[2])
    endif
endfunction

   
let s:prop_type_name = 'ColorTips'
let s:prop_type_id = 0
let s:prop_types = []
function! s:color_highlight() abort
    let l:matches = s:matchbufline('%', colortips#pattern(), 1, '$')
    if empty(l:matches)
        return
    endif
    call prop_clear(1, line('$'))
    for l:match in l:matches
        let l:type_name = s:prop_type_name . s:prop_type_id
        let l:colorcode = l:match.text
        let l:hlgroup = {'name': l:type_name,
                    \'guifg': s:parse_colorcode(l:colorcode)
                    \}
        call hlset([l:hlgroup])
        call prop_type_delete(l:type_name)
        call prop_type_add(l:type_name, {'highlight':l:type_name})
        let l:lnum = l:match.lnum
        let l:col = l:match.byteidx+1
        call prop_add(l:lnum, l:col, {'type':l:type_name, 'text': '■'})
        let s:prop_type_id += 1
    endfor
    let s:prop_type_id = 0
endfunction

"####################### Utility functions ######################
if exists('*matchbufline')
    let s:matchbufline = function('matchbufline')
else
    function! s:matchbufline(buf, pat, lnum, end, ...) abort
        let l:dict = get(a:, 1, {'submatches': v:false})
        let l:result = []
        let l:lines = getbufline(a:buf, a:lnum, a:end)
        for l:lnum in range(1, len(l:lines)+1)
            let l:element = get(l:lines, l:lnum-1, '')
            let l:start = 0
            while l:start<len(l:element)
                let l:match = matchstrpos(l:element, a:pat, l:start) 
                if empty(l:match[0])
                    break
                endif
                call add(l:result, {'lnum':l:lnum, 'byteidx':l:match[1], 'text':l:match[0]})
                let l:start = l:match[2]
            endwhile
        endfor
        return l:result
    endfunction
endif

function! s:between(target, lower, upper)
    if a:target < a:lower
        return a:lower
    elseif a:upper < a:target
        return a:upper
    else
        return a:target
    endif
endfunction

