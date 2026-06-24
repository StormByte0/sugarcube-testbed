# SugarCube Linter Testbed

A multi-file Tweego project in the **SugarCube 2** story format (v2.37.0),
designed to exercise the bulk of SugarCube's usable features **without external
dependencies**. Intended as a reference corpus for testing Twine / SugarCube
linters with JavaScript support.

## Project layout

```
tweego-sugarcube-fixed/
├── build.sh                    # Linux/macOS build script
├── build.bat                   # Windows CMD build script
├── build.ps1                   # Windows PowerShell build script (supports -Watch)
├── README.md                   # this file
└── src/
    ├── 00-meta.twee            # StoryData, StoryTitle, StoryDisplayTitle, StorySubtitle, StoryAuthor, StoryBanner
    ├── 01-init.twee            # StoryInit (variable init, audio caching, PRNG seed, metadata)
    ├── 02-ui.twee              # PassageReady, PassageHeader, PassageFooter, PassageDone, StoryCaption, StoryMenu
    ├── 10-start.twee           # Start (main hub)
    ├── 20-variables.twee       # <<set>>, <<unset>>, <<capture>>, <<run>>
    ├── 21-control.twee         # <<if>>, <<switch>>, <<for>>, <<break>>, <<continue>>
    ├── 22-display.twee         # <<print>>, <<=>>, <<->>, <<include>>, <<nobr>>, <<silent>>, <<type>>, <<do>>, <<redo>>
    ├── 23-interactive.twee     # <<link>>, <<button>>, <<textbox>>, <<textarea>>, <<numberbox>>, <<checkbox>>, <<radiobutton>>, <<listbox>>, <<cycle>>, <<option>>, <<optionsfrom>>, <<linkappend>>, <<linkprepend>>, <<linkreplace>>
    ├── 24-navigation.twee      # <<back>>, <<return>>, <<goto>>, <<actions>>, <<choice>>, all link forms
    ├── 25-dom.twee             # <<append>>, <<prepend>>, <<replace>>, <<remove>>, <<copy>>, <<addclass>>, <<removeclass>>, <<toggleclass>>
    ├── 26-misc.twee            # <<done>>, <<repeat>>, <<stop>>, <<timed>>, <<next>>
    ├── 27-markup.twee          # all SugarCube markup features
    ├── 28-operators.twee       # TwineScript operators and built-in functions
    ├── 29-js-api.twee          # SugarCube JS API: setup, State, Story, Config, Engine, Dialog, Save, UI, UIBar, SimpleAudio, Fullscreen, Macro, Template
    ├── 30-nobr.twee            # [nobr]-tagged passage
    ├── 31-widgets.twee         # [widget]-tagged passage + showcase
    ├── 32-script-passage.twee  # [script]-tagged passage + showcase
    ├── 33-stylesheet-passage.twee  # [stylesheet]-tagged passage + showcase
    ├── 40-story-areas.twee     # TownSquare, Healer, Bard, ForestEdge, ForestDeep, DungeonEntrance
    ├── 41-screens.twee         # CharacterSheet, InventoryScreen, Achievements, SettingsScreen, ResetGame
    ├── 42-custom-macro.twee    # demo of a custom Macro.add-defined macro
    ├── 43-links.twee           # consolidated links & navigation reference (all link forms in one place)
    ├── 44-templates.twee       # Template reference (function, array, and string forms)
    ├── 50-story.twee           # Playable narrative: StoryPrologue, MountainPass, CoastalRoad, etc.
    ├── 51-combat.twee          # Turn-based combat: CombatEncounter + EnemyTurn partial
    ├── 60-edge-cases.twee      # Tricky-but-valid syntax for linter stress-testing
    ├── story.js                # main Story JavaScript (Config, Setting, Macro, Template, Save, events)
    ├── story.css               # main Story Stylesheet (linter-relevant selectors)
    ├── audio/                  # audio assets (.mp3 etc.) → become audio passages
    └── images/                 # image assets (.png etc.) → become image passages
```

## Building

### Linux / macOS

```bash
# Requires Tweego on your PATH with the SugarCube-2 story format installed.
# Install: https://www.motoslave.net/tweego/
chmod +x build.sh
./build.sh
# → dist/story.html
```

Alternatively:

```bash
tweego -f sugarcube-2 -t -l -o dist/story.html src/
```

### Windows

```bat
:: CMD
build.bat
:: → dist\story.html
```

Or PowerShell:

```powershell
.\build.ps1
# → dist\story.html

.\build.ps1 -Watch         # rebuild on file change
.\build.ps1 -Output out.html
```

> **Note:** `build.ps1` searches common install locations for `tweego.exe` if it
> isn't on your PATH. You can also drop `tweego.exe` directly in the project root.

## Feature coverage

### Special passages

| Passage | File | Notes |
|---|---|---|
| `StoryData` | `00-meta.twee` | JSON: ifid, format, format-version, start, tag-colors |
| `StoryTitle` | `00-meta.twee` | Plain-text title |
| `StoryDisplayTitle` | `00-meta.twee` | Markup-enabled title (v2.31.0+) |
| `StorySubtitle` | `00-meta.twee` | UI bar subtitle |
| `StoryAuthor` | `00-meta.twee` | UI bar author byline |
| `StoryBanner` | `00-meta.twee` | UI bar banner |
| `StoryCaption` | `02-ui.twee` | UI bar caption — stats + quest log |
| `StoryMenu` | `02-ui.twee` | UI bar story menu |
| `StoryInit` | `01-init.twee` | Variable init, audio cache, PRNG seed, metadata |
| `PassageReady` | `02-ui.twee` | Pre-render hook (no output) |
| `PassageHeader` | `02-ui.twee` | Prepended to every passage |
| `PassageFooter` | `02-ui.twee` | Appended to every passage |
| `PassageDone` | `02-ui.twee` | Post-display hook (DOM/event-safe) |
| `Start` | `10-start.twee` | Main hub |

### Special tags exercised

| Tag | Used in |
|---|---|
| `widget` | `31-widgets.twee` |
| `script` | `32-script-passage.twee` |
| `stylesheet` | `33-stylesheet-passage.twee` |
| `nobr` | `30-nobr.twee` |
| Custom (story-area) tags | `forest`, `town`, `dungeon`, `battle`, `hub`, `docs` |

### Macro groups covered

- **Variables & scripting**: `<<set>>`, `<<unset>>`, `<<capture>>`, `<<run>>`, `<<script>>`
- **Display**: `<<print>>`, `<<=>>`, `<<->>`, `<<include>>`, `<<nobr>>`, `<<silent>>`, `<<type>>`, `<<do>>`, `<<redo>>`
- **Control**: `<<if>>`/`<<elseif>>`/`<<else>>`, `<<switch>>`/`<<case>>`/`<<default>>`, `<<for>>` (3-part + range), `<<break>>`, `<<continue>>`
- **Interactive**: `<<link>>`, `<<button>>`, `<<linkappend>>`, `<<linkprepend>>`, `<<linkreplace>>`, `<<textbox>>`, `<<textarea>>`, `<<numberbox>>`, `<<checkbox>>`, `<<radiobutton>>`, `<<listbox>>`, `<<cycle>>`, `<<option>>`, `<<optionsfrom>>`
- **Navigation**: `<<back>>`, `<<return>>`, `<<goto>>`, `<<actions>>` (deprecated), `<<choice>>` (deprecated)
- **DOM**: `<<append>>`, `<<prepend>>`, `<<replace>>`, `<<remove>>`, `<<copy>>`, `<<addclass>>`, `<<removeclass>>`, `<<toggleclass>>`
- **Misc**: `<<done>>`, `<<repeat>>`, `<<stop>>`, `<<timed>>`, `<<next>>`, `<<widget>>`
- **Audio**: `<<cacheaudio>>` (in `StoryInit`)
- **Custom** (via `Macro.add` in `story.js`): `<<emojify>>` (void macro), `<<banner>>` (container macro with payload)

### Links covered (see `43-links.twee` for the consolidated reference)

- Simple: `[[Passage]]`, `[[Text|Passage]]`
- Arrow forms: `Text->Passage`, `Passage<-Text`
- With setters: `[[Text|Passage][$var to val]]`, `[[Text|Passage][$arr.pushUnique(x)]]`
- Image links: `[img[src][Passage]]`, `[img[Title|src][Passage]]`
- HTML anchor with `data-passage` / `data-setter`
- `<<link>>` — text-only, with-target, with-body (setter), with image label, with backtick expression arg
- `<<button>>` — plain and with-target
- `<<back>>`, `<<return>>`, `<<goto>>`, `<<actions>>` (deprecated), `<<choice>>` (deprecated)
- `.link-visited` class (only when `Config.addVisitedLinkClass = true`)

### Widgets covered (see `31-widgets.twee`)

Defined in a `[widget]`-tagged passage; called from any other passage:

- `<<hello "Name">>` — void widget with positional args (`_args[0]`)
- `<<statblock "Label" $value>>` — widget with multiple positional args
- `<<quote>>...<</quote>>` — **container widget** (uses `_contents`)
- `<<randomcolor>>` — widget returning a random array element
- `<<ifhasinv "Item">>` — widget with conditional logic
- `_args`, `_args.raw`, `_args.full`, `_args.name`, `_contents` all exercised

### Custom macros covered (defined in `story.js` via `Macro.add`)

- `<<emojify "smile">>` — void macro with a key→emoji lookup table
- `<<emojify `(_feeling is "happy") ? "smile" : "frown"`>>` — backtick expression arg
- `<<banner>>...<</banner>>` — **container macro** (uses `this.payload[0].contents`)
- `Macro.has()`, `Macro.get()` queried from passages

### Templates covered (see `44-templates.twee`; defined in `story.js`)

Registered via `Template.add()` and invoked with `?name` markup:

- `?greeting` — function form
- `?username` — function form reading `State.variables`
- `?random-num` — function form returning a fresh random number per render
- `?random-greeting` — **array form** (SugarCube picks one at random each render)
- `?story-name` — **string form** (constant substitution)
- `Template.has()` queried from passages

### TwineScript operators

- Assignment: `to`, `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `++`, `--`
- Comparison: `is`, `isnot`, `eq`, `neq`, `gt`, `gte`, `lt`, `lte` + JS `===`, `!==`, `>`, `>=`, `<`, `<=`
- Logical: `and`, `or`, `not`, `&&`, `||`, `!`
- Defined checks: `def`, `ndef`
- Arithmetic: `+`, `-`, `*`, `/`, `%`, `**`
- Member access: `.prop`, `[index]`, `["key"]`
- SugarCube array methods: `.first()`, `.last()`, `.includes()`, `.includesAll()`, `.includesAny()`, `.pushUnique()`, `.deleteWith()`, `.count()`, `.toShuffled()`, `.random()`
- SugarCube string methods: `.toUpperFirst()`, `.count()`, `.includes()`
- SugarCube number methods: `.clamp(min, max)`
- Ternary: `? :` (JS context)
- Backtick expression args: `` <<emojify `(_feeling is "happy") ? "smile" : "frown"`>> ``

### Built-in functions

`clone`, `either`, `random`, `randomFloat`, `visited`, `visitedTags`, `hasVisited`, `lastVisited`, `passage`, `previous`, `tags`, `turns`, `time`, `memorize`, `recall`, `forget`, `setPageElement`, `triggerEvent`, `importScripts`, `importStyles`

### Markup features

Headings (h1–h6), `//em//`, `''bold''`, `__u__`, `==s==`, `^^sup^^`, `~~sub~~`, ordered/unordered lists, nested lists, blockquotes, inline/block code, hr, `"""verbatim"""`, `<nowiki>`, `<html>`, `@@.class;...@@`, `@@#id;style;...@@`, `?template`, all 3 comment styles, line continuation `\`, link forms (`[[X]]`, `[[X|Y]]`, `[[X][setter]]`, arrow forms), `[img[...]]`, naked variables.

### JavaScript API (used in passages and story.js)

- `setup` — author static data
- `State.variables`, `State.temporary`, `State.passage`, `State.turns`, `State.length`, `State.metadata`, `State.prng`, `State.setVar`, `State.getVar`
- `Story.get`, `Story.has`, `Story.filter`, `Story.find`, `Story.name`, `Story.ifId`
- `Config.*` (debug, history, macros, passages, navigation, saves, ui, audio)
- `Macro.add`, `Macro.has`, `Macro.get`, `Macro.tags`
- `Template.add`, `Template.has`, `Template.get`
- `Engine.play`, `Engine.restart`
- `Dialog.create`, `Dialog.wiki`, `Dialog.open`, `Dialog.close`, `Dialog.isOpen`
- `Save.disk.save`, `Save.browser.auto.save`, `Save.onLoad.add`, `Save.onSave.add`
- `UI.saves`, `UI.settings`, `UI.restart`, `UI.update`
- `UIBar.show`, `UIBar.hide`, `UIBar.toggle`, `UIBar.stow`, `UIBar.unstow`
- `SimpleAudio.select`, `.play`, `.pause`, `.mute`, `.unmute`, `.volume`
- `Fullscreen.toggle`, `.isEnabled`, `.isFullscreen`
- jQuery extensions: `$.wiki`, `$(sel).wiki`
- Events: `:storyready`, `:passageinit`, `:passagestart`, `:passagerender`, `:passagedisplay`, `:passageend`, `:dialogopening`, `:dialogopened`, `:dialogclosing`, `:dialogclosed`, `:enginerestart`, `:uiupdate`, `:typingstart`, `:typingstop`, `:typingcomplete`

### Setting API (in story.js)

All 5 control kinds exercised: `Setting.addHeader`, `Setting.addToggle`, `Setting.addList`, `Setting.addRange`, `Setting.addValue`. With `onInit` and `onChange` callbacks.

> **Note:** A previous version of this README mentioned `Setting.addText`. That method does **not** exist in SugarCube 2.37.0 — only `addHeader`, `addToggle`, `addList`, `addRange`, and `addValue` are available. To display static text in the settings dialog, use `Setting.addHeader(name, desc)`.

### Custom `<<code>>` macro (defined in story.js)

The testbed uses `<<code>>...<</code>>` throughout (150 occurrences across 17 files) to wrap macro names like `<<set>>`, `<<if>>`, etc. for monospaced display. This macro is **defined in `story.js`** as a container macro that outputs its raw payload as escaped text inside a `<span class="code">`. SugarCube's container-macro parser hands us the raw source text between `<<code>>` and `<</code>>`, so nested `<<...>>` sequences are NOT invoked as macros.

### CSS selectors covered (story.css)

`html`, `body`, `body[data-tags~="forest"]`, `body[data-tags~="dungeon"]`, `body[data-tags~="battle"]`, `#story`, `#passages`, `.passage`, `.link-internal`, `.link-external`, `.link-broken`, `.link-disabled`, `.link-visited`, `.passage-header`, `.passage-footer`, `.hud-hp`, `.hud-gold`, `.hud-level`, `#story-banner`, `#story-title`, `#story-subtitle`, `#story-author`, `#story-caption`, `#menu-story`, `.widget-hello`, `.stat-block`, `.widget-quote`, `.macro-type`, `.macro-type-done`, `.macro-type-cursor`, `.macro-append-insert`, `.macro-prepend-insert`, `.macro-replace-insert`, `.error-view`, `#ui-dialog-body`, `.from-stylesheet-tag`, `.debug-banner`, `.custom-banner`, `.emoji`, `.code`.

## Things deliberately included for linter coverage

A few **deprecated** macros (`<<actions>>`, `<<choice>>`) are present in
`24-navigation.twee` so a linter can verify deprecation-warning behavior. They
are clearly commented as deprecated.

The `[script]` and `[stylesheet]` passage tags are used in
`32-script-passage.twee` and `33-stylesheet-passage.twee` even though Tweego
authors normally use `.js`/`.css` files instead — this is to exercise tag-based
handling for linters that need to support Twine 1 / Twee v1 workflows.

## Things deliberately NOT included (would need external dependencies)

- No external JS libraries (jQuery is shipped by SugarCube itself).
- No external CSS frameworks.
- No image/audio files are bundled (paths like `audio/bgm.mp3` are referenced
  in `<<cacheaudio>>` for syntax coverage only — supply your own assets if you
  want them to actually play).
- No Twine 2 GUI-only features (story-format metadata editor etc.).

## IFID

The story has a fixed IFID (`D674C58C-DEFA-4F70-B7A2-27742230C0FC`) in
`StoryData`. Replace it with a fresh one if you fork this project — generate
one at https://tads.org/ifid/ or via `uuidgen`.
