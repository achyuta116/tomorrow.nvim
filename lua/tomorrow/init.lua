-- when reopening neovim, present the
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- user with a prompt to specify valid filepath for file which has been moved

-- our picker function: colors

-- to execute the function
local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "r+")
if file then

else
    file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "w")
    if file then
        file:write("[]")
    else
        print("Error Creating tomorrow.json", err)
    end
end


-- a table which stores a list of (comment) for a given filename
-- a function which adds a (file, comment) to a table
-- a function which deletes the (file, comment) from the table
-- persist the table in memory somehow
-- before completion of renaming, prompt the user
