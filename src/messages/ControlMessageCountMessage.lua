local LGB = LibGroupBroadcast
local ControlMessageBase = LGB.internal.class.ControlMessageBase

local ControlMessageCountMessage = ControlMessageBase:Subclass()
LGB.internal.class.ControlMessageCountMessage = ControlMessageCountMessage

function ControlMessageCountMessage:Initialize(data)
    ControlMessageBase.Initialize(self, 0, data)
end

function ControlMessageCountMessage:SetCount(count)
    self.data:Rewind()
    self.data:WriteUInt(count, 4)
end

function ControlMessageCountMessage:GetCount()
    self.data:Rewind()
    return self.data:ReadUInt(4)
end

function ControlMessageCountMessage.CastFrom(message)
    return setmetatable(message, ControlMessageCountMessage)
end
