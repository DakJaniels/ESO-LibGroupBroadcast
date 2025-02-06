-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local FlagField = LGB.internal.class.FlagField

--- @class OptionalField: FieldBase
--- @field New fun(self: OptionalField, valueField: FieldBase): OptionalField
local OptionalField = FieldBase:Subclass()
LGB.internal.class.OptionalField = OptionalField

function OptionalField:Initialize(valueField)
    FieldBase.Initialize(self, valueField.label)

    self.isNilField = self:RegisterSubField(FlagField:New("IsNil"))
    self.valueField = self:RegisterSubField(valueField)
    self:Assert(ZO_Object.IsInstanceOf(valueField, FieldBase), "'valueField' must be an instance of FieldBase")
end

--- @protected
function OptionalField:GetNumBitsRangeInternal()
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
