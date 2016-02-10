" TODO drop ExecUnixWin calls in maps
" TODO drop other unnecessary comments
" TODO update plugins order

set nocompatible

" leader mapping must be set before it is used
let mapleader = ","
let maplocalleader = "\\"

syntax on


" ======================================================================
" INHERITED SETTINGS
" ======================================================================
"
" partly taken from: $VIMRUNTIME/vimrc_example.vim

if has('mouse')
  set mouse=a
endif

if has("autocmd")
  augroup vimrcEx
  au!

  autocmd FileType text setlocal textwidth=78

  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
endif

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

function! DeleteSwapFiles()
    let current_dir = getcwd()
    exe('! find ' . current_dir . ' -name "*.sw[opn]"')
    if confirm('Delete swap files?', "&Yes\n&No", 1)==1
        exe('! find ' . current_dir . ' -name "*.sw[opn]" -delete')
    endif
endfunction

function! BetterZeroBehaviour()
    let first_nonblank = match(getline('.'), '\S') + 1
    let current = col('.')
    if current == 1 || first_nonblank < current
        call cursor(line('.'), first_nonblank)
    else
        call cursor(line('.'), 1)
    endif
endfunction

function! CleanupSearchRegister()
    " delete '\<' and '\>' from search buffer if they are at the beginning and end
    let s_reg = getreg('/')
    if( strpart(s_reg, 0, 2) == '\<' && strpart(s_reg, strlen(s_reg) - 2, 2) == '\>' )
        call setreg( '/', strpart(s_reg, 2, (strlen(s_reg) - 4)) )
    endif
endfunction

function! PreservePositionExec(cmd)
    let [s, c] = [@/, getpos('.')]
    exe a:cmd
    let @/ = s
    call setpos('.', c)
endfunction

function! ExecUnixWin(nixCmd, winCmd)
    if has("win16") || has("win32") || has("win64")
        exe a:winCmd
    else
        exe a:nixCmd
    endif
endfunction

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

    " Don't use Ex mode, use Q for formatting
    map Q gq

    " TODO fix weird replace buffer behaviour
    " do not overwrite default register if replacing in visual mode
    vnoremap <silent> p p<ESC>:call setreg('*', getreg('0'))<CR>

    " <C-L> should clear highlights
    nnoremap <C-L> :nohl<CR><C-L>

    " next buffer
    map <C-H> :bn<CR>

    " j and k should work on visual lines when real lines are wrapped
    nmap j gj
    nmap k gk
    vmap j gj
    vmap k gk

    " remap 0 to behave more intelligently
    nmap 0 :call BetterZeroBehaviour()<CR>

    " <C-Space> does the omnicomplete
    inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
    \ "\<lt>C-n>" :
    \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
    \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
    \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
    imap <C-@> <C-Space>

    " write to a file using sudo
    map <leader>ww :w !sudo tee % > /dev/null<CR>

    " remove current buffer
    map <leader>br :bw<CR>
    map <leader>bw :bw!<CR>
    map <leader>sw :w <BAR> bw!<CR>

    " new buffer
    map <leader>ee :enew<CR>

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

    " show registers
    nmap <leader>rr :reg<CR>

    " substitution shortcut
    map <leader>ss :%s//gc<left><left><left>

    " cd to directory of current file
    map <leader>cd :cd %:p:h<CR>

    " delete all swap files
    map <leader>sd : call DeleteSwapFiles()<CR>

    " open vimrc for editing
    map <leader>rc :e ~/.vimrc<CR>

    " save and run current file
    map <leader>go :w<CR>:!"%"<CR>

    " full screen
    map <leader>fs :set lines=999 <BAR> set columns=999<CR>

    " toggle relative/absolute line numbers
    map <leader>nu :set rnu!<CR>

    " highlight current word without jumping
    map <leader>hw *N

    map <leader>dm :delmarks!<CR>

    " remove trailing whitespaces
    nnoremap <leader>tw :call PreservePositionExec('%s/\s\+$//e')<CR>
    " double the number of whitespaces at the beginning of each line
    nnoremap <leader>> :call PreservePositionExec('%s/^\s*/&&/')<CR>
    " halve the number of whitespaces at the beginning of each line
    nnoremap <leader><LT> :call PreservePositionExec('%s/\(^\s*\)\1/\1/')<CR>

    " custom search across all buffers
    map <leader>/b :bufdo il! //<Left>
    " custom substitution across all buffers
    map <leader>sb :bufdo %s//gce<Left><Left><Left><Left>

    " list some tags I like to use -> small TaskList
    map <leader>tg :il! /\<TODO\>\\|\<FIXME\>\\|\<XXX\>\\|\<NOTE\>\\|\<BUG\>\\|\<HACK\>\\|\<TODEL\>\\|\<OPTIMIZE\>\\|\<WIP\>\\|\<DONE\>\\|\<DEBUG\>/<CR>

    " format xml, *nix only
    call ExecUnixWin("map <leader>fx :%!xmllint --format -<CR>", '')

    " format json, *nix only; NOTE if not working, run 'sudo cpan JSON::XS'
    call ExecUnixWin("map <leader>fj :%!json_xs -f json -t json-pretty<CR>", '')
endfunction

function! InitializeLanguageSpecificSettings()
    " Markdown
    autocmd BufRead,BufNewFile *.md,*.markdown set filetype=markdown
    autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=79

    " bash with vi input mode
    autocmd BufRead,BufNewFile bash-fc-* set filetype=sh

    " Ruby
    autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
    autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
    autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
    autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
    autocmd FileType ruby,eruby setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " Python
    autocmd FileType python set omnifunc=pythoncomplete#Complete

    " Scala
    autocmd FileType scala setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " HTML
    autocmd FileType xhtml,html setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

    " CSS
    autocmd FileType css,scss setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2
endfunction

function! InitializePlugins()
    " NOTE Vundle install
    "     (i.) git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    "     (ii.) :BundleInstall
    set nocompatible
    filetype off
    set rtp+=~/.vim/bundle/Vundle.vim/
    call vundle#rc()
    Bundle 'gmarik/Vundle.vim'

    Bundle 'davidbeckingsale/Smyck-Color-Scheme'
    Bundle 'Lokaltog/vim-distinguished'

    Bundle 'scrooloose/nerdtree'
    let g:NERDTreeIgnore = ['\.pyc$']

    Bundle 'mru.vim'
    let g:MRU_Max_Entries = 10000
    let g:MRU_Window_Height = 15
    let g:MRU_Add_Menu = 0

    Bundle 'LustyJuggler'

    Bundle 'bufexplorer.zip'

    Bundle 'Lokaltog/powerline', {'rtp':  'powerline/bindings/vim'}
    " NOTE Powerline install
    "     - needs patched fonts to be installed
    "     - Sauce Code Powerline
    "             - https://github.com/Lokaltog/powerline-fonts
    set guifont=Source\ Code\ Pro\ for\ Powerline:h15
    let g:Powerline_symbols = 'fancy'

    "Bundle 'bling/vim-airline'

    Bundle 'scrooloose/nerdcommenter'

    Bundle 'sjl/gundo.vim'
    let g:gundo_width = 80

    Bundle 'wincent/Command-T'
    " NOTE Command-T install
    "    cd ~/.vim/bundle/Command-T/ruby/command-t
    "    ruby extconf.rb  # with ruby 1.8.7
    "    make
    let g:CommandTAlwaysShowDotFiles = 1

    Bundle 'majutsushi/tagbar'
    " NOTE TagBar install
    "     - Exuberant Ctags must be installed
    "         - http://ctags.sourceforge.net/
    "         - brew install ctags
    "         - http://adamyoung.net/Exuberant-Ctags-OS-X
    " FIXME problems with Ruby
    call ExecUnixWin("let g:tagbar_ctags_bin = '/usr/local/bin/ctags'", "let g:tagbar_ctags_bin = 'C:/ctags58/ctags.exe'")
    let g:tagbar_left = 1
    " TODO scala, clojure

    Bundle 'ikusalic/vim-rainbow'

    Bundle 'Mark--Karkat'
    highlight def MarkWord7  ctermbg=DarkCyan    ctermfg=Black guibg=#00AF87 guifg=Black
    highlight def MarkWord8  ctermbg=DarkMagenta ctermfg=Black guibg=#00AF00 guifg=Black
    highlight def MarkWord9  ctermbg=DarkGreen   ctermfg=Black guibg=#878700 guifg=Black
    highlight def MarkWord10 ctermbg=DarkRed     ctermfg=Black guibg=#AF875F guifg=Black

    Bundle 'LargeFile'
    let g:LargeFile = 5

    Bundle 'scrooloose/syntastic'
    " NOTE Syntastic install
    "     - for different languages (must be on path):
    "          - python: flake8 python package
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_python_flake8_args = "--ignore=E501"

    Bundle 'nathanaelkane/vim-indent-guides'
    let g:indent_guides_guide_size = 1
    let g:indent_guides_start_level = 2
    let g:indent_guides_enable_on_vim_startup = 1
    if !has('gui_running')
        let g:indent_guides_auto_colors = 0
        autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=Red ctermbg=234
        autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=Green ctermbg=236
    endif

    Bundle 'terryma/vim-multiple-cursors'
    let g:multi_cursor_start_key = '<C-A>'
    let g:multi_cursor_next_key = '<C-n>'
    let g:multi_cursor_prev_key = '<C-p>'
    let g:multi_cursor_skip_key = '<C-x>'
    let g:multi_cursor_quit_key = '<Esc>'

    " NOTE install ack: `apt-get install ack-grep` or `brew install ack`
    Bundle 'mileszs/ack.vim'

    Bundle 'regedarek/ZoomWin'

    Bundle 'SearchComplete'

    Bundle 'kshenoy/vim-signature'
    let g:SignatureEnabledAtStartup = 1

    Bundle 'xolox/vim-misc'
    Bundle 'xolox/vim-easytags'
    let g:easytags_updatetime_warn = 0

    Bundle 'mikewest/vimroom'
    let g:vimroom_sidebar_height = 1
    let g:vimroom_width = 85
    let g:vimroom_scrolloff = 3

    Bundle '907th/vim-auto-save'
    let g:auto_save = 1
    let g:auto_save_in_insert_mode = 0
    let g:auto_save_events = ["InsertLeave", "TextChanged"]
    let g:auto_save_silent = 1

    Bundle 'reedes/vim-wheel'

    "Bundle 'tpope/vim-surround'  # TODO

    "Bundle 'sjl/splice.vim'

    "Bundle 'henrik/vim-indexed-search'
    "let g:indexed_search_shortmess = 1

    " TODO sessions

    Bundle 'rubycomplete.vim'

    Bundle 'pythoncomplete'

    Bundle 'fatih/vim-go'

    Bundle 'scala/scala-tool-support', {'rtp': 'tool-support/vim'}

    Bundle 'tpope/vim-markdown'

    Bundle 'Valloric/YouCompleteMe'
    " NOTE YouCompleteMe install
    "     cd ~/.vim/bundle/YouCompleteMe
    "     ./install.sh --clang-completer
    "
    "     - if vim is crashing (Vim: Caught deadly signal ABRT):
    "         - linked lib: `otool -L /Applications/MacVim.app/Contents/MacOS/Vim | grep Python`
    "         - `install_name_tool -change <path-to-linked-lib <path-to-new-lib> /Applications/MacVim.app/Contents/MacOS/Vim`
    "         - check:
    "             - https://github.com/Valloric/YouCompleteMe/issues/8
    "             - https://github.com/Valloric/YouCompleteMe/issues/18

    "http://www.vim.org/scripts/script.php?script_id=39 matchit
    "http://www.vim.org/scripts/script.php?script_id=386 py matchit
    "http://www.vim.org/scripts/script.php?script_id=290 rb matchit

    "Bundle 'airblade/vim-gitgutter'
    "let g:gitgutter_enabled = 0

    filetype plugin indent on

    if has('gui_running')
        colo smyck

        " mark 80th line
        set colorcolumn=80
        hi ColorColumn guibg=#303030

        " Todos should be bluish
        hi Todo guibg=#4000ff
        hi Todo guifg=gray

        " fix visual mode
        hi Visual guibg=#505070
        hi Visual guifg=gray

        " fix spell-checking
        hi clear SpellBad
        hi SpellBad gui=underline guibg=#551111
    else
        let &t_Co = 256
        colo distinguished

        " mark 80th line
        set colorcolumn=80

        " fix spell-checking
        hi clear SpellBad
        hi SpellBad ctermfg=208 ctermbg=124
    endif
endfunction

function! InitializePluginMappings()
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

    map <leader>rb :RainbowParenthesesToggle<CR>

    map <leader>mt :Mark<CR>
    map <leader>mm :Mark
    map <leader>mc :MarkClear<CR>
    map <leader>mn :<C-u>call mark#SearchCurrentMark(0)<CR>
    map <leader>mN :<C-u>call mark#SearchCurrentMark(1)<CR>

    map <leader>st :let g:syntastic_auto_loc_list = (g:syntastic_auto_loc_list == 1) ? 2 : 1 <BAR> :lcl <BAR> :SyntasticCheck<CR>

    map <leader>ig :IndentGuidesToggle<CR>

    xmap <C-A> :<C-U>call multiple_cursors#new("v")<CR>
    nmap <C-A> :call multiple_cursors#new("n")<CR>

    map <leader>aa :Ack
    "map <leader>ar :! ack -l 'pattern' | xargs perl -pi -E 's/pattern/replacement/g'  # TODO

    map <leader>zw :ZoomWin<CR>

    noremap / :call SearchCompleteStart()<CR>/

    map <leader>tm :SignatureToggleSigns<CR>

    map <leader>ct :UpdateTags -R .<CR>

    map <leader>vr :VimroomToggle<CR>:set number<CR>

    map <leader>as :AutoSaveToggle<CR>

    map <C-J> :call wheel#VScroll(0, '')<CR>
    map <C-K> :call wheel#VScroll(1, '')<CR>

    "map <leader>gg :GitGutterToggle<CR> TODO not working
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
set number
set relativenumber
set notitle
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
set noswapfile
set writebackup
set noautowrite
set noautowriteall
set noautoread
set ffs=unix,dos,mac
set enc=utf-8
set spelllang=en,hr,de

set foldmethod=indent
set foldlevel=99

set nolist
set listchars=tab:>-,trail:.,eol:$,nbsp:.

set guicursor=a:blinkon0

set completeopt=menuone,longest,preview


" ======================================================================
" MY AUTO COMMANDS
" ======================================================================

" TODO disable the capslock when leaving insert mode

" set custom mappings only
autocmd VimEnter * call InitializeMappings()
autocmd VimEnter * call InitializePluginMappings()

" maximise Vim's window
if has('gui_running')
    call ExecUnixWin("set lines=9999 | set columns=999", "autocmd GUIEnter * simalt ~x")
endif

" close Omni-Completion tip window on movement in insert mode or when leaving insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" highlight more Todo keywords
augroup HiglightTODO
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', '\<TODO\>\|\<FIXME\>\|\<XXX\>\|\<NOTE\>\|\<BUG\>\|\<HACK\>\|\<TODEL\>\|\<OPTIMIZE\>\|\<WIP\>\|\<DONE\>\|\<DEBUG\>')
augroup END

call InitializeLanguageSpecificSettings()
