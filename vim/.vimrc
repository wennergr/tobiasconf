" *****************************************************************************
" .vimrc setup
" 
" Author:	Tobias Wennergern (wennergr@gmail.com)
" Influences: 	DBriscoe (pydave@gmail.com)
"

" Initial setup {{{1

" Execute pathogen
execute pathogen#infect()

set nocompatible				" who needs vi, we've got Vim!

syntax on
filetype plugin indent on

" Storage {{{1
" I put most vim temp files in their own directory.
let s:vim_cache = expand('$HOME/.vim-cache')
if filewritable(s:vim_cache) == 0 && exists("*mkdir")
    call mkdir(s:vim_cache, "p", 0700)
endif

" ctrlp (fuzzy file finder) cache
let g:ctrlp_cache_dir = s:vim_cache.'/ctrlp'

" Set utf-8 encoding
set encoding=utf-8

" Display {{{1
set background=dark			" I use dark background
set nolazyredraw			" Don't repaint when scripts are running
set scrolloff=3				" Keep 3 lines below and above cursor
set number				    " Show line numbering
set numberwidth=1			" Use 1 col + 1 space for numbers
set guioptions-=T			" Disable the toolbar
colorscheme sandydune

" Undo {{{1
if has("persistent_undo")
    " Enable undo that lasts between sessions.
    " TODO: how/when to clean up undo files?
    set undofile
    let &undodir = s:vim_cache.'/undo'
    if filewritable(&undodir) == 0 && exists("*mkdir")
        " If the directory doesn't exist try to create undo dir, because vim
        " 703 doesn't do it even though this change should make it work:
        "   http://code.google.com/p/vim-undo-persistence/source/detail?r=70
        call mkdir(&undodir, "p", 0700)
    endif

    augroup persistent_undo
        au!
        au BufWritePre /tmp/*           setlocal noundofile
        au BufWritePre COMMIT_EDITMSG   setlocal noundofile
        au BufWritePre *.tmp            setlocal noundofile
        au BufWritePre *.bak            setlocal noundofile
        au BufWritePre .vim-aside       setlocal noundofile
    augroup END
endif

" Settings {{{1

"""" Messages, Info, Status
set shortmess+=a				" Use [+] [RO] [w] for modified, read-only, modified
set showcmd						" Display what command is waiting for an operator
set ruler						" line numbers and column the cursor is on
set laststatus=2				" Always show statusline, even if only 1 window
set noequalalways               " Don't resize when closing a window
set report=0					" Notify of all whole-line changes
set visualbell					" Use visual bell (no beep)
set linebreak					" Show wrap at word boundaries and preface wrap with >>
set showbreak=>>
set list                        " Display whitespace special characters such as <tab>

""" Buffers
"set splitbelow                  " Make preview (and all other) splits appear at the bottom
set switchbuf=useopen       " Ignore tabs; try to stay within the current viewport

"""" Editing
set nojoinspaces            " I don't use double spaces
set showmatch				" Briefly jump to the matching bracket
set matchtime=1				" For .1 seconds
"set formatoptions-=tc		" can I format for myself?? (only matters when textwidth>0)
set formatoptions+=r		" magically continue comments
set formatoptions-=o        " I tend to use o for whitespace, not continuing
                            " comments (some filetypes overwrite)
set isfname-==              " allow completion in var=/some/path
set tabstop=4				" 1 tab = x spaces
set shiftwidth=4			" (used on auto indent)
set softtabstop=4			" 4 spaces as a tab for bs/del
set smarttab				" Use tab button for tabs
set expandtab				" Use spaces, not tabs (use Ctrl-V+Tab to insert a tab)
set cinkeys-=0#             " Free # from the first column: It's for more than preprocessors!
set autoindent				" Indent like previous line
set smartindent				" Try to be clever about indenting
"set cindent				" Really clever indenting
if version > 600
    set backspace=start         " backspace can clear up to beginning of line
endif

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" we don't want to edit these type of files
set wildignore=*.o,*.obj,*.bak,*.exe,*.pyc,*.swp,*.class
" Show these file types at the end while using :edit command
set suffixes+=.class,.exe,.o,.obj,.dat,.dll,.aux,.pdf,.gch

" Coding {{{1
set history=500				" 100 Lines of history

" Figure out what function we're in. This relies on a coding standard where
" functions start in the first column and their signature is on one line.
" Mapped to the similar <C-g> (which I don't use very often).
" TODO: Should this be language-specific? There's definitely a better version
" for python (to allow nested definitions and to show functions and classes.
" Can I combine this with <C-g>'s functionality (print both) and override that
" key?
nnoremap <C-g><C-g>  :let last_search=@/<Bar> ?^\w? mark c<Bar> noh<Bar> echo getline("'c")<Bar> let @/ = last_search<CR>


" Command Line {{{1
" Autocomplete in cmdline: Give longest completion with list of options then
" tab through options.
set wildmenu
set wildmode=longest:list,full

" Completion {{{1

" bind ctrl+space for omnicompletion
inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-x><C-o>

let g:EclimCompletionMethod = 'omnifunc'
let g:acp_enableAtStartup = 1


" Use all complete options
set completeopt=menu,preview,menuone
" Note: we must choose between showfulltag and completeopt+=longest. See help.
"set showfulltag				" Show more information while completing tags
set completeopt+=longest        " Fill in the longest match

" Don't search included files for insert completion since that should be fast. 
" Don't use tags for insert completion, that's what omnicomplete is for
set complete-=t
set complete-=i

" Always use forward slashes.
if exists('+shellslash')
    set shellslash
endif

" Asides {{{1

" Write Asides to yourself. (Quick access to a file for random things I want
" to write down.)
nnoremap <F1> :sp ~/.vim-aside<CR>:r! date<CR>o<CR>

" Similar map for todo.
nnoremap <Leader><F1> :sp ~/.todo<CR>

" Common text {{{1

nnoremap <C-s> :w<CR>

" select all
nnoremap <C-a> 1GVG

" gc selects previously changed text. (|gv| but for modification.)
nnoremap gc :<C-U>silent!normal!`[v`]<CR>

" Make backspace work in normal
nnoremap <BS> X

" undo a change in the previous window - often used for diff
nnoremap <C-w>u :wincmd p <bar> undo <bar> wincmd p <bar> diffupdate<CR>
" Faster diff update.
function! s:UpdateDiff()
    if &diff
        diffupdate
    else
        echom "E99: Current buffer is not in diff mode"
    endif
endf
nnoremap <silent> du :call <SID>UpdateDiff()<CR>

" Generic Header comments (requires formatoptions+=r)
"  Uses vim's commentstring to figure out the local comment character
nnoremap <Leader>hc ggO<C-r>=&commentstring<CR><Esc>0/%s<CR>2cl<CR> <C-r>%<CR><CR>Copyright (c) <C-R>=strftime("%Y")<CR> _company All Rights Reserved.<CR><Esc>3kA

" Indent {{{2
" Use Ctrl-Tab/Tab and Shift-Tab to change indent in visual
" Note: this can probably be done with Select mode, but I don't use that.
xnoremap <tab> >gv
xnoremap <S-Tab> <LT>gv

" Shadow: Improve existing commands {{{2

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" Folding {{{1

" Settings
set foldmethod=syntax		" By default, use syntax to determine folds
set foldlevelstart=99		" All folds open by default
set foldnestmax=3           " At deepest, fold blocks within class methods

" <space> toggles folds opened and closed
nnoremap <Space> za
nnoremap <Leader><Space> zA

" <space> in visual mode creates a fold over the marked range
"xnoremap <space> zf

" From Paradigm: http://www.reddit.com/r/vim/comments/10cqgd/looking_for_a_languageaware_block_selection/c6cpyrg
" enable syntax folding for a variety of languages
"set g:vimsyn_folding = 'afmpPrt'
" create text object using [z and ]z
vnoremap if :<C-U>silent!normal![zjV]zk<CR>
onoremap if :normal Vif<CR>
vnoremap af :<C-U>silent!normal![zV]z<CR>
onoremap af :normal Vaf<CR>

" Create text objects for pairs of identical characters
for char in [ '$', '%', '*', ',', '-', '_', '.', '/', ':', ';', '<bar>', '<bslash>', '=' ]
	exec 'xnoremap i' . char . ' :<C-U>silent!normal!T' . char . 'vt' . char . '<CR>'
	exec 'onoremap i' . char . ' :normal vi' . char . '<CR>'
	exec 'xnoremap a' . char . ' :<C-U>silent!normal!F' . char . 'vf' . char . '<CR>'
	exec 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

"}}}
" Plugins   {{{1

" Gundo -- visualize the undo tree
nnoremap <F2> :GundoToggle<CR>

" Eclim was trying to connect on startup because it sees loaded_taglist
" Either one of these flags to fixed it, but now it doesn't happen anymore.
"let g:EclimTaglistEnabled = 0
"let g:taglisttoo_disabled = 1

" Eclim indentation makes the screen flicker and doesn't help much
let g:EclimXmlIndentDisabled = 1
" Eclim xml validation never works because I don't have DTDs
let g:EclimXmlValidate = 0

" Note: To turn off the signs that are added everywhere, you can use these
" commands:
" sign undefine qf_warning
" sign undefine qf_error

" Don't show todo markers in margin
let g:EclimSignLevel = 2

" Reduce the amount of automatic stuff from xml.vim
let g:no_xml_maps = 1

" Don't have maps for bufkill -- too easy to delete a buffer by accident
let no_bufkill_maps = 1


" Pydoc
"  Pydoc maps conflict with \p
let no_pydoc_maps = 1
"  Highlighting is ugly
let g:pydoc_highlight = 0

" Turning all on gives me end of line highlighting that I don't like.
" For some reason, if I turn everything else on, then I don't get it.
"let python_highlight_all = 1
let python_highlight_builtin_funcs = 1
let python_highlight_builtin_objs = 1
let python_highlight_doctests = 1
let python_highlight_exceptions = 1
let python_highlight_indent_errors = 1
let python_highlight_space_errors = 1
let python_highlight_string_format = 1
let python_highlight_string_formatting = 1
let python_highlight_string_templates = 1

" Calendar
let g:calendar_no_mappings = 1

" Scratch
let g:itchy_always_split = 1
"issue #1: let g:itchy_startup = 1

" Quick access to a Scratch and a Scratch of the current filetype
nnoremap <Leader>ss :Scratch<CR>
nnoremap <Leader>sf :exec 'Scratch '. &filetype<CR>

" Golden-ratio
" Don't resize automatically.
let g:golden_ratio_autocommand = 0

" Mnemonic: - is next to =, but instead of resizing equally, all windows are
" resized to focus on the current.
nmap <C-w>- <Plug>(golden_ratio_resize)
" Fill screen with current window.
nnoremap <C-w>+ <C-w><Bar><C-w>_

" Powerline
" Don't want to need patched fonts everywhere.
let Powerline_symbols = 'compatible'
let Powerline_stl_path_style = 'relative'
" Use my theme
let Powerline_theme = 'sanity'
let Powerline_colorscheme = 'sanity'

let g:Powerline#Segments#ctrlp#segments#focus = ''
let g:Powerline#Segments#ctrlp#segments#prev = ''
let g:Powerline#Segments#ctrlp#segments#next = ''

" NotGrep
let g:notgrep_no_mappings = 1

" Operators
map <Leader>` <Plug>(operator-camelize-toggle)

"}}}



