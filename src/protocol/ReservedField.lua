-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase

local AVAILABLE_OPTIONS = {
    numBits = true,
}

--[[ doc.lua begin ]]--

--- @docType hidden
--- @class ReservedField: FieldBase
--- @field New fun(self: ReservedField, label: string, numBits: number): ReservedField
local ReservedField = FieldBase:Subclass()
LGB.internal.class.ReservedField = ReservedField

--- @protected
function ReservedField:Initialize(label, numBits)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, { numBits = numBits })
    self:Assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
end

--- @protected
function ReservedField:GetNumBitsRangeInternal()
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
