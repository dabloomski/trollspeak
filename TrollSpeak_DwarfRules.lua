DwarfSpeakRules = {}

function DwarfSpeakRules.Apply(text)
    -- Multi-word phrases first (space forms of negation + common contractions)
    text = text:gsub("%f[%a]going to%f[%A]",  "gonnae")
    text = text:gsub("%f[%a]want to%f[%A]",   "wanna")
    text = text:gsub("%f[%a]have to%f[%A]",   "need tae")
    text = text:gsub("%f[%a]can not%f[%A]",   "cannae")
    text = text:gsub("%f[%a]do not%f[%A]",    "dinnae")
    text = text:gsub("%f[%a]does not%f[%A]",  "disnae")
    text = text:gsub("%f[%a]did not%f[%A]",   "didnae")
    text = text:gsub("%f[%a]is not%f[%A]",    "isnae")
    text = text:gsub("%f[%a]was not%f[%A]",   "wasnae")
    text = text:gsub("%f[%a]were not%f[%A]",  "werenae")
    text = text:gsub("%f[%a]will not%f[%A]",  "willnae")
    text = text:gsub("%f[%a]am not%f[%A]",    "amnae")
    text = text:gsub("%f[%a]are not%f[%A]",   "arenae")
    -- Positive contractions for "ye" (words.lua already turns you're/you'll/you've
    -- into ye're/ye'll/ye've via frontier matching; these catch the uncontracted forms)
    text = text:gsub("%f[%a]ye are%f[%A]",    "ye're")
    text = text:gsub("%f[%a]ye will%f[%A]",   "ye'll")
    text = text:gsub("%f[%a]ye have%f[%A]",   "ye've")
    -- Single-word rules
    text = text:gsub("([%a])ing%f[%A]",       "%1in'")
    return text
end
