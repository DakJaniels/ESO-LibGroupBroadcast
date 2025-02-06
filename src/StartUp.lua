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

local function SetupInstance(instance)
    instance.dataMessageQueue = internal.class.MessageQueue:New()
    instance.handlerManager = internal.class.HandlerManager:New()
    instance.protocolManager = internal.class.ProtocolManager:New(instance.callbackManager, instance.dataMessageQueue,
        instance.handlerManager)
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

    function instance:RegisterHandler(...)
        return instance.handlerManager:RegisterHandler(...)
    end

    function instance:GetHandler(...)
        return instance.handlerManager:GetHandlerApi(...)
    end

    function instance:DeclareCustomEvent(...)
        return instance.protocolManager:DeclareCustomEvent(...)
    end

    function instance:RegisterForCustomEvent(...)
        return instance.protocolManager:RegisterForCustomEvent(...)
    end

    function instance:UnregisterForCustomEvent(...)
        return instance.protocolManager:UnregisterForCustomEvent(...)
    end

    function instance:DeclareProtocol(...)
        return instance.protocolManager:DeclareProtocol(...)
    end

    return instance
end

function LibGroupBroadcast:Initialize()
    internal.gameApiWrapper = internal.class.GameApiWrapper:New(authKey, "LibGroupBroadcast", internal.callbackManager)
    SetupInstance(internal)
    internal.authKey = nil
    self.internal = nil
    self.Initialize = nil
end
