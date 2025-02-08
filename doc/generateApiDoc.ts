// SPDX-FileCopyrightText: 2025 sirinsidiator
//
// SPDX-License-Identifier: Artistic-2.0

const SOURCE_PATH = "./src";
const OUTPUT_FILE = "./doc/LibGroupBroadcast.doc.lua";
const INCLUDED_FILES = new Set([
    "PublicApi.lua",
    "protocol/FieldBase.lua",
    "protocol/Protocol.lua",
    "protocol/NumericField.lua",
    "protocol/FlagField.lua",
    "protocol/OptionalField.lua",
    "protocol/ArrayField.lua",
    "protocol/TableField.lua",
    "protocol/VariantField.lua",
    "protocol/EnumField.lua",
    "protocol/PercentageField.lua",
    "protocol/StringField.lua",
    "protocol/ReservedField.lua",
    "BinaryBuffer.lua",
    "GameApiWrapper.lua",
    "test/MockGameApiWrapper.lua",
    "MessageQueue.lua",
    "HandlerManager.lua",
    "ProtocolManager.lua",
    "BroadcastManager.lua",
    "StartUp.lua",
]);

import fs = require("fs");
import path = require("path");

const output = [
    `-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @meta LibGroupBroadcast

--- @class LibGroupBroadcast
local LibGroupBroadcast = {}`,
];
INCLUDED_FILES.forEach((file) => {
    const filePath = path.join(SOURCE_PATH, file);
    const content = fs.readFileSync(filePath, "utf8");
    const lines = content.split("\n");

    let isRelevantPart = false;
    let inFunction = false;
    lines.forEach((line) => {
        if (!isRelevantPart) {
            if (line.startsWith('--[[ doc.lua begin ]]--')) {
                isRelevantPart = true;
            }
            return;
        } else if (line.startsWith('--[[ doc.lua end ]]--')) {
            isRelevantPart = false;
        } else if (line.startsWith('--- @docType') || line.startsWith('LGB.internal')) {
            return;
        } else if (inFunction) {
            if (line.startsWith("end")) {
                inFunction = false;
            }
        } else {
            if (line.startsWith("LGB.")) {
                line = line.replace("LGB.", "LibGroupBroadcast.");
            } else if (line.startsWith("internal:Initialize()")) {
                return;
            } else if (line.startsWith("function")) {
                inFunction = true;
                line = line.replace("LGB:", "LibGroupBroadcast:");
                line = line.replace("LGB.", "LibGroupBroadcast.");
                line = line.trim();
                if (!line.endsWith("end")) {
                    line = line + " end";
                }
                output.push(line);
                return;
            } else if (line.startsWith("local function")) {
                inFunction = true;
                return;
            }

            if (line.trim() === "" || !line.startsWith("    ")) {
                output.push(line);
            }
        }
    });
});

fs.writeFileSync(OUTPUT_FILE, output.join("\n"));
