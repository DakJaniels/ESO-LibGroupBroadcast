local LGB = LibGroupBroadcast
local MessageBase = LGB.internal.class.MessageBase

local DataMessageBase = MessageBase:Subclass()
LGB.internal.class.DataMessageBase = DataMessageBase

function DataMessageBase:Initialize(id, data, idBits, dataBits, options)
    MessageBase.Initialize(self, id, data, idBits, dataBits)
    self.options = options or {}
    self.queueHistory = {}
end

function DataMessageBase:SetQueued(entryId)
    self.queueHistory[#self.queueHistory + 1] = {
        id = entryId,
        added = GetGameTimeMilliseconds(),
        status = "queued"
    }
end

function DataMessageBase:SetDequeued(reason)
    local entry = self.queueHistory[#self.queueHistory]
    if entry then
        entry.removed = GetGameTimeMilliseconds()
        entry.status = reason
    end
end

function DataMessageBase:GetLastAdded()
    local history = self.queueHistory[#self.queueHistory]
    if history then
        return history.added
    end
    return 0
end

function DataMessageBase:IsRelevantInCombat()
    return self.options.isRelevantInCombat == true
end

function DataMessageBase:ShouldDeleteQueuedMessages()
    return self.options.replaceQueuedMessages == true
end

function DataMessageBase:ShouldRequeue()
    return false
end

DataMessageBase:MUST_IMPLEMENT("GetSize")
