local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase

--- @class FlagField: FieldBase
local FlagField = FieldBase:Subclass()
LGB.internal.class.FlagField = FlagField


function FlagField:Initialize(label, options)
    FieldBase.Initialize(self, label, options)

    options = self.options
    self:Assert(options.defaultValue == nil or type(options.defaultValue) == "boolean",
        "defaultValue must be a boolean or nil")
end

function FlagField:GetNumBitsRange()
    return 1, 1
end

function FlagField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    assert(type(value) == "boolean", "Value must be a boolean")
    data:GrowIfNeeded(1)
    data:WriteBit(value)
    return true
end

function FlagField:Deserialize(data)
    return data:ReadBit(true)
end
