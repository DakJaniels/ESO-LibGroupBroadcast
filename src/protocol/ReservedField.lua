local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase

--- @class ReservedField: FieldBase
local ReservedField = FieldBase:Subclass()
LGB.internal.class.ReservedField = ReservedField

function ReservedField:Initialize(label, numBits)
    FieldBase.Initialize(self, label, { numBits = numBits })
    self:Assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
end

function ReservedField:GetNumBitsRange()
    local numBits = self.options.numBits
    return numBits, numBits
end

function ReservedField:Serialize(data, _)
    local numBits = self.options.numBits
    data:GrowIfNeeded(numBits)
    data:Seek(numBits)
    return true
end

function ReservedField:Deserialize(data)
    local numBits = self.options.numBits
    data:Seek(numBits)
    return nil
end
