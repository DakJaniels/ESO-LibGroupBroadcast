if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FlagField = LGB.internal.class.FlagField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("FlagField", function()
        it("should be able to create a new instance", function()
            local field = FlagField:New("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, FlagField))
        end)

        it("should have a min and max bit size of 1", function()
            local field = FlagField:New("test")
            assert.is_true(field:IsValid())
            local minBits, maxBits = field:GetNumBitsRange()
            assert.equals(1, minBits)
            assert.equals(1, maxBits)
        end)

        it("should be able to serialize and deserialize 'true'", function()
            local field = FlagField:New("test")
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, true))
            buffer:Rewind()
            assert.is_true(field:Deserialize(buffer))
        end)

        it("should be able to serialize and deserialize 'false'", function()
            local field = FlagField:New("test")
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, false))
            buffer:Rewind()
            assert.is_false(field:Deserialize(buffer))
        end)

        it("should return false when serializing a non-boolean value", function()
            local field = FlagField:New("test")
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_false(field:Serialize(buffer, 0))
        end)

        it("should support a defaultValue", function()
            local field = FlagField:New("test", { defaultValue = true })
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer))
            buffer:Rewind()
            assert.is_true(field:Deserialize(buffer))
        end)

        it("should be invalid with a defaultValue that is not a boolean", function()
            local field = FlagField:New("test", { defaultValue = 0 })
            assert.is_false(field:IsValid())
        end)
    end)
end)
