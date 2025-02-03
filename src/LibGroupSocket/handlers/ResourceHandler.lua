-- LibGroupSocket & its files © sirinsidiator                   --
-- Distributed under The Artistic License 2.0 (see LICENSE)     --
------------------------------------------------------------------

local LGS = LibGroupSocket
local LGB = LibGroupBroadcast
local type, version = LGS.MESSAGE_TYPE_RESOURCES, 3
local handler, saveData = LGS:RegisterHandler(type, version)
if (not handler) then return end
local SKIP_CREATE = true
local ON_RESOURCES_CHANGED = "OnResourcesChanged"
local logger = LGS.logger:Create("ResourceHandler")

handler.resources = {}
local resources = handler.resources
local defaultData = {
    version = 1,
    enabled = true,
    percentOnly = true,
}

local function GetCachedUnitResources(unitName, skipCreate)
    local unitResources = resources[unitName]
    if (not unitResources and not skipCreate) then
        resources[unitName] = {
            [POWERTYPE_MAGICKA] = { current = 1000, maximum = 1000, percent = 255 },
            [POWERTYPE_STAMINA] = { current = 1000, maximum = 1000, percent = 255 },
            lastUpdate = 0,
        }
        unitResources = resources[unitName]
    end
    return unitResources
end

function handler:GetLastUpdateTime(unitTag)
    local unitName = GetRawUnitName(unitTag)
    local unitResources = GetCachedUnitResources(unitName, SKIP_CREATE)
    if (unitResources) then return unitResources.lastUpdate end
    return -1
end

local function OnResourceChanged(unitResources, changedResource, unitTag, current, maximum, percentage)
    local stamina = unitResources[POWERTYPE_STAMINA]
    local magicka = unitResources[POWERTYPE_MAGICKA]
    if maximum == 100 then
        changedResource.maximum = 1000
        changedResource.current = math.floor(percentage * 1000)
    else
        changedResource.maximum = maximum
        changedResource.current = current
    end
    changedResource.percent = percentage
    unitResources.lastUpdate = GetTimeStamp()
    local isSelf = IsUnitPlayer(unitTag)
    logger:Verbose("magicka: %d/%d stamina: %d/%d", magicka.current, magicka.maximum, stamina.current, stamina.maximum)
    LGS.cm:FireCallbacks(ON_RESOURCES_CHANGED, unitTag, magicka.current, magicka.maximum, stamina.current,
        stamina.maximum, isSelf)
end

local function OnStaminaChanged(unitTag, unitName, current, maximum, percentage)
    local unitResources = GetCachedUnitResources(unitName)
    local stamina = unitResources[POWERTYPE_STAMINA]
    OnResourceChanged(unitResources, stamina, unitTag, current, maximum, percentage)
end

local function OnMagickaChanged(unitTag, unitName, current, maximum, percentage)
    local unitResources = GetCachedUnitResources(unitName)
    local magicka = unitResources[POWERTYPE_MAGICKA]
    OnResourceChanged(unitResources, magicka, unitTag, current, maximum, percentage)
end

function handler:RegisterForResourcesChanges(callback)
    LGS.cm:RegisterCallback(ON_RESOURCES_CHANGED, callback)
end

function handler:UnregisterForResourcesChanges(callback)
    LGS.cm:UnregisterCallback(ON_RESOURCES_CHANGED, callback)
end

function handler:Send()
    -- no longer used
end

function handler:InitializeSettings(optionsData, IsSendingDisabled)
    -- no longer used
end

-- savedata becomes available twice in case the standalone lib is loaded
local function InitializeSaveData(data)
    saveData = data

    if (not saveData.version) then
        ZO_DeepTableCopy(defaultData, saveData)
    end

    --  if(saveData.version == 1) then
    --      -- update it
    --  end
end

local function Unload()
    LGS.cm:UnregisterCallback(type, handler.dataHandler)
    LGS.cm:UnregisterCallback("savedata-ready", InitializeSaveData)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketResourceHandler", EVENT_UNIT_CREATED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketResourceHandler", EVENT_UNIT_DESTROYED)
end

local function Load()
    InitializeSaveData(saveData)
    LGS.cm:RegisterCallback("savedata-ready", function(data)
        InitializeSaveData(data.handlers[type])
    end)

    LGB:RegisterForStaminaUpdate(OnStaminaChanged)
    LGB:RegisterForMagickaUpdate(OnMagickaChanged)

    handler.Unload = Unload
end

if (handler.Unload) then handler.Unload() end
Load()
