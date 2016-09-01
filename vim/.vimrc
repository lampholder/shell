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

" === EDITING =============================================================
" Indentation {
set expandtab
set tabstop=4
set shiftwidth=4
" }

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
nnoremap <Up> <ESC>
nnoremap <Down> <ESC>
nnoremap <Left> <ESC>
nnoremap <Right> <ESC>

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
    exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    call matchdelete(ring)
    redraw
endfunction

"====[ Make the 81st column stand out ]====================
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

"====[ Make tabs, trailing whitespace, and non-breaking spaces visible ]======

exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list

"====[ Swap : and ; to make colon commands easier to type ]======

nnoremap  ;  :

"====[ Plugins ]=====
inoremap <expr>  <C-K>   BDG_GetDigraph()

noremap <Leader>k :NERDTreeToggle<CR>

autocmd! BufWritePost,BufReadPost * Neomake  "Not BufEnter please

set laststatus=2
