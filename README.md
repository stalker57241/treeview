# TreeView

TreeView is a plugin for [vis](https://github.com/martanne/vis)
P. S. Not a tree now

# Usage

Enabling:

```lua
require('plugins/treeview').setup()
```

Enter `:tree` to open file list.
Or add a macro
```
vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
  -- your commands
  vis:map(vis.modes.NORMAL, '<Tab>', function()
    vis:command("tree")
    return true
  end)
end)
```

# Dependencies

- [`lfs`](https://github.com/lunarmodules/luafilesystem)

# What need to do

- Open subfolders directly in active list
