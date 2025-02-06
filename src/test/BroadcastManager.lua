if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local ProtocolManager = LGB.internal.class.ProtocolManager
local HandlerManager = LGB.internal.class.HandlerManager
local MockGameApiWrapper = LGB.internal.class.MockGameApiWrapper
local BroadcastManager = LGB.internal.class.BroadcastManager
local MessageQueue = LGB.internal.class.MessageQueue
local StringField = LGB.internal.class.StringField
local ArrayField = LGB.internal.class.ArrayField
local TableField = LGB.internal.class.TableField
local NumericField = LGB.internal.class.NumericField
local PercentageField = LGB.internal.class.PercentageField

local function SetupBroadcastManager()
    local callbackManager = ZO_CallbackObject:New()
    local dataMessageQueue = MessageQueue:New()
    local handlerManager = HandlerManager:New()
    local gameApiWrapper = MockGameApiWrapper:New(callbackManager)
    local protocolManager = ProtocolManager:New(callbackManager, dataMessageQueue, handlerManager)
    local broadcastManager = BroadcastManager:New(gameApiWrapper, protocolManager, callbackManager, dataMessageQueue)
    return {
        callbackManager = callbackManager,
        dataMessageQueue = dataMessageQueue,
        handlerManager = handlerManager,
        gameApiWrapper = gameApiWrapper,
        protocolManager = protocolManager,
        broadcastManager = broadcastManager,
    }
end

Taneth("LibGroupBroadcast", function()
    describe("BroadcastManager", function()
        it("should be able to create a new instance", function()
            local internal = SetupBroadcastManager()
            assert.is_true(ZO_Object.IsInstanceOf(internal.broadcastManager, BroadcastManager))
        end)

        it.async("should be able to send and receive a long message", function(done)
            local internal = SetupBroadcastManager()
            local manager = internal.broadcastManager

            local sendDataTriggered = 0
            ZO_PreHook(manager, "SendData", function()
                sendDataTriggered = sendDataTriggered + 1
            end)

            local onDataReceivedTriggered = 0
            ZO_PreHook(manager, "OnDataReceived", function()
                onDataReceivedTriggered = onDataReceivedTriggered + 1
            end)

            local outgoingData = { text = string.rep("a", 255) }
            local handlerId = internal.handlerManager:RegisterHandler("test", "test")
            local protocol = internal.protocolManager:DeclareProtocol(handlerId, 0, "test")
            assert.is_not_nil(protocol)
            protocol:AddField(StringField:New("text"))
            protocol:OnData(function(unitTag, data)
                assert.same(outgoingData, data)
                assert.equals("player", unitTag)
                assert.equals(10, sendDataTriggered)
                assert.equals(10, onDataReceivedTriggered)
                done()
            end)
            protocol:Finalize()

            assert.is_true(protocol:Send(outgoingData))
        end)

        it.async("should be able to send and receive an array of tables", function(done)
            local internal = SetupBroadcastManager()
            local manager = internal.broadcastManager
            manager.IsInCombat = function() return false end

            local outgoingData = {
                test = {
                    { numberA = 0,  numberB = 1,  numberC = 2,  numberD = 3 },
                    { numberA = 4,  numberB = 5,  numberC = 6,  numberD = 7 },
                    { numberA = 8,  numberB = 9,  numberC = 10, numberD = 11 },
                    { numberA = 12, numberB = 13, numberC = 14, numberD = 15 },
                    { numberA = 16, numberB = 17, numberC = 18, numberD = 19 },
                    { numberA = 20, numberB = 21, numberC = 22, numberD = 23 },
                    { numberA = 24, numberB = 25, numberC = 26, numberD = 27 },
                    { numberA = 28, numberB = 29, numberC = 30, numberD = 31 }
                }
            }

            local handlerId = internal.handlerManager:RegisterHandler("test", "test")
            local protocol = internal.protocolManager:DeclareProtocol(handlerId, 0, "test")
            protocol:AddField(ArrayField:New(TableField:New("test", {
                NumericField:New("numberA"),
                NumericField:New("numberB"),
                NumericField:New("numberC"),
                NumericField:New("numberD")
            }), { minLength = 1, maxLength = 8 }))
            protocol:OnData(function(unitTag, data)
                assert.same(outgoingData, data)
                assert.equals("player", unitTag)
                done()
            end)
            protocol:Finalize()

            assert.is_true(protocol:Send(outgoingData))
        end)

        it.async("should be able to set multiple different message types in the same broadcast", function(done)
            local internal = SetupBroadcastManager()
            local protocolManager = internal.protocolManager

            local received = {
                testEvent1 = false,
                testEvent2 = false,
                test1 = false,
                test2 = false
            }
            local function FinishTest()
                for _, hasReceived in pairs(received) do
                    if not hasReceived then return end
                end
                done()
            end

            local handlerId = internal.handlerManager:RegisterHandler("test", "test")
            local FireEvent1 = protocolManager:DeclareCustomEvent(handlerId, 0, "testEvent1")
            protocolManager:RegisterForCustomEvent("testEvent1", function(unitTag)
                assert.equals("player", unitTag)
                received.testEvent1 = true
                FinishTest()
            end)

            local FireEvent2 = protocolManager:DeclareCustomEvent(handlerId, 5, "testEvent2")
            protocolManager:RegisterForCustomEvent("testEvent2", function(unitTag)
                assert.equals("player", unitTag)
                received.testEvent2 = true
                FinishTest()
            end)

            local outgoingData1 = {
                text = "hello",
                number = 42
            }
            local outgoingData2 = {
                percentage = 1
            }

            local protocol1 = protocolManager:DeclareProtocol(handlerId, 0, "test1")
            protocol1:AddField(StringField:New("text"))
            protocol1:AddField(NumericField:New("number"))
            protocol1:OnData(function(unitTag, data)
                assert.same(outgoingData1, data)
                assert.equals("player", unitTag)
                received.test1 = true
                FinishTest()
            end)
            assert.is_true(protocol1:Finalize())

            local protocol2 = protocolManager:DeclareProtocol(handlerId, 1, "test2")
            protocol2:AddField(PercentageField:New("percentage"))
            protocol2:OnData(function(unitTag, data)
                assert.same(outgoingData2, data)
                assert.equals("player", unitTag)
                received.test2 = true
                FinishTest()
            end)
            assert.is_true(protocol2:Finalize())

            FireEvent1(outgoingData1)
            FireEvent2(outgoingData2)
            assert.is_true(protocol1:Send(outgoingData1))
            assert.is_true(protocol2:Send(outgoingData2))
        end)
    end)
end)
