-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FrameHandler = LGB.internal.class.FrameHandler
local logger = LGB.internal.logger

--- @class BroadcastManager
--- @field New fun(self: BroadcastManager, gameApiWrapper: GameApiWrapper, protocolManager: ProtocolManager, callbackManager: ZO_CallbackObject, dataMessageQueue: MessageQueue): BroadcastManager
local BroadcastManager = ZO_InitializingObject:Subclass()
LGB.internal.class.BroadcastManager = BroadcastManager

local CURRENT_VERSION = 1

function BroadcastManager:Initialize(gameApiWrapper, protocolManager, callbackManager, dataMessageQueue)
    self.gameApiWrapper = gameApiWrapper
    self.protocolManager = protocolManager
    self.callbackManager = callbackManager
    self.dataMessageQueue = dataMessageQueue
    self.frameHandler = {
        [1] = FrameHandler:New(),
    }

    callbackManager:RegisterCallback("RequestSendData", function()
        self:RequestSendData()
    end)

    callbackManager:RegisterCallback("OnDataReceived", function(unitTag, data)
        self:OnDataReceived(unitTag, data)
    end)
end

function BroadcastManager:RequestSendData()
    if self.sendHandle then return end

    local inCombat = self:IsInCombat()
    local hasCombatRelevantMessages = self.protocolManager:HasRelevantMessages(true)
    if inCombat and not hasCombatRelevantMessages then return end

    local delay = self.gameApiWrapper:GetCooldown()
    if delay == 0 then
        delay = self.gameApiWrapper:GetInitialSendDelay()
    end

    self.sendHandle = zo_callLater(function()
        self:SendData()
    end, delay)
end

local function AddMessage(message, frameHandler, toRequeue)
    if not message then return false end
    if frameHandler:AddDataMessage(message) then
        if message:ShouldRequeue() then
            toRequeue[#toRequeue + 1] = message
        end
    else
        logger:Warn("Failed to add message to frame")
    end
    return true
end

function BroadcastManager:FillSendBuffer(inCombat)
    local frameHandler = self.frameHandler[CURRENT_VERSION]

    local eventMessages = self.protocolManager:GenerateCustomEventMessages()
    for _, message in ipairs(eventMessages) do
        if not frameHandler:AddControlMessage(message) then
            break
        end
    end

    local toRequeue = {}
    local queue = self.dataMessageQueue
    local message = queue:GetOldestRelevantMessage(inCombat)
    AddMessage(message, frameHandler, toRequeue)

    while frameHandler:GetBytesFree() > 3 do
        message = queue:GetNextRelevantEntry(inCombat)
        if not AddMessage(message, frameHandler, toRequeue) then break end
    end

    local bytesFree = frameHandler:GetBytesFree()
    if bytesFree > 1 and bytesFree <= 3 then
        message = queue:GetNextRelevantEntryWithExactSize(3, inCombat)
        if not message then
            message = queue:GetNextRelevantEntry(inCombat)
        end
        AddMessage(message, frameHandler, toRequeue)
    end

    for i = 1, #toRequeue do
        queue:EnqueueMessage(toRequeue[i])
    end

    return frameHandler
end

function BroadcastManager:IsInCombat()
    return self.gameApiWrapper:IsInCombat()
end

function BroadcastManager:SendData()
    self.sendHandle = nil

    local inCombat = self:IsInCombat()
    local frameHandler = self:FillSendBuffer(inCombat)
    if frameHandler:HasData() then
        local data = frameHandler:Serialize()
        local result = self.gameApiWrapper:BroadcastData(data)
        if result == GROUP_ADD_ON_DATA_BROADCAST_RESULT_SUCCESS then
            frameHandler:Reset()
        else
            -- TODO handle failures
            logger:Warn("Broadcast failed with result %d", result)
        end
    end

    if self.protocolManager:HasRelevantMessages(inCombat) then
        self:RequestSendData()
    end
end

function BroadcastManager:OnDataReceived(unitTag, data)
    local version = data:ReadUInt(3)

    local frameHandler = self.frameHandler[version]
    if not frameHandler then
        logger:Warn("Received data with unsupported version %d from %s", version, unitTag)
        return
    end

    local controlMessages, dataMessages = frameHandler:Deserialize(data)
    controlMessages = self.protocolManager:HandleCustomEventMessages(unitTag, controlMessages)
    if #controlMessages > 0 then
        local unknownIds = {}
        for _, message in ipairs(controlMessages) do
            unknownIds[#unknownIds + 1] = message:GetId()
        end
        logger:Debug("Received %d control messages with unknown IDs (%s) from %s", #controlMessages,
            table.concat(unknownIds, ", "), unitTag)
    end

    self.protocolManager:HandleDataMessages(unitTag, dataMessages)
end
