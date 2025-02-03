local LGB = LibGroupBroadcast
local NumericField = LGB.internal.class.NumericField
local ArrayField = LGB.internal.class.ArrayField
local EnumField = LGB.internal.class.EnumField

--- @class StringField: ArrayField
local StringField = ArrayField:Subclass()
LGB.internal.class.StringField = StringField

-- as of v10.3.2 utf8.char still crashes the game, so we use this code ported from the utf8lib in Lua5.3 instead
local UTF8BUFFSZ = 8
local buff = {}
for i = 1, UTF8BUFFSZ do buff[i] = 0 end
local function utf8esc(x)
    local n = 1
    assert(x >= 0 and x <= 0x10FFFF, "Invalid codepoint")
    if x < 0x80 then
        buff[UTF8BUFFSZ - 1] = x
    else
        local mfb = 0x3F
        repeat
            buff[UTF8BUFFSZ - n] = BitAnd(0xFF, BitOr(0x80, BitAnd(x, 0x3F)))
            n = n + 1
            x = BitRShift(x, 6)
            mfb = BitRShift(mfb, 1)
        until x <= mfb
        buff[UTF8BUFFSZ - n] = BitAnd(0xFF, BitOr(BitLShift(BitNot(mfb, 8), 1), x))
    end
    return string.char(unpack(buff, UTF8BUFFSZ - n, UTF8BUFFSZ - 1))
end

function StringField:Initialize(label, options)
    options = options or {}

    local charField
    if options.characters then
        if not self:Assert(type(options.characters) == "string", "characters must be a string") then return end
        local codepoints = { utf8.codepoint(options.characters, 1, #options.characters) }
        charField = EnumField:New(label, codepoints)
    else
        charField = NumericField:New(label, { numBits = 8 })
    end
    ArrayField.Initialize(self, charField, options)
end

function StringField:Serialize(data, value)
    value = self:GetValueOrDefault(value)
    assert(type(value) == "string", "Value must be a string")
    local parts
    if self.options.characters then
        parts = { utf8.codepoint(value, 1, #value) }
    else
        parts = { string.byte(value, 1, #value) }
    end
    return ArrayField.Serialize(self, data, parts)
end

function StringField:Deserialize(data)
    local parts = ArrayField.Deserialize(self, data)
    if #parts == 0 then return "" end
    if self.options.characters then
        for i = 1, #parts do
            parts[i] = utf8esc(parts[i])
        end
        return table.concat(parts)
        -- TODO simplify, once the utf8.char function no longer crashes the game
        -- return utf8.char(unpack(parts))
    end
    return string.char(unpack(parts))
end
