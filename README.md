# TreeView

TreeView is a plugin for [vis](https://github.com/martanne/vis) to view files, folders, and so on, what isn't possible by default

# Available commands

- `:tree` - open TreeView
- `:parent` - open parent folder in TreeView (No matter from where)

# Installation

To install this plugin, just clone it and install dependency:

```sh
git clone https://github.com/stalker57241/treeview ~/.config/vis/plugins/treview
luarocks install luafilesystem
```

# Usage

## Enabling plugin

```lua
local treeview = require('plugins/treeview')
treeview.setup()
-- There will be more configurations and options
```

Enter `:tree` to open file list.

## Adding mappings

```
vis.events.subscribe(vis.events.INIT, function()
  -- your other settings
  vis:map(vis.modes.NORMAL, '<Tab>', function()
    vis:command("tree") -- for opening tree window by button
    return true
  end)
  vis:map(vis.modes.NORMAL, '!', function()
    vis:command("parent") -- for jumping up inside tree
    return true
  end)
end)
```


## Opening by default

To open it, when no files present, add to your `visrc.lua`:
```lua
-- ...
-- This event emitted after all windows created and files opened, before mainloop started
vis.events.subscribe(vis.events.START, function() 
    if vis.win.file.name == nil then -- or something like "vis.win.file.path == nil"
        vis:command('tree')
        -- Add feedkeys to go right, like <C-w>l
        vis:feedkeys('<C-w>l')
    end
end)
-- ...
```

# Dependencies

- [`lfs`](https://github.com/lunarmodules/luafilesystem)

# What need to do

- [X] Open subfolders directly in active list
- [ ] Highlight it!
- [ ] Search by name
  - [ ] Filter by name
- [ ] More sorting algorithms (If possible)
