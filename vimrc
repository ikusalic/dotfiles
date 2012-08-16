set nocompatible

" leader mapping must be set before it is used
let mapleader = ","

syntax on

" ======================================================================
" INHERITED SETTINGS - partly taken from: $VIMRUNTIME/vimrc_example.vim
" ======================================================================

" Don't use Ex mode, use Q for formatting
"map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
"inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set diffexpr=MyDiff()
if !exists("*MyDiff")
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction
endif


" ======================================================================
" MY FUNCTIONS
" ======================================================================

" more intelligent zero behaviour
function! MyZeroBehaviour()
    let first_nonblank = match(getline('.'), '\S') + 1
    let current = col('.')
    if current == 1 || first_nonblank < current
        call cursor(line('.'), first_nonblank)
    else
        call cursor(line('.'), 1)
    endif
endfunction

" delete '\<' and '\>' from search buffer if they are at the beginning and end
function! CleanupSearchRegister()
    let s_reg = getreg('/')
    if( strpart(s_reg, 0, 2) == '\<' && strpart(s_reg, strlen(s_reg) - 2, 2) == '\>' )
        call setreg( '/', strpart(s_reg, 2, (strlen(s_reg) - 4)) )
    endif
endfunction

" execute command while preserving position
function! PreservePosition(cmd)
    let [s, c] = [@/, getpos('.')]
    exe a:cmd
    let @/ = s
    call setpos('.', c)
endfunction

" execute command depending if Vim is in Unix-like environment or in Windows
function! ExecUnixWin(nixCmd, winCmd)
    if has("win16") || has("win32") || has("win64")
        exe a:winCmd
    else
        exe a:nixCmd
    endif
endfunction

" reset all existing mappings and initialize chosen ones
function! InitializeMappings()
    " reset all existing mappings
    mapclear

    " keep old functionality of , (comma)
    nnoremap <leader>, ,

    " jj can be used instead of <ESC>
    inoremap jj <ESC>
    cnoremap jj <C-C>

    " Y should behave like C and D (yank to the end of line)
    map Y y$

    " <C-L> should clear highlights
    nnoremap <C-L> :nohl<CR><C-L>

    " previous/next buffer
    map <C-H> :bp<CR>
    map <C-J> :bn<CR>

    " j and k should work on visual lines when real lines are wrapped
    nmap j gj
    nmap k gk
    vmap j gj
    vmap k gk

    " remap 0 to behave more intelligently
    nmap 0 :call MyZeroBehaviour()<CR>

    " <C-Space> does the omnicomplete
    inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
    \ "\<lt>C-n>" :
    \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
    \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
    \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
    imap <C-@> <C-Space>

    " write to a file using sudo
    map <leader>ww :w !sudo tee % > /dev/null<CR>

    " delete current buffer
    map <leader>bd :bd<CR>

    " delete last character from system buffer
    map <leader>dd :call setreg('*', strpart(getreg('*'), 0, strlen(getreg('*')) - 1))<CR>

    " delete '\<' and '\>' from search buffer if they are at the beginning and end
    map <leader>// :call CleanupSearchRegister()<CR>

    " toggle spell checking
    map <leader>sp :setlocal spell!<CR>

    " toggle wrap
    map <leader>wr :setlocal wrap!<CR>

    " toggle show unprintable characters
    nmap <leader>li :set list!<CR>

    " substitution shortcut
    map <leader>ss :%s//gc<left><left><left>

    " cd to directory of current file
    map <leader>cd :cd %:p:h<CR>

    " open vimrc for editing
    map <leader>rc :e $VIM/vimrc<CR>

    " save and run current file
    map <leader>go :w<CR>:!"%"<CR>

    " full screen
    map <leader>fs :set lines=999 <BAR> set columns=999<CR>

    " toggle relative/absolute line numbers
    map <leader>nu :exe( (&rnu == 1) ? 'set nu' : 'set rnu' )<CR>

    " toggle highlighting of current column
    map <leader>hc :setlocal cursorcolumn!<CR>

    " remove trailing whitespaces
    nnoremap <leader>tw :call PreservePosition('%s/\s\+$//e')<CR>
    " double the number of whitespaces at the beginning of each line
    nnoremap <leader>> :call PreservePosition('%s/^\s*/&&/')<CR>
    " halve the number of whitespaces at the beginning of each line
    nnoremap <leader><LT> :call PreservePosition('%s/\(^\s*\)\1/\1/')<CR>

    " find all occurrences of custom pattern in all files
    map <leader>/v :noautocmd <Bar> vimgrep//gj ** <Bar> cw<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    " find all occurrences of custom pattern in all files using external grep
    call ExecUnixWin('map <leader>/g :exe(":enew <Bar> :r !grep -r -n \"\" " . getcwd()) <Home>' . repeat("<Right>", 30), '')

    " custom search across all buffers
    map <leader>/b :bufdo il! //<Left>
    " custom substitution across all buffers
    map <leader>sb :bufdo %s//gce<Left><Left><Left><Left>

    " list some tags I like to use -> small TaskList
    map <leader>tg :il! /TODO\\|FIXME\\|XXX\\|NOTE\\|BUG\\|HACK\\|TODEL/<CR>
    " TODO
    "autocmd Syntax * syn keyword myTodo TODO FIXME XXX NOTE BUG HACK TODEL contained
    "autocmd Syntax * syn match myComment "#.*" contains=myTodo
    "autocmd Syntax * hi def link myTodo Todo
    "http://stackoverflow.com/questions/4097259/in-vim-how-do-i-highlight-todo-and-fixme
    "http://stackoverflow.com/questions/8423228/custom-keyword-highlighted-as-todo-in-vi

    " format xml, *nix only
    call ExecUnixWin("map <leader>fx :%!xmllint --format -<CR>", '')

    " format json, *nix only; NOTE if not working, run 'sudo cpan JSON::XS'
    call ExecUnixWin("map <leader>fj :%!json_xs -f json -t json-pretty<CR>", '')

    " ##### PLUGIN MAPPINGS
    map <leader>nt :NERDTreeToggle<CR>
    map <leader>nc :NERDTree .<CR>

    map <leader>mr :exe( (getreg('%') =~ '__MRU_Files__') ? ':q' : ':MRU' )<CR>

    map <leader>lj :LustyJuggler<CR>

    map <leader>be :exe( (getreg('%') == '[BufExplorer]') ? ':norm q' : ':BufExplorer' )<CR>

    map <leader>tt :CommandT<CR>

    nmap <leader>cc :call NERDComment(0, "toggle")<CR>
    vmap <leader>cc :call NERDComment(1, "toggle")<CR>

    map <leader>gd :GundoToggle<CR>

    map <leader>tb :TagbarToggle<CR>

    call ExecUnixWin('', "map <leader>ct :ConqueTerm bash<CR>")

    map <leader>rb :RainbowParenthesesToggle<CR>

    map <leader>mt :Mark<CR>
    map <leader>mm :Mark 
    map <leader>mc :MarkClear<CR>
    map <leader>mn :<C-u>call mark#SearchCurrentMark(0)<CR>
    map <leader>mN :<C-u>call mark#SearchCurrentMark(1)<CR>
endfunction

" custom language specific settings
function! InitializeLanguageSpecificSettings()
    " Ruby
    autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
    autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
    autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
    autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
    autocmd FileType ruby,eruby setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " Python
    autocmd FileType python set omnifunc=pythoncomplete#Complete

    " JavaScript
    " TODO TODEL Crockford uses 4 spaces
    autocmd FileType javascript setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " HTML
    autocmd FileType xhtml,html setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " CSS
    autocmd FileType css,scss setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2
endfunction

" plugins
function! InitializePlugins()
    " General:
    " --------
    " Vundle -> Vim plugin manager
    " Wombat -> Dark gray color scheme
    " NERDTree -> Filesystem explorer
    " MRU -> Plugin to manage Most Recently Used (MRU) files
    " LustyJuggler -> Switch very quickly among your active buffers
    " BufExplorer -> Find buffers when there are many open ones
    " Command-T -> Fast file navigation for VIM
    " NERDCommenter -> easy commenting of code for many filetypes
    " Gundo -> Visual Undo in vim with diff's to check the differences
    " TagBar -> Source code browser
    " Conque Shell (Term) -> Run interactive commands inside a Vim buffer
    " Rainbow -> colors nasted parentheses
    " Mark : Highlight several words in different colors simultaneously
    "
    " Language Specific:
    " ------------------
    " pythoncomplete : Python Omni Completion
    " rubycomplete.vim : ruby omni-completion
    " rails.vim : Ruby on Rails: easy file navigation, enhanced syntax highlighting, and more

    " Vundle -> Vim plugin manager
    "     https://github.com/gmarik/vundle
    "     - install:
    "     (i.) git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    "     (ii.) :BundleInstall
    "     - usage:
    "     :BundleList          - list configured bundles
    "     :BundleInstall(!)    - install(update) bundles
    "     :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
    set nocompatible
    filetype off
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'

    " color scheme
    Bundle 'vim-scripts/Wombat'
    " TODO screen saver
    "Bundle 'vim-scripts/matrix.vim--Yang'

    " vundle settings for all other plugins
    Bundle 'scrooloose/nerdtree'
    Bundle 'vim-scripts/mru.vim'
    Bundle 'vim-scripts/LustyJuggler'
    Bundle 'vim-scripts/bufexplorer.zip'
    Bundle 'wincent/Command-T'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'sjl/gundo.vim'
    Bundle 'majutsushi/tagbar'
    Bundle 'vim-scripts/Conque-Shell'
    Bundle 'ikusalic/vim-rainbow'
    Bundle 'vim-scripts/Mark--Karkat'
    "Bundle 'scrooloose/syntastic'  # TODO

    "Bundle 'TODO'  TODO sessions
    "
    " http://www.vim.org/scripts/script.php?script_id=39 matchit  # TODO
    "Bundle 'tpope/vim-fugitive'  # TODO
    "Bundle 'vim-scripts/dbext.vim'  # TODO
    "Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}  # TODO

    " language specific plugins
    Bundle 'vim-scripts/pythoncomplete'
    Bundle 'vim-scripts/rubycomplete.vim'
    Bundle 'tpope/vim-rails'
    " TODO ropevim
    "http://www.vim.org/scripts/script.php?script_id=386 py matchit  # TODO
    "http://www.vim.org/scripts/script.php?script_id=290 rb matchit  # TODO

    filetype plugin indent on

    " Wombat -> Dark gray color scheme
    "     http://www.vim.org/scripts/script.php?script_id=1778
    "     - usage:
    "     :colo wombat in vimrc
    if has('gui_running')
        :colo wombat

        " make the cursor visible when on parentheses
        hi cursor guifg=black

        " mark 80th line
        set colorcolumn=80
        hi ColorColumn guibg=#303030

        " do not use italic:
        hi Comment gui=none
        hi String gui=none
        hi Todo gui=none

        " Todos should be bluish
        hi Todo guibg=#4000ff
    endif

    " NERDTree -> Filesystem explorer
    "     http://www.vim.org/scripts/script.php?script_id=1658
    "     - usage:
    "     <leader>nt
    "     <leader>nc
    "     :NERDTree d:\

    " MRU -> Plugin to manage Most Recently Used (MRU) files
    "     http://www.vim.org/scripts/script.php?script_id=521
    "     - usage:
    "     <leader>mr
    "     :MRU {pattern}
    let g:MRU_Max_Entries = 1000
    let g:MRU_Window_Height = 15
    let g:MRU_Add_Menu = 0

    " LustyJuggler -> Switch very quickly among your active buffers
    "     http://www.vim.org/scripts/script.php?script_id=2050
    "     - usage:
    "     <leader>lj

    " BufExplorer -> Find buffers when there are many open ones
    "     http://www.vim.org/scripts/script.php?script_id=42
    "     - usage:
    "     <leader>be
    "     d -> delete buffer

    " Command-T -> Fast file navigation for VIM
    "     http://www.vim.org/scripts/script.php?script_id=3025
    "     - install (when placed in bundle):
    "     (use ruby 1.8.7)
    "     cd ~/.vim/bundle/command-t
    "     bundle install
    "     rake make
    "     - usage:
    "     <leader>tt
    "     :CommandTFlush
    let g:CommandTAlwaysShowDotFiles = 1

    " NERDCommenter -> easy commenting of code for many filetypes
    "     http://www.vim.org/scripts/script.php?script_id=1218
    "     - usage:
    "     <leader>cc
    "

    " Gundo -> Visual Undo in vim with diff's to check the differences
    "     http://www.vim.org/scripts/script.php?script_id=3304
    "     - usage:
    "     <leader>gd
    let g:gundo_width = 80

    " TagBar -> Source code browser
    "     http://www.vim.org/scripts/script.php?script_id=3465
    "     - Exuberant Ctags must be installed
    "         - http://ctags.sourceforge.net/
    "         - http://adamyoung.net/Exuberant-Ctags-OS-X
    "     - usage:
    "     <leader>tb
    call ExecUnixWin("let g:tagbar_ctags_bin = '/usr/local/bin/ctags'", "let g:tagbar_ctags_bin = 'C:/ctags58/ctags.exe'")
    let g:tagbar_left = 1

    " Conque Shell (Term) -> Run interactive commands inside a Vim buffer
    "     http://www.vim.org/scripts/script.php?script_id=2771
    "     - usage:
    "      <leader>ct
    "     :ConqueTerm {cmd/python/...}
    let g:ConqueTerm_Color = 2
    let g:ConqueTerm_Syntax = 'python'

    " (modified) Rainbow -> colors nasted parentheses
    "     https://github.com/ikusalic/vim-rainbow
    "     - usage:
    "     <leader>rb

    " Mark : Highlight several words in different colors simultaneously
    "     http://www.vim.org/scripts/script.php?script_id=2666
    "     - usage:
    "     <leader>mt
    "     <leader>mm
    "     <leader>mc
    "     <leader>mn
    "     <leader>mN
    highlight def MarkWord7  ctermbg=DarkCyan    ctermfg=Black guibg=#00AF87 guifg=Black
    highlight def MarkWord8  ctermbg=DarkMagenta ctermfg=Black guibg=#00AF00 guifg=Black
    highlight def MarkWord9  ctermbg=DarkGreen   ctermfg=Black guibg=#878700 guifg=Black
    highlight def MarkWord10 ctermbg=DarkRed     ctermfg=Black guibg=#AF875F guifg=Black

    " LANGUAGE SPECIFIC PLUGINS:
    " ==========================
    " Python:
    " -------
    " pythoncomplete : Python Omni Completion
    "     http://www.vim.org/scripts/script.php?script_id=1542
    "     - usage: automatic
    "
    " TODO
    " Pydoc -> Opens up pydoc within vim
    "     http://www.vim.org/scripts/script.php?script_id=910
    "     - usage:
    "     <leader>p{wW}
    "     :Pydoc {smt}
    "
    " PyFlakes -> Underlines and displays errors with Python on-the-fly
    "     http://www.vim.org/scripts/script.php?script_id=2441
    "     koristena verzija: https://github.com/mitechie/pyflakes-pathogen
    "     - usage:
    "     <leader>pf
    "     :cc
    "
    " pep8 -> Check your python source files with PEP8
    "     http://www.vim.org/scripts/script.php?script_id=2914
    "     treba i: https://github.com/jcrocholl/pep8
    "     - usage:
    "     <leader>p8
    " Configure Pydoc
    "let g:pydoc_cmd = "C:/Python26/Lib/pydoc.py"
    "let g:pydoc_wh = 999
    " Configure PyFlakes
    "map <leader>pf :PyflakesUpdate<CR>
    "let g:pyflakes_use_quickfix = 0
    " Configure pep8
    "let g:pep8_map='<leader>p8'

    " Ruby:
    " -----
    " rubycomplete.vim : ruby omni-completion
    "     http://www.vim.org/scripts/script.php?script_id=1662
    "     - usage: automatic
    "
    " rails.vim : Ruby on Rails: easy file navigation, enhanced syntax highlighting, and more
    "     http://www.vim.org/scripts/script.php?script_id=1567
    "     - usage:
    "     TODO
endfunction


" ======================================================================
" MY CUSTOM SETTINGS
" ======================================================================

" configure plugins
call InitializePlugins()

filetype on
filetype plugin indent on

set clipboard=unnamed
set backspace=indent,eol,start
set history=10000
set showcmd
set showmode
set wildmenu
set wildmode=longest:full
set lazyredraw
set guioptions=egrL

set ruler
set relativenumber
set title
set cmdheight=2
set visualbell
set laststatus=2
set report=0

set nowrap
set cursorline
set splitright
set virtualedit=block
set scrolloff=3

set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set autoindent
set smartindent
set shiftround

set ignorecase
set smartcase
set hlsearch
set incsearch

set hidden
set nobackup
set writebackup
set noautowrite
set noautowriteall
set noautoread
set ffs=dos,unix,mac
set enc=utf-8

set foldmethod=indent
set foldlevel=99

set nolist
set listchars=tab:>-,trail:.,eol:$

set guifont=Lucida_Console:h15
set guicursor=a:blinkon0

set completeopt=menuone,longest,preview


" ======================================================================
" MY AUTO COMMANDS
" ======================================================================

" TODO disable the capslock when leaving insert mode

" set custom mappings only
autocmd VimEnter * call InitializeMappings()

" maximise Vim's window
call ExecUnixWin("set lines=9999 | set columns=999", "autocmd GUIEnter * simalt ~x")

" close Omni-Completion tip window on movement in insert mode or when leaving insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

call InitializeLanguageSpecificSettings()
