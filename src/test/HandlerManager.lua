if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local HandlerManager = LGB.internal.class.HandlerManager

Taneth("LibGroupBroadcast", function()
    describe("HandlerManager", function()
        it("should be able to create a new instance", function()
            local manager = HandlerManager:New()
            assert.is_true(ZO_Object.IsInstanceOf(manager, HandlerManager))
        end)

        it("should be able to register and get a handler table", function()
            local manager = HandlerManager:New()
            local handler = {}
            local handlerId = manager:RegisterHandler("test1", "test2", handler)
            assert.equals("number", type(handlerId))
            assert.equals(handler, manager:GetHandlerApi("test1"))
        end)

        it("should be able to register a private handler", function()
            local manager = HandlerManager:New()
            local handlerId = manager:RegisterHandler("test1", "test2")
            assert.equals("number", type(handlerId))
            assert.is_nil(manager:GetHandlerApi("test1"))
        end)

        it("should not be possible to register a handler name more than once", function()
            local manager = HandlerManager:New()
            local handler1 = {}
            local handlerId1 = manager:RegisterHandler("test1", "test2", handler1)
            assert.equals("number", type(handlerId1))

            local handler2 = {}
            local handlerId2 = manager:RegisterHandler("test1", "test3", handler2)
            assert.is_nil(handlerId2)

            local handlerId3 = manager:RegisterHandler("test4", "test3", handler2)
            assert.equals("number", type(handlerId3))

            assert.equals(handler1, manager:GetHandlerApi("test1"))
            assert.equals(handler2, manager:GetHandlerApi("test4"))
        end)
    end)
end)
