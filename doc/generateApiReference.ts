// SPDX-FileCopyrightText: 2025 sirinsidiator
//
// SPDX-License-Identifier: Artistic-2.0

import fs = require("fs");
import path = require("path");
import { exec } from "child_process";

const HOME_PATH = process.env["USERPROFILE"];
const VSCODE_EXTENSIONS_PATH = path.join(HOME_PATH, ".vscode", "extensions");
const extensions = fs.readdirSync(VSCODE_EXTENSIONS_PATH).filter((ext) => ext.startsWith("sumneko.lua")).map(ext => {
    const matches = RegExp(/sumneko\.lua-(\d+)\.(\d+)\.(\d+)-win32-x64/).exec(ext);
    if (!matches) {
        return null;
    }
    const [major, minor, patch] = matches.slice(1).map(Number);
    return { major, minor, patch, ext };
}).filter(ext => ext !== null).sort((a, b) => {
    if (a.major !== b.major) {
        return b.major - a.major;
    } else if (a.minor !== b.minor) {
        return b.minor - a.minor;
    } else {
        return b.patch - a.patch;
    }
}).map(ext => ext.ext);

const LS_SERVER_PATH = path.join(VSCODE_EXTENSIONS_PATH, extensions[0], "server", "bin", "lua-language-server.exe");
const PROJECT_PATH = path.resolve(process.cwd(), "./src");
const OUTPUT_PATH = path.resolve(process.cwd(), "./doc");
const PROJECT_URI = toFileUri(PROJECT_PATH);

function toFileUri(filePath: string) {
    filePath = filePath.replace(/^(\w:)/, (_, letter) => letter.toLowerCase());
    let uri = new URL(`file://${filePath}`).href + "/";
    return uri.replace(/file:\/\/\/(\w):/g, "file:///$1%3A");
}

const cmd = `${LS_SERVER_PATH} --doc=${PROJECT_PATH} --doc_out_path=${OUTPUT_PATH} --logpath=${OUTPUT_PATH}`;
console.log(cmd);

exec(cmd, (error, stdout, stderr) => {
    if (error) {
        console.error(error);
        return;
    }

    const jsonFile = path.join(OUTPUT_PATH, "doc.json");
    const content = fs.readFileSync(jsonFile, "utf-8");
    const data = JSON.parse(content);

    const output = [];
    const relevantEntries = getSortedRelevantEntries(data);
    const options = new Map<string, RelevantEntry>();
    relevantEntries.filter(entry => entry.docType === "options").forEach((entry) => {
        options.set(entry.name, entry);
    });
    function findOption(field: DocEntryFields) {
        if (field.extends.args) {
            for (const arg of field.extends.args) {
                const type = arg.view.replace("?", "");
                const option = options.get(type);
                if (option) {
                    options.delete(type);
                    return option;
                }
            }
        }
        return null;
    }

    relevantEntries.filter(entry => entry.docType !== "options").forEach((entry) => {
        output.push(`[SIZE="3"]${entry.name}[/SIZE]`);
        entry.fields.forEach(field => {
            output.push("[INDENT]");
            output.push(`    [SIZE="2"]${field.name}[/SIZE]`);
            output.push("    [INDENT]");
            if (field.extends?.view) {
                output.push('        [highlight="Lua"]');
                output.push(field.extends.view);
                output.push("        [/highlight]");
            }
            if (field.desc) {
                output.push(convertDescriptionToBBCode(field.desc));
            }
            const option = findOption(field);
            if (option) {
                output.push(convertOptionToBBCode(option));
            }
            output.push("    [/INDENT]");
            output.push("[/INDENT]");
            output.push("");
        });
        output.push("");
    });

    const outPathTxt = path.join(OUTPUT_PATH, "api_reference.txt");
    fs.writeFileSync(outPathTxt, output.join("\n"));
});

const PREFIX = path.basename(path.resolve(process.cwd())) + "/src/";
const ALLOWED_FILE_LIST = [
    "PublicApi.lua",
    "Handler.lua",
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
    "StartUp.lua",
];

const ALLOWED_FILES = {};
ALLOWED_FILE_LIST.forEach((file, index) => {
    ALLOWED_FILES[file] = index + 1;
});

function isAllowedFile(entryFile: string) {
    if (!entryFile) {
        return false;
    }
    return !!ALLOWED_FILES[entryFile];
}

function getOrder(file: string) {
    return ALLOWED_FILES[file] ?? 1;
}

function setDocType<T extends (DocEntryDefines | DocEntryFields)>(entry: T): T {
    entry.docType = "default";
    if (entry.desc) {
        if (entry.desc.startsWith(" @docType hidden")) {
            entry.docType = "hidden";
        } else if (entry.desc.startsWith(" @docType options")) {
            entry.docType = "options";
        }
    }
    return entry;
}

function isPublic(entry: DocEntryDefines | DocEntryFields) {
    return entry.visible === 'public';
}

function getSortedRelevantEntries(entries: DocEntry[]) {
    const relevantEntriesBySymbol = new Map<string, RelevantEntry>();
    function getOrCreateEntry(name: string, file: string, docType: string) {
        file = file.slice(file.indexOf(PREFIX) + PREFIX.length);
        if (!relevantEntriesBySymbol.has(name)) {
            relevantEntriesBySymbol.set(name, {
                fields: [],
                name,
                docType,
                order: getOrder(file),
            });
        }
        return relevantEntriesBySymbol.get(name);
    }

    getOrCreateEntry("LibGroupBroadcast", "", "default");
    entries.forEach((entry) => {
        entry.defines.filter(isPublic).map(setDocType)
            .filter((define) => isAllowedFile(define.file))
            .forEach(define => getOrCreateEntry(entry.name, define.file, define.docType))
        entry.fields?.filter(isPublic).map(setDocType).filter((field) => isAllowedFile(field.file)).forEach(field => {
            const relevantEntry = getOrCreateEntry(entry.name, field.file, field.docType);
            relevantEntry.fields.push(field);
        });
    });

    return Array.from(relevantEntriesBySymbol.values())
        .filter(entry => entry.docType !== "hidden")
        .sort((a, b) => {
            return a.order - b.order;
        })
        .map((entry) => {
            entry.fields.sort((a, b) => {
                if (a.file !== b.file) {
                    const orderA = ALLOWED_FILES[a.file.slice(a.file.indexOf(PREFIX) + PREFIX.length)] ?? 1;
                    const orderB = ALLOWED_FILES[b.file.slice(b.file.indexOf(PREFIX) + PREFIX.length)] ?? 1;
                    return orderA - orderB;
                }
                return a.start[0] - b.start[0];
            });
            return entry;
        });
}

function convertDescriptionToBBCode(desc: string) {
    desc = desc.replace(
        /@\*(.*?)\* `(.+)` (.+)\n\n/g,
        "[I]@$1[/I] [B]$2[/B] $3\n"
    );
    desc = desc.replace(/@\*(.*?)\* `(.+)` (.+)/g, "[I]@$1[/I] [B]$2[/B] $3");

    if (desc.includes("See:")) {
        let parts = desc.split("See:");
        let output = [parts[0]];
        output.push("See:");
        output.push("[LIST]");
        parts[1].split("\n").forEach((reference) => {
            reference = reference.trim();
            reference = reference.replace(/^\*\s*/, "");
            reference = replaceUrls(reference);
            output.push(`    [*]${reference}`);
        });
        output.push("[/LIST]");
        desc = output.join("\n");
    }

    return desc;
}

function convertOptionToBBCode(option: RelevantEntry) {
    let output = [];
    output.push("\nOptions:");
    output.push("[LIST]");
    option.fields.forEach((field) => {
        const type = field.extends.view.replace("?", "");
        output.push(`    [*][B]${field.name}[/B] - [I]${type}[/I] - ${field.desc}`);
    });
    output.push("[/LIST]");
    return output.join("\n");
}

const URL_REPLACEMENTS = new Map<string, string>();
URL_REPLACEMENTS.set(
    PROJECT_URI,
    "https://github.com/sirinsidiator/ESO-LibGroupBroadcast/blob/main/src/"
);

const ESO_SOURCE_LINKS = new Map<string, string>();

function replaceUrls(markdown: string) {
    let matches = markdown.match(/\[(.*)\]\((.*)\)/);
    if (matches) {
        let url = matches[2];
        URL_REPLACEMENTS.forEach((value, key) => {
            if (url.startsWith(key)) {
                url = url.replace(key, value);
                url = url.replace(/#(\d+)#\d+$/, "#L$1");
            }
        });
        return `[URL='${url}']${matches[1]}[/URL]`;
    } else {
        matches = markdown.match(/~(.*)~/);
        if (matches) {
            let label = matches[1];
            if (ESO_SOURCE_LINKS.has(label)) {
                return `[URL='${ESO_SOURCE_LINKS.get(label)}']${label}[/URL]`;
            }
        }
        return markdown;
    }
}

interface DocEntry {
    defines: DocEntryDefines[];
    fields: DocEntryFields[];
    name: string;
    type: string;
}

interface RelevantEntry {
    name: string;
    order: number;
    docType: string;
    fields: DocEntryFields[];
}

interface DocEntryFields {
    desc?: string;
    name: string;
    type: string;
    extends: DocEntryExtends;
    file: string;
    start: [number, number];
    visible: string;
    docType?: string;
}

interface DocEntryDefines {
    extends: DocEntryExtends;
    file: string;
    finish: number;
    start: number;
    type: string;
    view: string;
    desc?: string;
    visible: string;
    docType?: string;
}

interface DocEntryExtends {
    finish: number;
    start: number;
    type: string;
    view: string;
    args?: DocEntryExtendsArgs[];
}

interface DocEntryExtendsArgs {
    name: string;
    view: string;
}
