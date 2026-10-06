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
	file = nil,
	path = "~",
}
-- local file
local function noop() return true end
local function unmap(window, mode, name)
	window:map(mode, name, noop)
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
end
local function getcwd()
	return os.getenv("PWD") or io.popen("pwd"):read("*l")
end
local function readfiles(buffer, path)
	vis:info("path: " .. path)
	local p = io.popen('ls -1 "' .. path .. '"')
	local cursor = 0
	for entry in p:lines() do
		buffer:insert(cursor, entry .. "\n")
		cursor = cursor + #entry + 1
	end
	p:close()
end
local function opentree()
	if module.win == nil then
		-- local filepath = vis.win.file.path:match("^(.*)/[^/]*$") or vis.win.file.path
		vis:command("vnew")
		module.win = vis.win
		module.file = module.win.file
		module.file.name = "TreeView"
		readfiles(module.file, module.path)
		module.win:draw()
		module.win.syntax = nil
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
	vis:command_register('tree', opentree, 'Opens tree view')
end

return module
