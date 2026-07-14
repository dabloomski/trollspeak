local PREFIX = "|cffff9900TrollSpeak:|r "

-- Pre-dialect saves stored these as flat tables/arrays. Wrap them under "troll"
-- so existing custom content survives the upgrade; "dwarf" starts empty.
local function MigrateDialectTable(t)
    if type(t) == "table" and type(t.troll) == "table" and type(t.dwarf) == "table" then
        return t
    end
    return { troll = t or {}, dwarf = {} }
end

function TrollSpeak_InitDB()
    if not TrollSpeakDB then
        TrollSpeakDB = {}
    end
    if TrollSpeakDB.starterChance == nil then
        TrollSpeakDB.starterChance = 15
    end
    if TrollSpeakDB.endingChance == nil then
        TrollSpeakDB.endingChance = 40
    end
    TrollSpeakDB.customPhrases  = MigrateDialectTable(TrollSpeakDB.customPhrases)
    TrollSpeakDB.customStarters = MigrateDialectTable(TrollSpeakDB.customStarters)
    TrollSpeakDB.customEndings  = MigrateDialectTable(TrollSpeakDB.customEndings)
    if not TrollSpeakDB.minimap then
        TrollSpeakDB.minimap = {}
    end
end

-- Dialect, on/off, and channel toggles are per-character (TrollSpeakCharDB).
-- The first character to log in after this split inherits whatever the old
-- account-wide values were; every other character starts from defaults.
function TrollSpeak_InitCharDB()
    local firstInit = not TrollSpeakCharDB
    if firstInit then
        TrollSpeakCharDB = {
            activeDialect = TrollSpeakDB and TrollSpeakDB.activeDialect,
            masterEnabled = TrollSpeakDB and TrollSpeakDB.masterEnabled,
            autoChannels  = TrollSpeakDB and TrollSpeakDB.autoChannels,
        }
        if TrollSpeakDB then
            TrollSpeakDB.activeDialect = nil
            TrollSpeakDB.masterEnabled = nil
            TrollSpeakDB.autoChannels  = nil
        end
    end

    if not TrollSpeakCharDB.activeDialect then
        TrollSpeakCharDB.activeDialect = "troll"
    end
    if TrollSpeakCharDB.masterEnabled == nil then
        TrollSpeakCharDB.masterEnabled = true
    end
    if not TrollSpeakCharDB.autoChannels then
        TrollSpeakCharDB.autoChannels = {
            say     = false,
            yell    = false,
            emote   = false,
            party   = false,
            guild   = false,
            raid    = false,
            whisper = false,
        }
    end
    local channels = { "say", "yell", "emote", "party", "guild", "raid", "whisper" }
    for _, ch in ipairs(channels) do
        if TrollSpeakCharDB.autoChannels[ch] == nil then
            TrollSpeakCharDB.autoChannels[ch] = false
        end
    end
end

local function ActiveDialect(dialectKey)
    return dialectKey or (TrollSpeakCharDB and TrollSpeakCharDB.activeDialect) or "troll"
end

function TrollSpeak_GetCustomPhrase(lowerTrimmed, dialectKey)
    if not TrollSpeakDB or not TrollSpeakDB.customPhrases then return nil end
    local bucket = TrollSpeakDB.customPhrases[ActiveDialect(dialectKey)]
    return bucket and bucket[lowerTrimmed]
end

function TrollSpeak_HandleConfig(args)
    local sub, value = args:match("^(%S+)%s+(.+)$")
    if not sub then
        print(PREFIX .. "Usage: /troll config starter <0-100> | ending <0-100> | dialect <troll|dwarf>")
        return
    end
    sub = sub:lower()

    if sub == "dialect" then
        local key = value:lower():match("^%s*(.-)%s*$")
        if TrollSpeakDialects and TrollSpeakDialects[key] then
            TrollSpeakCharDB.activeDialect = key
            print(PREFIX .. "Auto-translate dialect set to " .. key .. ".")
        else
            print(PREFIX .. "Unknown dialect '" .. key .. "'. Valid: troll, dwarf.")
        end
        return
    end

    local num = tonumber(value)
    if not num or num < 0 or num > 100 then
        print(PREFIX .. "Value must be between 0 and 100.")
        return
    end
    if sub == "starter" then
        TrollSpeakDB.starterChance = num
        print(PREFIX .. "Starter chance set to " .. num .. "%.")
    elseif sub == "ending" then
        TrollSpeakDB.endingChance = num
        print(PREFIX .. "Ending chance set to " .. num .. "%.")
    else
        print(PREFIX .. "Unknown config option '" .. sub .. "'. Use starter, ending, or dialect.")
    end
end

function TrollSpeak_HandleAddPhrase(args, dialectKey)
    local sep = args:find("|")
    if not sep then
        print(PREFIX .. "Usage: /troll add <original>|<translation>")
        return
    end
    local original    = args:sub(1, sep - 1)
    local translation = args:sub(sep + 1):gsub("^|", "")  -- strip WoW's || escaping
    original    = original:lower():match("^%s*(.-)%s*$")
    translation = translation:match("^%s*(.-)%s*$")
    if original == "" or translation == "" then
        print(PREFIX .. "Original and translation cannot be empty.")
        return
    end
    TrollSpeakDB.customPhrases[ActiveDialect(dialectKey)][original] = translation
    print(PREFIX .. "Added: \"" .. original .. "\" -> \"" .. translation .. "\"")
end

function TrollSpeak_HandleRemovePhrase(args, dialectKey)
    local original = args:lower():match("^%s*(.-)%s*$")
    if original == "" then
        print(PREFIX .. "Usage: /troll remove <original>")
        return
    end
    local bucket = TrollSpeakDB.customPhrases[ActiveDialect(dialectKey)]
    if bucket[original] then
        bucket[original] = nil
        print(PREFIX .. "Removed phrase: \"" .. original .. "\"")
    else
        print(PREFIX .. "No custom phrase found for: \"" .. original .. "\"")
    end
end

function TrollSpeak_HandleListPhrases(dialectKey)
    dialectKey = ActiveDialect(dialectKey)
    print(PREFIX .. "Custom phrases (" .. dialectKey .. "):")
    local count = 0
    for orig, trans in pairs(TrollSpeakDB.customPhrases[dialectKey]) do
        print(PREFIX .. "  \"" .. orig .. "\" -> \"" .. trans .. "\"")
        count = count + 1
    end
    if count == 0 then
        print(PREFIX .. "  (none)")
    end
end

function TrollSpeak_AddStarter(text, dialectKey)
    text = text:match("^%s*(.-)%s*$")
    if text == "" then return false, "Starter cannot be empty." end
    local list = TrollSpeakDB.customStarters[ActiveDialect(dialectKey)]
    list[#list + 1] = text
    return true
end

function TrollSpeak_RemoveStarter(index, dialectKey)
    table.remove(TrollSpeakDB.customStarters[ActiveDialect(dialectKey)], index)
end

function TrollSpeak_AddEnding(text, dialectKey)
    text = text:match("^%s*(.-)%s*$")
    if text == "" then return false, "Ending cannot be empty." end
    local list = TrollSpeakDB.customEndings[ActiveDialect(dialectKey)]
    list[#list + 1] = text
    return true
end

function TrollSpeak_RemoveEnding(index, dialectKey)
    table.remove(TrollSpeakDB.customEndings[ActiveDialect(dialectKey)], index)
end
