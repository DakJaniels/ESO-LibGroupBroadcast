local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase

--- @class TableField: FieldBase
local TableField = FieldBase:Subclass()
LibGroupBroadcast.internal.class.TableField = TableField

function TableField:Initialize(label, fields, options)
    FieldBase.Initialize(self, label, options)
    if self:Assert(type(fields) == "table", "'fields' must be a table") then
        for i = 1, #fields do
            if not self:Assert(ZO_Object.IsInstanceOf(fields[i], FieldBase), "All fields must be instances of FieldBase") then break end
        end
    else
        fields = {}
    end
    self.fields = fields
end

function TableField:GetWarnings()
    local output = {}
    ZO_CombineNumericallyIndexedTables(FieldBase.GetWarnings(self))
    for i = 1, #self.fields do
        ZO_CombineNumericallyIndexedTables(output, self.fields[i]:GetWarnings())
    end
    return output
end

function TableField:IsValid()
    if not FieldBase.IsValid(self) then return false end
    for i = 1, #self.fields do
        if not self.fields[i]:IsValid() then return false end
    end
    return true
end

function TableField:GetNumBitsRange()
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
