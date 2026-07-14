local PREFIX         = "|cffff9900TrollSpeak:|r "
local ADDON_VERSION  = "1.4"

local starters = {
    "Ya mon, ",
    "Ahh, ",
    "Now listen mon, ",
    "Hmm, ",
    "Ey mon, ",
    "Listen up, ",
    "By da Loa, ",
    "Well den, ",
    "Hm mon, ",
}

local endingsNeutral = {
    ", mon.",
    ", ya know?",
    ". De spirits be watchin'.",
    ", brudda.",
    ". Da Loa be pleased.",
}

local endingsQuestion = {
    ", mon?",
    ", ya know what I sayin'?",
    ", brudda?",
    " Da Loa know da answer, mon?",
}

local endingsExclaim = {
    ", mon!",
    ", ya hear me!",
    " Da Loa be watchin'!",
    ", brudda!",
}

TrollSpeakDialects = TrollSpeakDialects or {}
TrollSpeakDialects["troll"] = {
    label           = "Troll",
    words           = TrollSpeakWords,
    rules           = TrollSpeakRules,
    getPhrase       = TrollSpeak_GetPhrase,
    phrases         = TrollSpeakPhrases,  -- raw tables, for UI introspection (e.g. phrase reference tab)
    pools           = TrollSpeakPools,
    fillers         = TrollSpeakFillers,
    starters        = starters,
    endingsNeutral  = endingsNeutral,
    endingsQuestion = endingsQuestion,
    endingsExclaim  = endingsExclaim,
}

function TrollSpeak_Translate(text, dialectKey)
    if not text or text == "" then return text end

    dialectKey = dialectKey or (TrollSpeakCharDB and TrollSpeakCharDB.activeDialect) or "troll"
    local dialect = TrollSpeakDialects[dialectKey] or TrollSpeakDialects["troll"]

    -- Extract WoW hyperlinks before any processing.
    -- text:lower() corrupts |H (required uppercase) into |h, breaking the link.
    -- We stash each link, replace it with a sentinel placeholder, and restore after.
    local S = "\001"  -- SOH control char; cannot be typed into WoW chat
    local links = {}
    local workText = text:gsub("|c%x+|H.-|h%[.-%]|h|r", function(link)
        links[#links + 1] = link
        return S .. #links .. S
    end)

    -- Check all-caps on the link-stripped text (links contain lowercase hex that
    -- would otherwise defeat the all-caps detection).
    local hasAlpha    = workText:match("%a") ~= nil
    local allCaps     = hasAlpha and (workText == workText:upper())
    local origCapital = hasAlpha and workText:match("^%s*%u") ~= nil

    workText      = workText:lower()
    local trimmed = workText:match("^%s*(.-)%s*$")

    local function applyCaps(s)
        if allCaps     then return s:upper() end
        if origCapital then return s:sub(1,1):upper() .. s:sub(2) end
        return s
    end

    -- Custom phrases (highest priority, returned as-is)
    local result = TrollSpeak_GetCustomPhrase(trimmed, dialectKey)
    if result then return applyCaps(result) end

    -- Built-in phrases (returned as-is, no starters/endings)
    result = dialect.getPhrase(trimmed)
    if result then return applyCaps(result) end

    -- Word lists then rules
    workText = dialect.words.Apply(workText)
    workText = dialect.rules.Apply(workText)

    -- Detect and strip trailing smiley so it always ends up after any added ending
    local smiley = ""
    workText = workText:gsub("%s*([:;=xX8%-][%-o]?[%)D%(Pp/\\|3oO]%s*)$", function(s)
        smiley = " " .. s:match("^%s*(.-)%s*$")
        return ""
    end)

    -- Detect and strip trailing punctuation
    local lastChar      = workText:sub(-1)
    local endingPool    = dialect.endingsNeutral
    local trailingPunct = ""

    if lastChar == "?" then
        endingPool    = dialect.endingsQuestion
        trailingPunct = "?"
        workText      = workText:sub(1, -2)
    elseif lastChar == "!" then
        endingPool    = dialect.endingsExclaim
        trailingPunct = "!"
        workText      = workText:sub(1, -2)
    elseif lastChar == "." then
        trailingPunct = "."
        workText      = workText:sub(1, -2)
    end

    -- Merge custom starters and endings into the built-in pools
    local allStarters = {}
    for _, v in ipairs(dialect.starters) do allStarters[#allStarters + 1] = v end
    local customStarters = TrollSpeakDB and TrollSpeakDB.customStarters and TrollSpeakDB.customStarters[dialectKey]
    if customStarters then
        for _, v in ipairs(customStarters) do allStarters[#allStarters + 1] = v end
    end

    local allEndingPool = {}
    for _, v in ipairs(endingPool) do allEndingPool[#allEndingPool + 1] = v end
    local customEndings = TrollSpeakDB and TrollSpeakDB.customEndings and TrollSpeakDB.customEndings[dialectKey]
    if customEndings then
        for _, v in ipairs(customEndings) do
            local last = v:sub(-1)
            local matchesPool = (last == "?" and endingPool == dialect.endingsQuestion)
                             or (last == "!" and endingPool == dialect.endingsExclaim)
                             or (last ~= "?" and last ~= "!" and endingPool == dialect.endingsNeutral)
            if matchesPool then
                allEndingPool[#allEndingPool + 1] = v
            end
        end
    end

    local starterChance = TrollSpeakDB and TrollSpeakDB.starterChance or 15
    local endingChance  = TrollSpeakDB and TrollSpeakDB.endingChance  or 40
    local roll = math.random(100)

    if roll <= starterChance then
        local starter = allStarters[math.random(#allStarters)]
        workText = starter .. workText:sub(1, 1):lower() .. workText:sub(2) .. trailingPunct .. smiley
    elseif roll <= starterChance + endingChance then
        local ending = allEndingPool[math.random(#allEndingPool)]
        workText = workText .. ending .. smiley
    else
        workText = workText .. trailingPunct .. smiley
    end

    -- Apply capitalisation before restoring links so links stay in original case.
    workText = applyCaps(workText)

    -- Restore links
    if #links > 0 then
        workText = workText:gsub(S .. "(%d+)" .. S, function(idx)
            return links[tonumber(idx)]
        end)
    end

    return workText
end

local lastChatType   = "SAY"
local lastTellTarget = nil

local function GetActiveChatType()
    return lastChatType, lastTellTarget
end

local function OnEnterPressedHandler(editBox)
    local text     = editBox:GetText()
    local chatType = editBox:GetAttribute("chatType") or "SAY"

    lastChatType   = chatType
    lastTellTarget = editBox:GetAttribute("tellTarget")

    if TrollSpeakCharDB and TrollSpeakCharDB.masterEnabled
    and TrollSpeakCharDB.autoChannels
    and text and text ~= "" and text:sub(1, 1) ~= "/" then
        local ct = chatType:lower()
        if (ct == "say"     and TrollSpeakCharDB.autoChannels.say)
        or (ct == "yell"    and TrollSpeakCharDB.autoChannels.yell)
        or (ct == "emote"   and TrollSpeakCharDB.autoChannels.emote)
        or (ct == "party"   and TrollSpeakCharDB.autoChannels.party)
        or (ct == "guild"   and TrollSpeakCharDB.autoChannels.guild)
        or (ct == "raid"    and TrollSpeakCharDB.autoChannels.raid)
        or (ct == "whisper" and TrollSpeakCharDB.autoChannels.whisper) then
            editBox:SetText(TrollSpeak_Translate(text))
        end
    end

    ChatEdit_SendText(editBox, 1)
    editBox:SetText("")
    if not IsShiftKeyDown() then
        ChatEdit_DeactivateChat(editBox)
    end
end

local function ParseVersion(v)
    local maj, min = v:match("^(%d+)%.(%d+)")
    return tonumber(maj) or 0, tonumber(min) or 0
end

local function IsNewerVersion(v1, v2)
    local maj1, min1 = ParseVersion(v1)
    local maj2, min2 = ParseVersion(v2)
    return maj1 > maj2 or (maj1 == maj2 and min1 > min2)
end

local trollspeakUsers = {}

local function HandleAddonMessage(prefix, message, channel, sender)
    if prefix ~= "TrollSpeak" then return end
    local senderName = sender:match("^([^%-]+)") or sender

    if message == "PING" then
        C_ChatInfo.SendAddonMessage("TrollSpeak", "PONG:" .. ADDON_VERSION, "WHISPER", sender)

    elseif message:match("^PONG:") then
        local ver = message:match("^PONG:(.+)")
        trollspeakUsers[senderName] = ver

    elseif message:match("^VER:") then
        local ver = message:match("^VER:(.+)")
        if IsNewerVersion(ver, ADDON_VERSION) then
            print(PREFIX .. senderName .. " be runnin' TrollSpeak v" .. ver
                .. " — ya version be old, mon! Get da latest!")
        end
    end
end

local function HookChatFrames()
    local numWindows = NUM_CHAT_WINDOWS or 10
    for i = 1, numWindows do
        local frame = _G["ChatFrame" .. i]
        if frame and frame.editBox and frame.editBox:GetScript("OnEnterPressed") then
            frame.editBox:SetScript("OnEnterPressed", OnEnterPressedHandler)
        end
    end
end

local function HandleSlashCommand(input, dialectKey)
    dialectKey = dialectKey or "troll"
    local dialect      = TrollSpeakDialects[dialectKey]
    local dialectLabel = dialect and dialect.label or dialectKey

    input = input:match("^%s*(.-)%s*$")

    if input == "" then
        print(PREFIX .. "/troll <text>               - translate to Troll and send")
        print(PREFIX .. "/dwarf <text>               - translate to Dwarf and send")
        print(PREFIX .. "/troll test <text>          - translate and print only (no send)")
        print(PREFIX .. "/troll on [channel]  - enable (no arg = say/yell/emote/party/guild)")
        print(PREFIX .. "/troll off [channel] - disable (no arg = all channels)")
        print(PREFIX .. "/troll ooc <text>    - send without translation")
        print(PREFIX .. "/troll status               - show settings")
        print(PREFIX .. "/troll ui                   - open settings panel")
        print(PREFIX .. "/troll config starter <0-100>")
        print(PREFIX .. "/troll config ending  <0-100>")
        print(PREFIX .. "/troll config dialect <troll|dwarf> - dialect used for auto-translate")
        print(PREFIX .. "/troll add <original>|<translation>   (or /dwarf add ...)")
        print(PREFIX .. "/troll remove <original>              (or /dwarf remove ...)")
        print(PREFIX .. "/troll list                            (or /dwarf list)")
        return
    end

    local cmd, rest = input:match("^(%S+)%s*(.*)")
    cmd  = cmd:lower()
    rest = rest or ""

    if cmd == "on" then
        local ch = rest:lower():match("^%s*(.-)%s*$")
        if ch == "" then
            -- First-time: if no channels configured yet, set social defaults
            local hasAny = false
            for _, v in pairs(TrollSpeakCharDB.autoChannels) do
                if v then hasAny = true; break end
            end
            if not hasAny then
                TrollSpeakCharDB.autoChannels.say   = true
                TrollSpeakCharDB.autoChannels.yell  = true
                TrollSpeakCharDB.autoChannels.emote = true
                TrollSpeakCharDB.autoChannels.party = true
                TrollSpeakCharDB.autoChannels.guild = true
            end
            TrollSpeakCharDB.masterEnabled = true
            print(PREFIX .. "Auto-translate enabled.")
        elseif TrollSpeakCharDB.autoChannels[ch] ~= nil then
            TrollSpeakCharDB.autoChannels[ch] = true
            TrollSpeakCharDB.masterEnabled = true
            print(PREFIX .. "Auto-translate enabled for " .. ch .. ".")
        else
            print(PREFIX .. "Unknown channel '" .. ch .. "'. Valid: say, yell, emote, party, guild, raid, whisper.")
        end
        TrollSpeak_UpdateMinimapButton()

    elseif cmd == "off" then
        local ch = rest:lower():match("^%s*(.-)%s*$")
        if ch == "" then
            TrollSpeakCharDB.masterEnabled = false
            print(PREFIX .. "Auto-translate disabled.")
        elseif TrollSpeakCharDB.autoChannels[ch] ~= nil then
            TrollSpeakCharDB.autoChannels[ch] = false
            print(PREFIX .. "Auto-translate disabled for " .. ch .. ".")
        else
            print(PREFIX .. "Unknown channel '" .. ch .. "'. Valid: say, yell, emote, party, guild, raid, whisper.")
        end
        TrollSpeak_UpdateMinimapButton()

    elseif cmd == "status" then
        print(PREFIX .. "Auto-translate: " .. (TrollSpeakCharDB.masterEnabled and "ON" or "OFF"))
        print(PREFIX .. "Starter chance: " .. TrollSpeakDB.starterChance .. "%")
        print(PREFIX .. "Ending chance:  " .. TrollSpeakDB.endingChance .. "%")
        print(PREFIX .. "Auto-translate dialect: " .. (TrollSpeakCharDB.activeDialect or "troll"))
        local active = {}
        for ch, on in pairs(TrollSpeakCharDB.autoChannels) do
            if on then active[#active + 1] = ch end
        end
        if #active > 0 then
            table.sort(active)
            print(PREFIX .. "Channels: " .. table.concat(active, ", "))
        else
            print(PREFIX .. "Channels: none configured")
        end

    elseif cmd == "ui" then
        TrollSpeak_ShowUI()

    elseif cmd == "config" then
        TrollSpeak_HandleConfig(rest)

    elseif cmd == "add" then
        TrollSpeak_HandleAddPhrase(rest, dialectKey)

    elseif cmd == "remove" then
        TrollSpeak_HandleRemovePhrase(rest, dialectKey)

    elseif cmd == "list" then
        TrollSpeak_HandleListPhrases(dialectKey)

    elseif cmd == "ooc" then
        if rest == "" then
            print(PREFIX .. "Usage: /troll ooc <text>")
        else
            local chatType, tellTarget = GetActiveChatType()
            SendChatMessage(rest, chatType, nil, tellTarget)
        end

    elseif cmd == "test" then
        if rest == "" then
            print(PREFIX .. "Usage: /troll test <text>")
        else
            local lower = rest:lower():match("^%s*(.-)%s*$")
            local matchType
            if TrollSpeak_GetCustomPhrase(lower, dialectKey) then
                matchType = "custom phrase"
            elseif dialect.getPhrase(lower) then
                matchType = "built-in phrase"
            else
                matchType = "word/rule"
            end
            print(PREFIX .. "[" .. matchType .. ", " .. dialectLabel .. "] 3 rolls:")
            for _ = 1, 3 do
                print(PREFIX .. "  " .. TrollSpeak_Translate(rest, dialectKey))
            end
        end

    elseif cmd == "who" then
        trollspeakUsers = {}
        trollspeakUsers[UnitName("player")] = ADDON_VERSION
        if IsInGuild() then
            C_ChatInfo.SendAddonMessage("TrollSpeak", "PING", "GUILD")
            print(PREFIX .. "Askin' da guild who be usin' TrollSpeak...")
            C_Timer.After(3, function()
                local list = {}
                for name, ver in pairs(trollspeakUsers) do
                    list[#list + 1] = name .. " (v" .. ver .. ")"
                end
                table.sort(list)
                print(PREFIX .. "TrollSpeak users in da guild (" .. #list .. "):")
                for _, entry in ipairs(list) do
                    print(PREFIX .. "  " .. entry)
                end
            end)
        else
            print(PREFIX .. "Ya not in a guild, mon.")
        end

    else
        local translated = TrollSpeak_Translate(input, dialectKey)
        local chatType, tellTarget = GetActiveChatType()
        SendChatMessage(translated, chatType, nil, tellTarget)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == "TrollSpeak" then
        TrollSpeak_InitDB()
        TrollSpeak_InitCharDB()
        HookChatFrames()
        C_ChatInfo.RegisterAddonMessagePrefix("TrollSpeak")
        print(PREFIX .. "v" .. ADDON_VERSION .. " loaded. Type /troll or /dwarf for help.")
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGIN" then
        if IsInGuild() then
            C_ChatInfo.SendAddonMessage("TrollSpeak", "VER:" .. ADDON_VERSION, "GUILD")
        end

    elseif event == "CHAT_MSG_ADDON" then
        HandleAddonMessage(arg1, arg2, arg3, arg4)
    end
end)

SLASH_TROLLSPEAK1 = "/troll"
SlashCmdList["TROLLSPEAK"] = function(input) HandleSlashCommand(input, "troll") end

SLASH_DWARFSPEAK1 = "/dwarf"
SlashCmdList["DWARFSPEAK"] = function(input) HandleSlashCommand(input, "dwarf") end
