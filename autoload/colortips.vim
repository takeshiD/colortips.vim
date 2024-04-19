" Author: takeshid
" #ff0000 #0f0
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

function! s:get_buf_displayline()
    let l:bufnr = bufnr('%')
    let l:winids = win_findbuf(l:bufnr)
    let l:lines = []
    for l:winid in l:winids
        let l:wininfo = get(getwininfo(l:winid), 0, v:none)
        let l:line = {
                    \'top':get(l:wininfo, 'topline', -1), 
                    \'bottom':get(l:wininfo, 'botline', -1)
                    \}
        call add(l:lines, l:line)
    endfor
    call sort(l:lines, {x,y -> x.top > y.top})
    return l:lines
endfunction

let s:prop_type_name = 'ColorTips'
let s:prop_type_id = 0
let s:prop_types = []

function! s:color_highlight()
    let l:lines = s:get_buf_displayline()
    " echo l:lines
    let l:lines = s:merge_lines(l:lines)
    " echo l:lines
    let l:matches = []
    for l:line in l:lines
        let l:matches += s:matchbufline('%', colortips#pattern(), l:line.top, l:line.bottom)
        call prop_clear(l:line.top, l:line.bottom)
    endfor
    if empty(l:matches)
        return
    endif
    try
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
    catch /E966/|E964/
        call s:error_at('prop_add: invalid argument ' .. 'lnum=' .. l:lnum .. ',col=' .. l:col .. ',matchtext=' .. "\'" .. l:match.text .. "\'", v:exception, v:thowpoint)
    finally
        let s:prop_type_id = 0
    endtry
endfunction

"####################### Utility functions ######################
if exists('*matchbufline')
    let s:matchbufline = function('matchbufline')
else
    function! s:matchbufline(buf, pat, lnum, end, ...) abort
        let l:dict = get(a:, 1, {'submatches': v:false})
        let l:result = []
        let l:lines = getbufline(a:buf, a:lnum, a:end)
        for l:lnum in range(len(l:lines))
            let l:element = get(l:lines, l:lnum, '')
            let l:start = 0
            while l:start<len(l:element)
                let l:match = matchstrpos(l:element, a:pat, l:start) 
                if empty(l:match[0])
                    break
                endif
                call add(l:result, {'lnum':a:lnum+l:lnum, 'byteidx':l:match[1], 'text':l:match[0]})
                let l:start = l:match[2]
            endwhile
        endfor
        return l:result
    endfunction
endif

function! s:between(target, lower, upper) abort
    if a:target < a:lower
        return a:lower
    elseif a:upper < a:target
        return a:upper
    else
        return a:target
    endif
endfunction

function! s:merge(line1, line2) abort
    return {
            \'top':min([a:line1.top,a:line2.top]),
            \'bottom':max([a:line1.bottom,a:line2.bottom]),
            \}
endfunction

function! s:is_overlap(line1, line2) abort
    if !(a:line1.top <= a:line1.bottom && a:line2.top <= a:line2.bottom)
        throw "colortips.vim#exception is_overlap failed"
    endif

    if a:line1.top <= a:line2.top && a:line1.bottom < a:line2.top
        return 0
    else
        return 1
    endif
endfunction

function! s:push(stack, val) abort
    call add(a:stack, a:val)
endfunction

function! s:pop(stack) abort
    return remove(a:stack, -1)
endfunction

function! s:merge_lines(lines) abort
    if len(a:lines) <= 1
        return a:lines
    endif
    let l:result = [] " as using stack
    let l:i = 0
    for l:line in a:lines
        call s:push(l:result, l:line)
        if len(l:result) >= 2
            let l:first = s:pop(l:result)
            let l:second = s:pop(l:result)
            if s:is_overlap(l:first, l:second)
                let l:merged = s:merge(l:first, l:second)
                call s:push(l:result, l:merged)
            else
                call s:push(l:result, l:second)
                call s:push(l:result, l:first)
            endif
        endif
    endfor
    return l:result
endfunction

function! s:error_at(msg, excpetion, throwpoint)
    echohl ErrorMsg
    echomsg "[colortips.vim]" .. a:msg
    echohl None
endfunction
