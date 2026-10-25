# TreeView API

## Lifecycle

### `treeview.setup()`

Sets up everything

## Commands

### `:tree`

Toggles treeview display

### `:parent`

Opens parent directory in `treeview`

## Recommendations

Mine `visrc.lua`:

```lua
vis.events.subscribe(vis.events.INIT, function()
  -- Other settings
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

### Opening by default

To open `treeview` on start, when no files present add to `visrc.lua` this:

```lua
local treeview = require('plugins/treeview')
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

# At `dev` (**WIP**)

This changes available at `dev` branch and will be added, removed. or changed in further updates.

## Events

### `treeview.events.INTERACT`

**Signature**: `interact()`

**CAUTION**: Not working.

### `treeview.events.OPEN_FOLDER`

**Signature**: `open_folder(newbasedir)`

Emitted when editor rerooting

## Getters

### `tabview.getpath()`

Returns root folder of `treeview`

## Setters

### `tabview.setwidth(width)`

**VWIP** (**Very** work in progress)

Sets width of `treeview` panel.

Awaiting for merging pull request [`max_size`](https://github.com/martanne/vis/pull/1430)

Works properly only with [`stalker57241/vis`](https://github.com/stalker57241/vis)
