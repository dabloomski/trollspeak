local wordList = {
    -- negation contractions (apostrophe forms; "X not" space forms live in Rules.lua)
    { "cannot",   "cannae"   },
    { "can't",    "cannae"   },
    { "don't",    "dinnae"   },
    { "doesn't",  "disnae"   },
    { "didn't",   "didnae"   },
    { "isn't",    "isnae"    },
    { "wasn't",   "wasnae"   },
    { "weren't",  "werenae"  },
    { "aren't",   "arenae"   },
    { "won't",    "willnae"  },
    -- pronouns
    { "yourself", "yerself"  },  -- frontier pattern won't touch this via "your" below
    { "your",     "yer"      },
    { "you",      "ye"       },  -- also naturally covers you're/you'll/you've via frontier
    -- vowel shifts (oo/oot family)
    { "about",    "aboot"    },
    { "around",   "aroond"   },
    { "down",     "doon"     },
    { "house",    "hoose"    },
    { "out",      "oot"      },
    { "now",      "noo"      },
    -- misc vocabulary
    { "know",     "ken"      },
    { "small",    "wee"      },
    { "little",   "wee"      },
    { "yes",      "aye"      },
    { "of",       "o'"       },
    { "child",    "bairn"    },
    { "children", "bairns"   },
    { "boy",      "laddie"   },
    { "girl",     "lassie"   },
}

DwarfSpeakWords = {}

function DwarfSpeakWords.Apply(text)
    for _, pair in ipairs(wordList) do
        text = text:gsub("%f[%a]" .. pair[1] .. "%f[%A]", pair[2])
    end
    return text
end
