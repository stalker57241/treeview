local lfs = require("lfs")

local vis = _G.vis

local env, mt = {}, {
	__index = _G,

	__newindex = function ()
		error("Error: runaway assignment on treeview module", 2)
	end
}
local _ENV = setmetatable(env, mt)

-- MAIN --

local module = {
	win = nil,
	lastwin = nil,
	file = nil,
	path = "~",
	relativepath = "~"
}
-- local file
local function noop() return true end
local function unmap(window, mode, name)
	window:map(mode, name, noop)
end
local function getline(file, cursor)
	return file.lines[cursor]
end
local function parent(path)
  path = path:gsub("/+$", "")
  return path:match("^(.*)/[^/]+$") or "."
end
local function readfiles(buffer, path)
	buffer:delete(0, buffer.size)
	local HEADER = "TreeView\n"
	buffer:insert(0, HEADER)
	local cursor = #HEADER
	buffer:insert(cursor, path .. "\n\n")
	cursor = cursor + #path + 2
	buffer:insert(cursor, "../\n")
	cursor = cursor + 4
	for entry in lfs.dir(path) do if entry ~= "." and entry ~= ".." then
		buffer:insert(cursor, entry)
		cursor = cursor + #entry
		if lfs.attributes(path .. "/" .. entry, "mode") == "directory" then
			buffer:insert(cursor, "/")
			cursor = cursor + 1
		end
		buffer:insert(cursor, "\n")
		cursor = cursor + 1
	end end
	module.win:draw()
	vis:redraw()
end
local function maptree(window)
	unmap(window, vis.modes.NORMAL, "i")
	unmap(window, vis.modes.NORMAL, "I")
	unmap(window, vis.modes.NORMAL, "a")
	unmap(window, vis.modes.NORMAL, "A")
	unmap(window, vis.modes.NORMAL, "O")
	unmap(window, vis.modes.NORMAL, "o")
	unmap(window, vis.modes.NORMAL, "R")
	unmap(window, vis.modes.NORMAL, "s")
	unmap(window, vis.modes.NORMAL, "S")
	unmap(window, vis.modes.NORMAL, "c")
    unmap(window, vis.modes.NORMAL, "C")
	unmap(window, vis.modes.NORMAL, "r")
	window:map(vis.modes.NORMAL, "<Enter>", function() 
		local lineid = window.selection.line
		local line = getline(module.file, lineid)
		if lfs.attributes(module.path .. "/" .. line, "mode") == "directory" then
			if line == "../" then
				module.path = parent(module.path)
				readfiles(module.file, module.path)
			else
				module.path = module.path .. "/" .. line:gsub("/+$", "")
				readfiles(module.file, module.path)
			end
			vis:info("Folder: '" .. line .. "'")
		else 
			module.lastwin.file = module.path .. "/" .. line
			vis:info("File at: '" .. module.path .. "/" .. line .. "'")
		end
	end)
end
local function getcwd()
	return os.getenv("PWD") or io.popen("pwd"):read("*l")
end
local function opentree(path)
	if module.win == nil then
		module.lastwin = vis.win
		vis:command("vnew")
		module.win = vis.win
		module.file = module.win.file
		module.file.name = "TreeView"
		readfiles(module.file, path)
		module.win:draw()
		module.win.syntax = nil
		module.win.numbers = false
		-- module.win.width = 10
		-- module.win.tabwidth = 2
		module.win.statusbar = false
		maptree(module.win)
		module.win:draw()
		--module.win:status("TreeView")
		vis:redraw()
--		vis:info("opentree")
	else module.win:close(true) end
end

-- EXPORT --
vis.events.subscribe(vis.events.WIN_CLOSE, function(win)
	if win == module.win then
		module.win = nil
		module.file = nil
		return true
	end
	return false
end)
function module.setup()
	module.path = getcwd()
	module.relativepath = module.path
	vis:command_register('tree', function() opentree(module.path) end, 'Opens tree view')
end

return module
