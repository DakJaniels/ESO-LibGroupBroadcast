local LGB = LibGroupBroadcast
--- @class FieldBase

local FieldBase = ZO_InitializingObject:Subclass()
LGB.internal.class.FieldBase = FieldBase

--- Initializes a new FieldBase object.
--- @param label string The label of the field.
--- @param options table? Optional configuration for the field.
function FieldBase:Initialize(label, options)
    self.label = label
    self.options = options or {}
    self:Assert(type(label) == "string", "Label must be a string")
    self:Assert(type(self.options) == "table", "Options must be a table")
end

function FieldBase:Assert(condition, message)
    if not condition then
        local warnings = self:GetWarnings()
        warnings[#warnings + 1] = message
        return false
    end
    return true
end

function FieldBase:GetWarnings()
    if not self.warnings then
        self.warnings = {}
    end
    return self.warnings
end

function FieldBase:IsValid()
    return not self.warnings or #self.warnings == 0
end

function FieldBase:GetLabel()
    return self.label
end

--- Returns the passed value or options.defaultValue if the value is nil.
--- @protected
--- @param value any The value to check.
--- @return any value The value or options.defaultValue.
function FieldBase:GetValueOrDefault(value)
    if value == nil then
        return self.options.defaultValue
    end
    return value
end

--- The Validate function has to ensure the passed value can be serialized and sent.
--- @param value any The value to validate.
--- @return boolean valid Whether the value is valid.
FieldBase:MUST_IMPLEMENT("Validate")

--- The Serialize function has to serialize the value and write it to the data stream.
--- @param data ByteBuffer The data stream to write to.
FieldBase:MUST_IMPLEMENT("Serialize")

--- The Deserialize function has to read the value from the data stream and return it.
--- @param data ByteBuffer The data stream to read from.
--- @return any value The deserialized value.
FieldBase:MUST_IMPLEMENT("Deserialize")

FieldBase:MUST_IMPLEMENT("GetNumBitsRange")
