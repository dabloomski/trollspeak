# TrollSpeak

**TrollSpeak** auto-translates your chat into troll-speak so you can stay in character without thinking about it. Type normally, TrollSpeak handles the rest: "the" becomes "da", "running" becomes "runnin'", "you" becomes "ya", and the Loa get mentioned more than they probably should.

Use `/troll on` to enable auto-translate for common channels, or pick specific ones with `/troll on guild`, `/troll on say`, etc. `/troll off` pauses it without touching your settings. Right-click the minimap icon to open settings, left-click to toggle on/off.

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
| `/troll <text>` | Translate and send to active channel |
| `/troll test <text>` | Translate and print locally — nothing sent |
| `/troll ooc <text>` | Out of Character, send without translation |
| `/troll on [channel]` | Enable auto-translate (no arg = all social channels) |
| `/troll off [channel]` | Disable auto-translate (no arg = pause all) |
| `/troll status` | Show current settings |
| `/troll config starter <0-100>` | Set starter phrase chance (default 15%) |
| `/troll config ending <0-100>` | Set ending phrase chance (default 40%) |
| `/troll add <original>\|<translation>` | Add a custom phrase |
| `/troll remove <original>` | Remove a custom phrase |
| `/troll list` | List all custom phrases |
| `/troll ui` | Open settings panel |
| `/troll who` | Survey the guild for TrollSpeak users and versions |

Channels: `say`, `yell`, `emote`, `party`, `guild` are enabled by `/troll on`. `raid` and `whisper` require explicit opt-in with `/troll on raid` etc.

---

## Settings panel

### Settings tab
- **Auto-Translate Channels** — toggle each channel independently
- **Probabilities** — sliders for starter chance (default 15%) and ending chance (default 40%)
- **Custom Starters** — add your own opener phrases (e.g. `Ey mon, ` — include the trailing space)
- **Custom Endings** — add your own closing phrases; end with `?` for the question pool, `!` for exclaim, anything else for neutral
- **Custom Phrases** — exact-match overrides; checked before everything else

### Phrases tab
Full reference of every built-in trigger and the phrases it can produce, with the actual output shown (not just pool names). Type in the search box to filter by trigger word or phrase text.

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

## Custom phrases

Add your own via the settings panel or `/troll add <original>|<translation>`. Custom phrases override built-in ones, so you can tweak anything you don't like.

```
/troll add lets go|Forward warriors, da Loa be wit us!
/troll list
/troll remove lets go
```

## Custom starters and endings

Custom starters and endings are mixed into the built-in pools — the addon picks randomly from all of them together. Add them on the **Settings** tab or they can also be added slash commands in the future.

For endings, the pool is chosen by the punctuation at the end of what you type:
- Ends with `?` → question pool
- Ends with `!` → exclaim pool  
- Anything else → neutral pool
