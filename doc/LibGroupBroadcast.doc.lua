-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @meta LibGroupBroadcast

--- @class LibGroupBroadcast
local LibGroupBroadcast = {}

--- Registers a handler under a unique name. A handler in this context is a library or addon that uses one or more protocols or custom events for communication.
--- @param handlerName string The name of the handler to register.
--- @param addonName string The name of the addon or library that is registering the handler.
--- @param handlerApi? table The handler table to register. Should provide some api for addon authors to interact with. Can be nil if the handler api is private or should be accessed via other means.
--- @return number|nil handlerId An identifier for the handler to declare protocols and custom events with or nil if the registration failed.
--- @see LibGroupBroadcast.GetHandler
function LibGroupBroadcast:RegisterHandler(handlerName, addonName, handlerApi) end

--- Returns a handler's api by its unique name, if it is public.
--- @param handlerName string The name of the handler to get.
--- @return table handler The handler table that was registered with the given name.
--- @see LibGroupBroadcast.RegisterHandler
function LibGroupBroadcast:GetHandler(handlerName) end

--- This function declares a custom event that can be used to send messages without data to other group members with minimal overhead.
--- Each event id and event name has to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param handlerId number The ID of the handler this custom event should be associated with.
--- @param eventId number The custom event ID to use.
--- @param eventName string The custom event name to use.
--- @return function|nil FireEvent A function that can be called to request sending this custom event to other group members or nil if the declaration failed.
function LibGroupBroadcast:DeclareCustomEvent(handlerId, eventId, eventName) end

--- Registers a callback function to be called when a custom event is received.
--- @param eventName string The custom event name to register for.
--- @param callback fun(unitTag: string) The callback function to call when the custom event is received. Receives the unitTag of the sender as an argument.
--- @return boolean success True if the callback was successfully registered, false otherwise.
function LibGroupBroadcast:RegisterForCustomEvent(eventName, callback) end

--- Unregisters a callback function from a custom event.
--- @param eventName string The custom event name to unregister from.
--- @param callback fun(unitTag: string) The callback function to unregister. Has to be the same instance as the one registered.
--- @return boolean success True if the callback was successfully unregistered, false otherwise.
function LibGroupBroadcast:UnregisterForCustomEvent(eventName, callback) end

--- Declares a new protocol with the given ID and name and returns the Protocol object instance.
---
--- The protocol id and name have to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param handlerId number The ID of the handler this custom event should be associated with.
--- @param protocolId number The ID of the protocol to declare.
--- @param protocolName string The name of the protocol to declare.
--- @return Protocol|nil protocol The Protocol object instance that was declared or nil if the declaration failed.
--- @see Protocol
function LibGroupBroadcast:DeclareProtocol(handlerId, protocolId, protocolName) end

--- Creates and returns an ArrayField, which can be used to send the passed field multiple times.
--- Internally this will use a NumericField to store the length of the array and then serialize the values using the passed field.
--- By default the array can have up to 255 elements, but this can be changed using the options table.
--- @param valueField FieldBase The field that should be used for the values in the array.
--- @param options? ArrayFieldOptions The options table to use for the field.
--- @return ArrayField field The created ArrayField instance.
--- @see ArrayField
function LibGroupBroadcast.CreateArrayField(valueField, options) end

--- Creates and returns an instance of the EnumField class.
--- @param label string The label of the field.
--- @param valueTable any[] The array containing the possible values for the field.
--- @param options? EnumFieldOptions The options table to use for the field.
--- @return EnumField field The created EnumField instance.
--- @see EnumField
function LibGroupBroadcast.CreateEnumField(label, valueTable, options) end

--- Creates and returns an instance of the FlagField class.
--- @param label string The label of the field.
--- @param options? FlagFieldOptions The options table to use for the field.
--- @return FlagField field The created FlagField instance.
--- @see FlagField
function LibGroupBroadcast.CreateFlagField(label, options) end

--- Creates and returns an instance of the NumericField class.
--- @param label string The label of the field.
--- @param options? NumericFieldOptions The options table to use for the field.
--- @return NumericField field The created NumericField instance.
--- @see NumericField
function LibGroupBroadcast.CreateNumericField(label, options) end

--- Creates and returns an instance of the OptionalField class.
--- @param valueField FieldBase The field that should be made optional.
--- @return OptionalField field The created OptionalField instance.
--- @see OptionalField
function LibGroupBroadcast.CreateOptionalField(valueField) end

--- Creates and returns an instance of the PercentageField class.
--- @param label string The label of the field.
--- @param options? PercentageFieldOptions The options table to use for the field.
--- @return PercentageField field The created PercentageField instance.
--- @see PercentageField
function LibGroupBroadcast.CreatePercentageField(label, options) end

--- Creates and returns an instance of the ReservedField class.
--- @param label string The label of the field.
--- @param numBits number The number of bits to reserve.
--- @return ReservedField field The created ReservedField instance.
--- @see ReservedField
function LibGroupBroadcast.CreateReservedField(label, numBits) end

--- Creates and returns an instance of the StringField class.
--- @param label string The label of the field.
--- @param options? StringFieldOptions The options table to use for the field.
--- @return StringField field The created StringField instance.
--- @see StringField
function LibGroupBroadcast.CreateStringField(label, options) end

--- Creates and returns an instance of the TableField class.
--- @param label string The label of the field.
--- @param valueFields FieldBase[] A list of fields contained in the table.
--- @param options? TableFieldOptions The options table to use for the field.
--- @return TableField field The created TableField instance.
--- @see TableField
function LibGroupBroadcast.CreateTableField(label, valueFields, options) end

--- Creates and returns an instance of the VariantField class.
--- @param label string The label of the field.
--- @param variants FieldBase[] A list of fields that can be used as variants.
--- @param options? VariantFieldOptions The options table to use for the field.
--- @return VariantField field The created VariantField instance.
--- @see VariantField
function LibGroupBroadcast.CreateVariantField(label, variants, options) end

--- Creates a subclass of the FieldBase class. Can be used to create custom field types.
--- @generic T : FieldBase
--- @return T subclass The created FieldBase subclass.
--- @see FieldBase
function LibGroupBroadcast.CreateFieldBaseSubclass() end

--- Creates a new separate instance of the LibGroupBroadcast library for use in Taneth tests.
---
--- The returned table has the same API as the global LibGroupBroadcast table, but is not connected to the global state.
--- It also contains references to some internal objects that are not normally exposed and uses an instance of MockGameApiWrapper.
---
--- @see LibGroupBroadcastInternal.SetupMockInstance
function LibGroupBroadcast.SetupMockInstance() end


--- @class FieldOptionsBase
--- @field defaultValue any? The default value for the field.

--- @class FieldBase
--- @field protected index integer
--- @field protected label string
--- @field protected warnings table<string>
--- @field protected subfields table<FieldBase>
--- @field protected options FieldOptionsBase
--- @field private avaliableOptions table<string, boolean>
--- @field protected New fun(self: FieldBase, label: string, options?: FieldOptionsBase): FieldBase
--- @field private MUST_IMPLEMENT fun(self:FieldBase, methodName: string)
--- @field protected Initialize fun(self:FieldBase, label: string, options?: FieldOptionsBase)
--- @field protected Subclass fun(): FieldBase
--- @field protected GetNumBitsRangeInternal fun(self:FieldBase): integer, integer
--- @field Serialize fun(self:FieldBase, data: BinaryBuffer, value?: any)
--- @field Deserialize fun(self:FieldBase, data: BinaryBuffer): any
local FieldBase = ZO_InitializingObject:Subclass()


--- Initializes a new FieldBase object.
--- @protected
--- @param label string The label of the field.
--- @param options? FieldOptionsBase Optional configuration for the field.
function FieldBase:Initialize(label, options) end

--- Internal function to add options for validation.
--- @protected
--- @param availableOptions table<string, boolean> Additional available options for the field, used for validation.
function FieldBase:RegisterAvailableOptions(availableOptions) end

--- Internal function to validate and get the options.
--- @protected
--- @param availableOptions? table<string, boolean> Optional available options for the field, used for validation.
--- @return FieldOptionsBase options The validated options.
function FieldBase:ValidateAndGetOptions(availableOptions) end

--- Asserts that the condition is true and adds a warning if it is not.
--- @protected
--- @param condition boolean The condition to check.
--- @param message string The warning message to add.
--- @return boolean valid Whether the condition is true.
function FieldBase:Assert(condition, message) end

--- Internal function to register a subfield, so it can be checked for warnings and validity.
--- @protected
--- @generic T : FieldBase
--- @param field T The subfield to register.
--- @return T field The passed field.
function FieldBase:RegisterSubField(field) end

--- Returns the warnings for this field.
--- @return table<string> warnings The warnings for this field.
function FieldBase:GetWarnings() end

--- Returns whether the field is valid.
--- @return boolean valid Whether the field is valid.
function FieldBase:IsValid() end

--- Returns the label of the field.
--- @return string label The label of the field.
function FieldBase:GetLabel() end

--- Returns the passed value or options.defaultValue if the value is nil.
--- @protected
--- @param value any The value to check.
--- @return any value The value or options.defaultValue.
function FieldBase:GetValueOrDefault(value) end

--- Returns the minimum and maximum number of bits the serialized data will take up.
--- @return integer minBits The minimum number of bits the serialized data will take up.
--- @return integer maxBits The maximum number of bits the serialized data will take up.
function FieldBase:GetNumBitsRange() return self:GetNumBitsRangeInternal() end

--- @class ProtocolOptions
--- @field isRelevantInCombat boolean? Whether the protocol is relevant in combat.
--- @field replaceQueuedMessages boolean? Whether to replace already queued messages with the same protocol ID when Send is called.

--- @class Protocol
--- @field protected id number
--- @field protected name string
--- @field protected manager ProtocolManager
--- @field protected fields FieldBase[]
--- @field protected fieldsByLabel table<string, FieldBase>
--- @field protected finalized boolean
--- @field protected onDataCallback fun(unitTag: string, data: table)
--- @field protected options ProtocolOptions
--- @field protected New fun(self: Protocol, id: number, name: string, manager: ProtocolManager): Protocol
local Protocol = ZO_InitializingObject:Subclass()

--- @protected
function Protocol:Initialize(id, name, manager) end

--- Getter for the protocol's ID.
--- @return number id The protocol's ID.
function Protocol:GetId() end

--- Getter for the protocol's name.
--- @return string name The protocol's name.
function Protocol:GetName() end

--- Adds a field to the protocol. Fields are serialized in the order they are added.
--- @param field FieldBase The field to add.
--- @return Protocol protocol Returns the protocol for chaining.
function Protocol:AddField(field) end

--- Sets the callback to be called when data is received for this protocol.
--- @param callback fun(unitTag: string, data: table) The callback to call when data is received.
--- @return Protocol protocol Returns the protocol for chaining.
function Protocol:OnData(callback) end

--- Returns whether the protocol has been finalized.
--- @return boolean isFinalized Whether the protocol has been finalized.
function Protocol:IsFinalized() end

--- Finalizes the protocol. This must be called before the protocol can be used to send or receive data.
--- @param options? ProtocolOptions Optional options for the protocol.
function Protocol:Finalize(options) end

--- Converts the passed values into a message and queues it for sending.
--- @param values table The values to send.
--- @param options? ProtocolOptions Optional options for the message.
--- @return boolean success Whether the message was successfully queued.
function Protocol:Send(values, options) end

--- Internal function to receive data for the protocol.
--- @protected
function Protocol:Receive(unitTag, message) end


--- @class NumericFieldOptions: FieldOptionsBase
--- @field defaultValue number? The default value for the field
--- @field numBits number? The number of bits to use for the field. If not provided, it will be calculated based on the value range.
--- @field minValue number? The minimum value that can be sent. If not provided, it will be calculated based on the number of bits and maxValue.
--- @field maxValue number? The maximum value that can be sent. If not provided, it will be calculated based on the number of bits and minValue.
--- @field precision number? The precision to use when sending the value. Will be used to divide the value before sending and multiply it after receiving. If not provided, the value will be sent as is.
--- @field trimValues boolean? Whether to trim values to the range. If not provided, send will fail with a warning when the value is out of range.

--- @class NumericField: FieldBase
--- @field protected minValue number
--- @field protected maxValue number
--- @field protected maxSendValue number
--- @field protected numBits number
--- @field protected options NumericFieldOptions
--- @field New fun(self: NumericField, label: string, options?: NumericFieldOptions): NumericField
local NumericField = FieldBase:Subclass()


--- Initializes a new NumericField object.
--- @protected
--- @param label string The label of the field.
--- @param options NumericFieldOptions Optional configuration for the field.
--- @see NumericFieldOptions
function NumericField:Initialize(label, options) end

--- @protected
function NumericField:GetNumBitsRangeInternal() end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? number The value to serialize.
function NumericField:Serialize(data, value) end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return number value The deserialized value.
function NumericField:Deserialize(data) end


--- @class FlagFieldOptions: FieldOptionsBase
--- @field defaultValue boolean? The default value for the field.

--- @class FlagField: FieldBase
--- @field New fun(self: FlagField, label: string, options?: FlagFieldOptions): FlagField
local FlagField = FieldBase:Subclass()

--- @protected
function FlagField:Initialize(label, options) end

--- @protected
function FlagField:GetNumBitsRangeInternal() end

function FlagField:Serialize(data, value) end

function FlagField:Deserialize(data) end


--- @class OptionalField: FieldBase
--- @field protected isNilField FlagField
--- @field protected valueField FieldBase
--- @field New fun(self: OptionalField, valueField: FieldBase): OptionalField
local OptionalField = FieldBase:Subclass()

--- @protected
function OptionalField:Initialize(valueField) end

--- @protected
function OptionalField:GetNumBitsRangeInternal() end

function OptionalField:Serialize(data, value) end

function OptionalField:Deserialize(data) end


--- @class ArrayFieldOptions : FieldOptionsBase
--- @field minLength number? The minimum length of the array.
--- @field maxLength number? The maximum length of the array.
--- @field defaultValue table? The default value for the field.

--- @class ArrayField: FieldBase
--- @field protected minLength number
--- @field protected maxLength number
--- @field protected countField NumericField
--- @field protected valueField FieldBase
--- @field New fun(self:ArrayField, valueField: FieldBase, options?: ArrayFieldOptions): ArrayField
local ArrayField = FieldBase:Subclass()

--- @protected
function ArrayField:Initialize(valueField, options) end

--- @protected
function ArrayField:GetNumBitsRangeInternal() end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? table The value to serialize.
function ArrayField:Serialize(data, value) end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return table value The deserialized value.
function ArrayField:Deserialize(data) end


--- @class TableFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.

--- @class TableField: FieldBase
--- @field protected fields FieldBase[]
--- @field New fun(self: TableField, label: string, valueFields: FieldBase[], options?: TableFieldOptions): TableField
local TableField = FieldBase:Subclass()

--- @protected
function TableField:Initialize(label, valueFields, options) end

--- @protected
function TableField:GetNumBitsRangeInternal() end

function TableField:Serialize(data, value) end

function TableField:Deserialize(data) end


--- @class VariantFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.
--- @field maxNumVariants number? The maximum number of variants that can be used. Can be used to reserve space for future variants.
--- @field numBits number? The number of bits to use for the amount of variants. Can be used to reserve additional space to allow for future variants.

--- @class VariantField: FieldBase
--- @field protected labelField EnumField
--- @field protected variants FieldBase[]
--- @field protected variantByLabel table<string, FieldBase>
--- @field New fun(self: VariantField, label: string, variants: FieldBase[], options?: VariantFieldOptions): VariantField
local VariantField = FieldBase:Subclass()

--- @protected
function VariantField:Initialize(label, variants, options) end

--- @protected
function VariantField:GetNumBitsRangeInternal() end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? table The value to serialize.
function VariantField:Serialize(data, value) end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return table value The deserialized value.
function VariantField:Deserialize(data) end


--- @class EnumFieldOptions: FieldOptionsBase
--- @field maxValue number? The max value of the field. Defaults to the length of the valueTable. Can be used to reserve space for future values.
--- @field numBits number? The number of bits to use for the field. Can be used to reserve a specific number of bits for future values.

--- @class EnumField: FieldBase
--- @field protected indexField NumericField
--- @field protected valueTable any[]
--- @field protected valueLookup table
--- @field New fun(self: EnumField, label: string, valueTable: any[], options?: EnumFieldOptions): EnumField
local EnumField = FieldBase:Subclass()

--- @protected
function EnumField:Initialize(label, valueTable, options) end

--- @protected
function EnumField:GetNumBitsRangeInternal() end

function EnumField:Serialize(data, value) end

function EnumField:Deserialize(data) end


--- @class PercentageFieldOptions: FieldOptionsBase
--- @field defaultValue number? The default value for the field. Must be between 0 and 1.
--- @field numBits number? The number of bits to use for the percentage.

--- @class PercentageField: NumericField
--- @field New fun(self: PercentageField, label: string, options?: PercentageFieldOptions): PercentageField
local PercentageField = NumericField:Subclass()

--- @protected
function PercentageField:Initialize(label, options) end


--- @class StringFieldOptions: FieldOptionsBase
--- @field characters string? The characters to use for the string. If not provided, the string will be treated as a sequence of bytes.
--- @field minLength number? The minimum length of the string. Defaults to 0.
--- @field maxLength number? The maximum length of the string. Defaults to 255.
--- @field defaultValue string? The default value for the field.

--- @class StringField: FieldBase
--- @field protected arrayField ArrayField
--- @field New fun(self: StringField, label: string, options?: StringFieldOptions): StringField
local StringField = FieldBase:Subclass()


--- @protected
function StringField:Initialize(label, options) end

--- @protected
function StringField:GetNumBitsRangeInternal() end

--- Writes the value to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param value? string The value to serialize. If not provided, the default value specified in the options will be used.
function StringField:Serialize(data, value) end

--- Reads the value from the data stream.
--- @param data BinaryBuffer The data stream to read from.
--- @return string value The deserialized value.
function StringField:Deserialize(data) end


--- @class ReservedField: FieldBase
--- @field New fun(self: ReservedField, label: string, numBits: number): ReservedField
local ReservedField = FieldBase:Subclass()

--- @protected
function ReservedField:Initialize(label, numBits) end

--- @protected
function ReservedField:GetNumBitsRangeInternal() end

function ReservedField:Serialize(data, _) end

function ReservedField:Deserialize(data) end


--- @class BinaryBuffer
--- @field protected bytes table<number> The bytes of the buffer.
--- @field protected bitLength number The number of bits in the buffer.
--- @field protected cursor number The current cursor position.
--- @field New fun(self: BinaryBuffer, numBits: number): BinaryBuffer
local BinaryBuffer = ZO_InitializingObject:Subclass()


--- Initializes a new BinaryBuffer with the specified number of bits.
--- @protected
--- @param numBits number The number of bits the buffer should have. Has to be a positive number.
function BinaryBuffer:Initialize(numBits) end

--- Clears the buffer and sets all bits to 0. The length of the buffer remains the same.
function BinaryBuffer:Clear() end

--- Grows the buffer if the specified number of bits would exceed the current length.
--- @param numBits number The number of bits to grow the buffer by.
function BinaryBuffer:GrowIfNeeded(numBits) end

--- Getter for the number of bits in the buffer.
--- @return number bitLength The number of bits in the buffer.
function BinaryBuffer:GetNumBits() end

--- Getter for the number of bytes in the buffer.
--- @return number byteLength The number of bytes in the buffer (rounded up to full bytes).
function BinaryBuffer:GetByteLength() end

--- Writes a single bit to the buffer.
--- @param value number|boolean The value to write. Must be 1/0 or true/false.
function BinaryBuffer:WriteBit(value) end

--- Writes an unsigned integer to the buffer.
--- @param value number The value to write. Must be a non-negative number and fit in the specified number of bits.
--- @param numBits number The number of bits to write. Must be a positive number.
function BinaryBuffer:WriteUInt(value, numBits) end

--- Writes a string to the buffer.
--- @param value string The value to write. Must be a string.
function BinaryBuffer:WriteString(value) end

--- Writes another buffer to the buffer. The cursor of the input buffer is modified.
--- @param value BinaryBuffer The buffer to write. Must be a BinaryBuffer.
--- @param numBits? number The number of bits to write from the input buffer. If not specified the entire buffer is written.
--- @param offset? number The offset to start reading from. If not specified the input buffer is read from the start.
function BinaryBuffer:WriteBuffer(value, numBits, offset) end

--- Reads a single bit from the buffer.
--- @param asBoolean? boolean Whether to return the value as a boolean. If not specified, the value is returned as a number.
--- @return number|boolean value The read value. If asBoolean is true, the value is a boolean.
function BinaryBuffer:ReadBit(asBoolean) end

--- Reads an unsigned integer from the buffer.
--- @param numBits number The number of bits to read. Must be a positive number.
--- @return number value The read value.
function BinaryBuffer:ReadUInt(numBits) end

--- Reads a string from the buffer.
--- @param byteLength number The number of bytes to read. Must be a positive number.
--- @return string value The read value.
function BinaryBuffer:ReadString(byteLength) end

--- Reads a number of bits from the buffer and returns them as a new buffer.
--- @param numBits number The number of bits to read from the buffer.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer:ReadBuffer(numBits) end

--- Seeks the cursor by the specified number of bits.
--- @param numBits number The number of bits to seek. Must be a positive number.
function BinaryBuffer:Seek(numBits) end

--- Rewinds the cursor to the specified position (starting at 1).
--- @param cursor? number The position to rewind to. If not specified, the cursor is rewound to the start of the buffer.
function BinaryBuffer:Rewind(cursor) end

--- Returns the buffer as a hexadecimal string.
--- @return string hexString The buffer as a hexadecimal string.
function BinaryBuffer:ToHexString() end

--- Creates a new BinaryBuffer from a hexadecimal string.
--- @param hexString string The hexadecimal string to create the buffer from.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer.FromHexString(hexString) end

--- Returns the buffer as a table of unsigned 32-bit integers for use with the broadcast api.
--- @return table<number> result The buffer as a table of unsigned 32-bit integers.
function BinaryBuffer:ToUInt32Array() end

--- Creates a new BinaryBuffer from unsigned 32-bit integers, as passed by the broadcast api.
--- @param numBits number The number of bits the buffer should have. Must be a positive number.
--- @param ... number The values to create the buffer from. Must match the specified number of bits.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer.FromUInt32Values(numBits, ...) end


--- @class GameApiWrapper
--- @field New fun(self:GameApiWrapper, authKey: string, namespace: string, callbackManager: ZO_CallbackObject):GameApiWrapper
local GameApiWrapper = ZO_InitializingObject:Subclass()

function GameApiWrapper:Initialize(authKey, namespace, callbackManager) end

function GameApiWrapper:GetCooldown() end

function GameApiWrapper:GetInitialSendDelay() end

function GameApiWrapper:IsInCombat() end

function GameApiWrapper:BroadcastData(buffer) end

function GameApiWrapper:OnDataReceived(unitTag, ...) end


--- @class MockGameApiWrapper: GameApiWrapper
--- @field New fun(self: MockGameApiWrapper, callbackManager: ZO_CallbackObject): MockGameApiWrapper
local MockGameApiWrapper = GameApiWrapper:Subclass()

function MockGameApiWrapper:Initialize(callbackManager) end

function MockGameApiWrapper:GetCooldown() end

function MockGameApiWrapper:SetCooldown(cooldown) end

function MockGameApiWrapper:GetInitialSendDelay() end

function MockGameApiWrapper:IsInCombat() end

function MockGameApiWrapper:SetInCombat(inCombat) end

function MockGameApiWrapper:BroadcastData(buffer) end

function MockGameApiWrapper:SetUnitTag(unitTag) end


--- @class MessageQueue
--- @field New fun(self: MessageQueue): MessageQueue
local MessageQueue = ZO_InitializingObject:Subclass()

function MessageQueue:Initialize() end

function MessageQueue:EnqueueMessage(message) end

function MessageQueue:DequeueMessage(i) end

function MessageQueue:DeleteMessagesByProtocolId(protocolId) end

function MessageQueue:GetSize() end

function MessageQueue:HasRelevantMessages(inCombat) end

function MessageQueue:GetOldestRelevantMessage(inCombat) end

function MessageQueue:GetNextRelevantEntry(inCombat) end

function MessageQueue:GetNextRelevantEntryWithExactSize(size, inCombat) end


--- @class HandlerManager
--- @field New fun(self: HandlerManager): HandlerManager
local HandlerManager = ZO_InitializingObject:Subclass()

function HandlerManager:Initialize() end

function HandlerManager:RegisterHandler(handlerName, addonName, handlerApi) end

function HandlerManager:GetHandlerApi(handlerName) end

function HandlerManager:GetHandler(handlerId) end

function HandlerManager:GenerateId() end


--- @class ProtocolManager
--- @field New fun(self: ProtocolManager, callbackManager: ZO_CallbackObject, dataMessageQueue: MessageQueue, handlerManager: HandlerManager): ProtocolManager
local ProtocolManager = ZO_InitializingObject:Subclass()

function ProtocolManager:Initialize(callbackManager, dataMessageQueue, handlerManager) end

function ProtocolManager:DeclareCustomEvent(handlerId, eventId, eventName, options) end

function ProtocolManager:GetCustomEventCallbackName(eventName) end

function ProtocolManager:RegisterForCustomEvent(eventName, callback) end

function ProtocolManager:UnregisterForCustomEvent(eventName, callback) end

function ProtocolManager:GenerateCustomEventMessages() end

function ProtocolManager:HandleCustomEventMessages(unitTag, messages) end

function ProtocolManager:DeclareProtocol(handlerId, protocolId, protocolName) end

function ProtocolManager:QueueDataMessage(message) end

function ProtocolManager:HasRelevantMessages(inCombat) end

function ProtocolManager:HandleDataMessages(unitTag, messages) end


--- @class BroadcastManager
--- @field New fun(self: BroadcastManager, gameApiWrapper: GameApiWrapper, protocolManager: ProtocolManager, callbackManager: ZO_CallbackObject, dataMessageQueue: MessageQueue): BroadcastManager
local BroadcastManager = ZO_InitializingObject:Subclass()

function BroadcastManager:Initialize(gameApiWrapper, protocolManager, callbackManager, dataMessageQueue) end

function BroadcastManager:RequestSendData() end


function BroadcastManager:FillSendBuffer(inCombat) end

function BroadcastManager:IsInCombat() end

function BroadcastManager:SendData() end

function BroadcastManager:OnDataReceived(unitTag, data) end

--- @class LibGroupBroadcastMockInstance : LibGroupBroadcast
--- @field callbackManager ZO_CallbackObject
--- @field gameApiWrapper MockGameApiWrapper
--- @field dataMessageQueue MessageQueue
--- @field handlerManager HandlerManager
--- @field protocolManager ProtocolManager
--- @field broadcastManager BroadcastManager