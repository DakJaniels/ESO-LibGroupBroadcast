local LGS = LibStub("LibGroupSocket")
local LuaUnit = require('luaunit')
local assertEquals = LuaUnit.assertEquals
local assertTrue = LuaUnit.assertTrue
local assertAlmostEquals = LuaUnit.assertAlmostEquals
local stepCount = 70000
local stepSize = 1/stepCount
local margin = stepSize / 2

TestLibGroupSocket = {}

function TestLibGroupSocket:CreateTestCases(prefix, testCases, testFunction)
	for i = 1, #testCases do
		local test = testCases[i]
		self[string.format("test%s%s%d", prefix, i < 10 and "0" or "", i)] = function()
			testFunction(test.input, test.output)
		end
	end
end

do
	local testCases = {
		{input = {0x00}, output = {false, false, false, false, false, false, false, false}},
		{input = {0xff}, output = {true, true, true, true, true, true, true, true}},
		{input = {0x55}, output = {true, false, true, false, true, false, true, false}},
		{input = {0xaa}, output = {false, true, false, true, false, true, false, true}},
		{input = {0x0f}, output = {true, true, true, true, false, false, false, false}},
		{input = {0xf0}, output = {false, false, false, false, true, true, true, true}},
		{input = {0x01}, output = {true, false, false, false, false, false, false, false}},
		{input = {0x80}, output = {false, false, false, false, false, false, false, true}},
	}
	TestLibGroupSocket:CreateTestCases("ReadBit", testCases, function(input, expected)
		local index, bitIndex, actual = 1, 1
		while index == 1 do
			local expectedState = expected[bitIndex]
			actual, index, bitIndex = LGS:ReadBit(input, index, bitIndex)
			assertTrue(bitIndex > 0 and bitIndex < 9)
			assertEquals(actual, expectedState)
		end
		assertEquals(index, 2)
		assertEquals(bitIndex, 1)
	end)
end

do
	local testCases = {
		{input = {false, false, false, false, false, false, false, false}, output = {0x00}},
		{input = {true, true, true, true, true, true, true, true}, output = {0xff}},
		{input = {true, false, true, false, true, false, true, false}, output = {0x55}},
		{input = {false, true, false, true, false, true, false, true}, output = {0xaa}},
		{input = {true, true, true, true, false, false, false, false}, output = {0x0f}},
		{input = {false, false, false, false, true, true, true, true}, output = {0xf0}},
		{input = {true, false, false, false, false, false, false, false}, output = {0x01}},
		{input = {false, false, false, false, false, false, false, true}, output = {0x80}},
		{input = {false, false, false, false, false, false, false, true, true}, output = {0x80, 0x01}},
	}
	TestLibGroupSocket:CreateTestCases("WriteBit", testCases, function(input, expected)
		local index, bitIndex = 1, 1
		local data = {}
		for _, value in ipairs(input) do
			index, bitIndex = LGS:WriteBit(data, index, bitIndex, value)
			assertTrue(bitIndex > 0 and bitIndex < 9)
		end
		assertEquals(index, 2)
		assertEquals(bitIndex, #input % 8 + 1)
		assertEquals(data, expected)
	end)
end

do
	local testCases = {
		{input = {("a"):byte()}, output = {"a"}},
		{input = {0x00}, output = {string.char(0x00)}},
		{input = {0xff}, output = {string.char(0xff)}},
		{input = {("a"):byte(), ("b"):byte(), ("c"):byte()}, output = {"a", "b", "c"}},
	}
	TestLibGroupSocket:CreateTestCases("ReadChar", testCases, function(input, expected)
		local index, actual = 1
		while index <= #input do
			local expectedState = expected[index]
			actual, index = LGS:ReadChar(input, index)
			assertEquals(actual, expectedState)
		end
		assertEquals(index, #input + 1)
	end)
end

do
	local testCases = {
		{input = {"a"}, output = {("a"):byte()}},
		{input = {string.char(0x00)}, output = {0x00}},
		{input = {string.char(0xff)}, output = {0xff}},
		{input = {"a", "b", "c"}, output = {("a"):byte(), ("b"):byte(), ("c"):byte()}},
	}
	TestLibGroupSocket:CreateTestCases("WriteChar", testCases, function(input, expected)
		local index = 1
		local data = {}
		for _, value in ipairs(input) do
			index = LGS:WriteChar(data, index, value)
		end
		assertEquals(index, #expected + 1)
		assertEquals(data, expected)
	end)
end

do
	local testCases = {
		{input = {0x00}, output = {0x00}},
		{input = {0xff}, output = {0xff}},
		{input = {0x01, 0x02}, output = {0x01, 0x02}},
	}
	TestLibGroupSocket:CreateTestCases("ReadUint8", testCases, function(input, expected)
		local index, actual = 1
		while index <= #input do
			local expectedState = expected[index]
			actual, index = LGS:ReadUint8(input, index)
			assertEquals(actual, expectedState)
		end
		assertEquals(index, #input + 1)
	end)
end

do
	local testCases = {
		{input = {0x00}, output = {0x00}},
		{input = {0xff}, output = {0xff}},
		{input = {0x01, 0x02}, output = {0x01, 0x02}},
		{input = {20.5}, output = {20}},
		{input = {-20.5}, output = {0}},
		{input = {2000}, output = {255}},
	}
	TestLibGroupSocket:CreateTestCases("WriteUint8", testCases, function(input, expected)
		local index = 1
		local data = {}
		for _, value in ipairs(input) do
			index = LGS:WriteUint8(data, index, value)
		end
		assertEquals(index, #expected + 1)
		assertEquals(data, expected)
	end)
end

do
	local testCases = {
		{input = {0x00, 0x00}, output = {0x0000}},
		{input = {0xff, 0xff}, output = {0xffff}},
		{input = {0x01, 0x02}, output = {0x0102}},
		{input = {0x00, 0x00, 0x00, 0x00}, output = {0x0000, 0x0000}},
		{input = {0xff, 0xff, 0xff, 0xff}, output = {0xffff, 0xffff}},
		{input = {0x01, 0x02, 0x03, 0x04}, output = {0x0102, 0x0304}},
	}
	TestLibGroupSocket:CreateTestCases("ReadUint16", testCases, function(input, expected)
		local index, actual = 1
		while index <= #input do
			local expectedState = expected[(index + 1) / 2]
			actual, index = LGS:ReadUint16(input, index)
			assertEquals(actual, expectedState)
		end
		assertEquals(index, #input + 1)
	end)
end

do
	local testCases = {
		{input = {0x0000}, output = {0x00, 0x00}},
		{input = {0xffff}, output = {0xff, 0xff}},
		{input = {0x0102}, output = {0x01, 0x02}},
		{input = {0x0000, 0x0000}, output = {0x00, 0x00, 0x00, 0x00}},
		{input = {0xffff, 0xffff}, output = {0xff, 0xff, 0xff, 0xff}},
		{input = {0x0102, 0x0304}, output = {0x01, 0x02, 0x03, 0x04}},
		{input = {20.5}, output = {0, 20}},
		{input = {-20.5}, output = {0, 0}},
		{input = {0xfffff}, output = {0xff, 0xff}},
	}
	TestLibGroupSocket:CreateTestCases("WriteUint16", testCases, function(input, expected)
		local index = 1
		local data = {}
		for _, value in ipairs(input) do
			index = LGS:WriteUint16(data, index, value)
		end
		assertEquals(index, #expected + 1)
		assertEquals(data, expected)
	end)
end

do
	local testCases = {
		{input = {0, 0, 0, 0}, output = {0, 0}},
		{input = {1, 2, 3, 4}, output = {0x0102/stepCount, 0x0304/stepCount}},
		{input = {nil, nil, nil, nil}, output = {0x0000/stepCount, 0x0000/stepCount}},
		{input = {255, 255, 255, 255}, output = {0xffff/stepCount, 0xffff/stepCount}},
	}
	TestLibGroupSocket:CreateTestCases("EncodeData", testCases, function(input, expected)
		local a1, a2 = LGS:EncodeData(unpack(input))
		local e1, e2 = unpack(expected)
		assertAlmostEquals(a1, e1, margin)
		assertAlmostEquals(a2, e2, margin)
	end)
end

do
	local testCases = {
		{input = {0x0000/stepCount, 0x0000/stepCount}, output = {0, 0, 0, 0}},
		{input = {0x8000/stepCount, 0x0000/stepCount}, output = {128, 0, 0, 0}},
		{input = {0x0001/stepCount, 0x0000/stepCount}, output = {0, 1, 0, 0}},
		{input = {0x0000/stepCount, 0x8000/stepCount}, output = {0, 0, 128, 0}},
		{input = {0x0000/stepCount, 0x0001/stepCount}, output = {0, 0, 0, 1}},
		{input = {0x0102/stepCount, 0x0304/stepCount}, output = {1, 2, 3, 4}},
		{input = {0xffff/stepCount, 0xffff/stepCount}, output = {255, 255, 255, 255}},
	}
	TestLibGroupSocket:CreateTestCases("DecodeData", testCases, function(input, expected)
		local actual = {LGS:DecodeData(unpack(input))}
		assertEquals(actual, expected)
	end)
end

do
	local testCases = {
		{input = {0, 0}, output = 0x00},
		{input = {31, 7}, output = 0xff},
		{input = {31, 0}, output = 0xf8},
		{input = {0, 7}, output = 0x07},
		{input = {1, 1}, output = 0x09},
		{input = {2, 1}, output = 0x11},
	}
	TestLibGroupSocket:CreateTestCases("EncodeHeader", testCases, function(input, expected)
		local actual = LGS:EncodeHeader(unpack(input))
		assertEquals(actual, expected)
	end)
end

do
	local testCases = {
		{input = 0x00, output = {0, 0}},
		{input = 0xff, output = {31, 7}},
		{input = 0xf8, output = {31, 0}},
		{input = 0x07, output = {0, 7}},
		{input = 0x09, output = {1, 1}},
		{input = 0x11, output = {2, 1}},
	}
	TestLibGroupSocket:CreateTestCases("DecodeHeader", testCases, function(input, expected)
		local actual = {LGS:DecodeHeader(input)}
		assertEquals(actual, expected)
	end)
end