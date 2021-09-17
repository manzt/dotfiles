set rtp +=~/.vim

nnoremap <SPACE> <Nop>
let mapleader="\<Space>"


" =============================================================================
" # PLUGINS
" =============================================================================

call plug#begin()

"enable hard mode
Plug 'takac/vim-hardtime'
let g:hardtime_default_on = 1

" Vim enhancements
Plug 'editorconfig/editorconfig-vim'

" Color scheme
Plug 'chriskempson/base16-vim'
" Plug 'RRethy/nvim-base16'
" Plug 'morhetz/gruvbox'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Semantic language support
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

" Syntactic language support
Plug 'rust-lang/rust.vim'

" File tree viewer
" Plug 'preservim/nerdtree'
" Plug 'ryanoasis/vim-devicons'

" Delete, change, add surrounding pairs
Plug 'tpope/vim-surround'

" Nice find highlighting
Plug 'romainl/vim-cool'
Plug 'cespare/vim-toml'

nnoremap <leader>j :NERDTreeToggle<CR>

call plug#end()


" =============================================================================
" # Autocommands
" =============================================================================

" Jump to last edit position on opening file
if has("autocmd")
  " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
  au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" =============================================================================
" # Deal with colors ... 
" =============================================================================

if !has('gui_running')
  set t_Co=256
endif

if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

set background=dark
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard

highlight Normal guibg=NONE ctermbg=NONE

" Brighter comments
call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")

" call matchadd('ColorColumn', '\%81v', 90)
highlight ColorColumn ctermbg=8
set colorcolumn=90

" =============================================================================
" # Key mappings
" =============================================================================

" Ctrl+j as Esc
nnoremap <C-j> <Esc>
inoremap <C-j> <Esc>

" Open hotkeys
map <C-p> :Files<CR>
nmap <leader>; :Buffers<CR>

" Quick-save
nmap <leader>w :w<CR>

" Copy clipboard
map <leader>y "*y

" <leader>s for Rg search
noremap <leader>s :Rg

" Toggle through buffers
nnoremap <leader><leader> <c-^>

" Align selected lines
vnoremap <leader>ib :!align<cr>

" Close all other splits
nnoremap <leader>o :only<cr>

" Open new file adjacent to current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>


" =============================================================================
" # Editor settings
" =============================================================================

" Turn on syntax highlighting.
syntax on

" Default settings for spacing
set tabstop=4
set shiftwidth=4
" set expandtab

" Completion
" Better display for messages
set cmdheight=2

" Keep more context when scrolling off the end of a buffer
set scrolloff=3

" Enable file type detection, use default filetype settings
filetype plugin indent on
set autoindent

" If a file is changed outside of vim, automatically reload it without asking
set autoread

" Line numbers
set number
set relativenumber 
set numberwidth=2

" Permanent undo
set undodir=~/.vimdid
set undofile

" TextEdit might fail if hidden is not set.
set hidden

" Having longer update time leads to noticeable delays 
" and poor user experience.
set updatetime=300

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

set mouse=a " Enable mouse usage (all modes) in terminals

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Ignore patterns for ctrlp
set wildignore+=*/tmp/*
set wildignore+=*/node_modules/*

" Sane splits
set splitright
set splitbelow

set showcmd " Show (partial) command in status line.

set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2

set hidden
set nowrap
set nojoinspaces

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

set encoding=utf-8
set ambiwidth=single


" =============================================================================
" # LSP client setup
" =============================================================================

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
EOF


" =============================================================================
" # Auto complete setup
" =============================================================================

lua << EOF
-- Compe setup
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
    luasnip = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

--This line is important for auto-import
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
EOF

au BufReadPost *.njk set syntax=html
