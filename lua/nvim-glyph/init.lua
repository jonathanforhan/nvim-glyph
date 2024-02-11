---@module 'nvim-glyph.init'

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local dropdown = require('telescope.themes').get_dropdown({})
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local digraphs = require('nvim-glyph.digraphs')

local M = {}

M.opts = {
  -- path of the vim digraph table
  digraph_table_path = vim.fn.expand("$VIMRUNTIME/doc/digraph.txt"),

  -- telescope style for popup
  telescope_style = dropdown,

  -- these are the catagories that nvim-glyph defines to be excludable
  exclude_catagories = {
    -- 'GREEK',
    -- 'LATIN',
    -- 'CYRILLIC',
    -- 'HEBREW',
    -- 'ARABIC',
    -- 'BOX',
    -- 'JAPANESE',
    -- 'OTHER'
  },

  -- exclude these keywords for being display, still present for queries, however
  exclude_keywords = {
    'GREEK ',
    'LATIN ',
    'CYRILLIC ',
    'HEBREW ',
    'ARABIC ',
    'ARABIC%-INDIC ',
    'EXTENDED ',
    'VULGAR ',
    'HIRAGANA ',
    'KATAKANA ',
    'BOPOMOFO ',
    'CAPITAL ',
    'SMALL ',
    'LETTER ',
    'DIGIT ',
  },

  -- exclude certain digraph codes from being included
  exclude_code = {},

  -- custom user-defined digraphs
  custom = {},
}

---setup with digraph options
---@param opts any
M.setup = function(opts)
  -- copy user opts into default
  for k, v in pairs(opts) do
    M.opts[k] = v
  end

  -- catagories toupper
  for i = 1, #M.opts.exclude_catagories do
    M.opts.exclude_catagories[i] = M.opts.exclude_catagories[i]:upper()
  end

  -- keywords toupper
  for i = 1, #M.opts.exclude_keywords do
    M.opts.exclude_keywords[i] = M.opts.exclude_keywords[i]:upper()
  end

  M.opts = digraphs.expand_excludes(M.opts)
end

---pick_digraph
---allows user the pick a diagraph via query
M.pick_digraph = function()
  local mode = vim.api.nvim_get_mode().mode
  local insert = mode == 'i' or mode == 'v'

  pickers.new(M.opts.telescope_style, {
    prompt_title = 'Digraphs',
    finder = finders.new_table({
      results = digraphs.fetch(M.opts),
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1] .. ' ' .. entry[3],
          ordinal = entry[3] .. ',' .. entry[2],
        }
      end,
    }),
    sorter = conf.generic_sorter(M.opts.telescope_style),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_put({ selection.value[1] }, '', false, true)
        if insert then
          vim.api.nvim_feedkeys('a', 'n', true)
        end
      end)
      return true
    end
  }):find()
end

return M
