set rtp +=~/.vim

nnoremap <SPACE> <Nop>
let mapleader="\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================

call plug#begin()

Plug 'editorconfig/editorconfig-vim'

" Color scheme
Plug 'chriskempson/base16-vim'

" Fuzzy finder
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Semantic language support
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

" Snippets
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" Pretty icons for LSP
Plug 'onsails/lspkind-nvim'

" Language/format-specific tools
Plug 'simrat39/rust-tools.nvim'
Plug 'snakemake/snakemake', {'rtp': 'misc/vim'}
Plug 'jose-elias-alvarez/typescript.nvim'

" Delete, change, add surrounding pairs
Plug 'tpope/vim-surround'

" make hlsearch nicer
Plug 'romainl/vim-cool'

" vim ui select
Plug 'nvim-telescope/telescope-ui-select.nvim'

" formatting
Plug 'mhartington/formatter.nvim'

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

call plug#end()


" =============================================================================
" # Autocommands
" =============================================================================

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

" =============================================================================
" # Colors
" =============================================================================

set background=dark
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard

" =============================================================================
" # Key mappings
" =============================================================================

" Ctrl+j as Esc
" nnoremap <C-j> <Esc>
" inoremap <C-j> <Esc>

" Copy clipboard
map <leader>y "*y

" open current file with default app
nmap <leader>x :!open %<CR>

xnoremap <leader>go <esc>:'<,'>:w !google<CR>

" =============================================================================
" # Editor settings
" =============================================================================

" Turn folding off
set nofoldenable

" Turn on syntax highlighting.
syntax on

" Default settings for spacing
set tabstop=4
set shiftwidth=4
" set expandtab

" Completion
" Better display for messages
set cmdheight=1

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

set list
set listchars=tab:→\ ,trail:·

" Permanent undo
set undodir=~/.vimdid
set undofile

" Having longer update time leads to noticeable delays 
" and poor user experience.
set updatetime=300

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

set mouse=a " Enable mouse usage (all modes) in terminals

" Sane splits
set splitright
set splitbelow

" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2

set nowrap
" Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set nojoinspaces

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Proper search
set incsearch
set ignorecase smartcase
set gdefault

set encoding=utf-8
set ambiwidth=single

" =============================================================================
" # Telescope
" =============================================================================
"
noremap <C-p> :Telescope git_files<CR>
noremap <leader>ff :Telescope find_files<CR>
noremap <leader>; :Telescope buffers<CR>
noremap <leader>s :Telescope live_grep<CR>
noremap <leader>d :Telescope diagnostics<CR>
noremap <leader>D :Telescope lsp_type_definitions<CR>
noremap gr :Telescope lsp_references<CR>

" edit dotfiles
noremap <leader>ed :Telescope git_files cwd=~/github/manzt/dotfiles<CR>

lua << EOF
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
EOF

" =============================================================================
" # LSP
" =============================================================================

lua << EOF
require("mason").setup()
require("mason-lspconfig").setup()

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>dn', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>dp', vim.diagnostic.goto_prev, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
   -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

require('lspconfig')['solargraph'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
require('lspconfig')['pyright'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
require('lspconfig')['svelte'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
require('lspconfig')['eslint'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
require('lspconfig')['vuels'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
require('lspconfig')['denols'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
  root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
}
require('typescript').setup {
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = require('lspconfig').util.root_pattern('package.json'),
  },
}
require('rust-tools').setup {
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      ["rust-analyzer"] = { checkOnSave = { command = "clippy" } },
    },
  },
}

EOF

" =============================================================================
" # Auto complete setup
" =============================================================================

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect


lua <<EOF
local cmp = require 'cmp'
cmp.setup({
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<c-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<c-space>"] = cmp.mapping.complete(),
    --- https://stackoverflow.com/questions/71914213/nvim-completion-menu-issue
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item()),
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item()),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = require('lspkind').cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[snip]",
        path = "[path]",
      },
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
})
EOF


" =============================================================================
" # Treesitter
" =============================================================================
lua <<EOF
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
EOF

" =============================================================================
" # Formatter
" =============================================================================
lua <<EOF
local denofmt = function()
  return {
    exe = "deno",
    args = { "fmt", "-", "--options-use-tabs" },
    stdin = true,
  }
end

local black = function()
  return {
    exe = "black",
    args = { '-' },
    stdin = true,
  }
end

require('formatter').setup({
  filetype = {
    python = { black },
    javascript = { denofmt },
    javascriptreact = { denofmt },
    typescript = { denofmt },
    typescriptreact = { denofmt },
    html = { denofmt },
    css = { denofmt },
    json = { denofmt },
    markdown = { denofmt },
  }
})
EOF

nnoremap <silent> <leader>f :Format<CR>
set timeoutlen=300
