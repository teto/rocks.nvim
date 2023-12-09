---@mod rocks.cache rocks.nvim luarocks cache
---
---@brief [[
---
---Cached luarocks state.
---
---@brief ]]

-- Copyright (C) 2023 Neorocks Org.
--
-- Version:    0.1.0
-- License:    GPLv3
-- Created:    07 Dec 2023
-- Updated:    07 Dec 2023
-- Homepage:   https://github.com/nvim-neorocks/rocks.nvim
-- Maintainer: NTBBloodbath <bloodbathalchemist@protonmail.com>

local cache = {}

local luarocks = require("rocks.luarocks")
local nio = require("nio")

---@type { [string]: Rock[] } | nil
local _cached_rocks = nil

---Query luarocks packages and populate the cache.
---@async
cache.populate_cached_rocks = nio.create(function()
    if _cached_rocks then
        return
    end
    _cached_rocks = vim.empty_dict()
    ---@cast _cached_rocks Rock[]
    local future = nio.control.future()
    luarocks.cli({ "search", "--porcelain", "--all" }, function(obj)
        ---@cast obj vim.SystemCompleted
        future.set(obj)
    end, { text = true })
    ---@type vim.SystemCompleted
    local obj = future.wait()
    local result = obj.stdout
    if obj.code ~= 0 or not result then
        -- set cache back to nil so that we can retry again
        _cached_rocks = nil
        return
    end
    for name, version in result:gmatch("(%S+)%s+(%S+)%srockspec%s+[^\n]+") do
        if name ~= "lua" then
            local rock_list = _cached_rocks[name] or vim.empty_dict()
            ---@cast rock_list Rock[]
            table.insert(rock_list, { name = name, version = version })
            _cached_rocks[name] = rock_list
        end
    end
    if vim.tbl_isempty(_cached_rocks) then
        _cached_rocks = nil
    end
end)

---Tries to get the cached rocks.
---Returns an empty list if the cache is not ready,
---and triggers an async task to populate the cache.
---@return { [string]: Rock[] } rocks indexed by name
function cache.try_get_rocks()
    if not _cached_rocks then
        nio.run(cache.populate_cached_rocks)
        local rocks = vim.empty_dict()
        ---@cast rocks { [string]: Rock[] }
        return rocks
    end
    return _cached_rocks
end

return cache