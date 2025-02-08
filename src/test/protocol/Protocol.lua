-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
--- @class Protocol
local Protocol = LGB.internal.class.Protocol
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local VariantField = LGB.internal.class.VariantField
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("Protocol", function()
        it("should be able to create a new instance", function()
            local field = Protocol:New(0, "test", {})
            assert.is_true(ZO_Object.IsInstanceOf(field, Protocol))
            assert.equals(0, field:GetId())
            assert.equals("test", field:GetName())
        end)

        it("should be able to be finalized", function()
            local protocol = Protocol:New(0, "test", {})
            protocol:AddField(FlagField:New("flag"))
            protocol:AddField(NumericField:New("number"))
            protocol:OnData(function() end)
            assert.is_true(protocol:Finalize())
        end)

        it("should be able to send FixedSizeDataMessages and FlexSizeDataMessages as needed", function()
            local sentMessage

            local protocol = Protocol:New(0, "test", {
                QueueDataMessage = function(_, message) sentMessage = message end
            })
            protocol:AddField(VariantField:New("test", {
                FlagField:New("flag"),
                NumericField:New("number")
            }))
            protocol:OnData(function(data) end)
            protocol:Finalize()

            assert.is_true(protocol:Send({ test = { flag = true } }))
            assert.is_not_nil(sentMessage)
            assert.is_true(ZO_Object.IsInstanceOf(sentMessage, FixedSizeDataMessage))

            sentMessage = nil
            assert.is_true(protocol:Send({ test = { number = 1 } }))
            assert.is_not_nil(sentMessage)
            assert.is_true(ZO_Object.IsInstanceOf(sentMessage, FlexSizeDataMessage))
        end)

        it("should be able to receive FixedSizeDataMessages and FlexSizeDataMessages as needed", function()
            local receivedUnitTag, receivedData

            local protocol = Protocol:New(0, "test", {})
            protocol:AddField(VariantField:New("test", {
                FlagField:New("flag"),
                NumericField:New("number")
            }))
            protocol:OnData(function(unitTag, data)
                receivedUnitTag = unitTag
                receivedData = data
            end)
            protocol:Finalize()

            local message = FixedSizeDataMessage:New(0, BinaryBuffer.FromHexString("40"))
            protocol:Receive("group1", message)
            assert.equals("group1", receivedUnitTag)
            assert.is_true(receivedData.test.flag)

            receivedData = nil
            message = FlexSizeDataMessage:New(0, BinaryBuffer.FromHexString("80 00 00 00 80"))
            protocol:Receive("group2", message)
            assert.equals("group2", receivedUnitTag)
            assert.equals(1, receivedData.test.number)
        end)
    end)
end)
