local wordList = {
    -- er-words (longer words first so substrings don't interfere)
    { "forever",  "forevah"  },
    { "together", "togethah" },
    { "remember", "remembah" },
    { "monster",  "monstah"  },
    { "master",   "mastah"   },
    { "member",   "membah"   },
    { "number",   "numbah"   },
    { "danger",   "dangah"   },
    { "brother",  "brothah"  },
    { "mother",   "mothah"   },
    { "sister",   "sistah"   },
    { "father",   "fathah"   },
    { "under",    "undah"    },
    { "after",    "aftah"    },
    { "never",    "nevah"    },
    { "hunter",   "huntah"   },
    { "healer",   "healah"   },
    { "player",   "playah"   },
    { "power",    "powah"    },
    { "water",    "watah"    },
    { "other",    "othah"    },
    { "over",     "ovah"     },
    { "ever",     "evah"     },
    -- th-words
    { "thanks",   "tanks"    },
    { "these",    "dese"     },
    { "there",    "dere"     },
    { "their",    "deir"     },
    { "those",    "dose"     },
    { "think",    "tink"     },
    { "thing",    "ting"     },
    { "them",     "dem"      },
    { "they're",  "dey be"   },  -- must precede "they" → "dey"
    { "they",     "dey"      },
    { "then",     "den"      },
    { "this",     "dis"      },
    { "that",     "dat"      },
    { "the",      "da"       },
    -- other
    { "nothing",  "nuttin'"  },
    { "and",      "an'"      },
    { "three",    "tree"     },
    { "what",     "wha'"     },
    { "with",     "wit"      },
    { "isn't",    "ain't"    },
    { "i am",     "me be"    },  -- must precede "i" → "me"
    { "i'm",      "me be"    },  -- must precede "i" → "me"
    { "my",       "me"       },
    { "you're",   "ya be"    },  -- must precede "you" → "ya"
    { "we're",    "we be"    },
    { "your",     "ya"       },
    { "you",      "ya"       },
    { "i",        "me"       },
}

TrollSpeakWords = {}

function TrollSpeakWords.Apply(text)
    for _, pair in ipairs(wordList) do
        text = text:gsub("%f[%a]" .. pair[1] .. "%f[%A]", pair[2])
    end
    return text
end
