local address, slot, maxwidth, maxheight, maxtier = ...

local lua_utf8 = require("utf8")

local bindaddress
local depthTbl = {1,4,8}
local rdepthTbl = {1,nil,nil,2,nil,nil,nil,3}

-- gpu component
local obj = {}

function obj.bind(address) -- Binds the GPU to the screen with the specified address.
	cprint("gpu.bind", address)
	compCheckArg(1,address,"string")
	local thing = component.exists(address)
	if thing == nil then
		return nil, "invalid address"
	elseif thing ~= "screen" then
		return nil, "not a screen"
	end
	bindaddress = address
end
function obj.getForeground() -- Get the current foreground color and whether it's from the palette or not.
	cprint("gpu.getForeground")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "getForeground")
end
function obj.setForeground(value, palette) -- Sets the foreground color to the specified value. Optionally takes an explicit palette index. Returns the old value and if it was from the palette its palette index.
	cprint("gpu.setForeground", value, palette)
	compCheckArg(1,value,"number")
	compCheckArg(2,palette,"boolean","nil")
	if bindaddress == nil then
		return nil, "no screen"
	end
	if palette and component.cecinvoke(bindaddress, "getDepth") == 1 then
		error("color palette not suppported",3)
	end
	if palette == true and (value < 0 or value > 15) then
		error("invalid palette index",3)
	end
	return component.cecinvoke(bindaddress, "setForeground", value, palette)
end
function obj.getBackground() -- Get the current background color and whether it's from the palette or not.
	cprint("gpu.getBackground")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "getBackground")
end
function obj.setBackground(value, palette) -- Sets the background color to the specified value. Optionally takes an explicit palette index. Returns the old value and if it was from the palette its palette index.
	cprint("gpu.setBackground", value, palette)
	compCheckArg(1,value,"number")
	compCheckArg(2,palette,"boolean","nil")
	if bindaddress == nil then
		return nil, "no screen"
	end
	if palette and component.cecinvoke(bindaddress, "getDepth") == 1 then
		error("color palette not suppported",3)
	end
	value = math.floor(value)
	if palette and (value < 0 or value > 15) then
		error("invalid palette index",3)
	end
	return component.cecinvoke(bindaddress, "setBackground", value, palette)
end
function obj.getDepth() -- Returns the currently set color depth.
	cprint("gpu.getDepth")
	return depthTbl[component.cecinvoke(bindaddress, "getDepth")]
end
function obj.setDepth(depth) -- Set the color depth. Returns the previous value.
	cprint("gpu.setDepth", depth)
	compCheckArg(1,depth,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	local scrmax = component.cecinvoke(bindaddress, "maxDepth")
	if rdepthTbl[depth] == nil or rdepthTbl[depth] > math.max(scrmax, maxtier) then
		error("unsupported depth",3)
	end
	return component.cecinvoke(bindaddress, "setDepth", rdepthTbl[depth])
end
function obj.maxDepth() -- Get the maximum supported color depth.
	cprint("gpu.maxDepth")
	return depthTbl[math.min(component.cecinvoke(bindaddress, "maxDepth"), maxtier)]
end
function obj.fill(x, y, width, height, char) -- Fills a portion of the screen at the specified position with the specified size with the specified character.
	cprint("gpu.fill", x, y, width, height, char)
	compCheckArg(1,x,"number")
	compCheckArg(2,y,"number")
	compCheckArg(3,width,"number")
	compCheckArg(4,height,"number")
	compCheckArg(5,char,"string")
	if bindaddress == nil then
		return nil, "no screen"
	end
	if lua_utf8.len(char) ~= 1 then
		return nil, "invalid fill value"
	end
	return component.cecinvoke(bindaddress, "fill", x, y, width, height, char)
end
function obj.getScreen() -- Get the address of the screen the GPU is currently bound to.
	cprint("gpu.getScreen")
	return bindaddress
end
function obj.getResolution() -- Get the current screen resolution.
	cprint("gpu.getResolution")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "getResolution")
end
function obj.setResolution(width, height) -- Set the screen resolution. Returns true if the resolution changed.
	cprint("gpu.setResolution", width, height)
	compCheckArg(1,width,"number")
	compCheckArg(2,height,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "setResolution", width, height)
end
function obj.maxResolution() -- Get the maximum screen resolution.
	cprint("gpu.maxResolution")
	if bindaddress == nil then
		return nil, "no screen"
	end
	local smw,smh = component.cecinvoke(bindaddress, "maxResolution")
	return math.min(smw, maxwidth), math.min(smh, maxheight)
end
function obj.getPaletteColor(index) -- Get the palette color at the specified palette index.
	cprint("gpu.getPaletteColor", index)
	compCheckArg(1,index,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	if component.cecinvoke(bindaddress, "getDepth") == 1 then
		return "palette not available"
	end
	index = math.floor(index)
	if index < 0 or index > 15 then
		error("invalid palette index",3)
	end
	return component.cecinvoke(bindaddress, "getPaletteColor", index)
end
function obj.setPaletteColor(index, color) -- Set the palette color at the specified palette index. Returns the previous value.
	cprint("gpu.setPaletteColor", index, color)
	compCheckArg(1,index,"number")
	compCheckArg(2,color,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	if component.cecinvoke(bindaddress, "getDepth") == 1 then
		return "palette not available"
	end
	index = math.floor(index)
	if index < 0 or index > 15 then
		error("invalid palette index",3)
	end
	return component.cecinvoke(bindaddress, "setPaletteColor", index, color)
end
function obj.get(x, y) -- Get the value displayed on the screen at the specified index, as well as the foreground and background color. If the foreground or background is from the palette, returns the palette indices as fourth and fifth results, else nil, respectively.
	cprint("gpu.get", x, y)
	compCheckArg(1,x,"number")
	compCheckArg(2,y,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	local w,h = component.cecinvoke(bindaddress, "getResolution")
	if x < 1 or x > w or y < 1 or y > h then
		error("index out of bounds",3)
	end
	return component.cecinvoke(bindaddress, "get", x, y)
end
function obj.set(x, y, value, vertical) -- Plots a string value to the screen at the specified position. Optionally writes the string vertically.
	cprint("gpu.set", x, y, value, vertical)
	compCheckArg(1,x,"number")
	compCheckArg(2,y,"number")
	compCheckArg(3,value,"string")
	compCheckArg(4,vertical,"boolean","nil")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "set", x, y, value, vertical)
end
function obj.copy(x, y, width, height, tx, ty) -- Copies a portion of the screen from the specified location with the specified size by the specified translation.
	cprint("gpu.copy", x, y, width, height, tx, ty)
	compCheckArg(1,x,"number")
	compCheckArg(2,y,"number")
	compCheckArg(3,width,"number")
	compCheckArg(4,height,"number")
	compCheckArg(5,tx,"number")
	compCheckArg(6,ty,"number")
	if bindaddress == nil then
		return nil, "no screen"
	end
	return component.cecinvoke(bindaddress, "copy", x, y, width, height, tx, ty)
end

local cec = {}

return obj,cec
