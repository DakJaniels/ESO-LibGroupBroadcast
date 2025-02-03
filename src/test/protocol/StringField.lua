if not Taneth then return end
local LGB = LibGroupBroadcast
local StringField = LGB.internal.class.StringField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("StringField", function()
        it("should be able to create a new instance", function()
            local field = StringField:New("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, StringField))
        end)

        it("should be able to serialize and deserialize a string", function()
            local field = StringField:New("test")
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            local expectedNumBits = 8 + 0 * 8
            assert.is_true(field:Serialize(buffer, ""))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 4 * 8
            assert.is_true(field:Serialize(buffer, "test"))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 5 * 8 * 3
            assert.is_true(field:Serialize(buffer, "あいうえお"))
            assert.equals(expectedNumBits, buffer:GetNumBits())

            buffer:Rewind()
            assert.equals("", field:Deserialize(buffer))
            assert.equals("test", field:Deserialize(buffer))
            assert.equals("あいうえお", field:Deserialize(buffer))
        end)

        it("should be able to serialize and deserialize an optimized string using options", function()
            local field = StringField:New("test", { characters = "0123456789", minLength = 4, maxLength = 8 })
            assert.is_true(field:IsValid())
            local minBits, maxBits = field:GetNumBitsRange()
            assert.equals(3 + 4 * 4, minBits)
            assert.equals(3 + 8 * 4, maxBits)

            local buffer = BinaryBuffer:New(1)
            assert.is_false(field:Serialize(buffer, ""))
            local expectedNumBits = 3 + 4 * 4
            assert.is_true(field:Serialize(buffer, "0123"))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 3 + 7 * 4
            assert.is_true(field:Serialize(buffer, "3456789"))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            assert.is_false(field:Serialize(buffer, " 56789a"))

            buffer:Rewind()
            assert.equals("0123", field:Deserialize(buffer))
            assert.equals("3456789", field:Deserialize(buffer))
        end)

        it("should be able to serialize and deserialize a string with a custom character set", function()
            local field = StringField:New("test", { characters = "あいうえお" })
            assert.is_true(field:IsValid())
            local minBits, maxBits = field:GetNumBitsRange()
            assert.equals(8 + 0 * 3, minBits)
            assert.equals(8 + 255 * 3, maxBits)

            local buffer = BinaryBuffer:New(1)
            local expectedNumBits = 8 + 0 * 3
            assert.is_true(field:Serialize(buffer, ""))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 2 * 3
            assert.is_true(field:Serialize(buffer, "あい"))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 2 * 3
            assert.is_true(field:Serialize(buffer, "えお"))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            assert.is_false(field:Serialize(buffer, "test"))

            buffer:Rewind()
            assert.equals("", field:Deserialize(buffer))
            assert.equals("あい", field:Deserialize(buffer))
            assert.equals("えお", field:Deserialize(buffer))
        end)
    end)
end)
