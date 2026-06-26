/* ============================================================
 * SugarCube Linter Testbed — Story JavaScript
 * ============================================================
 * Loaded at startup. Demonstrates: setup, Config, Setting,
 * Macro.add, Template.add, State.metadata, Save.onLoad/onSave,
 * Dialog, Engine, UI, UIBar, SimpleAudio, Fullscreen, event
 * listeners for all SugarCube navigation + dialog + system events.
 * ============================================================ */

/* ---------- `setup` — author-defined static data ---------- */
window.setup = window.setup || {};

setup.constants = {
        PARTY_SIZE: 4,
        MAX_LEVEL: 20,
        VERSION: "1.0.0-linter-testbed"
};

setup.helpers = {
        rollDice(sides = 6) {
                return random(1, sides);
        },
        formatGold(amount) {
                return `${amount}g`;
        },
        capitalize(str) {
                return str ? str.toUpperFirst() : "";
        }
};

/* Add a function from a [script]-tagged passage (see StoryScriptTagDemo) */
setup.greetFromScript = setup.greetFromScript || function (name) {
        return `Hi ${name} from setup!`;
};

/* ---------- `Config` — SugarCube configuration ---------- */
Config.debug = false;                       // Enable debug mode
Config.history.controls = true;             // Show back/forward UI buttons
Config.history.maxStates = 40;              // Max history moments
Config.macros.maxLoopIterations = 1000;     // Safety limit for <<for>>
Config.macros.typeSkipKey = " ";            // Skip key for <<type>> macro
Config.macros.typeVisitedPassages = true;   // <<type>> animates on revisits
Config.addVisitedLinkClass = true;          // Add .link-visited to visited links
Config.loadDelay = 0;                       // Loading screen delay (ms)
Config.passages.displayTitles = true;       // Update document.title per passage
Config.passages.transitionOut = 0;          // Outgoing passage transition (ms)
Config.saves.maxAutoSaves = 1;              // Number of auto-saves
Config.saves.maxSlotSaves = 8;              // Number of save slots
Config.saves.isAllowed = function (saveType) {
        // Disallow saving during battles
        return !tags().includes("battle");
};
Config.saves.id = "linter-testbed";         // Save slot namespace
Config.saves.version = 1;                   // Save schema version (for migrations)
Config.saves.descriptions = function (save) {
        return `${save.metadata?.description ?? "Save"} — ${new Date(save.date).toLocaleString()}`;
};

/* ---------- `Setting` — built-in settings dialog ---------- */
Setting.addHeader("Gameplay");

Setting.addToggle("hardcoreMode", {
        label: "Hardcore mode (one life)",
        default: false,
        desc: "If enabled, dying ends the run permanently.",
        onInit: function () { console.log("[Setting] hardcoreMode init"); },
        onChange: function () { console.log("[Setting] hardcoreMode changed:", settings.hardcoreMode); }
});

Setting.addList("difficulty", {
        label: "Difficulty",
        list: ["Easy", "Normal", "Hard"],
        default: "Normal",
        desc: "Choose the difficulty level.",
        onChange: function () { console.log("[Setting] difficulty:", settings.difficulty); }
});

Setting.addRange("textSpeed", {
        label: "Text speed (ms per char)",
        min: 0,
        max: 200,
        step: 5,
        default: 40,
        desc: "Speed of {{{<<type>>}}} macro output.",
        onChange: function () { console.log("[Setting] textSpeed:", settings.textSpeed); }
});

Setting.addHeader("Audio");

Setting.addToggle("audioEnabled", {
        label: "Enable audio",
        default: true,
        onChange: function () {
                if (settings.audioEnabled) {
                        SimpleAudio.unmute();
                } else {
                        SimpleAudio.mute();
                }
        }
});

Setting.addRange("masterVolume", {
        label: "Master volume",
        min: 0,
        max: 1,
        step: 0.05,
        default: 0.7,
        onChange: function () { SimpleAudio.volume(settings.masterVolume); }
});

Setting.addHeader("Accessibility");

Setting.addValue("colorScheme", {
        default: "auto",
        onChange: function () { console.log("[Setting] colorScheme:", settings.colorScheme); }
});

/* NOTE: SugarCube 2.37.0 has no Setting.addText method — only addHeader, addToggle,
 * addList, addRange, and addValue. To display static text in the settings dialog,
 * use addHeader with a description. */
Setting.addHeader("Notes", "Custom accessibility notes go here.");

/* ---------- `Macro.add` — custom macro ---------- */
Macro.add("emojify", {
        skipArgs: false,
        handler() {
                const map = {
                        smile: "😊",
                        heart: "❤️",
                        star: "⭐",
                        crown: "👑",
                        frown: "☹️"
                };
                const key = this.args[0];
                const emoji = map[key] ?? "❓";
                $(this.output).wiki(`<span class="emoji emoji-${key}">${emoji}</span>`);
        }
});

/* A container macro (uses payload contents) */
Macro.add("banner", {
        tags: null,
        handler() {
                const contents = this.payload[0].contents;
                $(this.output).wiki(`<div class="custom-banner">${contents}</div>`);
        }
});

/*
 * {{{...}}} — inline code styling macro.
 *
 * Used throughout the testbed to wrap macro/symbol names (e.g. {{{<<set>>}}})
 * for monospaced display. The payload contents are output as escaped text inside a
 * <span class="code"> so that literal `<<set>>` etc. show up as text rather than being
 * invoked as macros. SugarCube's container-macro parser hands us the raw source text
 * between `{{{` and `}}}`, so nested `<<...>>` sequences are NOT invoked.
 */
Macro.add("code", {
        tags: null,
        handler() {
                if (this.payload.length === 0) {
                        return; /* empty {{{}}} */
                }
                const text = this.payload[0].contents;
                jQuery(document.createElement("span"))
                        .addClass("code")
                        .text(text)
                        .appendTo(this.output);
        }
});

/* ---------- `Template.add` — ?name markup ---------- */
Template.add("greeting", () => "Hello");
Template.add("username", function () {
        return State.variables.playerName || "Traveler";
});
Template.add("random-num", () => String(random(1, 100)));

/* Array form — SugarCube picks one entry at random each render */
Template.add("random-greeting", ["Hi", "Hey", "Howdy", "Greetings", "Salutations"]);

/* String form — simple constant substitution */
Template.add("story-name", Story.name);

/* ---------- `Save.onLoad` / `Save.onSave` — save hooks ---------- */
Save.onLoad.add(function (save, details) {
        console.log("[Save.onLoad]", details.type, save);
        if (save.version !== Config.saves.version) {
                console.warn("[Save.onLoad] Version mismatch — migrating...");
                save.version = Config.saves.version;
        }
});

Save.onSave.add(function (save, details) {
        console.log("[Save.onSave]", details.type, save);
        save.metadata = save.metadata || {};
        save.metadata.savedAt = Date.now();
});

/* ---------- Event listeners ---------- */

// :storyready — fires once at startup after SugarCube is fully initialized
$(document).on(":storyready", function () {
        console.log("[Event] :storyready — story is ready");
});

// Navigation events (in order)
$(document).on(":passageinit", function (ev) {
        console.log("[Event] :passageinit", ev.detail.passage.name);
});

$(document).on(":passagestart", function (ev) {
        console.log("[Event] :passagestart", ev.detail.passage.name);
});

$(document).on(":passagerender", function (ev) {
        console.log("[Event] :passagerender", ev.detail.passage.name);
});

$(document).on(":passagedisplay", function (ev) {
        console.log("[Event] :passagedisplay", ev.detail.passage.name);
});

$(document).on(":passageend", function (ev) {
        console.log("[Event] :passageend", ev.detail.passage.name);
});

// Dialog events
$(document).on(":dialogopening", function () { console.log("[Event] :dialogopening"); });
$(document).on(":dialogopened",  function () { console.log("[Event] :dialogopened");  });
$(document).on(":dialogclosing", function () { console.log("[Event] :dialogclosing"); });
$(document).on(":dialogclosed",  function () { console.log("[Event] :dialogclosed");  });

// System events
$(document).on(":enginerestart", function () { console.log("[Event] :enginerestart"); });
$(document).on(":uiupdate",      function () { console.log("[Event] :uiupdate");      });

// Typing events
$(document).on(":typingstart",   function () { console.log("[Event] :typingstart");   });
$(document).on(":typingstop",    function () { console.log("[Event] :typingstop");    });
$(document).on(":typingcomplete",function () { console.log("[Event] :typingcomplete");});

// Custom event (triggered from PassageDone when a battle passage loads)
$(document).on(":battlestart", function () {
        console.log("[Event] :battlestart — a battle passage was just displayed");
        SimpleAudio.select("battle").play();
});

/* ---------- Example: override navigation conditionally ---------- */
Config.navigation.override = function (destName) {
        // If player has the "cursed" flag, redirect to "Cursed" passage
        if (State.variables.flags && State.variables.flags.cursed && destName !== "Cursed") {
                return "Cursed";
        }
        return undefined; // pass through
};

/* ---------- Example: pre-render hook on passage text ---------- */
Config.passages.onProcess = function (passage) {
        /* SugarCube calls onProcess with an object: { title, tags, text }
         * The function MUST return a string (the processed passage text).
         * Returning anything else breaks downstream Wikification. */
        if (passage == null || typeof passage.text !== "string") {
                return "";
        }
        // Strip trailing whitespace from each line
        return passage.text.split("\n").map(l => l.replace(/\s+$/, "")).join("\n");
};

/* ---------- Example: debug-only postdisplay task via event ---------- */
if (Config.enableOptionalDebugging) {
        $(document).on(":passagedisplay", function (ev) {
                const p = ev.detail.passage;
                $("#passages").prepend(`<div class="debug-banner">[DEBUG] ${p.name} (tags: ${p.tags.join(", ")})</div>`);
        });
}

/* ---------- Utility: expose via setup for in-passage use ---------- */
setup.logStoryInfo = function () {
        console.table({
                title: Story.name,
                ifid: Story.ifId,
                passageCount: Story.size,
                turns: State.turns
        });
};
