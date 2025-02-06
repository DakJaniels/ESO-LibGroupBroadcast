-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local LGB = LibGroupBroadcast

local GroupResources = {}
local handlerId = LGB:RegisterHandler("GroupResources", "LibGroupBroadcastGroupResources", GroupResources)
assert(handlerId, "Failed to register handler for GroupResources")

function GroupResources:Initialize()
    local GroupResourceManager = GroupResources.GroupResourceManager
    local callbackManager = ZO_CallbackObject:New()
    local stamina = GroupResourceManager:New(handlerId, 1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA, callbackManager, LGB)
    local magicka = GroupResourceManager:New(handlerId, 2, "Magicka", COMBAT_MECHANIC_FLAGS_MAGICKA, callbackManager, LGB)
    GroupResources.GroupResourceManager = nil
    GroupResources.Initialize = nil
    return stamina, magicka
end
