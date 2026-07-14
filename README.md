# TrollSpeak

*Two dialects, one addon: `/troll` for Caribbean-patois troll-speak, `/dwarf` for Scottish-brogue dwarf-speak.*

**TrollSpeak** auto-translates your chat as you type so you can stay in character without thinking about it — pick your dialect and go. As Troll: "the" becomes "da", "running" becomes "runnin'", "you" becomes "ya", and the Loa get mentioned more than they probably should. As Dwarf: "you" becomes "ye", "cannot" becomes "cannae", and the ancestors get invoked instead of the Loa. Both run through the same engine with their own word lists, phrases, and flavor — see [Word substitutions](#word-substitutions) / [Phrases](#phrases) for Troll and [Dwarf dialect](#dwarf-dialect) for Dwarf.

Use `/troll on` to enable auto-translate for common channels, or pick specific ones with `/troll on guild`, `/troll on say`, etc. `/troll off` pauses it without touching your settings. Right-click the minimap icon to open settings, left-click to toggle on/off. Auto-translate always uses one active dialect at a time (default Troll) — switch it with `/troll config dialect dwarf`.

Active dialect, on/off, and which channels are enabled are all saved **per character** — so your troll can auto-translate to Troll in guild chat while your dwarf alt auto-translates to Dwarf, without touching each other's settings. Starter/ending chance and your custom phrases/starters/endings are shared across your whole account instead, since those are more like vocabulary you build up over time.

The settings panel has two tabs. **Settings** lets you configure which channels are active, tune how often starter and ending phrases appear, and manage your own custom phrases, starters, and endings. **Phrases** is a searchable reference of every built-in trigger and the actual phrases it can produce — useful for sharing with guildies. Test a line before sending with `/troll test <text>`.

Custom phrases, starters, and endings are added through the settings panel or via slash commands, and survive addon updates. Custom phrases take priority over built-in ones, so you can override anything you don't like.

Built for **Darkspear Tribe** — a hardcore troll-only guild on WoW Classic Era.

---

## Installation

1. Download and unzip
2. Place the `TrollSpeak` folder in `World of Warcraft/_classic_era_/Interface/AddOns/`
3. Restart WoW or reload with `/reload`

---

## Commands

| Command | Description |
|---|---|
| `/troll <text>` | Translate to Troll and send to active channel |
| `/dwarf <text>` | Translate to Dwarf and send to active channel |
| `/troll test <text>` | Translate and print locally — nothing sent |
| `/troll ooc <text>` | Out of Character, send without translation |
| `/troll on [channel]` | Enable auto-translate (no arg = all social channels) |
| `/troll off [channel]` | Disable auto-translate (no arg = pause all) |
| `/troll status` | Show current settings, including active dialect |
| `/troll config starter <0-100>` | Set starter phrase chance (default 15%) |
| `/troll config ending <0-100>` | Set ending phrase chance (default 40%) |
| `/troll config dialect <troll\|dwarf>` | Set which dialect auto-translate uses |
| `/troll add <original>\|<translation>` | Add a custom phrase (Troll) |
| `/dwarf add <original>\|<translation>` | Add a custom phrase (Dwarf) |
| `/troll remove <original>` | Remove a custom phrase (Troll) |
| `/troll list` | List custom phrases (Troll) — use `/dwarf list` for Dwarf's |
| `/troll ui` | Open settings panel |
| `/troll who` | Survey the guild for TrollSpeak users and versions |

`/troll` and `/dwarf` share every command — `on`/`off`/`status`/`config`/`ui`/`who` are dialect-agnostic control commands, while `add`/`remove`/`list`/`test`/plain-text translation apply to whichever prefix you typed.

Channels: `say`, `yell`, `emote`, `party`, `guild` are enabled by `/troll on`. `raid` and `whisper` require explicit opt-in with `/troll on raid` etc. Auto-translate for these channels always uses this character's single active dialect (`/troll config dialect ...`) — there's no per-channel dialect, and channel/on-off settings don't carry over to your other characters.

---

## Settings panel

### Settings tab
- **Auto-Translate Channels** — toggle each channel independently
- **Probabilities** — sliders for starter chance (default 15%) and ending chance (default 40%), shared across both dialects
- **Custom Starters** — add your own opener phrases (e.g. `Ey mon, ` — include the trailing space)
- **Custom Endings** — add your own closing phrases; end with `?` for the question pool, `!` for exclaim, anything else for neutral
- **Custom Phrases** — exact-match overrides; checked before everything else

A **Dialect** dropdown next to the version header switches which dialect the Custom Starters/Endings/Phrases lists (and the Phrases tab) operate on — same setting as `/troll config dialect troll|dwarf`.

### Phrases tab
Full reference of every built-in trigger and the phrases it can produce for the currently selected dialect, with the actual output shown (not just pool names). Type in the search box to filter by trigger word or phrase text; switch dialects from the Settings tab to see the other one's triggers.

---

## Word substitutions

Common words are always swapped:

| You type | Troll says |
|---|---|
| the | da |
| this / that / they / them | dis / dat / dey / dem |
| think / thing / thanks | tink / ting / tanks |
| brother / mother / never / other | brothah / mothah / nevah / othah |
| you / your | ya |
| I am | I be |
| running / watching / going | runnin' / watchin' / goin' |
| are | be |
| going to | goin' ta |
| want to | wanna |
| have to | need ta |

---

## Phrases

Short phrases are matched exactly and replaced with troll-speak from a pool. A few examples:

| You type | Troll says (one of several) |
|---|---|
| `ty` / `thanks` / `thx` | *"tanks, mon"* / *"da Loa bless ya, brudda"* |
| `gg` / `gg wp` | *"good game, mon"* / *"da Loa favored us today, brudda"* |
| `gl` / `glhf` / `good luck` | *"da Loa smile on ya, mon"* / *"may da spirits guide ya, brudda"* |
| `gn` / `nn` | *"da Loa watch over ya sleep, mon"* |
| `np` / `no problem` | *"easy tings, brudda"* / *"da troll got ya, mon"* |
| `lol` / `haha` / `lmao` | *"Da spirits be laughin', mon!"* |
| `hi` / `hey` / `hello` | *"Wha' gwaan, brudda?"* / *"Da Loa bring ya to me, mon!"* |
| `bye` / `cya` / `later` | *"Walk good, mon."* / *"Da Loa watch ya path, brudda."* |
| `grats` / `gz` / `congrats` | *"Da tribe be proud of ya, mon!"* |
| `welcome` | *"De trolls welcome ya, brudda! Try not ta die, mon."* |
| `brb` | *"be back soon, mon"* |
| `afk` | *"da troll be away"* |
| `omw` | *"dis troll be on da way, mon"* |
| `oom` | *"dis troll be out of mana, mon"* |
| `need healing` | *"dis troll be dyin', send da healer!"* |
| `wipe` | *"da spirits take us dis time, mon"* |
| `rip` / `gg irl` | *"Da spirits take another one, mon. Respect."* |
| `be careful` | *"watch ya step mon, death be permanent"* |
| `don't die` | *"stay alive mon, da Loa not ready for ya yet"* |
| `good morning` / `gm` | *"Rise and shine, brudda! Da Loa got work for ya today!"* |

Phrases skip the starter/ending system — they're already complete troll sentences. The full list with all pool variants is visible in-game on the **Phrases** tab of the settings panel.

---

## Dwarf dialect

`/dwarf` runs the same engine as `/troll`, with its own Scottish-brogue word list and phrase pool instead of Caribbean pidgin.

### Word substitutions

| You type | Dwarf says |
|---|---|
| you / your | ye / yer |
| cannot / can't | cannae |
| don't / doesn't / didn't | dinnae / disnae / didnae |
| isn't / wasn't / aren't | isnae / wasnae / arenae |
| know | ken |
| small / little | wee |
| about / around / down / out / now | aboot / aroond / doon / oot / noo |
| going to | gonnae |
| want to | wanna |
| have to | need tae |
| running / watching / going | runnin' / watchin' / goin' |

### Phrases

| You type | Dwarf says (one of several) |
|---|---|
| `ty` / `thanks` / `thx` | *"much obliged, laddie"* / *"aye, much appreciated, lassie"* |
| `gg` / `gg wp` | *"good game, laddie"* / *"solid as stone, friend"* |
| `gl` / `glhf` / `good luck` | *"may the ancestors watch o'er ye, laddie"* |
| `gn` / `nn` | *"sleep well, lassie, the ancestors keep watch"* |
| `np` / `no problem` | *"nae bother, laddie"* |
| `lol` / `haha` / `lmao` | *"By me beard, that's funny, laddie!"* |
| `hi` / `hey` / `hello` | *"Well met, laddie!"* / *"Ey up, lassie!"* |
| `bye` / `cya` / `later` | *"Safe travels, friend."* |
| `grats` / `gz` / `congrats` | *"The ancestors be proud, laddie!"* |
| `welcome` | *"Grab an ale, laddie, ye're home now!"* |
| `brb` | *"back in a wee bit, laddie"* |
| `afk` | *"away from the forge"* |
| `omw` | *"on me way, laddie"* |
| `oom` | *"oot o' mana, laddie"* |
| `need healing` | *"I'm dyin' here, send the healer!"* |
| `wipe` | *"the ancestors took us this time"* |
| `rip` / `gg irl` | *"The ancestors welcome another home, friend."* |
| `be careful` | *"watch yer step, laddie, death be permanent"* |
| `don't die` | *"stay alive, laddie, the ancestors no' ready for ye yet"* |
| `good morning` / `gm` | *"Rise and shine, laddie!"* |

Same rules as Troll: exact-match phrases skip starters/endings, custom phrases override built-ins, and everything is case-insensitive.

---

## Custom phrases

Add your own via the settings panel or `/troll add <original>|<translation>` (or `/dwarf add ...` for the Dwarf dialect). Custom phrases override built-in ones, so you can tweak anything you don't like. Each dialect keeps its own separate list.

```
/troll add lets go|Forward warriors, da Loa be wit us!
/troll list
/troll remove lets go

/dwarf add lets go|Onward, laddies, tae glory!
/dwarf list
```

## Custom starters and endings

Custom starters and endings are mixed into the built-in pools — the addon picks randomly from all of them together. Add them on the **Settings** tab, which operates on whichever dialect is currently active (see [Settings panel](#settings-panel)). Each dialect keeps its own separate starters/endings.

For endings, the pool is chosen by the punctuation at the end of what you type:
- Ends with `?` → question pool
- Ends with `!` → exclaim pool  
- Anything else → neutral pool
