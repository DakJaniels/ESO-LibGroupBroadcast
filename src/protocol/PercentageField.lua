local LGB = LibGroupBroadcast
local NumericField = LGB.internal.class.NumericField

--- @class PercentageField: NumericField
local PercentageField = NumericField:Subclass()
LGB.internal.class.PercentageField = PercentageField

function PercentageField:Initialize(label, options)
    options = options or {}
    options.numBits = options.numBits or 7
    options.minValue = 0
    options.maxValue = 1
    options.precision = 1 / (2 ^ options.numBits - 1)

    NumericField.Initialize(self, label, options)
end
