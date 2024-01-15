## Do it Tomorrow!
A neovim plugin which helps you to remember what has to be done in a project the next day!

### Installation
```lua
-- Install the plugin via packer or lazy.nvim
use {
    "achyuta116/tomorrow.nvim",
}
```

### Configuration
The default configuration uses the following keybinds
```lua
vim.api.nvim_set_keymap("n", "<leader>tx", ":lua require('tomorrow').delete_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>ta", ":lua require('tomorrow').add_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tl", ":lua require('tomorrow').list_comments()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tL", ":lua require('tomorrow').all_comments()<CR>", {})
```

Change the default configuration using `on_attach` as follows 

```lua
require('tomorrow').setup {
    on_attach = function(bufnr) 
        vim.api.nvim_set_keymap("n", "<leader>x", ":lua require('tomorrow').delete_comment()<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>a", ":lua require('tomorrow').add_comment()<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>l", ":lua require('tomorrow').list_comments()<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>L", ":lua require('tomorrow').all_comments()<CR>", {})
    end
}
```

### Features
`add_comment` 
Saves a comment for the open buffer  
`delete_comment` 
Opens a finder window which has you select a particular comment to delete
`list_comments` 
Opens a new window populating lines with comments for the previously open buffer 
`all_comments` 
From the current working directory, opens a quickfix menu populating entries with comments from all files part of the cwd which have comments associated with them


### Contribution
Submit any feature requests or bug fixes as an issue.
