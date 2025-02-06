local LGB = LibGroupBroadcast

--- @class LibGroupBroadcastUIReload
local lib = {}

local handlerId = LGB:RegisterHandler("UIReload", "LibGroupBroadcastUIReload", lib)

local EVENT_NAME = "UIReload"
local SendEvent = LGB:DeclareCustomEvent(handlerId, 0, EVENT_NAME)
assert(SendEvent, "Failed to declare custom event for UI reload")

EVENT_MANAGER:RegisterForEvent("LibGroupBroadcastUIReload", EVENT_PLAYER_ACTIVATED, function(_, initial)
    if initial == false then
        SendEvent()
    end
    EVENT_MANAGER:UnregisterForEvent("LibGroupBroadcastUIReload", EVENT_PLAYER_ACTIVATED)
end)

--- Registers a callback for group member UI reloads.
--- @param callback fun(unitTag: string) The callback function that will be called when a group member's UI reloads.
--- @return boolean success True if the callback was successfully registered, false otherwise.
--- @see LibGroupBroadcastUIReload.UnregisterForUIReload
function lib:RegisterForUIReload(callback)
    return LGB:RegisterForCustomEvent(EVENT_NAME, callback)
end

--- Unregisters a callback for group member UI reloads.
--- @param callback fun(unitTag: string) The callback function to unregister. Has to be the same instance as the one registered.
--- @return boolean success True if the callback was successfully unregistered, false otherwise.
--- @see LibGroupBroadcastUIReload.RegisterForUIReload
function lib:UnregisterForUIReload(callback)
    return LGB:UnregisterForCustomEvent(EVENT_NAME, callback)
end
