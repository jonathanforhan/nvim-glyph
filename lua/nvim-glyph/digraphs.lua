---@module "nvim-glyph.digraphs"

local util = require("nvim-glyph.util")

local M = {}

-- internal, expanded catagories; see init.lua for user-facing catagories
M.catagories = {
  "GREEK",
  "LATIN",
  "CYRILLIC",
  "HEBREW",
  "ARABIC",
  "EXTENDED",
  "BOX",
  "HIRAGANA",
  "KATAKANA",
  "BOPOMOFO",
}

---read_digraphs
---read in diagraph table help from vimdoc
---@param digraph_table_path string
---@return table
local read_digraphs = function(digraph_table_path)
  if not util.file_exists(digraph_table_path) then
    error("vim digraph table not found at: " .. digraph_table_path)
  end

  local lines = {}
  local table_found = false

  for line in io.lines(digraph_table_path) do
    if not table_found then
      -- find the table mbyte section
      if line:find("digraph%-table%-mbyte") then
        table_found = true
      end
    else
      lines[#lines + 1] = line
    end
  end

  table.remove(lines, 1)      -- remove header
  table.remove(lines, #lines) -- remove footer
  table.remove(lines, #lines) --
  table.remove(lines, #lines) --

  return lines
end

---replace exclude catagory with more extensive list
---@param opts table
---@return table
M.expand_excludes = function(opts)
  for i = 1, #opts.exclude_catagories do
    if opts.exclude_catagories[i] == "JAPANESE" then
      opts.exclude_catagories[i] = nil
      opts.exclude_catagories[#opts.exclude_catagories + 1] = "HIRAGANA"
      opts.exclude_catagories[#opts.exclude_catagories + 1] = "KATAKANA"
      opts.exclude_catagories[#opts.exclude_catagories + 1] = "BOPOMOFO"
    elseif opts.exclude_catagories[i] == "ARABIC" then
      opts.exclude_catagories[#opts.exclude_catagories + 1] = "EXTENDED"
    end
  end

  return opts
end

---add custom unicode to digraph_table
---@param table of custom digrams
---@param[out] diagraph_table to append to
M.add_custom = function(custom, digraph_table)
  for i = 1, #custom do
    local custom = custom[i]

    digraph_table[#digraph_table + 1] = {
      custom.value,
      custom.display,
      custom.ordinal or custom.display
    }
  end
end

---fetch_digraphs
---read digraphs and construct a queryable table for telescope
---@param opts table
---@return table
M.fetch = function(opts)
  local digraphs = read_digraphs(opts.digraph_table_path)
  local digraph_table = {}

  for i = 1, #digraphs do
    -- iterate by tab
    local w = {}
    for word in digraphs[i]:gmatch("([^\t]+)") do
      w[#w + 1] = word
    end

    local catagory = "OTHER"
    for j = 1, #M.catagories do
      if w[5] and w[5]:match("^" .. M.catagories[j]) then
        catagory = M.catagories[j]
      end
    end

    -- exclude user defined choices
    local exclude = false
    for j = 1, #opts.exclude_catagories do
      if catagory == opts.exclude_catagories[j] then
        exclude = true
      end
    end

    local exclude_index = w[5] and 4 or 3 -- space edge case
    for j = 1, #opts.exclude_code do
      if w[exclude_index] == tostring(opts.exclude_code[j]) then
        exclude = true
      end
    end

    if not exclude then
      -- scrub data for easier query
      local value = w[5] and w[1] or " "
      local ordinal = w[5] or w[4]
      local display = w[5] or w[4]

      for j = 1, #opts.exclude_keywords do
        display = display:gsub(opts.exclude_keywords[j], "")
      end

      digraph_table[#digraph_table + 1] = { value, ordinal, display }
    end
  end

  return digraph_table
end

return M
