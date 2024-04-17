" Author: takeshid

function! colortips#enable() abort
    call s:color_highlight()
endfunction

function! colortips#disable() abort
endfunction

function! colortips#toggle() abort
endfunction


let s:prop_type_name = 'ColorTipsHighlight'
let s:prop_type_id = 0
let s:prop_types = []
"
function! s:color_highlight() abort
    call prop_clear(1, line('$'))
    let l:matches = s:matchbufline('%', '#[0-9a-fA-F]\{6\}', 1, '$')
    if empty(l:matches)
        return
    endif
    for l:match in l:matches
        let l:type_name = s:prop_type_name . s:prop_type_id
        let l:colorcode = l:match.text
        let l:hlgroup = {'name': l:type_name,
                    \'guifg': s:parse_colorcode(l:colorcode)
                    \}
        call hlset([l:hlgroup])
        call prop_type_add(l:type_name, {'highlight':l:type_name})
        let l:lnum = l:match.lnum
        let l:col = l:match.byteidx+1
        call prop_add(l:lnum, l:col, {'type':l:type_name, 'text': '▇▇'})
    endfor
endfunction

function! s:parse_colorcode(colorcode) abort
    return colorcode
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
