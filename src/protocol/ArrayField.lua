local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField

--- @class ArrayField: FieldBase
local ArrayField = FieldBase:Subclass()
LGB.internal.class.ArrayField = ArrayField

local DEFAULT_MAX_LENGTH = 2 ^ 8 - 1

function ArrayField:Initialize(valueField, options)
    FieldBase.Initialize(self, valueField.label, options)

    options = self.options
    local minLength = options.minLength or 0
    local maxLength = options.maxLength or DEFAULT_MAX_LENGTH

    self:Assert(type(minLength) and minLength >= 0, "minLength must be a number >= 0")
    self:Assert(type(maxLength) and maxLength > minLength, "maxLength must be a number > minLength")
    self:Assert(ZO_Object.IsInstanceOf(valueField, FieldBase), "valueField must be an instance of FieldBase")

    self.countField = NumericField:New("count", {
        minValue = minLength,
        maxValue = maxLength,
    })
    self.minLength = minLength
    self.maxLength = maxLength
    self.valueField = valueField
end

function ArrayField:GetWarnings()
    local output = {}
    local warnings = FieldBase.GetWarnings(self)
    local lengthWarnings = self.countField:GetWarnings()
    local valueWarnings = self.valueField:GetWarnings()
    ZO_CombineNumericallyIndexedTables(output, warnings, lengthWarnings, valueWarnings)
    return output
end

function ArrayField:IsValid()
    return FieldBase.IsValid(self) and self.countField:IsValid() and self.valueField:IsValid()
end

function ArrayField:GetNumBitsRange()
    local minCountBits, maxCountBits = self.countField:GetNumBitsRange()
    local minValueBits, maxValueBits = self.valueField:GetNumBitsRange()
    local minBits = minCountBits + self.minLength * minValueBits
    local maxBits = maxCountBits + self.maxLength * maxValueBits
    return minBits, maxBits
end

function ArrayField:Serialize(data, value)
    assert(type(value) == "table", "value must be a table")

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

function ArrayField:Deserialize(data)
    local count = self.countField:Deserialize(data)
    local value = {}
    for i = 1, count do
        value[i] = self.valueField:Deserialize(data)
    end
    return value
end
