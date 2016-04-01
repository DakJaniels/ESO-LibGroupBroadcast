local LuaUnit = require('luaunit')
local lu = LuaUnit.LuaUnit

local function getAddonName()
	local name
	for line in io.lines(".project") do
		name = line:match("^\t<name>(.+)</name>")
		if(name) then
			return name
		end
	end
	print("Could not find addon name.")
	return nil
end

local function importAddonFiles()
	for line in io.lines("src/" .. getAddonName() .. ".txt") do
		if(not line:find("^%s*##") and line:find("\.lua")) then
			require(line:match("^%s*(.+)\.lua"))
		end
	end
end

local function mockGlobals()
	zo_strsplit = function(...)
		return unpack(LuaUnit.private.strsplit(...))
	end
	local eventCallback
	EVENT_MANAGER = {
		RegisterForEvent = function(name, eventId, callback) eventCallback = callback end,
		UnregisterForEvent = function(name, eventId, callback) end
	}
	df = function(format, ...)
		print(string.format(format, ...))
	end
	d = print
	SetMapToMapListIndex = function() end
	GetCurrentMapIndex = function() return 27 end

	PING_EVENT_ADDED = 1
	MAP_PIN_TYPE_PLAYER_WAYPOINT = 85
	MAP_PIN_TYPE_PING = 86
	MAP_PIN_TYPE_RALLY_POINT = 87
	local pingX, pingY = 0, 0
	function PingMap(pingType, pingMapType, x, y)
		if(eventCallback) then
			pingX, pingY = x, y
			eventCallback(0, PING_EVENT_ADDED, MAP_PIN_TYPE_PING, "player", x, y, true)
		end
	end

	function GetMapPing(tag)
		return pingX, pingY
	end

	ZO_CallbackObject = {
		New = function()
			return {
				RegisterCallback = function() end
			}
		end
	}
	ZO_WorldMapPins = {}
	ZO_WorldMap_RefreshCustomPinsOfType = function() end
	GetAPIVersion = function() return 100014 end
	GetZoneIndex = function() end
	SLASH_COMMANDS = {}
	ZO_WorldMap_AddCustomPin = function() end
	ZO_WorldMap_SetCustomPinEnabled = function() end
	DoesUnitExist = function() end
	GetDisplayName = function() return "name" end
	ZO_DeepTableCopy = function() return {} end
	LibGroupSockets_Data = {
		name = {
			version = 1,
			enabled = false,
			autoDisableOnGroupLeft = true,
			autoDisableOnSessionStart = true,
			handlers = {},
		}
	}
	ZO_Object = {
		New = function() return {} end,
		Subclass = function() return {} end
	}
end

mockGlobals()
importAddonFiles()

require('LibGroupSocketTest')

---- Control test output:
-- lu:setOutputType( "NIL" )
-- lu:setOutputType( "TAP" )
-- lu:setVerbosity( LuaUnit.VERBOSITY_LOW )
os.exit( lu:run() )
