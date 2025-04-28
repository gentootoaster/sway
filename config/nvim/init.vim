call plug#begin()

Plug 'nvim-lualine/lualine.nvim'
Plug 'Mofiqul/vscode.nvim'
Plug 'xiyaowong/transparent.nvim'

call plug#end()

lua <<EOF
require('lualine').setup{
  options = {
    theme = 'auto',
    icons_enabled = false,
    component_separators = '',
    section_separators = '',     
  }
}
EOF

colorscheme vscode 
set clipboard+=unnamedplus
set number
