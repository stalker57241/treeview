--[[
PLUGIN: TreeView
DESCRIPTION: Tree view plugin for vis
REPOSITORIES:
- https://github.com/stalker57241/treeview
AUTHOR:
	stalker320 (also stalker57241)
]]

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
	if path == "/" then return "/" end
	path = path:gsub("/+$", "")
	path = path:match("^(.*)/[^/]+$")
	if path == "" then
		return "/" 
	else
		return path 
	end
end
local function writeheader(buffer, offset, header)
	buffer:insert(offset, header)
	return offset + #header
end
local function listdir(path)
	local entries = {}
	for entry in lfs.dir(path) do if entry ~= "." and entry ~= ".." then
		table.insert(
			entries,
			{
				field = entry,
				isdir = lfs.attributes(path .. "/" .. entry, "mode") == "directory"
			}
		)
	end end
	table.sort(entries, function (a, b)
		if a.isdir ~= b.isdir then
			return a.isdir
		else return a.field < b.field end
	end)
	return ipairs(entries)
end
local function readfiles(buffer, path, indent, cursor)
	for _, entry in listdir(path) do if entry ~= "." and entry ~= ".." then
		if indent > 0 then for _ = 1, indent do
			buffer:insert(cursor, "  ")
			cursor = cursor + 2
		end end
		if entry.isdir then
			buffer:insert(cursor, "+ ")
		else buffer:insert(cursor, "  ") end
		cursor = cursor + 2
		buffer:insert(cursor, entry.field)
		cursor = cursor + #entry.field
		if entry.isdir then
			buffer:insert(cursor, "/")
			cursor = cursor + 1
		end
		buffer:insert(cursor, "\n")
		cursor = cursor + 1
	end end
	return cursor
end
local function openfiles(buffer, path)
	buffer:delete(0, buffer.size)
	local cursor = writeheader(buffer, 0, "\tTreeView\n\t<Enter> to interact\n\t<Space> to change root\n\t:parent to open parent directory\n" .. path .. "\n\n")
	if path ~= "/" then
		buffer:insert(cursor, "* ../\n")
		cursor = cursor + 6
	end
	cursor = readfiles(buffer, path, 0, cursor)
end
local function getlevel(line)
	local spaces = (line:match("^( *)") or ""):len()
	line = line:sub(spaces + 1, #line)
	if line:sub(1, 1) == "+" or line:sub(1, 1) == "-" or line:sub(1, 1) == "*" then
		return spaces / 2 -- "123+ X" is 3
	else
		return spaces / 2 - 1 -- "1234X" is 3 (file has "  " prefix)
	end
end
local function getstate(line)
	return line:sub(getlevel(line) * 2 + 1, #line):sub(1, 1)
end
local function getfile(line)
	local offset = getlevel(line) + 1
	if line:sub(#line - 1, #line) == "/" then
		return line:sub(offset * 2 + 1, #line - 1)
	else
		return line:sub(offset * 2 + 1, #line)
	end
end

-- Returns " ", "+", "-", or "*"
local function setstate(buffer, lineid, line, newstate)
	local start = buffer:offset_from_line_column(lineid)
	local where = start + getlevel(line) * 2
	buffer:delete(where, 1)
	buffer:insert(where, newstate)
end
local function collapsefiles(buffer, lineid)
	local line = buffer.lines[lineid]
	local state = getstate(line)
	local start = buffer:offset_from_line_column(lineid + 1)
	if state == " " or state == "*" then return end
	local level = getlevel(line)
	for id = lineid + 1, #(buffer.lines) do
		local currline = buffer.lines[id]
		local currlevel = getlevel(currline)
		if currlevel <= level then
			local fin = buffer:offset_from_line_column(id)
			buffer:delete(start, fin - start)
			return
		end
	end
	buffer:delete(start, buffer.size - start)
end
local function findparentfolder(buffer, level, lineid)
	for id = lineid, 1, -1 do
		local line = getline(buffer, id)
		local currlevel = getlevel(line)
		if currlevel < level then
			return getfile(line):gsub("/+$", ""), currlevel, id
		end
	end
	return "", level, lineid
end
local function getineditorpath(buffer, level, lineid)
	local parentfolder = ""
	if level > 0 then
		local foldername, lastlevel, lastlineid = "", level, lineid
		while lastlevel > 0 do
			foldername, lastlevel, lastlineid = findparentfolder(buffer, lastlevel, lastlineid)
			if foldername == "" then break end
			if parentfolder == "" then parentfolder = foldername
			else parentfolder = foldername .. "/" .. parentfolder end
		end
	end
	if parentfolder == "" then return "" end
	return "/" .. parentfolder
end
local function make_root(window)
	local lineid = window.selection.line
	local buffer = window.file
	local line = getline(buffer, lineid)
	local file = getfile(line)
	local level = getlevel(line)
	local state = getstate(line)
	local parentfolder = getineditorpath(buffer, level, lineid)
	if state == "/" or state == "\t" then return end
	if line == "* ../" then
		module.path = parent(module.path)
		openfiles(buffer, module.path)
		return
	elseif state == " " then
		module.path = parent(module.path .. parentfolder .. "/" .. file)
		openfiles(buffer, module.path)
		return
	end
	if module.path == "/" then
		module.path = (parentfolder .. "/" .. file):gsub("/+$", "")
	else
		module.path = (module.path .. parentfolder .. "/" .. file):gsub("/+$", "")
	end
	openfiles(buffer, module.path)
end

local function interact(window)
	local lineid = window.selection.line
	local buffer = window.file
	local line = getline(buffer, lineid)
	local level = getlevel(line)
	local file = getfile(line)
	local state = getstate(line)
	local parentfolder = getineditorpath(buffer, level, lineid)

	if state == "/" or state == "\t" then return end
	if state == " " then
		-- open file
		module.lastwin.file = module.path .. parentfolder .. "/" .. file
		return
	elseif state == "+" then
		-- open folder
		local offset = buffer:offset_from_line_column(lineid + 1) or buffer.size - 1
		readfiles(buffer, module.path .. parentfolder .. "/" .. file:sub(1, #file - 1), level + 1, offset)
		setstate(buffer, lineid, line, "-")
		return
	elseif state == "-" then
		-- close folder
		collapsefiles(buffer, lineid)
		setstate(buffer, lineid, line, "+")
		return
	elseif state == "*" then
		if file == "../" then
			module.path = parent(module.path)
			openfiles(buffer, module.path)
			return
		end
	end
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
	window:map(vis.modes.NORMAL, " ", function()
		make_root(window)
		window:draw()
	end)
	window:map(vis.modes.NORMAL, "<Enter>", function()
		interact(window)
		window:draw()
	end)
end
local function getcwd()
	return lfs.currentdir()
end
local function opentree(path)
	if module.win == nil then
		module.lastwin = vis.win
		vis:command("vnew")
		module.win = vis.win
		module.file = module.win.file
		module.file.name = "TreeView"
		openfiles(module.file, path)
		module.win.syntax = nil
		maptree(module.win)
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
	vis:command_register('parent', function() if module.win ~= nil then
		module.path = parent(module.path)
		openfiles(module.file, module.path)
	end end, "Opens parent directory")
end

return module
