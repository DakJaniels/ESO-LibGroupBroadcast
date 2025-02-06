-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local logger = LGB.internal.logger

--- @class TableFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.

--- @class TableField: FieldBase
--- @field New fun(self: TableField, label: string, valueFields: FieldBase[], options?: TableFieldOptions): TableField
local TableField = FieldBase:Subclass()
LGB.internal.class.TableField = TableField

function TableField:Initialize(label, valueFields, options)
    FieldBase.Initialize(self, label, options)
    options = self.options

    if self:Assert(type(valueFields) == "table", "'fields' must be a table") then
        for i = 1, #valueFields do
            if not self:Assert(ZO_Object.IsInstanceOf(valueFields[i], FieldBase), "All valueFields must be instances of FieldBase") then break end
            self:RegisterSubField(valueFields[i])
        end
    else
        valueFields = {}
    end
    self.fields = valueFields

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

--- @protected
function TableField:GetNumBitsRangeInternal()
    local minBits, maxBits = 0, 0
    for i = 1, #self.fields do
        local minFieldBits, maxFieldBits = self.fields[i]:GetNumBitsRange()
        minBits = minBits + minFieldBits
        maxBits = maxBits + maxFieldBits
    end
    return minBits, maxBits
end

function TableField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    if type(value) ~= "table" then
        logger:Warn("value must be a table")
        return false
    end

    for i = 1, #self.fields do
        local field = self.fields[i]
        if not field:Serialize(data, value[field.label]) then return false end
    end
    return true
end

function TableField:Deserialize(data)
    local value = {}

    for i = 1, #self.fields do
        local field = self.fields[i]
        value[field.label] = field:Deserialize(data)
    end

    return value
end
