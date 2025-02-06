-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local MessageQueue = LGB.internal.class.MessageQueue
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage

Taneth("LibGroupBroadcast", function()
    describe("MessageQueue", function()
        it("should be able to create a new instance", function()
            local queue = MessageQueue:New()
            assert.is_true(ZO_Object.IsInstanceOf(queue, MessageQueue))
        end)

        it("should be able to delete specific messages by id", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1)
            queue:EnqueueMessage(expected)

            assert.is_true(queue:HasRelevantMessages())
            queue:DeleteMessagesByProtocolId(1)
            assert.is_false(queue:HasRelevantMessages())
        end)

        it("should be able to return the oldest queued message", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1)
            expected.GetLastAdded = function() return 1 end
            queue:EnqueueMessage(expected)
            for i = 2, 5 do
                local message = FixedSizeDataMessage:New(i)
                message.GetLastAdded = function() return i end
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetOldestRelevantMessage()
            assert.equals(expected, actual)
        end)

        it("should be able to return the oldest queued combat relevant message", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1, BinaryBuffer:New(7), { isRelevantInCombat = true })
            expected.GetLastAdded = function() return 7 end
            queue:EnqueueMessage(expected)
            for i = 2, 5 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7), { isRelevantInCombat = true })
                message.GetLastAdded = function() return 6 + i end
                queue:EnqueueMessage(message)
            end
            for i = 6, 10 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7))
                message.GetLastAdded = function() return i end
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetOldestRelevantMessage(true)
            assert.equals(expected, actual)
        end)

        it("should be able to return the oldest queued message when in combat with no queued combat relevant messages",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                expected.GetLastAdded = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    message.GetLastAdded = function() return i end
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetOldestRelevantMessage(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the smallest queued message",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                expected.GetSize = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry()
                assert.equals(expected, actual)
            end)

        it("should be able to return the smallest queued combat relevant message", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1, BinaryBuffer:New(7), { isRelevantInCombat = true })
            expected.GetSize = function() return 1 end
            queue:EnqueueMessage(expected)
            for i = 2, 5 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7), { isRelevantInCombat = true })
                queue:EnqueueMessage(message)
            end
            for i = 6, 10 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7))
                message.GetSize = function() return 1 end
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetNextRelevantEntry(true)
            assert.equals(expected, actual)
        end)

        it("should be able to return the smallest queued message when in combat with no queued combat relevant messages",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                expected.GetSize = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest and smallest queued message",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                expected.GetLastAdded = function() return 1 end
                expected.GetSize = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 4 do
                    local message = FixedSizeDataMessage:New(i)
                    message.GetLastAdded = function() return i end
                    message.GetSize = function() return 1 end
                    queue:EnqueueMessage(message)
                end
                for i = 5, 6 do
                    local message = FixedSizeDataMessage:New(i)
                    message.GetLastAdded = function() return 0 end
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest queued message with the exact size",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                expected.GetSize = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(1)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest queued combat relevant message with the exact size",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1, BinaryBuffer:New(7), { isRelevantInCombat = true })
                expected.GetSize = function() return 1 end
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7), { isRelevantInCombat = true })
                    queue:EnqueueMessage(message)
                end
                for i = 6, 10 do
                    local message = FixedSizeDataMessage:New(i)
                    message.GetSize = function() return 1 end
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(1, true)
                assert.equals(expected, actual)
            end)

        it("should return no message when there are no messages with the exact size",
            function()
                local queue = MessageQueue:New()
                for i = 1, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(1)
                assert.is_nil(actual)
            end)
    end)
end)
