local panel        = nil
local _mainCat     = nil  -- Settings API category object, shared by both build functions
local phraseRows   = {}
local starterRows  = {}
local endingRows   = {}
local allPhraseGroups = {}  -- built once for phrase reference panel

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function AddHint(eb, text)
    local hint = eb:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hint:SetPoint("LEFT", eb, "LEFT", 6, 0)
    hint:SetText(text)
    local function update(self)
        hint:SetShown(self:GetText() == "")
    end
    eb:HookScript("OnTextChanged",     update)
    eb:HookScript("OnEditFocusGained", function() hint:Hide() end)
    eb:HookScript("OnEditFocusLost",   update)
end

local function MakeSep(parent, y)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetColorTexture(0.5, 0.5, 0.5, 0.4)
    t:SetSize(540, 1)
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
end

local function MakeHeader(parent, text, y)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
    fs:SetText(text)
    return fs
end

local function MakeLabel(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

-- ── Generic scrollable remove-list (starters / endings) ──────────────────────

local function RefreshSimpleList(cf, rowCache, dataArray, removeFn, refreshFn)
    for _, row in ipairs(rowCache) do row:Hide() end

    for i, text in ipairs(dataArray) do
        local row = rowCache[i]
        if not row then
            row = CreateFrame("Frame", nil, cf)

            row.lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.lbl:SetPoint("LEFT", row, "LEFT", 4, 0)
            row.lbl:SetWidth(460)
            row.lbl:SetJustifyH("LEFT")
            row.lbl:SetWordWrap(false)

            row.btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.btn:SetSize(64, 18)
            row.btn:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            row.btn:SetText("Remove")

            rowCache[i] = row
        end

        row:SetSize(548, 22)
        row:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, -(i - 1) * 23)
        row.lbl:SetText(text)
        row.index = i
        row.btn:SetScript("OnClick", function()
            removeFn(row.index)
            refreshFn()
        end)
        row:Show()
    end

    cf:SetHeight(math.max(#dataArray * 23, 22))
end

-- ── Custom phrases list ───────────────────────────────────────────────────────

local customPhraseContent = nil

local function RefreshPhraseList()
    if not customPhraseContent then return end

    for _, row in ipairs(phraseRows) do row:Hide() end

    local sorted = {}
    for orig, trans in pairs(TrollSpeakDB and TrollSpeakDB.customPhrases or {}) do
        sorted[#sorted + 1] = { orig = orig, trans = trans }
    end
    table.sort(sorted, function(a, b) return a.orig < b.orig end)

    if panel and panel.customPhraseHeader then
        local n = #sorted
        panel.customPhraseHeader:SetText(
            "Custom Phrases" .. (n > 0 and " (" .. n .. ")" or ""))
    end

    for i, p in ipairs(sorted) do
        local row = phraseRows[i]
        if not row then
            row = CreateFrame("Frame", nil, customPhraseContent)

            row.lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.lbl:SetPoint("LEFT", row, "LEFT", 4, 0)
            row.lbl:SetWidth(460)
            row.lbl:SetJustifyH("LEFT")
            row.lbl:SetWordWrap(false)

            row.btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.btn:SetSize(64, 18)
            row.btn:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            row.btn:SetText("Remove")

            phraseRows[i] = row
        end

        row:SetSize(548, 22)
        row:SetPoint("TOPLEFT", customPhraseContent, "TOPLEFT", 0, -(i - 1) * 23)
        row.lbl:SetText('"' .. p.orig .. '" -> "' .. p.trans .. '"')
        row.orig = p.orig
        row.btn:SetScript("OnClick", function()
            TrollSpeakDB.customPhrases[row.orig] = nil
            RefreshPhraseList()
        end)
        row:Show()
    end

    customPhraseContent:SetHeight(math.max(#sorted * 23, 22))
end

-- ── Sync settings panel from DB ───────────────────────────────────────────────

local starterContent = nil
local endingContent  = nil

local function RefreshStarterList()
    if not starterContent or not TrollSpeakDB then return end
    RefreshSimpleList(starterContent, starterRows,
        TrollSpeakDB.customStarters, TrollSpeak_RemoveStarter,
        function() RefreshStarterList() end)
end

local function RefreshEndingList()
    if not endingContent or not TrollSpeakDB then return end
    RefreshSimpleList(endingContent, endingRows,
        TrollSpeakDB.customEndings, TrollSpeak_RemoveEnding,
        function() RefreshEndingList() end)
end

local function SyncFromDB()
    if not panel or not TrollSpeakDB then return end

    for ch, cb in pairs(panel.chanCBs) do
        cb:SetChecked(TrollSpeakDB.autoChannels[ch] or false)
    end

    panel.starterSlider:SetValue(TrollSpeakDB.starterChance or 15)
    panel.endingSlider:SetValue(TrollSpeakDB.endingChance or 40)

    RefreshPhraseList()
    RefreshStarterList()
    RefreshEndingList()
end

-- ── Phrase reference panel ────────────────────────────────────────────────────

local phraseRefRows    = {}
local phraseRefContent = nil
local phraseSearchEB   = nil

local function BuildPhraseGroups()
    local FILLER = "mon"
    local valueToKeys = {}
    for k, v in pairs(TrollSpeakPhrases) do
        if not valueToKeys[v] then valueToKeys[v] = {} end
        valueToKeys[v][#valueToKeys[v] + 1] = k
    end

    local groups = {}
    for val, keys in pairs(valueToKeys) do
        table.sort(keys)

        local phrases = {}
        if val:sub(1, 1) == "@" then
            local pool = TrollSpeakPools and TrollSpeakPools[val]
            if pool then
                for _, p in ipairs(pool) do
                    phrases[#phrases + 1] = p:gsub("{filler}", FILLER)
                end
            end
        else
            phrases[1] = val
        end

        local searchParts = {}
        for _, k in ipairs(keys) do searchParts[#searchParts + 1] = k end
        for _, p in ipairs(phrases) do searchParts[#searchParts + 1] = p:lower() end

        groups[#groups + 1] = {
            triggers   = table.concat(keys, " / "),
            phrases    = phrases,
            searchText = table.concat(searchParts, " "),
            sortKey    = keys[1],
        }
    end

    table.sort(groups, function(a, b) return a.sortKey < b.sortKey end)
    return groups
end

local function RefreshPhraseRef(filter)
    if not phraseRefContent then return end

    filter = filter and filter:lower():match("^%s*(.-)%s*$") or ""

    local items = {}
    for gi, group in ipairs(allPhraseGroups) do
        local show = filter == "" or group.searchText:find(filter, 1, true)
        if show then
            if gi > 1 then
                items[#items + 1] = { isSep = true }
            end
            items[#items + 1] = { text = group.triggers, isTrigger = true }
            for _, p in ipairs(group.phrases) do
                items[#items + 1] = { text = '"' .. p .. '"' }
            end
        end
    end

    for _, row in ipairs(phraseRefRows) do row:Hide() end

    local yOffset = 0
    for i, item in ipairs(items) do
        local rowH = item.isSep and 5 or item.isTrigger and 20 or 18

        local row = phraseRefRows[i]
        if not row then
            row = CreateFrame("Frame", nil, phraseRefContent)
            row.lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.lbl:SetJustifyH("LEFT")
            row.lbl:SetWordWrap(false)
            phraseRefRows[i] = row
        end

        row:SetSize(554, rowH)
        row:SetPoint("TOPLEFT", phraseRefContent, "TOPLEFT", 0, -yOffset)

        if item.isSep then
            row.lbl:SetText("")
        elseif item.isTrigger then
            row.lbl:SetFontObject("GameFontNormal")
            row.lbl:SetPoint("LEFT", row, "LEFT", 4, 0)
            row.lbl:SetWidth(546)
            row.lbl:SetText(item.text)
        else
            row.lbl:SetFontObject("GameFontDisableSmall")
            row.lbl:SetPoint("LEFT", row, "LEFT", 18, 0)
            row.lbl:SetWidth(532)
            row.lbl:SetText(item.text)
        end

        row:Show()
        yOffset = yOffset + rowH
    end

    phraseRefContent:SetHeight(math.max(yOffset, 20))
end

-- ── Minimap button ────────────────────────────────────────────────────────────

local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("TrollSpeak", {
    type = "launcher",
    text = "TrollSpeak",
    icon = "Interface\\Icons\\spell_nature_bloodlust",

    OnClick = function(_, button)
        if button == "RightButton" then
            TrollSpeak_ShowUI()
            return
        end
        TrollSpeakDB.masterEnabled = not TrollSpeakDB.masterEnabled
        TrollSpeak_UpdateMinimapButton()
        if panel and panel:IsShown() then SyncFromDB() end
    end,

    OnTooltipShow = function(tooltip)
        tooltip:SetText("TrollSpeak")
        local active = TrollSpeakDB and TrollSpeakDB.masterEnabled
        tooltip:AddLine(active and "|cff00ff00Active|r" or "|cffff0000Inactive|r")
        tooltip:AddLine("Left-click: toggle on/off", 1, 1, 1)
        tooltip:AddLine("Right-click: open settings", 1, 1, 1)
    end,
})

function TrollSpeak_UpdateMinimapButton()
    local dbIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not dbIcon then return end
    local btn = dbIcon:GetMinimapButton("TrollSpeak")
    if not btn then return end
    local active = TrollSpeakDB and TrollSpeakDB.masterEnabled
    btn.icon:SetDesaturated(not active)
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, _, name)
    if name == "TrollSpeak" then
        LibStub("LibDBIcon-1.0"):Register("TrollSpeak", ldb, TrollSpeakDB.minimap)
        TrollSpeak_UpdateMinimapButton()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- ── Build settings panel ──────────────────────────────────────────────────────

local function BuildSettingsPanel()
    panel = CreateFrame("Frame")
    panel.name = "TrollSpeak"

    -- Prefer the new Settings API — it's the only reliable way to get sub-categories
    -- in Classic Era 1.15.x. Fall back to the legacy InterfaceOptions API otherwise.
    if Settings and Settings.RegisterCanvasLayoutCategory then
        _mainCat = Settings.RegisterCanvasLayoutCategory(panel, "TrollSpeak")
        Settings.RegisterAddOnCategory(_mainCat)
        panel._settingsCategory = _mainCat
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

    panel.refresh = SyncFromDB
    panel:SetScript("OnShow", SyncFromDB)
    panel.okay    = function() end
    panel.cancel  = function() end
    panel.default = function()
        if not TrollSpeakDB then return end
        TrollSpeakDB.starterChance = 15
        TrollSpeakDB.endingChance  = 40
        for ch in pairs(TrollSpeakDB.autoChannels) do
            TrollSpeakDB.autoChannels[ch] = false
        end
        TrollSpeak_UpdateMinimapButton()
        SyncFromDB()
    end

    -- Version header
    local hdr = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    hdr:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    hdr:SetText("TrollSpeak  v" .. (GetAddOnMetadata("TrollSpeak", "Version") or "?"))

    -- All settings content lives inside a scroll frame (content is taller than panel)
    local sf = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -44)
    sf:SetSize(590, 506)

    local c = CreateFrame("Frame", nil, sf)   -- c = content
    c:SetWidth(568)
    c:SetHeight(780)
    sf:SetScrollChild(c)

    -- Channels
    MakeHeader(c, "Auto-Translate Channels", 0)

    panel.chanCBs = {}
    local chanLayout = {
        { "say",     16,  -24 }, { "guild",  220,  -24 },
        { "yell",    16,  -48 }, { "party",  220,  -48 },
        { "emote",   16,  -72 }, { "raid",   220,  -72 },
        { "whisper", 16,  -96 },
    }
    for _, d in ipairs(chanLayout) do
        local ch, x, y = d[1], d[2], d[3]
        local cb = CreateFrame("CheckButton", "TrollSpeakCB_" .. ch, c, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", c, "TOPLEFT", x, y)
        cb.text:SetText(ch:sub(1,1):upper() .. ch:sub(2))
        cb:SetScript("OnClick", function(self)
            if TrollSpeakDB and TrollSpeakDB.autoChannels then
                TrollSpeakDB.autoChannels[ch] = self:GetChecked()
                TrollSpeak_UpdateMinimapButton()
            end
        end)
        panel.chanCBs[ch] = cb
    end

    MakeSep(c, -134)

    -- Probabilities
    MakeHeader(c, "Probabilities", -142)

    MakeLabel(c, "Starter chance:", 16, -166)
    panel.starterValFS = c:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.starterValFS:SetPoint("TOPLEFT", c, "TOPLEFT", 118, -166)

    local ss = CreateFrame("Slider", "TrollSpeakStarterSlider", c, "OptionsSliderTemplate")
    ss:SetWidth(530)
    ss:SetPoint("TOPLEFT", c, "TOPLEFT", 18, -181)
    ss:SetMinMaxValues(0, 100)
    ss:SetValueStep(1)
    _G[ss:GetName() .. "Low"]:SetText("0")
    _G[ss:GetName() .. "High"]:SetText("100")
    _G[ss:GetName() .. "Text"]:SetText("")
    ss:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v + 0.5)
        panel.starterValFS:SetText(v .. "%")
        if TrollSpeakDB then TrollSpeakDB.starterChance = v end
    end)
    panel.starterSlider = ss

    MakeLabel(c, "Ending chance:", 16, -214)
    panel.endingValFS = c:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.endingValFS:SetPoint("TOPLEFT", c, "TOPLEFT", 118, -214)

    local es = CreateFrame("Slider", "TrollSpeakEndingSlider", c, "OptionsSliderTemplate")
    es:SetWidth(530)
    es:SetPoint("TOPLEFT", c, "TOPLEFT", 18, -229)
    es:SetMinMaxValues(0, 100)
    es:SetValueStep(1)
    _G[es:GetName() .. "Low"]:SetText("0")
    _G[es:GetName() .. "High"]:SetText("100")
    _G[es:GetName() .. "Text"]:SetText("")
    es:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v + 0.5)
        panel.endingValFS:SetText(v .. "%")
        if TrollSpeakDB then TrollSpeakDB.endingChance = v end
    end)
    panel.endingSlider = es

    MakeSep(c, -259)

    -- Custom Starters
    MakeHeader(c, "Custom Starters", -267)
    MakeLabel(c, "End with a space:  \"Ya mon, \"", 16, -291)

    local starterEB = CreateFrame("EditBox", nil, c, "InputBoxTemplate")
    starterEB:SetSize(440, 20)
    starterEB:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -310)
    starterEB:SetAutoFocus(false)
    starterEB:SetMaxLetters(200)
    starterEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    AddHint(starterEB, "e.g.  Ey mon, ")

    local starterAddBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    starterAddBtn:SetSize(60, 22)
    starterAddBtn:SetPoint("LEFT", starterEB, "RIGHT", 8, 0)
    starterAddBtn:SetText("Add")
    starterAddBtn:SetScript("OnClick", function()
        local text = starterEB:GetText()
        if text == "" then return end
        TrollSpeak_AddStarter(text)
        starterEB:SetText("")
        starterEB:SetFocus()
        RefreshStarterList()
    end)
    starterEB:SetScript("OnEnterPressed", function() starterAddBtn:Click() end)

    local starterSF = CreateFrame("ScrollFrame", nil, c, "UIPanelScrollFrameTemplate")
    starterSF:SetSize(548, 70)
    starterSF:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -338)
    starterContent = CreateFrame("Frame", nil, starterSF)
    starterContent:SetWidth(528)
    starterContent:SetHeight(1)
    starterSF:SetScrollChild(starterContent)

    MakeSep(c, -416)

    -- Custom Endings
    MakeHeader(c, "Custom Endings", -424)
    MakeLabel(c, "Ends with ? = question pool  |  ! = exclaim pool  |  other = neutral", 16, -448)

    local endingEB = CreateFrame("EditBox", nil, c, "InputBoxTemplate")
    endingEB:SetSize(440, 20)
    endingEB:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -467)
    endingEB:SetAutoFocus(false)
    endingEB:SetMaxLetters(200)
    endingEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    AddHint(endingEB, "e.g.  , da voodoo be wit ya.")

    local endingAddBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    endingAddBtn:SetSize(60, 22)
    endingAddBtn:SetPoint("LEFT", endingEB, "RIGHT", 8, 0)
    endingAddBtn:SetText("Add")
    endingAddBtn:SetScript("OnClick", function()
        local text = endingEB:GetText()
        if text == "" then return end
        TrollSpeak_AddEnding(text)
        endingEB:SetText("")
        endingEB:SetFocus()
        RefreshEndingList()
    end)
    endingEB:SetScript("OnEnterPressed", function() endingAddBtn:Click() end)

    local endingSF = CreateFrame("ScrollFrame", nil, c, "UIPanelScrollFrameTemplate")
    endingSF:SetSize(548, 70)
    endingSF:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -495)
    endingContent = CreateFrame("Frame", nil, endingSF)
    endingContent:SetWidth(528)
    endingContent:SetHeight(1)
    endingSF:SetScrollChild(endingContent)

    MakeSep(c, -573)

    -- Custom Phrases
    panel.customPhraseHeader = MakeHeader(c, "Custom Phrases", -581)

    local function DoAdd()
        local orig  = panel.origEB:GetText():lower():match("^%s*(.-)%s*$")
        local trans = panel.transEB:GetText():match("^%s*(.-)%s*$")
        if orig == "" or trans == "" then return end
        if not TrollSpeakDB then return end
        TrollSpeakDB.customPhrases[orig] = trans
        panel.origEB:SetText("")
        panel.transEB:SetText("")
        panel.origEB:SetFocus()
        RefreshPhraseList()
    end

    local origEB = CreateFrame("EditBox", nil, c, "InputBoxTemplate")
    origEB:SetSize(220, 20)
    origEB:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -604)
    origEB:SetAutoFocus(false)
    origEB:SetMaxLetters(100)
    origEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    origEB:SetScript("OnEnterPressed",  function() panel.transEB:SetFocus() end)
    AddHint(origEB, "original phrase")
    panel.origEB = origEB

    local arrow = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    arrow:SetPoint("LEFT", origEB, "RIGHT", 6, 0)
    arrow:SetText("->")

    local transEB = CreateFrame("EditBox", nil, c, "InputBoxTemplate")
    transEB:SetSize(220, 20)
    transEB:SetPoint("LEFT", arrow, "RIGHT", 6, 0)
    transEB:SetAutoFocus(false)
    transEB:SetMaxLetters(200)
    transEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    transEB:SetScript("OnEnterPressed",  DoAdd)
    AddHint(transEB, "translation")
    panel.transEB = transEB

    local addBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("LEFT", transEB, "RIGHT", 8, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", DoAdd)

    local phraseSF = CreateFrame("ScrollFrame", "TrollSpeakPhraseScrollFrame", c, "UIPanelScrollFrameTemplate")
    phraseSF:SetSize(548, 120)
    phraseSF:SetPoint("TOPLEFT", c, "TOPLEFT", 16, -632)
    customPhraseContent = CreateFrame("Frame", nil, phraseSF)
    customPhraseContent:SetWidth(528)
    customPhraseContent:SetHeight(1)
    phraseSF:SetScrollChild(customPhraseContent)
end

-- ── Build phrase reference sub-panel ─────────────────────────────────────────

local function BuildPhrasesPanel()
    local pp = CreateFrame("Frame")
    pp.name   = "Phrases"
    pp.parent = "TrollSpeak"

    if _mainCat and Settings and Settings.RegisterCanvasLayoutSubcategory then
        local subCat = Settings.RegisterCanvasLayoutSubcategory(_mainCat, pp, "Phrases")
        Settings.RegisterAddOnCategory(subCat)
    elseif InterfaceOptions_AddCategory then
        -- Legacy fallback: parent field causes Classic Era to show it as a sub-entry
        pp.parent = "TrollSpeak"
        InterfaceOptions_AddCategory(pp)
    end

    pp:SetScript("OnShow", function()
        if #allPhraseGroups == 0 then
            allPhraseGroups = BuildPhraseGroups()
        end
        RefreshPhraseRef(phraseSearchEB and phraseSearchEB:GetText() or "")
    end)

    MakeLabel(pp, "Search:", 16, -16)

    phraseSearchEB = CreateFrame("EditBox", nil, pp, "InputBoxTemplate")
    phraseSearchEB:SetSize(530, 20)
    phraseSearchEB:SetPoint("TOPLEFT", pp, "TOPLEFT", 72, -16)
    phraseSearchEB:SetAutoFocus(false)
    phraseSearchEB:SetMaxLetters(80)
    phraseSearchEB:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        RefreshPhraseRef("")
    end)
    phraseSearchEB:SetScript("OnTextChanged", function(self)
        RefreshPhraseRef(self:GetText())
    end)
    AddHint(phraseSearchEB, "type to filter...")

    local refSF = CreateFrame("ScrollFrame", nil, pp, "UIPanelScrollFrameTemplate")
    refSF:SetSize(566, 510)
    refSF:SetPoint("TOPLEFT", pp, "TOPLEFT", 16, -44)
    phraseRefContent = CreateFrame("Frame", nil, refSF)
    phraseRefContent:SetWidth(546)
    phraseRefContent:SetHeight(1)
    refSF:SetScrollChild(phraseRefContent)
end

-- ── Wire everything up ────────────────────────────────────────────────────────

BuildSettingsPanel()
BuildPhrasesPanel()

-- ── Public entry point ────────────────────────────────────────────────────────

function TrollSpeak_ShowUI()
    if panel._settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(panel._settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
