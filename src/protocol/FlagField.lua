-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local logger = LGB.internal.logger

--[[ doc.lua begin ]]--

--- @docType options
--- @class FlagFieldOptions: FieldOptionsBase
--- @field defaultValue boolean? The default value for the field.

--- @docType hidden
--- @class FlagField: FieldBase
--- @field New fun(self: FlagField, label: string, options?: FlagFieldOptions): FlagField
local FlagField = FieldBase:Subclass()
LGB.internal.class.FlagField = FlagField

--- @protected
function FlagField:Initialize(label, options)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as FlagFieldOptions]]
    self:Assert(options.defaultValue == nil or type(options.defaultValue) == "boolean", "defaultValue must be a boolean")
end

--- @protected
function FlagField:GetNumBitsRangeInternal()
    return 1, 1
end

function FlagField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    if type(value) ~= "boolean" then
        logger:Warn("Value must be a boolean")
        return false
    end
    data:GrowIfNeeded(1)
    data:WriteBit(value)
    return true
end

function FlagField:Deserialize(data)
    return data:ReadBit(true)
end
