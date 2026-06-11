TrollSpeakRules = {}

function TrollSpeakRules.Apply(text)
    -- Multi-word phrases first: "going to" must run before ing->in' or it breaks
    text = text:gsub("%f[%a]going to%f[%A]",  "goin' ta")
    text = text:gsub("%f[%a]want to%f[%A]",   "wanna")
    text = text:gsub("%f[%a]have to%f[%A]",   "need ta")
    text = text:gsub("%f[%a]is not%f[%A]",    "ain't")
    text = text:gsub("%f[%a]he is%f[%A]",     "he be")
    text = text:gsub("%f[%a]she is%f[%A]",    "she be")
    text = text:gsub("%f[%a]it is%f[%A]",     "it be")
    -- Single-word rules
    text = text:gsub("([%a])ing%f[%A]",       "%1in'")
    text = text:gsub("%f[%a]are%f[%A]",       "be")
    return text
end
