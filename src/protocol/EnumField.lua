-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField
local logger = LGB.internal.logger

local AVAILABLE_OPTIONS = {
    numBits = true,
}

--[[ doc.lua begin ]]--

--- @docType options
--- @class EnumFieldOptions: FieldOptionsBase
--- @field maxValue number? The max value of the field. Defaults to the length of the valueTable. Can be used to reserve space for future values.
--- @field numBits number? The number of bits to use for the field. Can be used to reserve a specific number of bits for future values.

--- @docType hidden
--- @class EnumField: FieldBase
--- @field protected indexField NumericField
--- @field protected valueTable any[]
--- @field protected valueLookup table
--- @field New fun(self: EnumField, label: string, valueTable: any[], options?: EnumFieldOptions): EnumField
local EnumField = FieldBase:Subclass()
LGB.internal.class.EnumField = EnumField

--- @protected
function EnumField:Initialize(label, valueTable, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, options)
    options = self.options
    if not self:Assert(type(valueTable) == "table", "The valueTable must be a table") then return end
    self.indexField = self:RegisterSubField(NumericField:New("index", {
        numBits = options.numBits,
        minValue = 1,
        maxValue = math.max(#valueTable, options.maxValue or 0),
    }))

    self.valueTable = valueTable
    self.valueLookup = {}
    for i = 1, #valueTable do
        self.valueLookup[valueTable[i]] = i
    end

    if options.defaultValue then
        self:Assert(self.valueLookup[options.defaultValue] ~= nil, "The defaultValue has to be part of the valueTable")
    end
end

--- @protected
function EnumField:GetNumBitsRangeInternal()
    return self.indexField:GetNumBitsRange()
end

function EnumField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    local index = self.valueLookup[value]
    if not index then
        logger:Warn("The value is not in the valueTable")
        return false
    end
    return self.indexField:Serialize(data, index)
end

function EnumField:Deserialize(data)
    local index = self.indexField:Deserialize(data)
    return self.valueTable[index]
end
