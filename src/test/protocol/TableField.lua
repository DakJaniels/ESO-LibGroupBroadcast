if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local TableField = LGB.internal.class.TableField
local FlagField = LGB.internal.class.FlagField
local OptionalField = LGB.internal.class.OptionalField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("TableField", function()
        it("should be able to create a new instance", function()
            local field = TableField:New("test", {})
            assert.is_true(ZO_Object.IsInstanceOf(field, TableField))
        end)

        it("should support a defaultValue", function()
            local value = { flag = true }
            local field = TableField:New("test", { FlagField:New("flag") }, { defaultValue = value })
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer))

            buffer:Rewind()
            local actual = field:Deserialize(buffer)
            assert.same(value, actual)
        end)

        it("should be able to serialize and deserialize nested fields", function()
            local field = TableField:New("test", {
                FlagField:New("flag"),
                NumericField:New("numberA", { defaultValue = 1 }),
                OptionalField:New(NumericField:New("numberB")),
            })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { flag = true, numberA = 42, numberB = 0 }))
            assert.is_true(field:Serialize(buffer, { flag = false, numberA = 69 }))
            assert.is_true(field:Serialize(buffer, { flag = true }))

            buffer:Rewind()
            local data = field:Deserialize(buffer)
            assert.equals("table", type(data))
            assert.equals(true, data.flag)
            assert.equals(42, data.numberA)
            assert.equals(0, data.numberB)

            data = field:Deserialize(buffer)
            assert.equals("table", type(data))
            assert.equals(false, data.flag)
            assert.equals(69, data.numberA)
            assert.is_nil(data.numberB)

            data = field:Deserialize(buffer)
            assert.equals("table", type(data))
            assert.equals(true, data.flag)
            assert.equals(1, data.numberA)
            assert.is_nil(data.numberB)
        end)
    end)
end)
