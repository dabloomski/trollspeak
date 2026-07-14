DwarfSpeakFillers = {
    "laddie",
    "friend",
    "pal",
}

DwarfSpeakPools = {
    ["@thankyou"] = {
        "much obliged, {filler}",
        "ye have me thanks, {filler}",
        "many thanks, {filler}",
        "aye, much appreciated, {filler}",
    },
    ["@goodgame"] = {
        "good game, {filler}",
        "well fought, {filler}",
        "solid as stone, {filler}",
    },
    ["@wellplayed"] = {
        "ye played that well, {filler}",
        "respect, {filler}",
        "sturdy work, {filler}",
    },
    ["@goodluck"] = {
        "may the ancestors watch o'er ye, {filler}",
        "good luck oot there, {filler}",
        "may yer aim be true, {filler}",
    },
    ["@goodnight"] = {
        "sleep well, {filler}, the ancestors keep watch",
        "rest yer bones, {filler}",
        "good night, {filler}, dinnae let the trolls bite",
    },
    ["@noproblem"] = {
        "nae bother, {filler}",
        "easy done, {filler}",
        "dinnae mention it, {filler}",
    },
    ["@lol"] = {
        "Hah, {filler}!",
        "Haha, {filler}, ye're a riot!",
        "By me beard, that's funny, {filler}!",
    },
    ["@hello"] = {
        "Well met, {filler}!",
        "Ey up, {filler}!",
        "Good tae see ye, {filler}!",
        "Greetings, {filler}. Good tae cross paths with ye.",
    },
    ["@goodbye"] = {
        "Safe travels, {filler}.",
        "Until we meet again, {filler}.",
        "May the ancestors guide yer path, {filler}.",
    },
    ["@yes"] = {
        "Aye, {filler}, that be right!",
        "Aye aye, {filler}!",
        "By me beard, aye!",
    },
    ["@no"] = {
        "Nae, {filler}, that's no' the way.",
        "Nae chance, {filler}.",
        "I think not, {filler}.",
    },
    ["@sorry"] = {
        "Me apologies, {filler}.",
        "Me bad, {filler}.",
        "Forgive an auld dwarf, {filler}.",
    },
    ["@ready"] = {
        "Ready as ever, {filler}!",
        "Aye, born ready, {filler}!",
        "Let's do this, {filler}!",
    },
    ["@letsgo"] = {
        "Move oot, {filler}!",
        "Time tae go, {filler}!",
        "Onward, {filler}! Nae time tae waste!",
    },
    ["@nice"] = {
        "Nicely done, {filler}!",
        "Fine work, {filler}!",
        "Solid as stone, {filler}!",
    },
    ["@omg"] = {
        "By me beard, {filler}!",
        "Stone and iron, {filler}!",
        "Cannae believe it, {filler}!",
    },
    ["@welcome"] = {
        "Welcome tae the clan, {filler}!",
        "Ye be one of us now, {filler}!",
        "Grab an ale, {filler}, ye're home now!",
    },
    ["@grats"] = {
        "Well earned, {filler}!",
        "Grats, {filler}! Raise a mug!",
        "The ancestors be proud, {filler}!",
    },
    ["@goodmorning"] = {
        "Mornin', {filler}. Time tae get tae work.",
        "Rise and shine, {filler}!",
        "Up and at it, {filler}!",
    },
    ["@goodafternoon"] = {
        "Afternoon tae ye, {filler}.",
        "Good day, {filler}. How be the huntin'?",
        "Afternoon, {filler}. Keep yer axe sharp.",
    },
    ["@rip"] = {
        "The ancestors welcome another home, {filler}.",
        "Gone but nae forgotten. Respect.",
        "Died wi' a hammer in hand. Honor them.",
        "The mountain claimed one o' its own today.",
    },
}

DwarfSpeakPhrases = {
    -- WoW abbreviations
    ["thanks"]       = "@thankyou",
    ["thank you"]    = "@thankyou",
    ["ty"]           = "@thankyou",
    ["thx"]          = "@thankyou",
    ["tyvm"]         = "@thankyou",
    ["gg"]           = "@goodgame",
    ["gg wp"]        = "@goodgame",
    ["wp"]           = "@wellplayed",
    ["well played"]  = "@wellplayed",
    ["gl"]           = "@goodluck",
    ["glhf"]         = "@goodluck",
    ["good luck"]    = "@goodluck",
    ["gn"]           = "@goodnight",
    ["nn"]           = "@goodnight",
    ["good night"]   = "@goodnight",
    ["np"]           = "@noproblem",
    ["no problem"]   = "@noproblem",
    ["lol"]          = "@lol",
    ["haha"]         = "@lol",
    ["hahaha"]       = "@lol",
    ["lmao"]         = "@lol",
    ["rofl"]         = "@lol",
    ["hehe"]         = "@lol",
    ["hi"]           = "@hello",
    ["hello"]        = "@hello",
    ["hey"]          = "@hello",
    ["greetings"]    = "@hello",
    ["heya"]         = "@hello",
    -- Goodbye
    ["bye"]          = "@goodbye",
    ["cya"]          = "@goodbye",
    ["see ya"]       = "@goodbye",
    ["see you"]      = "@goodbye",
    ["farewell"]     = "@goodbye",
    ["later"]        = "@goodbye",
    ["tc"]           = "@goodbye",
    -- Yes
    ["yes"]          = "@yes",
    ["yeah"]         = "@yes",
    ["yep"]          = "@yes",
    ["yup"]          = "@yes",
    ["aye"]          = "@yes",
    -- No
    ["no"]           = "@no",
    ["nope"]         = "@no",
    ["nah"]          = "@no",
    -- Sorry
    ["sorry"]        = "@sorry",
    ["sry"]          = "@sorry",
    ["my bad"]       = "@sorry",
    ["mb"]           = "@sorry",
    ["apologies"]    = "@sorry",
    -- Ready
    ["r"]            = "@ready",
    ["rdy"]          = "@ready",
    ["ready"]        = "@ready",
    -- Let's go
    ["lg"]           = "@letsgo",
    ["lets go"]      = "@letsgo",
    ["let's go"]     = "@letsgo",
    ["go go"]        = "@letsgo",
    -- Nice
    ["nice"]         = "@nice",
    ["noice"]        = "@nice",
    ["nice one"]     = "@nice",
    -- Welcome
    ["welcome"]               = "@welcome",
    ["welcome to the guild"]  = "@welcome",
    ["welcome to the tribe"]  = "@welcome",
    ["welcome aboard"]        = "@welcome",
    ["wb"]                    = "welcome back, {filler}! good tae see ye still breathin'!",
    -- Grats
    ["grats"]          = "@grats",
    ["gratz"]          = "@grats",
    ["gz"]             = "@grats",
    ["gz!"]            = "@grats",
    ["congrats"]       = "@grats",
    ["congratulations"]= "@grats",
    -- OMG / wow
    ["omg"]          = "@omg",
    ["oh my god"]    = "@omg",
    ["oh my"]        = "@omg",
    ["wow"]          = "@omg",
    ["wow!"]         = "@omg",
    -- Chat
    ["brb"]          = "back in a wee bit, laddie",
    ["bb"]           = "farewell, may the ancestors watch o'er ye",
    ["afk"]          = "this dwarf be away for a wee bit",
    ["hf"]           = "have fun, may yer aim be true",
    ["omw"]          = "on me way, laddie",
    ["ss"]           = "stay safe, dyin's forever oot here",
    ["inc"]          = "they be comin', laddie!",
    ["oom"]          = "oot o' mana, laddie",
    ["wtf"]          = "by me beard, what be that?!",
    ["lol wtf"]      = "hah, by me beard, what?!",
    ["wtf lol"]      = "hah, by me beard, what?!",
    -- Combat / Raiding
    ["watch out"]    = "watch yer back, laddie!",
    ["incoming"]     = "they be comin', laddie!",
    ["need healing"] = "I'm dyin' here, send the healer!",
    ["pull"]         = "let's go, pull 'em!",
    ["wipe"]         = "the ancestors took us this time",
    ["dot"]          = "set 'em alight, laddie!",
    ["aoe"]          = "hit 'em all, laddie, let loose the cannons!",
    -- Social
    ["good morning"]  = "@goodmorning",
    ["good mornin'"]  = "@goodmorning",
    ["morning"]       = "@goodmorning",
    ["gm"]            = "@goodmorning",
    ["well done"]       = "@wellplayed",
    ["good afternoon"]  = "@goodafternoon",
    ["afternoon"]       = "@goodafternoon",
    ["good day"]        = "@goodafternoon",
    -- HC-specific
    ["be careful"]      = "watch yer step, laddie, death be permanent",
    ["don't die"]       = "stay alive, laddie, the ancestors no' ready for ye yet",
    ["safe travels"]    = "may the ancestors guide yer path, laddie",
    ["rip"]             = "@rip",
    ["gg irl"]          = "@rip",
    ["f in the chat"]   = "@rip",
    ["run"]          = "flee, laddie, the ancestors no' ready for ye!",
    ["run away"]     = "flee, laddie, the ancestors no' ready for ye!",
    ["danger"]       = "there be danger, laddie, watch yer back!",
}

local function ResolveFiller(text)
    return (text:gsub("{filler}", function()
        return DwarfSpeakFillers[math.random(#DwarfSpeakFillers)]
    end))
end

function DwarfSpeak_GetPhrase(lowerTrimmed)
    local value = DwarfSpeakPhrases[lowerTrimmed]
    if not value then return nil end

    if value:sub(1, 1) == "@" then
        local pool = DwarfSpeakPools[value]
        if not pool then return nil end
        return ResolveFiller(pool[math.random(#pool)])
    end

    return ResolveFiller(value)
end

local starters = {
    "Och, ",
    "Aye, ",
    "By me beard, ",
    "Noo listen, ",
    "Hmph, ",
}

local endingsNeutral = {
    ", laddie.",
    ", ken?",
    ", friend.",
    ". Cannae argue wi' that.",
    ", pal.",
}

local endingsQuestion = {
    ", aye?",
    ", ye ken?",
    ", laddie?",
    ", eh?",
}

local endingsExclaim = {
    ", laddie!",
    ", by me beard!",
    ", aye!",
    ", pal!",
}

TrollSpeakDialects = TrollSpeakDialects or {}
TrollSpeakDialects["dwarf"] = {
    label           = "Dwarf",
    words           = DwarfSpeakWords,
    rules           = DwarfSpeakRules,
    getPhrase       = DwarfSpeak_GetPhrase,
    phrases         = DwarfSpeakPhrases,  -- raw tables, for UI introspection (e.g. phrase reference tab)
    pools           = DwarfSpeakPools,
    fillers         = DwarfSpeakFillers,
    starters        = starters,
    endingsNeutral  = endingsNeutral,
    endingsQuestion = endingsQuestion,
    endingsExclaim  = endingsExclaim,
}
