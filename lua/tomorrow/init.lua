-- when reopening neovim, present the
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- user with a prompt to specify valid filepath for file which has been moved

-- to execute the function

-- a table which stores a list of (comment) for a given filename

local files
local _init = function()
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "r+")
    if file then
        local content = file:read("*a")
        local ok, result = pcall(vim.json.decode, content)
        if ok then
            files = result
        else
            print("Error Parsing tomorrow.json", result)
        end
    else
        file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "w")
        if file then
            file:write("[]")
        else
            print("Error Creating tomorrow.json", err)
        end
    end
end



-- a function which adds a (file, comment) to a table
local _add_to_files = function(path, comment)
    if not files[path] then
        files[path] = {
            comment
        }
    else
        table.insert(files[path], comment)
    end
end


-- a function which deletes the (file, comment) from the table
local _delete_from_file = function(path, index)
    if files[path] then
        table.remove(files[path], index)
    end
end

-- persist the table in memory somehow
local _persist = function()
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "r+")
    local new_content = vim.json.encode(files)
    if file then
        file:write(new_content)
    else
        print("Error Writing to tomorrow.json")
    end
end
-- before completion of renaming, prompt the user

_init()
