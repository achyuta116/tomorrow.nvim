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
local function _persist()
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "w")
    local new_content = vim.json.encode(M.files)
    if file then
        file:write(new_content)
        file:close()
    else
        print("Error Writing to tomorrow.json: ", err)
    end
end

local function _init()
end

-- a function which adds a (file, comment) to a table
local function _add_to_files(path, comment)
    local to_insert = { comment = comment, time = os.date("%Y-%m-%d %H:%M:%S", os.time()) }

    if not M.files[path] then
        M.files[path] = {
            to_insert
        }
    else
        table.insert(M.files[path], to_insert)
    end
    _persist()
end

function M.add_comment()
    _add_to_files(vim.fn.expand("%:p"), vim.fn.input("Add comment: "))
end

-- a function which deletes the (file, comment) from the table
local function _delete_from_file(path, comment)
    local index = nil
    local comments = M.files[path]
    if not comments then
        print("No comments for this file.")
        return
    end

    for idx, file_comment in ipairs(comments) do
        if file_comment.comment == comment then
            index = idx
            break
        end
    end

    if M.files[path] then
        table.remove(M.files[path], index)
    end
end

function M.delete_comment()
    pickers.new(require("telescope.themes").get_dropdown {}, {
        prompt_title = "Delete Comment",
        finder = finders.new_table {
            results = M.files[vim.fn.expand("%:p")],
            entry_maker = function(entry)
                return {
                    value = entry.comment,
                    display = entry.comment,
                    ordinal = entry.time
                }
            end
        },
        attach_mappings = function(prompt_bufnr, _)
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

local function _get_root()
    return vim.loop.cwd()
end

local function _get_relevant_files()
    local filenames = {}
    for filename, _ in pairs(M.files) do
        if filename:sub(1, #_get_root()) == _get_root() then
            table.insert(filenames, filename)
        end
    end

    return filenames
end

local function _get_comments(filename)
    return M.files[filename]
end

function M.list_comments()
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

function M.setup(config)
    local file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "r")
    if file then
        local content = file:read("*a")
        local ok, result = pcall(vim.json.decode, content)
        if ok then
            M.files = result
        else
            print("Error Parsing tomorrow.json", result, content)
        end
        file:close()
    else
        file, err = io.open(vim.fn.stdpath('data') .. "/tomorrow.json", "w")
        if file then
            file:write("[]")
            file:close()
        else
            print("Error Creating tomorrow.json", err)
        end
    end

    if config.default then
        function config.on_attach(bufnr)
            vim.api.nvim_set_keymap("n", "<leader>tx", ":lua require('tomorrow').delete_comment()<CR>", {})
            vim.api.nvim_set_keymap("n", "<leader>ta", ":lua require('tomorrow').add_comment()<CR>", {})
            vim.api.nvim_set_keymap("n", "<leader>tl", ":lua require('tomorrow').list_comments()<CR>", {})
        end
    end

    config.on_attach()
end

return M
