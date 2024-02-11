# nvim-glyph

a neovim plugin to have queryable glyphs

## Install

```lua
{
  'jonathanforhan/nvim-glyph',
  dependencies = {
    { 'nvim-telescope/telescope.nvim' }
  },
  opts = {},
  init = function()
    vim.keymap.set('i', '<C-k>', function()
      require('nvim-glyph').pick_glyph()
    end)
  end
```

## Default Setup

unless changed within ```opts``` these are the default options

```lua
opts = {
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
  exclude_code = {
    -- a digraph dec code (see ':h digraphs' for codes)
  },

  -- custom user-defined glyphs
  custom = {
    -- {
    --   value = ''                        -- any unicode (or any UTF-8 string for that matter)
    --   display = 'TUX'                    -- a description
    --   ordinal = 'query string' or nil    -- optional query string, will be the display if nil
    -- }
  },
}
```

## Demo
