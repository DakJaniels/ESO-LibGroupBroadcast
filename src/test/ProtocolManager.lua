if not Taneth then return end
local LGB = LibGroupBroadcast
local ProtocolManager = LGB.internal.class.ProtocolManager
local HandlerManager = LGB.internal.class.HandlerManager
local Protocol = LGB.internal.class.Protocol
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local OptionalField = LGB.internal.class.OptionalField
local MessageQueue = LGB.internal.class.MessageQueue
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage

local function CreateProtocolManager()
    local callbackManager = ZO_CallbackObject:New()
    local dataMessageQueue = MessageQueue:New()
    local handlerManager = HandlerManager:New()
    local handlerId = handlerManager:RegisterHandler("test", "test")
    return ProtocolManager:New(callbackManager, dataMessageQueue, handlerManager), handlerId
end

Taneth("LibGroupBroadcast", function()
    describe("ProtocolManager", function()
        it("should be able to create a new instance", function()
            local manager = CreateProtocolManager()
            assert.is_true(ZO_Object.IsInstanceOf(manager, ProtocolManager))
        end)

        it("should be able to declare multiple different custom events", function()
            local manager, handlerId = CreateProtocolManager()
            local fireEvent1 = manager:DeclareCustomEvent(handlerId, 0, "test1")
            local fireEvent2 = manager:DeclareCustomEvent(handlerId, 1, "test2")
            assert.equals(type(fireEvent1), "function")
            assert.equals(type(fireEvent2), "function")
        end)

        it("should not be able to declare the same custom event twice", function()
            local manager, handlerId = CreateProtocolManager()
            local fireEvent1 = manager:DeclareCustomEvent(handlerId, 0, "test1")
            local fireEvent2 = manager:DeclareCustomEvent(handlerId, 0, "test2")
            local fireEvent3 = manager:DeclareCustomEvent(handlerId, 1, "test1")
            assert.equals(type(fireEvent1), "function")
            assert.is_nil(fireEvent2)
            assert.is_nil(fireEvent3)
        end)

        it("should be able to generate and handle custom events", function()
            local manager, handlerId = CreateProtocolManager()
            local fireEvent1 = manager:DeclareCustomEvent(handlerId, 0, "test1")
            local fireEvent2 = manager:DeclareCustomEvent(handlerId, 1, "test2")
            local fireEvent3 = manager:DeclareCustomEvent(handlerId, 39, "test3")

            local triggered = 0
            manager.callbackManager:RegisterCallback("RequestSendData", function()
                triggered = triggered + 1
            end)

            fireEvent1()
            fireEvent2()
            fireEvent3()
            assert.equals(3, triggered)

            local messages = manager:GenerateCustomEventMessages()
            assert.equals(2, #messages)
            assert.equals(6, messages[1]:GetId())
            local events1 = messages[1]:GetEvents()
            assert.equals(2, #events1)
            assert.equals(0, events1[1])
            assert.equals(1, events1[2])

            assert.equals(15, messages[2]:GetId())
            local events2 = messages[2]:GetEvents()
            assert.equals(1, #events2)
            assert.equals(39, events2[1])

            local receivedUnitTag1, receivedUnitTag2, receivedUnitTag3
            assert.is_true(manager:RegisterForCustomEvent("test1", function(unitTag)
                receivedUnitTag1 = unitTag
            end))
            assert.is_true(manager:RegisterForCustomEvent("test2", function(unitTag)
                receivedUnitTag2 = unitTag
            end))
            assert.is_true(manager:RegisterForCustomEvent("test3", function(unitTag)
                receivedUnitTag3 = unitTag
            end))
            local unhandledMessages = manager:HandleCustomEventMessages("group1", messages)
            assert.equals(0, #unhandledMessages)
            assert.equals("group1", receivedUnitTag1)
            assert.equals("group1", receivedUnitTag2)
            assert.equals("group1", receivedUnitTag3)
        end)

        it("should be able to declare multiple different data protocols", function()
            local manager, handlerId = CreateProtocolManager()
            local protocol1 = manager:DeclareProtocol(handlerId, 0, "test1")
            local protocol2 = manager:DeclareProtocol(handlerId, 1, "test2")
            assert.is_true(ZO_Object.IsInstanceOf(protocol1, Protocol))
            assert.is_true(ZO_Object.IsInstanceOf(protocol2, Protocol))
        end)

        it("should not be able to declare the same data protocol twice", function()
            local manager, handlerId = CreateProtocolManager()
            local protocol1 = manager:DeclareProtocol(handlerId, 0, "test1")
            local protocol2 = manager:DeclareProtocol(handlerId, 0, "test2")
            local protocol3 = manager:DeclareProtocol(handlerId, 1, "test1")
            assert.is_true(ZO_Object.IsInstanceOf(protocol1, Protocol))
            assert.is_nil(protocol2)
            assert.is_nil(protocol3)
        end)

        it("should be able to generate and handle data messages", function()
            local manager, handlerId = CreateProtocolManager()

            local triggered = 0
            manager.callbackManager:RegisterCallback("RequestSendData", function()
                triggered = triggered + 1
            end)

            local protocol1IncomingUnitTag, protocol1IncomingData
            local protocol2IncomingUnitTag, protocol2IncomingData

            local protocol1 = manager:DeclareProtocol(handlerId, 0, "test1")
            protocol1:AddField(FlagField:New("flagA"))
            protocol1:AddField(FlagField:New("flagB"))
            protocol1:OnData(function(unitTag, data)
                protocol1IncomingUnitTag = unitTag
                protocol1IncomingData = data
            end)
            protocol1:Finalize()

            local protocol2 = manager:DeclareProtocol(handlerId, 1, "test2")
            protocol2:AddField(FlagField:New("flagC"))
            protocol2:AddField(NumericField:New("number"))
            protocol2:OnData(function(unitTag, data)
                protocol2IncomingUnitTag = unitTag
                protocol2IncomingData = data
            end)
            protocol2:Finalize()

            assert.is_true(protocol1:Send({ flagA = true, flagB = false }))
            assert.equals(1, triggered)
            local message1 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message1, FixedSizeDataMessage))
            message1.data:Rewind()

            assert.is_true(protocol2:Send({ flagC = true, number = 1 }))
            assert.equals(2, triggered)
            local message2 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message2, FlexSizeDataMessage))
            message2.data:Rewind()

            manager:HandleDataMessages("group1", { message1 })
            assert.equals("group1", protocol1IncomingUnitTag)
            assert.equals(true, protocol1IncomingData.flagA)
            assert.equals(false, protocol1IncomingData.flagB)

            manager:HandleDataMessages("group2", { message2 })
            assert.equals("group2", protocol2IncomingUnitTag)
            assert.equals(true, protocol2IncomingData.flagC)
            assert.equals(1, protocol2IncomingData.number)
        end)
    end)
end)
