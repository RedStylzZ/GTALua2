-- Loads the native descriptions from natives.h

natives = {}
nativeDescription = {}

local nativesH = LuaFolder().."/API/natives.h"
local namespaces = 0
local nativecount = 0
local namespace = ""

if file_exists(nativesH) then
	print("Loading native methods from natives.h ...")
	file = io.open(nativesH, "r")
	for line in file:lines() do
		line = trim(line)
		if string.sub(line, 1, 9) == "namespace" then
			local array = explode(" ", line)
			namespace = array[2]
			namespaces = namespaces + 1
			nativeDescription[namespace] = {}
			natives[namespace] = {}
		end
		if string.sub(line, 1, 6) == "static" then
			local array = explode(" ", line)
			local returns = array[2]
			local array2 = explode("(", array[3])
			local native = array2[1]
			local array3 = explode("(", line)
			local array4 = explode(")", array3[3])
			local array5 = explode(",", array4[1])
			local hash = array5[1]
			local array6 = explode(")", array3[2])
			local takes = array6[1]
			local nargs = 0
			if takes ~= "" then
				array9 = {}
				local array7 = explode(",", takes)
				local k, v
				for k, v in pairs(array7) do
					v = trim(v)
					array8 = explode(" ", v)
					array9[k] = array8[1]
					nargs = nargs + 1
				end
				takes = trim(table.concat(array9,","))
			end
			nativecount = nativecount + 1
			nativeDescription[namespace][native] = {["hash"]=hash, ["nargs"]=nargs, ["takes"]=takes, ["returns"]=returns}
			x = load("natives."..namespace.."."..native.." = function(...) return CallNative(\""..namespace.."\", \""..native.."\", ...) end")
			x()
		end
	end
--	print_r(natives)
	file:close()
	print("Detected "..namespaces.." namespaces.")
	print("Loaded "..nativecount.." natives.")
else
	error("File natives.h not found. Cannot continue.")
end
