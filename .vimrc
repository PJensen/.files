"
" Author: PJensen
" Date: 02/01/2012
" Description: gVim settings file.
"

" Color Scheme Init
colorscheme darkblue

" Tab, Whitespace and Spacing
set ts=3
set sw=3
set expandtab

" Line numbers enabled
set nu

" Set ignore case
set ic

" Enable pattern highlighting
set hls

" Enable show-match
set sm

" Syntax highlighting
syntax on

" Windows
source $VIMRUNTIME/mswin.vim

" Global Abbreviations
:iab <expr> dts strftime("%c")
iabbrev <silent> CWD <C-R>=getcwd()<CR>

" Load vim-gist
set runtimepath+=$HOME/.vim/vim-gist

" Github setup
" and ... this token is invalid.
let g:github_user = substitute(system('git config --get user.name'), "\n", '', '')
let g:github_token = "3b51b179b0c1d190c8835ab2ef00273a"

let g:tab_toggle = 1
	
" F5 kicks this file out as a Gist.
nmap <F5> :Gist -p<CR>

" Perform basic calculation
imap <silent> calc <C-R>=string(eval(input("Calculate: ")))<CR>

" Classic ASP comment...
imap <silent>  ---  <C-R>=CommentBlock(input("Enter comment: "),"'--")<CR>

" Equals alignment
nmap <silent>  ===  :call AlignAssignments()<CR>

" Function: 
" Description: 
function! ToggleTabs()
	syntax match Tab /\t/
	hi Tab gui=underline guifg=blue ctermbg=blue		
endfunction

" Function: CommentBlock
" Description: Given some input, write a comment block.
" See: http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html
function CommentBlock(comment, ...)
    "If 1 or more optional args, first optional arg is introducer...
    let introducer =  a:0 >= 1  ?  a:1  :  "//"

    "If 2 or more optional args, second optional arg is boxing character...
    let box_char   =  a:0 >= 2  ?  a:2  :  "*"

    "If 3 or more optional args, third optional arg is comment width...
    let width      =  a:0 >= 3  ?  a:3  :  strlen(a:comment) + 2

    " Build the comment box and put the comment inside it...
    return introducer . " " . repeat(box_char,width) . "\<CR>"
    \    . introducer . " " . a:comment        . "\<CR>"
    \    . introducer . " " . repeat(box_char,width) . "\<CR>"
endfunction

" Function: CommentBlock
" Description: Given some input, write a comment block.
" See: http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html
function AlignAssignments ()
    "Patterns needed to locate assignment operators...
    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'

    "Locate block of code to be considered (same indentation, no blanks)
    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
    let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
    let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
    if lastline < 0
        let lastline = line('$')
    endif

    "Find the column at which the operators should be aligned...
    let max_align_col = 0
    let max_op_width  = 0
    for linetext in getline(firstline, lastline)
        "Does this line have an assignment in it?
        let left_width = match(linetext, '\s*' . ASSIGN_OP)

        "If so, track the maximal assignment column and operator width...
        if left_width >= 0
            let max_align_col = max([max_align_col, left_width])

            let op_width      = strlen(matchstr(linetext, ASSIGN_OP))
            let max_op_width  = max([max_op_width, op_width+1])
         endif
    endfor

    "Code needed to reformat lines so as to align operators...
    let FORMATTER = '\=printf("%-*s%*s", max_align_col, submatch(1),
    \                                    max_op_width,  submatch(2))'

    " Reformat lines with operators aligned in the appropriate column...
    for linenum in range(firstline, lastline)
        let oldline = getline(linenum)
        let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
        call setline(linenum, newline)
    endfor
endfunction




