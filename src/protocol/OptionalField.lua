local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local FlagField = LGB.internal.class.FlagField

--- @class OptionalField: FieldBase
local OptionalField = FieldBase:Subclass()
LGB.internal.class.OptionalField = OptionalField

function OptionalField:Initialize(field)
    FieldBase.Initialize(self, field.label)

    self.isNilField = FlagField:New("IsNil")
    self.valueField = field
    self:Assert(ZO_Object.IsInstanceOf(field, FieldBase), "'field' must be an instance of FieldBase")
end

function OptionalField:GetWarnings()
    local output = {}
    local warnings = FieldBase.GetWarnings(self)
    local isNilWarnings = self.isNilField:GetWarnings()
    local valueWarnings = self.valueField:GetWarnings()
    ZO_CombineNumericallyIndexedTables(output, warnings, isNilWarnings, valueWarnings)
    return output
end

function OptionalField:IsValid()
    return FieldBase.IsValid(self) and self.isNilField:IsValid() and self.valueField:IsValid()
end

function OptionalField:GetNumBitsRange()
    local minFlagBits, maxFlagBits = self.isNilField:GetNumBitsRange()
    local _, maxValueBits = self.valueField:GetNumBitsRange()
    return minFlagBits, maxFlagBits + maxValueBits
end

function OptionalField:Serialize(data, value)
    if value == nil then
        if not self.isNilField:Serialize(data, true) then return false end
    else
        if not self.isNilField:Serialize(data, false) then return false end
        if not self.valueField:Serialize(data, value) then return false end
    end
    return true
end

function OptionalField:Deserialize(data)
    if self.isNilField:Deserialize(data) then
        return self.valueField:GetValueOrDefault()
    end

    return self.valueField:Deserialize(data)
end
