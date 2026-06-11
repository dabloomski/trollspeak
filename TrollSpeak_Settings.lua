local PREFIX = "|cffff9900TrollSpeak:|r "

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
    if not TrollSpeakDB.autoChannels then
        TrollSpeakDB.autoChannels = {
            say     = false,
            yell    = false,
            emote   = false,
            party   = false,
            guild   = false,
            raid    = false,
            whisper = false,
        }
    end
    -- Backfill channels added after initial release
    local backfill = { "yell", "emote", "party", "raid" }
    for _, ch in ipairs(backfill) do
        if TrollSpeakDB.autoChannels[ch] == nil then
            TrollSpeakDB.autoChannels[ch] = false
        end
    end
    if TrollSpeakDB.masterEnabled == nil then
        TrollSpeakDB.masterEnabled = true
    end
    if not TrollSpeakDB.customPhrases then
        TrollSpeakDB.customPhrases = {}
    end
    if not TrollSpeakDB.customStarters then
        TrollSpeakDB.customStarters = {}
    end
    if not TrollSpeakDB.customEndings then
        TrollSpeakDB.customEndings = {}
    end
    if not TrollSpeakDB.minimap then
        TrollSpeakDB.minimap = {}
    end
end

function TrollSpeak_GetCustomPhrase(lowerTrimmed)
    if not TrollSpeakDB or not TrollSpeakDB.customPhrases then return nil end
    return TrollSpeakDB.customPhrases[lowerTrimmed]
end

function TrollSpeak_HandleConfig(args)
    local sub, value = args:match("^(%S+)%s+(%d+)$")
    if not sub then
        print(PREFIX .. "Usage: /troll config starter <0-100> or /troll config ending <0-100>")
        return
    end
    local num = tonumber(value)
    if not num or num < 0 or num > 100 then
        print(PREFIX .. "Value must be between 0 and 100.")
        return
    end
    sub = sub:lower()
    if sub == "starter" then
        TrollSpeakDB.starterChance = num
        print(PREFIX .. "Starter chance set to " .. num .. "%.")
    elseif sub == "ending" then
        TrollSpeakDB.endingChance = num
        print(PREFIX .. "Ending chance set to " .. num .. "%.")
    else
        print(PREFIX .. "Unknown config option '" .. sub .. "'. Use starter or ending.")
    end
end

function TrollSpeak_HandleAddPhrase(args)
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
    TrollSpeakDB.customPhrases[original] = translation
    print(PREFIX .. "Added: \"" .. original .. "\" -> \"" .. translation .. "\"")
end

function TrollSpeak_HandleRemovePhrase(args)
    local original = args:lower():match("^%s*(.-)%s*$")
    if original == "" then
        print(PREFIX .. "Usage: /troll remove <original>")
        return
    end
    if TrollSpeakDB.customPhrases[original] then
        TrollSpeakDB.customPhrases[original] = nil
        print(PREFIX .. "Removed phrase: \"" .. original .. "\"")
    else
        print(PREFIX .. "No custom phrase found for: \"" .. original .. "\"")
    end
end

function TrollSpeak_HandleListPhrases()
    print(PREFIX .. "Custom phrases:")
    local count = 0
    for orig, trans in pairs(TrollSpeakDB.customPhrases) do
        print(PREFIX .. "  \"" .. orig .. "\" -> \"" .. trans .. "\"")
        count = count + 1
    end
    if count == 0 then
        print(PREFIX .. "  (none)")
    end
end

function TrollSpeak_AddStarter(text)
    text = text:match("^%s*(.-)%s*$")
    if text == "" then return false, "Starter cannot be empty." end
    TrollSpeakDB.customStarters[#TrollSpeakDB.customStarters + 1] = text
    return true
end

function TrollSpeak_RemoveStarter(index)
    table.remove(TrollSpeakDB.customStarters, index)
end

function TrollSpeak_AddEnding(text)
    text = text:match("^%s*(.-)%s*$")
    if text == "" then return false, "Ending cannot be empty." end
    TrollSpeakDB.customEndings[#TrollSpeakDB.customEndings + 1] = text
    return true
end

function TrollSpeak_RemoveEnding(index)
    table.remove(TrollSpeakDB.customEndings, index)
end
