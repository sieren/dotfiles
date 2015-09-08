runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect('bundle/{}')
filetype plugin indent on
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
set tw=90
set laststatus=2
set statusline+=%f\ 
set statusline+=%=  
set statusline+=%{gutentags#statusline()}
set statusline+=\ %c:%l\ 
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%91v', 100)
set backspace=2
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

"set runtimepath^=~/.vim/bundle/ctrlp.vim
"exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
"set list"
set t_Co=256
colo CandyPaper
