filetype plugin indent on
set encoding=UTF-8
set tabstop=2
set shiftwidth=2
set expandtab
set nowrap
set number
map <C-n> :NERDTreeToggle<CR>
map ; :Files<CR>
set laststatus=2
syntax on
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
let g:javascript_plugin_flow = 1
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1

:nmap # \

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>b <cmd>Bookmark<cr>

au BufRead,BufNewFile *.cdc setfiletype cadence

set termguicolors
set background=dark

let g:edge_style = 'neon'

so ~/.config/nvim/plugins.vim
so ~/.config/nvim/coc.vim

" colorscheme molokai
colorscheme catppuccin-mocha 

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fr <cmd>Telescope resume<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fg <cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>
nnoremap <leader>fb <cmd>Telescope file_browser path=%:p:h<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<TAB>"

" Barbar
nnoremap <silent>    <A-,> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <A-.> <Cmd>BufferNext<CR>
nnoremap <silent>    <A-c> <Cmd>BufferClose<CR>
nnoremap <silent>    <A-s-c> <Cmd>BufferRestore<CR>

" Clipboard
vnoremap y "*y
vnoremap p "*p

map <Leader>y "*y
map <Leader>p "*p

" Co-pilot
imap <silent><script><expr> <C-c> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

map <leader>n <cmd>NERDTreeFind<CR>

if exists("g:neovide")
  set guifont=Comic\ Mono:h12
endif

autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
  \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

lua require('telescope').load_extension('file_browser')
lua require('telescope').load_extension('live_grep_args')

set clipboard=unnamedplus
