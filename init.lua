-- Support the old multi-load method
intllib = intllib or {}

local MP = minetest.get_modpath("intllib")

dofile(MP.."/lib.lua")


local LANG = minetest.setting_get("language")
if not (LANG and (LANG ~= "")) then LANG = os.getenv("LANG") end
if not (LANG and (LANG ~= "")) then LANG = "en" end
LANG = LANG:sub(1, 2)

-- Support the old multi-load method
intllib.getters = intllib.getters or {}

intllib.strings = {}


local function noop_getter(s)
	return s
end


local INS_CHAR = intllib.INSERTION_CHAR
local insertion_pattern = "("..INS_CHAR.."?)"..INS_CHAR.."(%(?)(%d+)(%)?)"

local function make_getter(strs)
	return function(s, ...)
		local str = strs[s]
		if not str or str == "" then
			return s
		end
		if select("#", ...) == 0 then
			return str
		end
		local args = {...}
		local str = str:gsub(insertion_pattern, function(escape, open, num, close)
			if escape == "" then
				local replacement = tostring(args[tonumber(num)])
				if open == "" then
					replacement = replacement..close
				end
				return replacement
			else
				return INS_CHAR..open..num..close
			end
		end)
		return str
	end
end


function intllib.Getter(modname)
	modname = modname or minetest.get_current_modname()
	if not intllib.getters[modname] then
		local msgstr = intllib.get_strings(modname)
		if msgstr then
			intllib.getters[modname] = make_getter(msgstr)
		else
			intllib.getters[modname] = noop_getter
		end
	end
	return intllib.getters[modname]
end


function intllib.get_strings(modname)
	modname = modname or minetest.get_current_modname()
	local msgstr = intllib.strings[modname]
	if not msgstr then
		local modpath = minetest.get_modpath(modname)
		msgstr = intllib.load_strings(modpath.."/locale/"..LANG..".txt")
		intllib.strings[modname] = msgstr
	end
	return msgstr or nil
end

