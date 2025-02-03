if not Taneth then return end
local LGB = LibGroupBroadcast
local VariantField = LGB.internal.class.VariantField
local TableField = LGB.internal.class.TableField
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("VariantField", function()
        it("should be able to create a new instance", function()
            local field = VariantField:New("test", {})
            assert.is_true(ZO_Object.IsInstanceOf(field, VariantField))
        end)

        it("should be able to serialize and deserialize nested fields", function()
            local field = VariantField:New("test", {
                TableField:New("table", {
                    FlagField:New("flag"),
                    NumericField:New("number"),
                }),
                NumericField:New("number"),
            })
            d(field:GetWarnings())
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {
                table = { flag = true, number = 42 }
            }))
            assert.is_true(field:Serialize(buffer, {
                number = 69
            }))

            buffer:Rewind()
            local data = field:Deserialize(buffer)
            assert.equals("table", type(data))
            assert.is_nil(data.number)
            assert.is_not_nil(data.table)
            assert.equals(true, data.table.flag)
            assert.equals(42, data.table.number)

            data = field:Deserialize(buffer)
            assert.equals(69, data.number)
            assert.is_nil(data.table)
        end)
    end)
end)
