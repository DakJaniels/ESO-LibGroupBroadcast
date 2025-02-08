-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local logger = LGB.internal.logger

--[[ doc.lua begin ]]--

--- @class HandlerManager
--- @field New fun(self: HandlerManager): HandlerManager
local HandlerManager = ZO_InitializingObject:Subclass()
LGB.internal.class.HandlerManager = HandlerManager

function HandlerManager:Initialize()
    self.handlers = {}
    self.handlerByName = {}
    self.handlerById = {}
end

function HandlerManager:RegisterHandler(handlerName, addonName, handlerApi)
    assert(type(handlerName) == "string", "handlerName must be a string.")
    assert(type(addonName) == "string", "addonName must be a string.")
    assert(handlerApi == nil or type(handlerApi) == "table", "handlerApi must be a table or nil.")

    local handler = self.handlerByName[handlerName]
    if handler then
        logger:Warn("Handler '%s' has already been registered by '%s'.", handlerName, handler.addonName)
        return nil
    end

    local handlerId = self:GenerateId()
    handler = {
        handlerId = handlerId,
        handlerName = handlerName,
        addonName = addonName,
        api = handlerApi,
        customEvents = {},
        protocols = {},
    }
    self.handlers[#self.handlers + 1] = handler
    self.handlerByName[handlerName] = handler
    self.handlerById[handlerId] = handler
    return handlerId
end

function HandlerManager:GetHandlerApi(handlerName)
    local handler = self.handlerByName[handlerName]
    if handler then
        return handler.api
    end
end

function HandlerManager:GetHandler(handlerId)
    return self.handlerById[handlerId]
end

function HandlerManager:GenerateId()
    assert(#self.handlerById < 1000000, "Too many handlers registered")
    local id
    repeat
        id = math.random(1, 1000000)
    until not self.handlerById[id]
    return id
end
