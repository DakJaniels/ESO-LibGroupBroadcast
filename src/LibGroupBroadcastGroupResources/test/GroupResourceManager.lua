-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local LGB = LibGroupBroadcast
local GroupResources = LGB:GetHandler("GroupResources")
local SetupMockInstance = LGB.SetupMockInstance
local GroupResourceManager = GroupResources.GroupResourceManager

local function SetupHandler(id, name, powerType)
    local api = SetupMockInstance()
    local callbackManager = ZO_CallbackObject:New()
    local handlerId = api:RegisterHandler("test", "test")
    local handler = GroupResourceManager:New(handlerId, id, name, powerType, callbackManager, api)
    return handler, api
end

local function TeardownHandler(handler)
    local namespace = handler.namespace
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_GROUP_MEMBER_LEFT)
end

Taneth("LibGroupBroadcastGroupResources", function()
    describe("GroupResourceManager", function()
        it("should be able to create a new instance", function()
            local handler = SetupHandler(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            assert.is_true(ZO_Object.IsInstanceOf(handler, GroupResourceManager))
            TeardownHandler(handler)
        end)

        it.async("should be able to send power updates including the maximum value", function(done)
            local handler = SetupHandler(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)

            local current1, maximum1, percentage1 = handler:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            handler:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(10600, current2)
                assert.equals(21000, maximum2)
                assert.equals(32 / 63, percentage2)

                local current3, maximum3, percentage3 = handler:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownHandler(handler)
                done()
            end)
            handler:OnPlayerResourceChanged(10540, 21023)
        end, 1000)

        it.async("should be able to send power updates without the maximum value", function(done)
            local handler = SetupHandler(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            handler.config.sendMaximum = false

            local current1, maximum1, percentage1 = handler:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            handler:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(50, current2)
                assert.equals(100, maximum2)
                assert.equals(32 / 63, percentage2)

                local current3, maximum3, percentage3 = handler:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownHandler(handler)
                done()
            end)
            handler:OnPlayerResourceChanged(10540, 21023)
        end, 1000)


        it.async("should be able to replace queued power updates with more current values", function(done)
            local handler = SetupHandler(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            handler.config.sendMaximum = false

            local current1, maximum1, percentage1 = handler:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            handler:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(100, current2)
                assert.equals(100, maximum2)
                assert.equals(1, percentage2)

                local current3, maximum3, percentage3 = handler:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownHandler(handler)
                done()
            end)
            handler:OnPlayerResourceChanged(0, 21023)
            handler:OnPlayerResourceChanged(21023, 21023)
        end, 1000)
    end)
end)
