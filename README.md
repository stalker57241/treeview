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

Enabling:

```lua
require('plugins/treeview').setup()
```

Enter `:tree` to open file list.

Or add a mappings, like this:

```
vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
  -- your commands
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

# Dependencies

- [`lfs`](https://github.com/lunarmodules/luafilesystem)

# What need to do

- [X] Open subfolders directly in active list
- [ ] Highlight it!
- [ ] Search by name
  - [ ] Filter by name
- [ ] More sorting algorithms (If possible)
