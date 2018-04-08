" === PLUGIN MANAGEMENT ===================================================
execute pathogen#infect()
filetype plugin indent on
syntax on

let mapleader=","

set shell=bash "play nicely with fish shell

" Appearance {{{
" Cosmetics {
" Needed for Ubuntu:
set t_Co=256 "16 
let g:solarized_termtrans=1
let g:solarized_termcolors=256
set background=dark
colorscheme solarized

set hlsearch
highlight Search term=underline cterm=underline
" }
" Functional {
set number
" }}}

" mouses are for wimps
set mouse=

" === EDITING =============================================================
" Indentation {
set expandtab
set tabstop=4
set shiftwidth=4
" }

inoremap <c-z> <esc><c-z>

" === INTERACTION =========================================================
" Navigation {
" Move around more quickly:
noremap <C-j> 10j
noremap <C-k> 10k 
" Quicker access to buffers:
noremap <Leader>b :buffers<CR>:buffer<Space>
" Stop pestering me to save when moving between buffers:
set hidden
" <Ctrl-l> redraws the screen and removes any search highlighting.
noremap <silent> <C-l> :nohl<CR><C-l>
" }

" === USEFUL SHORTCUTS ====================================================
noremap <Leader>W :w !sudo tee % > /dev/null
noremap <Leader>n :setlocal number!<cr>


" === BAD HABITS ==========================================================
"nnoremap <Up> :resize -3<CR>
"nnoremap <Down> :resize +3<CR>
"nnoremap <Left> :vertical resize -3<CR>
"nnoremap <Right> :vertical resize +3<CR>

nnoremap <Up> <ESC>
nnoremap <Down> <ESC>
nnoremap <Left> <ESC>
nnoremap <Right> <ESC>

" resize horzontal split window
nmap <C-Up> <C-W>-<C-W>-
nmap <C-Down> <C-W>+<C-W>+
" resize vertical split window
nmap <C-Right> <C-W>><C-W>>
nmap <C-Left> <C-W><<C-W><

"=====[ Highlight matches when jumping to next ]=============

" This rewires n and N to do the highlighing...
nnoremap <silent> n   n:call HLNext(0.4)<cr>
nnoremap <silent> N   N:call HLNext(0.4)<cr>

function! HLNext (blinktime)
    highlight WhiteOnRed ctermfg=white ctermbg=red
    let [bufnum, lnum, col, off] = getpos('.')
    let matchlen = strlen(matchstr(strpart(getline('.'),col-1),@/))
    let target_pat = '\c\%#\%('.@/.'\)'
    let ring = matchadd('WhiteOnRed', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 100) . 'm'
    call matchdelete(ring)
    redraw
endfunction

"====[ Make tabs, trailing whitespace, and non-breaking spaces visible ]======

exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list

"====[ Swap : and ; to make colon commands easier to type ]======

nnoremap  ;  :

"====[ Plugins ]=====
"inoremap <expr>  <C-K>   BDG_GetDigraph()

"noremap <Leader>k :NERDTreeToggle<CR>


"autocmd FileType python setlocal completeopt-=preview

" These are defaults, but putting them here will help me to remember them :P
"let g:jedi#goto_command = "<leader>d"
"let g:jedi#goto_assignments_command = "<leader>g"
"let g:jedi#goto_definitions_command = ""
"let g:jedi#documentation_command = "K"
"let g:jedi#usages_command = "<leader>n"
"let g:jedi#completions_command = "<C-Space>"
"let g:jedi#rename_command = "<leader>r"

"let g:SuperTabDefaultCompletionType = "<c-n>"


set laststatus=2

"====[ Neomake ]========
let g:neomake_python_enabled_makers = ['pylint']
let g:neomake_javascript_enabled_makers = ['eslint']

" Always show the gutter
sign define dummy
autocmd! BufEnter * execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')
highlight SignColumn ctermbg=235

autocmd! BufWritePost,BufReadPost * Neomake  "Not BufEnter please
let g:neomake_error_sign = {
            \ 'text': '>>',
            \ 'texthl': 'ErrorMsg',
            \ }
hi MyWarningMsg ctermbg=3 ctermfg=0
let g:neomake_warning_sign = {
            \ 'text': '>>',
            \ 'texthl': 'MyWarningMsg',
            \ }

:nnoremap <Tab> :bnext<CR>
:nnoremap <S-Tab> :bprevious<CR>



"http://vim.wikia.com/wiki/Deleting_a_buffer_without_closing_the_window
"here is a more exotic version of my original Kwbd script
"delete the buffer; keep windows; create a scratch buffer if no buffers left
function s:Kwbd(kwbdStage)
  if(a:kwbdStage == 1)
    if(!buflisted(winbufnr(0)))
      bd!
      return
    endif
    let s:kwbdBufNum = bufnr("%")
    let s:kwbdWinNum = winnr()
    windo call s:Kwbd(2)
    execute s:kwbdWinNum . 'wincmd w'
    let s:buflistedLeft = 0
    let s:bufFinalJump = 0
    let l:nBufs = bufnr("$")
    let l:i = 1
    while(l:i <= l:nBufs)
      if(l:i != s:kwbdBufNum)
        if(buflisted(l:i))
          let s:buflistedLeft = s:buflistedLeft + 1
        else
          if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
            let s:bufFinalJump = l:i
          endif
        endif
      endif
      let l:i = l:i + 1
    endwhile
    if(!s:buflistedLeft)
      if(s:bufFinalJump)
        windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump | endif
      else
        enew
        let l:newBuf = bufnr("%")
        windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
      endif
      execute s:kwbdWinNum . 'wincmd w'
    endif
    if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
      execute "bd! " . s:kwbdBufNum
    endif
    if(!s:buflistedLeft)
      set buflisted
      set bufhidden=delete
      set buftype=
      setlocal noswapfile
    endif
  else
    if(bufnr("%") == s:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
  endif
endfunction

set mouse=""
