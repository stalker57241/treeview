# TreeView

TreeView is a plugin for [vis](https://github.com/martanne/vis) to view files, folders, and so on, what isn't possible by default

# Available commands

- `:tree`
- `:parent`

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
