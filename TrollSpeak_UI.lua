local panel        = nil
local contentFrame = nil
local phraseRows   = {}

-- ── Phrase list (sorted alphabetically) ──────────────────────────────────────

local function RefreshPhraseList()
    if not contentFrame then return end

    for _, row in ipairs(phraseRows) do
        row:Hide()
    end

    -- Sort phrases alphabetically by original
    local sorted = {}
    for orig, trans in pairs(TrollSpeakDB and TrollSpeakDB.customPhrases or {}) do
        sorted[#sorted + 1] = { orig = orig, trans = trans }
    end
    table.sort(sorted, function(a, b) return a.orig < b.orig end)

    -- Update header count
    if panel and panel.customPhraseHeader then
        local n = #sorted
        panel.customPhraseHeader:SetText(
            "Custom Phrases" .. (n > 0 and " (" .. n .. ")" or ""))
    end

    for i, p in ipairs(sorted) do
        local row = phraseRows[i]
        if not row then
            row = CreateFrame("Frame", nil, contentFrame)

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
        row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(i - 1) * 23)
        row.lbl:SetText('"' .. p.orig .. '" -> "' .. p.trans .. '"')
        row.orig = p.orig
        row.btn:SetScript("OnClick", function()
            TrollSpeakDB.customPhrases[row.orig] = nil
            RefreshPhraseList()
        end)
        row:Show()
    end

    contentFrame:SetHeight(math.max(#sorted * 23, 22))
end

-- ── Sync UI values from the live DB ──────────────────────────────────────────

local function SyncFromDB()
    if not panel or not TrollSpeakDB then return end

    for ch, cb in pairs(panel.chanCBs) do
        cb:SetChecked(TrollSpeakDB.autoChannels[ch] or false)
    end

    panel.starterSlider:SetValue(TrollSpeakDB.starterChance or 15)
    panel.endingSlider:SetValue(TrollSpeakDB.endingChance or 40)

    RefreshPhraseList()
end

-- ── Minimap button (LibDBIcon) ────────────────────────────────────────────────

local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("TrollSpeak", {
    type = "launcher",
    text = "TrollSpeak",
    icon = "Interface\\Icons\\spell_nature_bloodlust",

    OnClick = function(_, button)
        if button == "RightButton" then
            TrollSpeak_ShowUI()
            return
        end
        -- Left click: toggle master enabled (channel config is never touched)
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

-- Register with LibDBIcon after TrollSpeakDB is initialised
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, _, name)
    if name == "TrollSpeak" then
        LibStub("LibDBIcon-1.0"):Register("TrollSpeak", ldb, TrollSpeakDB.minimap)
        TrollSpeak_UpdateMinimapButton()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- ── Interface Options panel ───────────────────────────────────────────────────

local function AddHint(eb, text)
    local hint = eb:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hint:SetPoint("LEFT", eb, "LEFT", 6, 0)
    hint:SetText(text)
    local function update(self)
        hint:SetShown(self:GetText() == "")
    end
    eb:HookScript("OnTextChanged",      update)
    eb:HookScript("OnEditFocusGained",  function() hint:Hide() end)
    eb:HookScript("OnEditFocusLost",    update)
end

local function BuildUI()
    panel = CreateFrame("Frame")
    panel.name = "TrollSpeak"

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(panel, "TrollSpeak")
        Settings.RegisterAddOnCategory(cat)
        panel._settingsCategory = cat
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

    local function Header(text, y)
        local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        fs:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, y)
        fs:SetText(text)
        return fs
    end
    local function Sep(y)
        local t = panel:CreateTexture(nil, "ARTWORK")
        t:SetColorTexture(0.5, 0.5, 0.5, 0.4)
        t:SetSize(560, 1)
        t:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, y)
    end
    local function Label(text, x, y)
        local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        fs:SetText(text)
        return fs
    end

    Header("TrollSpeak  v" .. (GetAddOnMetadata("TrollSpeak", "Version") or "?"), -16)

    -- ── CHANNELS ─────────────────────────────────────────────────────────────

    Header("Auto-Translate Channels", -48)

    panel.chanCBs = {}
    local chanLayout = {
        { "say",     16,  -72 }, { "guild",  220,  -72 },
        { "yell",    16,  -96 }, { "party",  220,  -96 },
        { "emote",   16, -120 }, { "raid",   220, -120 },
        { "whisper", 16, -144 },
    }
    for _, d in ipairs(chanLayout) do
        local ch, x, y = d[1], d[2], d[3]
        local cb = CreateFrame("CheckButton", "TrollSpeakCB_" .. ch, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        cb.text:SetText(ch:sub(1,1):upper() .. ch:sub(2))
        cb:SetScript("OnClick", function(self)
            if TrollSpeakDB and TrollSpeakDB.autoChannels then
                TrollSpeakDB.autoChannels[ch] = self:GetChecked()
                TrollSpeak_UpdateMinimapButton()
            end
        end)
        panel.chanCBs[ch] = cb
    end

    Sep(-182)

    -- ── PROBABILITIES ─────────────────────────────────────────────────────────

    Header("Probabilities", -190)

    Label("Starter chance:", 16, -214)
    panel.starterValFS = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.starterValFS:SetPoint("TOPLEFT", panel, "TOPLEFT", 118, -214)

    local ss = CreateFrame("Slider", "TrollSpeakStarterSlider", panel, "OptionsSliderTemplate")
    ss:SetWidth(548)
    ss:SetPoint("TOPLEFT", panel, "TOPLEFT", 18, -229)
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

    Label("Ending chance:", 16, -262)
    panel.endingValFS = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.endingValFS:SetPoint("TOPLEFT", panel, "TOPLEFT", 118, -262)

    local es = CreateFrame("Slider", "TrollSpeakEndingSlider", panel, "OptionsSliderTemplate")
    es:SetWidth(548)
    es:SetPoint("TOPLEFT", panel, "TOPLEFT", 18, -277)
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

    Sep(-307)

    -- ── CUSTOM PHRASES ────────────────────────────────────────────────────────

    panel.customPhraseHeader = Header("Custom Phrases", -315)

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

    local origEB = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    origEB:SetSize(220, 20)
    origEB:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -338)
    origEB:SetAutoFocus(false)
    origEB:SetMaxLetters(100)
    origEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    origEB:SetScript("OnEnterPressed",  function() panel.transEB:SetFocus() end)
    AddHint(origEB, "original phrase")
    panel.origEB = origEB

    local arrow = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    arrow:SetPoint("LEFT", origEB, "RIGHT", 6, 0)
    arrow:SetText("->")

    local transEB = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    transEB:SetSize(220, 20)
    transEB:SetPoint("LEFT", arrow, "RIGHT", 6, 0)
    transEB:SetAutoFocus(false)
    transEB:SetMaxLetters(200)
    transEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    transEB:SetScript("OnEnterPressed",  DoAdd)
    AddHint(transEB, "translation")
    panel.transEB = transEB

    local addBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("LEFT", transEB, "RIGHT", 8, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", DoAdd)

    local sf = CreateFrame("ScrollFrame", "TrollSpeakScrollFrame", panel, "UIPanelScrollFrameTemplate")
    sf:SetSize(566, 130)
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -366)

    contentFrame = CreateFrame("Frame", nil, sf)
    contentFrame:SetWidth(546)
    contentFrame:SetHeight(1)
    sf:SetScrollChild(contentFrame)
end

BuildUI()

-- ── Public entry point ────────────────────────────────────────────────────────

function TrollSpeak_ShowUI()
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    elseif Settings and Settings.OpenToCategory and panel._settingsCategory then
        Settings.OpenToCategory(panel._settingsCategory:GetID())
    end
end
