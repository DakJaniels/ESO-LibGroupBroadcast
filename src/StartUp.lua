local authKey, addonName = RegisterForGroupAddOnDataBroadcastAuthKey("LibGroupBroadcast")
if not authKey then
    error("Data broadcast auth key has already been claimed by " .. addonName)
end

LibGroupBroadcast = {
    internal = {
        logger = LibDebugLogger:Create("LibGroupBroadcast"),
        callbackManager = ZO_CallbackObject:New(),
        class = {},
        handlers = {},
        authKey = authKey,
    },
}
local internal = LibGroupBroadcast.internal

function internal:RegisterHandler(handlerName)
    local handler = self.handlers[handlerName]
    if handler then
        internal.logger:Warn("Handler '%s' has already been registered.", handlerName)
        return nil
    end

    handler = {}
    self.handlers[handlerName] = handler
    return handler
end

function internal:GetHandler(handlerName)
    return self.handlers[handlerName]
end

local function SetupInstance(instance)
    instance.dataMessageQueue = internal.class.MessageQueue:New()
    instance.protocolManager = internal.class.ProtocolManager:New(instance.callbackManager, instance.dataMessageQueue)
    instance.broadcastManager = internal.class.BroadcastManager:New(instance.gameApiWrapper, instance.protocolManager,
        instance.callbackManager, instance.dataMessageQueue)
end

function internal.SetupMockInstance()
    local callbackManager = ZO_CallbackObject:New()
    local instance = setmetatable({
        callbackManager = callbackManager,
        gameApiWrapper = internal.class.MockGameApiWrapper:New(callbackManager),
    }, { __index = LibGroupBroadcast })
    SetupInstance(instance)

    function instance:DeclareCustomEvent(eventId, eventName)
        return instance.protocolManager:DeclareCustomEvent(eventId, eventName)
    end

    function instance:RegisterForCustomEvent(eventName, callback)
        return instance.protocolManager:RegisterForCustomEvent(eventName, callback)
    end

    function instance:UnregisterForCustomEvent(eventName, callback)
        return instance.protocolManager:UnregisterForCustomEvent(eventName, callback)
    end

    function instance:DeclareProtocol(protocolId, protocolName)
        return instance.protocolManager:DeclareProtocol(protocolId, protocolName)
    end

    return instance
end

local function InitializeUIReloadHandler()
    local SendEvent = LibGroupSocket:DeclareCustomEvent(0, "UIReload")
    -- LGB:RegisterForCustomEvent("UIReload", function(unitTag) end)
    if not SendEvent then return end

    EVENT_MANAGER:RegisterForEvent("LGBUIReloadHandler", EVENT_PLAYER_ACTIVATED, function(_, initial)
        if initial == false then
            SendEvent()
        end
        EVENT_MANAGER:UnregisterForEvent("LGBUIReloadHandler", EVENT_PLAYER_ACTIVATED)
    end)
end

function LibGroupBroadcast:Initialize()
    internal.gameApiWrapper = internal.class.GameApiWrapper:New(authKey, "LibGroupBroadcast", internal.callbackManager)
    SetupInstance(internal)
    internal.authKey = nil
    InitializeUIReloadHandler()
    self.internal = nil
    self.Initialize = nil
end
