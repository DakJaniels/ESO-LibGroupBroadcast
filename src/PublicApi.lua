local LGB = LibGroupBroadcast
local internal = LGB.internal

function LGB.SetupMockInstance()
    return internal.SetupMockInstance()
end

function LGB:DeclareCustomEvent(eventId, eventName)
    return internal.protocolManager:DeclareCustomEvent(eventId, eventName)
end

function LGB:RegisterForCustomEvent(eventName, callback)
    return internal.protocolManager:RegisterForCustomEvent(eventName, callback)
end

function LGB:UnregisterForCustomEvent(eventName, callback)
    return internal.protocolManager:UnregisterForCustomEvent(eventName, callback)
end

function LGB:DeclareProtocol(protocolId, protocolName)
    return internal.protocolManager:DeclareProtocol(protocolId, protocolName)
end

function LGB:RegisterHandler(handlerName)
    return internal:RegisterHandler(handlerName)
end

function LGB:GetHandler(handlerName)
    return internal:GetHandler(handlerName)
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
