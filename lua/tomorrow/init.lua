-- when reopening neovim, present the
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local plenary_path = require("plenary.path")
-- user with a prompt to specify valid filepath for file which has been moved

-- to execute the function

-- a table which stores a list of (comment) for a given filename
local M = {}
M.files = {}

-- persist the table in memory somehow
local _persist = function()
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "w+")
    local new_content = vim.json.encode(M.files)
    if file then
        file:write(new_content)
    else
        print("Error Writing to tomorrow.json: ", err)
    end
end

local _init = function()
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "r+")
    if file then
        local content = file:read("*a")
        local ok, result = pcall(vim.json.decode, content)
        if ok then
            M.files = result
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
    if not M.files[path] then
        M.files[path] = {
            { comment = comment, time = os.date("%Y-%m-%d %H:%M:%S", os.time()) }
        }
    else
        table.insert(M.files[path], comment)
    end
    _persist()
end

M.add_comment = function()
    _add_to_files(vim.fn.expand("%:p"), vim.fn.input("Add comment: "))
end


-- a function which deletes the (file, comment) from the table
local _delete_from_file = function(path, comment)
    local index = nil
    for idx, file_comment in ipairs(M.files[path]) do
        if file_comment.comment == comment then
            index = idx
            break
        end
    end

    if M.files[path] then
        table.remove(M.files[path], index)
    end
end

M.delete_comment = function()
    pickers.new(require("telescope.themes").get_dropdown {}, {
        prompt_title = "Delete Comment",
        finder = finders.new_table {
            results = M.files[vim.fn.expand("%:p")]
        },
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                _delete_from_file(vim.fn.expand("%:p"), selection)
            end)
            return true
        end,
    }):find()

    _persist()
end


-- before completion of renaming, prompt the user

local _get_root = function()
    return vim.loop.cwd()
end

local _get_relevant_files = function()
    local filenames = {}
    for filename, _ in pairs(M.files) do
        if filename:sub(1, #_get_root()) == _get_root() then
            table.insert(filenames, filename)
        end
    end

    return filenames
end

local _get_comments = function(filename)
    return M.files[filename]
end

M.list_comments = function()
    local comments = _get_comments(vim.fn.expand("%:p"))
    if not comments or vim.tbl_count(comments) == 0 then
        print("No comments available for this file")
        return
    end

    local list = vim.tbl_map(function(comment)
        return comment.time .. " " .. comment.comment
    end, comments)

    local buffer = vim.api.nvim_create_buf(false, true)
    if not (buffer == 0) then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, list)
        vim.api.nvim_command("new | setlocal buftype=nofile | setlocal bufhidden=hide | setlocal noswapfile")
        vim.api.nvim_command("buffer " .. buffer)
        vim.api.nvim_command("resize 10")
    end
end

vim.api.nvim_set_keymap("n", "<leader>ta", ":lua require('tomorrow').add_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tx", ":lua require('tomorrow').delete_comment()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tl", ":lua require('tomorrow').list_comments()<CR>", {})

_init()

return M
