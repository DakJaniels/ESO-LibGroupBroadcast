-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast

--[[ doc.lua begin ]] --

--- @class Handler
--- @field private proxy table
--- @field protected New fun(self: Handler, proxy: table): Handler
local Handler = ZO_InitializingObject:Subclass()
LGB.internal.class.Handler = Handler

--- @protected
function Handler:Initialize(proxy)
    self.proxy = proxy
end

--- Sets the API object for the handlerw which is returned by LibGroupSocket's GetHandler function.
--- @param api table The API object to set.
--- @see LibGroupSocket.GetHandler
function Handler:SetApi(api)
    self.proxy:SetApi(api)
end

--- Sets a display name for the handler for use in various places.
--- @param displayName string The display name to set.
function Handler:SetDisplayName(displayName)
    self.proxy:SetDisplayName(displayName)
end

--- Sets a description for the handler for use in various places.
--- @param description string The description to set.
function Handler:SetDescription(description)
    self.proxy:SetDescription(description)
end

--- Declares a custom event that can be used to send messages without data to other group members with minimal overhead or throws an error if the declaration failed.
--- 
--- Each event id and event name has to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param eventId number The custom event ID to use.
--- @param eventName string The custom event name to use.
--- @return function FireEvent A function that can be called to request sending this custom event to other group members.
function Handler:DeclareCustomEvent(eventId, eventName)
    return self.proxy:DeclareCustomEvent(eventId, eventName)
end

--- Declares a new protocol with the given ID and name and returns the Protocol object instance or throws an error if the declaration failed.
---
--- The protocol id and name have to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param protocolId number The ID of the protocol to declare.
--- @param protocolName string The name of the protocol to declare.
--- @return Protocol protocol The Protocol object instance that was declared.
--- @see Protocol
function Handler:DeclareProtocol(protocolId, protocolName)
    return self.proxy:DeclareProtocol(protocolId, protocolName)
end
