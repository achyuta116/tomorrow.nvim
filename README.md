### Do it Tomorrow!
A neovim plugin which helps you to remember what has to be done in a project the next day!

#### Installation
```lua
-- Install the plugin via packer or lazy.nvim
use {
    "achyuta116/tomorrow.nvim",
}
```

#### Configuration
The default configuration uses the following keybinds
```lua
vim.api.nvim_set_keymap("n", "<leader>tx", ":lua require('tomorrow').delete_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>ta", ":lua require('tomorrow').add_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tl", ":lua require('tomorrow').list_comments()<CR>", {})
```

Change the default configuration using `on_attach` as follows 

```lua
require('tomorrow').setup {
    on_attach = function(bufnr) 
        vim.api.nvim_set_keymap("n", "<leader>x", ":lua require('tomorrow').delete_comment()<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>a", ":lua require('tomorrow').add_comment()<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>l", ":lua require('tomorrow').list_comments()<CR>", {})
    end
}
```

#### Contribution
Submit any feature requests or bug fixes as an issue.
