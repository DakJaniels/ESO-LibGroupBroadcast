local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local EnumField = LGB.internal.class.EnumField

--- @class VariantField: FieldBase
local VariantField = FieldBase:Subclass()
LGB.internal.class.VariantField = VariantField

function VariantField:Initialize(label, variants, options)
    FieldBase.Initialize(self, label)

    local entries = {}
    local variantByLabel = {}
    if self:Assert(type(variants) == "table", "'variants' must be a table") then
        for i = 1, #variants do
            local variant = variants[i]
            if not self:Assert(ZO_Object.IsInstanceOf(variant, FieldBase), "All variants must be instances of FieldBase") then break end
            if not self:Assert(not variantByLabel[variant.label], "All variants must have unique labels") then break end
            variantByLabel[variant.label] = variant
            entries[#entries + 1] = variant.label
        end
    end

    self.labelField = EnumField:New("label", entries, options)
    self.variants = variants
    self.variantByLabel = variantByLabel
end

function VariantField:GetWarnings()
    local output = {}
    ZO_CombineNumericallyIndexedTables(output, FieldBase.GetWarnings(self), self.labelField:GetWarnings())
    for i = 1, #self.variants do
        ZO_CombineNumericallyIndexedTables(output, self.variants[i]:GetWarnings())
    end
    return output
end

function VariantField:IsValid()
    if not FieldBase.IsValid(self) then return false end
    if not self.labelField:IsValid(self) then return false end
    for i = 1, #self.variants do
        if not self.variants[i]:IsValid() then return false end
    end
    return true
end

function VariantField:GetNumBitsRange()
    local minBits, maxBits = self.labelField:GetNumBitsRange()
    for i = 1, #self.variants do
        local minVariantBits, maxVariantBits = self.variants[i]:GetNumBitsRange()
        minBits = minBits + minVariantBits
        maxBits = maxBits + maxVariantBits
    end
    return minBits, maxBits
end

function VariantField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    assert(type(value) == "table", "Value must be a table")
    local label, payload = next(value)
    local variant = self.variantByLabel[label]
    if not variant then return false end
    if not self.labelField:Serialize(data, label) then return false end
    if not variant:Serialize(data, payload) then return false end
    return true
end

function VariantField:Deserialize(data)
    local label = self.labelField:Deserialize(data)
    local variant = self.variantByLabel[label]
    local payload = {}
    if variant then
        payload[label] = variant:Deserialize(data)
    end
    return payload
end
