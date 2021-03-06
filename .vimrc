" Plugin Ideas:
" * WPM tracker and coach. Could count percent of backspaces or whatever.
"
" TODO:
" * tex insert copied equation command?
" * Improve underline style
" * Change abbrev function to handle irregular words?
" * Figure out nice way to save sessions. Both terminal and vim.
" * Add comma at end of last json line when making a new line
" * Search which excludes comments
" * ctrl-w parses it's as one word?
" * Automatically start next entry when I edit my journal?
" * autocorrect double first letter capitalizations?
" * <C-S-T> to recover closed buffers
" * Cron backup also to s3 bucket
" * Figure out why vim is starting up slow.
" * Make a TODO manager for random TODO lists in files.
"
" TODONE:
" * Prettier vim opening splash screen?
" * Nice tab navigation
" * <C-v> pastes like a normal text editor.
" * make a cron job which backs up some number of my files to my raspberry pi
"

" Don't fully understand why I need the following but it fixed something
" broken with tmux.
set background=dark
set t_Co=256

let mapleader = "-"
let maplocalleader = "="

" Plugins {{{
"Command to reinstall plugins: PluginInstall
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'SirVer/ultisnips'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'junegunn/goyo.vim'

call vundle#end()

filetype plugin indent on
" }}}

" Ultisnips {{{
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-f>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"
" }}}

" Aesthetics {{{
" TODO: Is this the prettiest you can do?
syntax on
set autoindent
set smartindent
set number

set smartcase

set cursorline
set noerrorbells
set title

set dir=~/.vim/.cache
set undofile
set undodir=~/.vim/undodir

set splitbelow
set splitright
set hidden
" Start Up Screen {{{

fun! Start()

  "Create a new unnamed buffer to display our splash screen inside of.
  enew

  " Set some options for this buffer to make sure that does not act like a
  " normal winodw.
  setlocal
    \ bufhidden=wipe
    \ buftype=nofile
    \ nobuflisted
    \ nocursorcolumn
    \ nocursorline
    \ nolist
    \ nonumber
    \ noswapfile
    \ norelativenumber

  " Our message goes here. Mine is simple.
  exec ":r !fortune"
  exec ":r ~/.vim/splash.txt"

  " When we are done writing out message set the buffer to readonly.
  setlocal
    \ nomodifiable
    \ nomodified

  " Just like with the default start page, when we switch to insert mode
  " a new buffer should be opened which we can then later save.
  nnoremap <buffer><silent> e :enew<CR>
  nnoremap <buffer><silent> i :enew <bar> startinsert<CR>
  nnoremap <buffer><silent> o :enew <bar> startinsert<CR>


endfun

" http://learnvimscriptthehardway.stevelosh.com/chapters/12.html
" Autocommands are a way of setting handlers for certain events.
" `VimEnter` is the event we want to handle. http://vimdoc.sourceforge.net/htmldoc/autocmd.html#VimEnter
" The cleene star (`*`) is a pattern to indicate which filenames this Autocommand will apply too. In this case, star means all files.
" We will call the `Start` function to handle this event.

" http://vimdoc.sourceforge.net/htmldoc/eval.html#argc%28%29
" The number of files in the argument list of the current window.
" If there are 0 then that means this is a new session and we want to display
" our custom splash screen.
if argc() == 0
  autocmd VimEnter * call Start()
endif

" }}}
"}}}

" Normal Mode Commands {{{
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <S-TAB> gT
nnoremap <C-I> gt
" TODO: somehow tab is shading <C_I>? why?
nnoremap <C-P> <C-I>
nnoremap <C-s> :w
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+
"}}}

" File Type Settings {{{
set spellfile=~/.vim/spell/en.utf-8.add
augroup spell
	autocmd!
	autocmd Filetype tex setlocal spell
	autocmd Filetype html setlocal spell
	autocmd Filetype text setlocal spell
augroup END

" TODO: What other files should I linewrap?
" TODO: Is this line working as I want?
augroup linewrap
	autocmd!
	autocmd Filetype bib setlocal wrap
	autocmd Filetype bib setlocal textwidth=80
augroup END

" This command is really just for editing tex files but it seems harmless to
" make generally available.
onoremap i$ :<c-u>normal! F$lvf$h<cr>
"}}}

" Extending Files {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>es :UltiSnipsEdit<cr>
" }}}

" Insert Mode Commands {{{
inoremap <c-u> <esc>lviwUwi
inoremap jk <esc>
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>
"}}}

" Aesthetic Scrolling Changes {{{
nnoremap <c-f> <c-f>zz
nnoremap <c-b> <c-b>zz
nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz
"}}}

" Vimscript file settings {{{
augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
	autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END
" }}}

" Livewriting mode {{{
function! ToggleWritingMode()
	if !exists('#WriteMode#InsertLeave')
		augroup WriteMode
			autocmd!
			autocmd InsertLeave * w
		augroup END
	else
		augroup WriteMode
			autocmd!
		augroup END
	endif
endfunction
command! WriteLive call ToggleWritingMode()
" }}}

" Macaulay2 Settings {{{
augroup filetype_mac
	autocmd!
	autocmd Filetype modula2 setlocal syntax=no
augroup END
" }}}

" Commenting Autocommands {{{

" TODO: make this line work for macaulay files
function! IsComment()
	let hg = join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
	return hg =~? 'comment' ? 1 : 0
endfunction

augroup comment
	autocmd!
	autocmd FileType python nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^x`c' : 'mcI#<esc>`c'
	autocmd FileType sh nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^x`c' : 'mcI#<esc>`c'
	autocmd FileType modula2 nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^xx`c' : 'mcI--<esc>`c'
	autocmd FileType vim nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^xx`c' : 'mcI"<space><esc>`c'
	autocmd FileType tex nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^xx`c' : 'mcI%<space><esc>`c'
	autocmd FileType html nnoremap <expr> <buffer> <localleader>c IsComment() ? 'mc^5x$4Xx`c' : 'mcI<!--<space><esc>$a<space>--!><esc>`c'
augroup END
" }}}

" Abbreviations {{{

" TODO: handle suffixes? Have toggle to handle which to generate? -v for verb?
function! Abbrevword(...)
	let toabbr = a:1
	let target = join(a:000[1:]," ") 
	execute ("iabbrev " . toabbr ." ".target)
	execute ("iabbrev " . toabbr."s ".target."s")
	execute ("iabbrev " . (toupper(toabbr[0]).toabbr[1:])." ".toupper(target[0]) . target[1:])
	execute ("iabbrev " . (toupper(toabbr[0]).toabbr[1:]."s ".toupper(target[0]).target[1:]."s"))
endfunction
command! -nargs=+ AbbrevWord call Abbrevword(<f-args>)

" Probability
AbbrevWord distr distribution
AbbrevWord disted distributed
AbbrevWord rv random variable
AbbrevWord rV random Variable
AbbrevWord prob probability
AbbrevWord probly probably
AbbrevWord prbs probabilities
AbbrevWord whp with high probability
AbbrevWord rMT random matrix theory

" Logic (Mathematical bent but not purely)
AbbrevWord ew elsewhere
AbbrevWord tf therefore
AbbrevWord wlog without loss of generality
AbbrevWord wrt with respect to
AbbrevWord te there exists
AbbrevWord fa for all
AbbrevWord lhs left hand side
AbbrevWord rhs right hand side
AbbrevWord defn definition
AbbrevWord fn function
AbbrevWord cond condition
AbbrevWord st such that
AbbrevWord iff if and only if
AbbrevWord sa such as
AbbrevWord ow otherwise
AbbrevWord resp respectively
AbbrevWord bc because
AbbrevWord wo without
AbbrevWord surj surjective
AbbrevWord inj injective
AbbrevWord bij bijective
AbbrevWord iso isomorphism

" Linear Algebra
AbbrevWord ind independent
AbbrevWord indy independently
AbbrevWord indc independence
AbbrevWord linind linearly independent
AbbrevWord codim codimension
AbbrevWord cok cokernel
AbbrevWord dmn dimension
AbbrevWord dmnl dimensional
AbbrevWord vs vector space

" General Math
AbbrevWord expy exponentially
AbbrevWord clh Cohen-Lenstra heuristic
AbbrevWord cl Cohen-Lenstra
AbbrevWord sst semi-standard Young tableaux
AbbrevWord inj injective
AbbrevWord padic $p$-adic
AbbrevWord poly polynomial
AbbrevWord seq sequence
AbbrevWord ctns continuous

" Analysis
AbbrevWord triineq triangle inequality
AbbrevWord tbt therefore by the
AbbrevWord ineq inequality


iabbrev ret return
AbbrevWord jmail jakethekoenig@gmail.com
" }}}
