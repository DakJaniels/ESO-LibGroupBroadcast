local LGB = LibGroupBroadcast
local internal = LGB.internal

function LGB.SetupMockInstance()
    return internal.SetupMockInstance()
end

function LGB:RegisterHandler(handlerName, addonName, handlerApi)
    return internal.handlerManager:RegisterHandler(handlerName, addonName, handlerApi)
end

function LGB:GetHandler(handlerName)
    return internal.handlerManager:GetHandlerApi(handlerName)
end

function LGB:DeclareCustomEvent(handlerId, eventId, eventName)
    return internal.protocolManager:DeclareCustomEvent(handlerId, eventId, eventName)
end

function LGB:RegisterForCustomEvent(eventName, callback)
    return internal.protocolManager:RegisterForCustomEvent(eventName, callback)
end

function LGB:UnregisterForCustomEvent(eventName, callback)
    return internal.protocolManager:UnregisterForCustomEvent(eventName, callback)
end

function LGB:DeclareProtocol(handlerId, protocolId, protocolName)
    return internal.protocolManager:DeclareProtocol(handlerId, protocolId, protocolName)
end

function LGB.CreateFlagField(...)
    return internal.class.FlagField:New(...)
end

function LGB.CreateNumericField(...)
    return internal.class.NumericField:New(...)
end

function LGB.CreateOptionalField(...)
    return internal.class.OptionalField:New(...)
end

function LGB.CreateArrayField(...)
    return internal.class.ArrayField:New(...)
end

function LGB.CreateEnumField(...)
    return internal.class.EnumField:New(...)
end

function LGB.CreatePercentageField(...)
    return internal.class.PercentageField:New(...)
end

function LGB.CreateStringField(...)
    return internal.class.StringField:New(...)
end

function LGB.CreateTableField(...)
    return internal.class.TableField:New(...)
end

function LGB.CreateVariantField(...)
    return internal.class.VariantField:New(...)
end

function LGB.CreateFieldBaseSubclass()
    return internal.class.FieldBase:Subclass()
end

LGB:Initialize()
