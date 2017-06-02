command! -range ConvertPath2Unix <line1>,<line2> :call ConvertPathWithCygpath('to_unix')
command! -range ConvertPath2Win <line1>,<line2> :call ConvertPathWithCygpath('to_win')
function! ConvertPathWithCygpath(option) range
    if !executable('cygpath.bat')
        let msg = "Error. cygpath.bat is not found" 
		echohl WarningMsg | echo msg | echohl None
        return
    endif

    " Pick up selected lines except from empty or only space line.

    let lines = []
    for line in getline(a:firstline, a:lastline)
        if match(line, "^[ \n]*$") == -1
            call add(lines, shellescape(line)) 
        endif
    endfor

    if len(lines) == 0
        let msg = "Error. No valid lines are selected"
		echohl WarningMsg | echo msg | echohl None
        return
    endif

    " Do cygpath and replace lines with converted paths.

    let option_of  = {'to_win' : ' -w ', 'to_unix' : ' -u '}
    let cyg_option = option_of[a:option]
    let cyg_cmd    = printf('cygpath.bat %s %s', cyg_option, join(lines, " "))

    let ret = system(cyg_cmd)

    if v:shell_error
        echoerr "cygpath command failed. command: " . cmd
        return
    endif

    let orig = @@
    silent normal gvd

    let @@ = ret
    silent normal "0p

    let @@ = orig
endfunction
