set nocp

"" Files, backups and undo
set nobackup
set nowb
set noswapfile

"" Encoding
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8

"" Whitespace
set wrap                          " wrap lines
set tabstop=2 shiftwidth=2        " a tab is two spaces
set softtabstop=2                 " 
set expandtab                     " do replace tab with spaces
set backspace=indent,eol,start    " backspace through everything in insert mode

"" Searching
set hlsearch                      " highlight matches
set incsearch                     " incremental searching
set ignorecase                    " searches are case insensitive...
set smartcase                     " ... unless they contain at least one capital letter

"" Other
set ls=2                          " always show status bar
set number                        " show line numbers
set nocursorline                  " dont display a marker on current line (performance)
set ruler                         " show cursor position
set showmatch                     " show matching ) and }
set showmode                      " show current mode
set nocursorcolumn                " disabled by default
set relativenumber                " show relative number
set showcmd                       " show commands

"" Syntax
syntax on                         " syntax highlight
syntax sync minlines=256

" Enable filetype plugins
filetype plugin on
filetype indent on

set statusline=\ %<%f\ %h%m%r
set statusline+=%{(&paste?\"PASTE\":\"\")}
set statusline+=%=
"" encoding
set statusline+=%{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}
set statusline+=%k\ %-14.(%l,%c%V%)\ %P

"" commands
command W w !sudo tee % > /dev/null

" Visual mode pressing # searches for the current selection
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

"" maps
let mapleader = "\<space>"
nmap <leader>w :w!<cr>
nmap <leader>q :wq<cr>

"" tab
nmap <leader>tn :tabnew<cr>
nmap <leader>to :tabonly<cr>
nmap <leader>tc :tabclose<cr>
nmap <leader>tml :tabmove -1<cr>
nmap <leader>tmr :tabmove +1<cr>
nmap <leader>t<leader> :tabnext
" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <silent><leader>t :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Move a line of text
nmap <silent><leader>j mz:m+<cr>`z
nmap <silent><leader>k mz:m-2<cr>`z

" Remove the Windows ^M - when the encodings gets messed up
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <silent><leader>pp :setlocal paste!<cr>
" Toggle line numbers
map <silent><leader>nn :setlocal number!<cr>:setlocal relativenumber!<cr>

if exists("+showtabline")
  function MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      let s .= '%' . i . 'T'
      let s .= (i == t ? '%1*' : '%2*')
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      let s .= ' '
      let s .= '[' . i . ']'
      let s .= '%*'
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      let file = bufname(buflist[winnr - 1])
      let file = fnamemodify(file, ':p:t')
      if file == ''
        let file = '[No Name]'
      endif
      let s .= file . ' '
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : '')
    return s
  endfunction
  set stal=2
  set tabline=%!MyTabLine()
endif

function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction
