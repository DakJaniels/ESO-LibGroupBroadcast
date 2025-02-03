local MessageQueue = ZO_InitializingObject:Subclass()
LibGroupBroadcast.internal.class.MessageQueue = MessageQueue

function MessageQueue:Initialize()
    self.nextId = 1
    self.messages = {}
end

function MessageQueue:EnqueueMessage(message)
    if message:ShouldDeleteQueuedMessages() then
        self:DeleteMessagesByProtocolId(message:GetId())
    end

    message:SetQueued(self.nextId)
    self.messages[#self.messages + 1] = message
    self.nextId = self.nextId + 1
end

function MessageQueue:DequeueMessage(i)
    if not i then i = #self.messages end
    if not self.messages[i] then return end

    local message = table.remove(self.messages, i)
    message:SetDequeued("dequeued")
    return message
end

function MessageQueue:DeleteMessagesByProtocolId(protocolId)
    for i = #self.messages, 1, -1 do
        if self.messages[i]:GetId() == protocolId then
            local message = table.remove(self.messages, i)
            message:SetDequeued("deleted")
        end
    end
end

function MessageQueue:GetSize()
    return #self.messages
end

function MessageQueue:HasRelevantMessages(inCombat)
    if inCombat then
        for _, message in ipairs(self.messages) do
            if message:IsRelevantInCombat() then
                return true
            end
        end
        return false
    else
        return #self.messages > 0
    end
end

local function byTimeAddedDesc(a, b)
    return a:GetLastAdded() > b:GetLastAdded()
end

local function bySizeDescAndTimeAddedDesc(a, b)
    local aSize = a:GetSize()
    local bSize = b:GetSize()
    if aSize == bSize then
        return a:GetLastAdded() > b:GetLastAdded()
    end
    return aSize > bSize
end

function MessageQueue:GetOldestRelevantMessage(inCombat)
    if #self.messages == 0 then return end

    table.sort(self.messages, byTimeAddedDesc)

    if inCombat then
        for i = #self.messages, 1, -1 do
            if self.messages[i]:IsRelevantInCombat() then
                return self:DequeueMessage(i)
            end
        end
    end

    return self:DequeueMessage()
end

function MessageQueue:GetNextRelevantEntry(inCombat)
    if #self.messages == 0 then return end

    table.sort(self.messages, bySizeDescAndTimeAddedDesc)

    if inCombat then
        for i = #self.messages, 1, -1 do
            if self.messages[i]:IsRelevantInCombat() then
                return self:DequeueMessage(i)
            end
        end
    end

    return self:DequeueMessage()
end

function MessageQueue:GetNextRelevantEntryWithExactSize(size, inCombat)
    if #self.messages == 0 then return end

    table.sort(self.messages, bySizeDescAndTimeAddedDesc)

    if inCombat then
        for i = #self.messages, 1, -1 do
            local message = self.messages[i]
            if message:IsRelevantInCombat() and message:GetSize() == size then
                return self:DequeueMessage(i)
            end
        end
    end

    for i = #self.messages, 1, -1 do
        if self.messages[i]:GetSize() == size then
            return self:DequeueMessage(i)
        end
    end
end
