runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect('bundle/{}')
Helptags
filetype plugin indent on
filetype plugin on
syntax on
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
set hlsearch
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set relativenumber
set number
set hidden
set tw=90
set laststatus=2
set statusline+=%f\ 
set statusline+=%{fugitive#statusline()}
set mouse=a
"set statusline+=%=  
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled=1
"set statusline+=%{gutentags#statusline()}
set statusline+=\ %c:%l\ 
let g:airline_theme = 'powerlineish'
let g:airline#extensions#hunks#enabled=0
"let g:airline_section_b = airline#section#create(['branch'])
let g:airline#extensions#tabline#enabled = 1
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%91v', 100)
set backspace=2
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
set background=dark
colorscheme CandyPaper 
if &term =~ 'xterm-256color'
set t_ut=
endif
let g:clang_cpp_options = '-std=c++11 -stdlib=libc++'
let g:Powerline_symbols = 'fancy'
let g:indentLine_enabled = 1
let g:indentLine_char = '┆'
let NERDTreeShowHidden = 1

nnoremap <F1> :NERDTree<CR>
nnoremap <F5> :buffers<CR>:buffer<Space>
" Highlight trailing whitespace
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
