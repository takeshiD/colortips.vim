" Author: takeshid

function! colortips#autocommand() abort
    if g:colortips_enable
        call colortips#update()
    endif
endfunction

function! colortips#enable() abort
    call colortips#update()
    let g:colortips_enable = 1
endfunction

function! colortips#disable() abort
    call colortips#clear()
    let g:colortips_enable = 0
endfunction

function! colortips#toggle() abort
    if g:colortips_enable
        call colortips#disable()
    else
        call colortips#enable()
    endif
endfunction

function! colortips#update()
    let l:lines = s:get_buf_displayline()
    let l:lines = s:merge_lines(l:lines)
    let l:matches = []
    for l:line in l:lines
        let l:matches += s:matchbufline('%', s:pattern, l:line.top, l:line.bottom)
        call prop_clear(l:line.top, l:line.bottom)
    endfor
    if empty(l:matches)
        return
    endif
    try
        let l:prop_type_id = 0
        for l:match in l:matches
            let l:type_name_tips = 'Colortips' .. l:prop_type_id
            let l:type_name_fill = 'ColortipsFill' .. l:prop_type_id
            let l:colorcode = s:parse_colorcode(l:match.text)
            let l:hlgroup_tips = {'name': l:type_name_tips,
                               \'guifg': l:colorcode
                               \}
            let l:hlgroup_fill = {'name': l:type_name_fill,
                               \'guibg': l:colorcode
                               \}
            call hlset([l:hlgroup_tips, l:hlgroup_fill])
            call prop_type_delete(l:type_name_tips)
            call prop_type_delete(l:type_name_fill)
            call prop_type_add(l:type_name_tips, {'highlight':l:type_name_tips})
            call prop_type_add(l:type_name_fill, {'highlight':l:type_name_fill})
            let l:lnum = l:match.lnum
            let l:col = l:match.byteidx+1
            let l:length = len(l:match.text)
            if g:colortips_left_visible
                call prop_add(l:lnum, l:col, {'type':l:type_name_tips, 'text': g:colortips_left_char})
            endif
            if g:colortips_right_visible
                call prop_add(l:lnum, l:col+l:length, {'type':l:type_name_tips, 'text': g:colortips_right_char})
            endif
            if g:colortips_fill_visible
                call prop_add(l:lnum, l:col, {'type':l:type_name_fill, 'length': l:length})
            endif
            let l:prop_type_id += 1
        endfor
    catch /E966/|E964/
        call s:error_at('prop_add: invalid argument ' .. 'lnum=' .. l:lnum .. ',col=' .. l:col .. ',matchtext=' .. "\'" .. l:match.text .. "\'", v:exception, v:thowpoint)
    endtry
endfunction

function! colortips#clear() abort
    call prop_clear(1, line('$'))
endfunction


"############# script locals #########################
let s:pattern_hex6 = '#\x\{6\}\ze\%(\_W\|$\)'
let s:pattern_hex3 = '#\x\{3\}\ze\%(\_W\|$\)'
let s:pattern_rgb  = 'rgb(\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*)'
let s:pattern_rgba = 'rgba(\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\d\{1,3\}\s*,\s*\(\d\+\.\?\d*\|\d*\.\?\d\+\)\s*)'
let s:pattern_list = [
            \s:pattern_hex6,
            \s:pattern_hex3,
            \s:pattern_rgb,
            \s:pattern_rgba,
            \]
let s:pattern = '\%(' .. join(s:pattern_list, '\|') .. '\)'


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

def! s:parse_colorcode(colorcode: string): string
    # Hex pattern: expect "#00ff00" or "#0f0"
    if colorcode[0] ==? "#"
        if len(colorcode[1 :]) == 6
            return colorcode
        elseif len(colorcode[1 :]) == 3
            return printf("#%s%s%s", colorcode[1] .. colorcode[1], colorcode[2] .. colorcode[2], colorcode[3] .. colorcode[3])
        endif
    endif
    # RGB pattern: expect rgb(255,0,0)
    if colorcode[: 3] ==? "rgb("
        var rgb = split(colorcode[4 : -2], ",")
        var r = s:between(str2nr(rgb[0]), 0, 255)
        var g = s:between(str2nr(rgb[1]), 0, 255)
        var b = s:between(str2nr(rgb[2]), 0, 255)
        return printf("#%02x%02x%02x", r, g, b)
    endif
    # RGBA pattern: expect rgba(255,0,0,0.6)
    if colorcode[: 4] ==? "rgba("
        var rgba = split(colorcode[5 : -2], ",")
        var r = s:between(str2nr(rgba[0]), 0, 255)
        var g = s:between(str2nr(rgba[1]), 0, 255)
        var b = s:between(str2nr(rgba[2]), 0, 255)
        var fg = [r, g, b]
        var alpha = s:between(str2float(rgba[3]), 0, 1.0)
        var bg_hex = get(hlget("Normal")[0], "guibg", "#ffffff")
        var bg = s:hex2list(bg_hex)
        var ret = s:compose_color(fg, bg, alpha)
        return printf("#%02x%02x%02x", ret[0], ret[1], ret[2])
    endif
    return "#ffffff"
enddef

function! s:get_buf_displayline(buf)
    let l:bufnr = bufnr(buf)
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

if exists('*matchbufline')
    let s:matchbufline = function('matchbufline')
else
    " Vim9
    def! s:matchbufline(buf: string, pat: string, lnum: number, end: number, dict: dict<bool> = null_dict): list<dict<any>>
        # var dict = get(a:, 1, {'submatches': v:false})
        var result = []
        var lines = getbufline(buf, lnum, end)
        for i in range(len(lines))
            var element = get(lines, i, '')
            var start = 0
            while start < len(element)
                var match = matchstrpos(element, pat, start) 
                if empty(match[0])
                    break
                endif
                call add(result, {'lnum': lnum + i, 'byteidx': match[1], 'text': match[0]})
                start = match[2]
            endwhile
        endfor
        return result
    enddef
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
