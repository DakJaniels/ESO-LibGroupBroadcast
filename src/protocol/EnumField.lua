local LGB = LibGroupBroadcast
local NumericField = LGB.internal.class.NumericField

--- @class EnumField: NumericField
local EnumField = NumericField:Subclass()
LGB.internal.class.EnumField = EnumField

function EnumField:Initialize(label, valueTable, options)
    options = options or {}
    options.minValue = 1
    options.maxValue = #valueTable
    NumericField.Initialize(self, label, options)

    if not self:Assert(type(valueTable) == "table", "valueTable must be a table") then return end
    self.valueTable = valueTable
    self.valueLookup = {}
    for i = 1, #valueTable do
        self.valueLookup[valueTable[i]] = i
    end
end

function EnumField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    local index = self.valueLookup[value]
    if not index then return false end
    return NumericField.Serialize(self, data, index)
end

function EnumField:Deserialize(data)
    local index = NumericField.Deserialize(self, data)
    return self.valueTable[index]
end
