-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField
local logger = LGB.internal.logger

--- @class ArrayFieldOptions : FieldOptionsBase
--- @field minLength number? The minimum length of the array.
--- @field maxLength number? The maximum length of the array.
--- @field defaultValue table? The default value for the field.

--- @class ArrayField: FieldBase
--- @field New fun(self:ArrayField, valueField: FieldBase, options?: ArrayFieldOptions): ArrayField
local ArrayField = FieldBase:Subclass()
LGB.internal.class.ArrayField = ArrayField

local DEFAULT_MAX_LENGTH = 2 ^ 8 - 1
local AVAILABLE_OPTIONS = {
    minLength = true,
    maxLength = true,
}

--- @protected
function ArrayField:Initialize(valueField, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, valueField.label, options)
    options = self.options
    local minLength = options.minLength or 0
    local maxLength = options.maxLength or DEFAULT_MAX_LENGTH

    self:Assert(type(minLength) and minLength >= 0, "minLength must be a number >= 0")
    self:Assert(type(maxLength) and maxLength > minLength, "maxLength must be a number > minLength")
    self:Assert(ZO_Object.IsInstanceOf(valueField, FieldBase), "valueField must be an instance of FieldBase")

    self.countField = self:RegisterSubField(NumericField:New("count", {
        minValue = minLength,
        maxValue = maxLength,
    }))
    self.minLength = minLength
    self.maxLength = maxLength
    self.valueField = self:RegisterSubField(valueField)

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

--- @protected
function ArrayField:GetNumBitsRangeInternal()
    local minCountBits, maxCountBits = self.countField:GetNumBitsRange()
    local minValueBits, maxValueBits = self.valueField:GetNumBitsRange()
    local minBits = minCountBits + self.minLength * minValueBits
    local maxBits = maxCountBits + self.maxLength * maxValueBits
    return minBits, maxBits
end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? table The value to serialize.
function ArrayField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    if type(value) ~= "table" then
        logger:Warn("value must be a table")
        return false
    end

    if #value < self.minLength or #value > self.maxLength then
        logger:Warn("length must be between " .. self.minLength .. " and " .. self.maxLength)
        return false
    end

    local count = #value
    if not self.countField:Serialize(data, count) then
        return false
    end

    for i = 1, count do
        if not self.valueField:Serialize(data, value[i]) then
            return false
        end
    end
    return true
end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return table value The deserialized value.
function ArrayField:Deserialize(data)
    local count = self.countField:Deserialize(data)
    local value = {}
    for i = 1, count do
        value[i] = self.valueField:Deserialize(data)
    end
    return value
end
