local LGB = LibGroupBroadcast

local GroupResources = LGB:RegisterHandler("GroupResources")
assert(GroupResources, "Failed to register handler for GroupResources")

function GroupResources:Initialize()
    local GroupResourceManager = GroupResources.GroupResourceManager
    local callbackManager = ZO_CallbackObject:New()
    local stamina = GroupResourceManager:New(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA, callbackManager, LGB)
    local magicka = GroupResourceManager:New(2, "Magicka", COMBAT_MECHANIC_FLAGS_MAGICKA, callbackManager, LGB)
    GroupResources.GroupResourceManager = nil
    GroupResources.Initialize = nil
    return stamina, magicka
end
