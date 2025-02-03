local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase

--- @class NumericField: FieldBase
local NumericField = FieldBase:Subclass()
LGB.internal.class.NumericField = NumericField

local MIN_SUPPORTED_VALUE = 0
local MAX_SUPPORTED_VALUE = 2 ^ 32 - 1

-- use FPU's rounding mode as seen in https://stackoverflow.com/a/58411671
local function Round(num)
    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
end

local function ApplyPrecision(value, precision)
    if not precision or precision == 1 then
        return value
    elseif precision > 1 then
        -- the FPU rounding returns incorrect results for precision > 1
        return math.floor(value / precision + 0.5)
    else
        -- need to invert like this, otherwise we get incorrect results in some cases
        return Round(value * (1 / precision))
    end
end

function NumericField:Initialize(label, options)
    FieldBase.Initialize(self, label, options)

    options = self.options
    if not self:Assert(options.numBits == nil or (options.numBits >= 2 and options.numBits <= 32), "Number of bits must be between 2 and 32") then return end

    if options.minValue then
        self.minValue = options.minValue
    elseif options.numBits then
        if options.maxValue then
            self.minValue = options.maxValue - 2 ^ options.numBits + 1
        else
            self.minValue = MIN_SUPPORTED_VALUE
        end
    else
        self.minValue = MIN_SUPPORTED_VALUE
    end

    if options.maxValue then
        self.maxValue = options.maxValue
    elseif options.numBits then
        local minValue = self.minValue or MIN_SUPPORTED_VALUE
        self.maxValue = minValue + 2 ^ options.numBits - 1
    else
        self.maxValue = MAX_SUPPORTED_VALUE
    end

    local range = ApplyPrecision(self.maxValue - self.minValue, options.precision)
    if not self:Assert(range > 0, "Value range must be more than 0") then return end
    if not self:Assert(range <= MAX_SUPPORTED_VALUE, "Value range is larger than 2^32-1") then return end

    local numBits = options.numBits or 0
    if numBits == 0 then
        while range > 0 do
            range = BitRShift(range, 1)
            numBits = numBits + 1
        end
        if not self:Assert(numBits <= 32, "Number of bits must be at most 32") then return end
    end
    self.maxSendValue = 2 ^ numBits - 1
    if not self:Assert(self.maxSendValue >= range, string.format("Effective value range (%s) is larger then possible transmission value (%s)", range, self.maxSendValue)) then return end
    self.numBits = numBits
end

function NumericField:GetNumBitsRange()
    return self.numBits, self.numBits
end

function NumericField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    assert(type(value) == "number", "Value must be a number")

    local options = self.options
    if options.trimValues then
        -- log debug
        if value < self.minValue then
            value = self.minValue
        elseif value > self.maxValue then
            value = self.maxValue
        end
    else
        if value < self.minValue or value > self.maxValue then
            -- log warning
            return false
        end
    end

    value = ApplyPrecision(value - self.minValue, options.precision)
    assert(value >= 0 and value <= self.maxSendValue, "Value out of range")
    data:GrowIfNeeded(self.numBits)
    data:WriteUInt(value, self.numBits)
    return true
end

function NumericField:Deserialize(data)
    local value = data:ReadUInt(self.numBits)
    local precision = self.options.precision
    if precision then
        value = value * precision
    end
    return value + self.minValue
end
