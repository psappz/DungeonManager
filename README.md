# DungeonManager

Dungeon planner for **WoW Forever**. DungeonManager shows which dungeons fit your level, lists every dungeon quest with quest giver, location and prerequisites, and tells you what to pick up before you go – so you can do all quests of a dungeon in a single run.

**Requires Questie (QuestieDB).** QuestieDB must be installed and enabled; the Questie map and tracker are optional.

## Features (v0.9)

- **Leveling list** with colours: green = recommended and open quests for you, grey-green = recommended but nothing open for you, orange = can enter but too hard, grey = outleveled, red = cannot enter (level or attunement). Widen the recommended range with −y / +x per character.
- **Detail view** per dungeon: range, entry level, group finder level, bosses, schematic overview maps for all 20 classic dungeons (larger dungeons with an overview and several sheets; click to enlarge) and every quest with status (in log, pick up, prerequisite open, starts in the dungeon, level too low, done). Done quests move to the bottom. Click a quest to set a map marker at the quest giver.
- **Faction safe**: quest givers and turn-ins of the other faction are never shown. Dungeons without quests for your faction are marked.
- **Class quests** of all classes, with class icon. Other classes in grey-green (planning for the group); highlighted when that class is in your group.
- **Hardcore protection**: dungeons whose entrance lies in a hostile capital (Ragefire Chasm, Ruins of Lordaeron, Hall of Thanes, The Stockade) are hidden on Hardcore realms (automatic, on or off).
- **Run preparation** (right-click on the minimap button): mark one or more dungeons (Shift-click), and DungeonManager lists all quests to pick up, grouped by place and sorted by route, plus a quest log check.
- **Endgame** and **Raids** tabs (information; completed after the launch).

Slash commands: `/dmgr`, `/dmgr prep`, `/dmgr settings`.

## Data sources

- **QuestieDB** (GPL-3.0): quests, quest givers, positions, prerequisites – read at runtime.
- `Data/Dungeons.lua`: researched dungeon data (ranges, entry levels, locations, attunements) and a hand list of dungeon quests, including the new Forever dungeons.
- `docs/maps`: source SVGs and legends of the schematic maps (own drawings, not to scale).

## Languages

All Latin-script game clients. UI texts: English and German; French, Spanish, Italian and Portuguese follow.

## License

GPL-3.0 – see [LICENSE](LICENSE). Provided as is, without warranty. Third-party libraries in `Libs/` keep their own licenses (LibStub public domain, CallbackHandler-1.0 / LibDataBroker-1.1 / LibDBIcon-1.0 BSD-style).
