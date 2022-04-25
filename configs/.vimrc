let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'dense-analysis/ale'
Plug 'Yggdroot/indentLine'

call plug#end()

set number
set showmatch
set wildmenu
set cursorline
set autoindent

syntax on

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType make set noexpandtab

