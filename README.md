# TreeView

TreeView is a plugin for [vis](https://github.com/martanne/vis) to view files, folders, and so on, what isn't possible by default

![screenshot1](https://github.com/stalker57241/treeview/blob/0ddc4235d0bfe7ae75b151bd7c86b16ca6df6997/.github/screenshot1.png)

# Available commands

- `:tree` - open TreeView
- `:parent` - open parent folder in TreeView (No matter from where)
  - Parent folder will open as tree root
  
# Bindings

- `Enter` to interact with file or folder.
- `Shift` + `Enter` (also `<KPEnter>`) To open folder or file's parent as tree root.

# Installation

To install this plugin, just clone it and install dependency:

```sh
git clone https://github.com/stalker57241/treeview ~/.config/vis/plugins/treeview
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

# Dependencies

- [`luafilesystem`](https://github.com/stalker57241/luafilesystem5.4) package
- [`tabview`](https://github.com/stalker57241/tabview) plugin (optional)
- [`plugin_register`](https://github.com/stalker57241/plugin_register) plugin (for proper interaction with other plugins)
# What need to do

- [X] Open subfolders directly in active list
- [X] Highlight it!
- [ ] Search by name
  - [ ] Filter by name
- [ ] More sorting algorithms (If possible)

# For developers

[`API`](https://github.com/stalker57241/treeview/blob/general/API.md)
