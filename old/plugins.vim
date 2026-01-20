call plug#begin('~/.local/share/nvim/site/plugged')

Plug 'vim-scripts/Gummybears'
Plug 'sainnhe/edge'
Plug 'peitalin/vim-jsx-typescript'
Plug 'airblade/vim-gitgutter'                                                                                        
Plug 'editorconfig/editorconfig-vim'                                                                                 
Plug 'itchyny/lightline.vim'                                                                                         
Plug 'junegunn/fzf.vim'                                                                                              
Plug 'tpope/vim-eunuch'                                                                                              
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'                                                                                           
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'scrooloose/nerdcommenter'
Plug 'ryanoasis/vim-devicons'
Plug 'pangloss/vim-javascript'    
Plug 'leafgarland/typescript-vim' 
Plug 'maxmellon/vim-jsx-pretty'   
Plug 'jparise/vim-graphql'        
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'tomasr/molokai'
Plug 'folke/tokyonight.nvim'
Plug 'github/copilot.vim'
Plug 'lewis6991/gitsigns.nvim' 
Plug 'nvim-tree/nvim-web-devicons' 
Plug 'romgrk/barbar.nvim'

Plug 'deparr/tairiki.nvim'
Plug 'tomasiser/vim-code-dark'
Plug 'w0ng/vim-hybrid'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'rainglow/vim'

call plug#end()                                                                                                      
filetype plugin indent on

let g:coc_global_extensions = [
      \'coc-biome',
      \'coc-tsserver',
      \'coc-json',
      \'coc-tsls',
      \'coc-git'
      \]
