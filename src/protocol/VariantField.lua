-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local EnumField = LGB.internal.class.EnumField
local logger = LGB.internal.logger

--- @class VariantFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.
--- @field maxNumVariants number? The maximum number of variants that can be used. Can be used to reserve space for future variants.
--- @field numBits number? The number of bits to use for the amount of variants. Can be used to reserve additional space to allow for future variants.

--- @class VariantField: FieldBase
--- @field New fun(self: VariantField, label: string, variants: FieldBase[], options?: VariantFieldOptions): VariantField
local VariantField = FieldBase:Subclass()
LGB.internal.class.VariantField = VariantField

local AVAILABLE_OPTIONS = {
    maxNumVariants = true,
    numBits = true,
}

--- @protected
function VariantField:Initialize(label, variants, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, options)
    options = self.options

    local entries = {}
    local variantByLabel = {}
    if self:Assert(type(variants) == "table", "'variants' must be a table") then
        for i = 1, #variants do
            local variant = variants[i]
            if not self:Assert(ZO_Object.IsInstanceOf(variant, FieldBase), "All variants must be instances of FieldBase") then break end
            if not self:Assert(not variantByLabel[variant.label], "All variants must have unique labels") then break end
            self:RegisterSubField(variant)
            variantByLabel[variant.label] = variant
            entries[#entries + 1] = variant.label
        end
    end

    self.labelField = self:RegisterSubField(EnumField:New("label", entries, {
        numBits = options.numBits,
        maxValue = options.maxNumVariants,
    }))
    self.variants = variants
    self.variantByLabel = variantByLabel

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

--- @protected
function VariantField:GetNumBitsRangeInternal()
    local minBits, maxBits = self.labelField:GetNumBitsRange()
    for i = 1, #self.variants do
        local minVariantBits, maxVariantBits = self.variants[i]:GetNumBitsRange()
        minBits = minBits + minVariantBits
        maxBits = maxBits + maxVariantBits
    end
    return minBits, maxBits
end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? table The value to serialize.
function VariantField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    if type(value) ~= "table" then
        logger:Warn("Value must be a table")
        return false
    end

    local label, payload = next(value)
    local variant = self.variantByLabel[label]
    if not variant then
        logger:Warn("Unknown variant: " .. tostring(label))
        return false
    end

    if not self.labelField:Serialize(data, label) then return false end
    if not variant:Serialize(data, payload) then return false end
    return true
end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return table value The deserialized value.
function VariantField:Deserialize(data)
    local label = self.labelField:Deserialize(data)
    local variant = self.variantByLabel[label]
    local payload = {}
    if variant then
        payload[label] = variant:Deserialize(data)
    end
    return payload
end
