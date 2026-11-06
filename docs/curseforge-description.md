# DungeonManager

**Every dungeon quest in one run.**

DungeonManager shows you which dungeons fit your level, lists every dungeon quest for your faction – with quest giver, location and prerequisites – and tells you what to pick up before you go. In WoW Forever mob experience in dungeons is low; the quests are what count. Do them all in one visit.

Made for **WoW Forever**. **Requires Questie (QuestieDB).**

> Please report anything that looks wrong (see *Feedback* below).

---

## The dungeon list

Left-click the minimap button. Every leveling dungeon – the classics and the nine new Forever dungeons – in one list, coloured for your character:

- **Green** – in your range, and you still have open quests there
- **Grey-green** – in your range, but nothing open for you (no quests for your faction or class, or all done)
- **Orange** – you can enter, but it is too hard
- **Grey** – outleveled
- **Red** – you cannot enter yet (level or attunement missing)

Widen the recommended range with **−y / +x** (per character). Dungeons without quests for your faction say so – the Deadmines for the Horde, for example.

## The dungeon page

Click a dungeon:

- Range, entry level, group finder level, number of bosses, location
- A **schematic overview map** with legend for every classic dungeon – larger dungeons have an overview plus detail sheets; click the map to enlarge it. Maps for the new Forever dungeons follow.
- **Every quest** for your faction with its status: in your log, pick up, prerequisite open, starts in the dungeon, level too low, done. Quest chains show what has to come first. Done quests move to the bottom – still visible, so you can point your group to them.
- **Click a quest** to set a map marker at the quest giver.

## Works with DungeonJournal

[**DungeonJournal**](https://www.curseforge.com/wow/addons/dungeonjournal) by **ExehnTV** is *the* dungeon reference for WoW Forever – bosses, loot, maps and carefully maintained quest data. DungeonManager does not try to replace it. When DungeonJournal is installed, DungeonManager uses its quest lists, maps and quest pages and concentrates on what it adds on top: which dungeon fits your level right now, faction and Hardcore safety, the run preparation with route, and the group and guild comparison.

- The DungeonManager window shows **"DungeonJournal active"** when it is found; hover it for details.
- **Open in DungeonJournal** on every dungeon page; clicking a quest opens its page in DungeonJournal.
- Pawn upgrade arrows for all quest rewards, thanks to DungeonJournal's reward data.

All credit for that data goes to ExehnTV – if you use it, please give [DungeonJournal](https://www.curseforge.com/wow/addons/dungeonjournal) a thumbs up. Without DungeonJournal, DungeonManager falls back to its own lists and maps. The integration can be switched off in the settings.

## Class quests

Class quests of **all** classes are listed with their class icon – your own like any other quest, those of other classes in grey-green for planning with your group. When a player of that class is in your group, the quest is highlighted.

## Run preparation

Shift-click one or more dungeons to mark them for a run, then right-click the minimap button. DungeonManager lists every quest you still have to pick up – **grouped by place and sorted by route** – plus quests that start inside the dungeon and class quests for your group. A quest log check warns you when your log is about to run full.

## Faction safe and Hardcore protection

DungeonManager **never** shows you a quest giver or a turn-in of the other faction. On **Hardcore realms**, dungeons whose entrance lies in a hostile capital (Ragefire Chasm, Ruins of Lordaeron, Hall of Thanes, The Stockade) are hidden – nobody should be sent to their death by an addon. You can switch the protection on or off manually as well.

## Endgame and raids

Endgame dungeons and the raids opening on 9 December are listed for information; these tabs are completed after the launch.

## Commands

- `/dmgr` – dungeon list
- `/dmgr prep` – run preparation
- `/dmgr settings` – settings

## Requirements

- **WoW Forever**
- **Questie with QuestieDB** (QuestieDB must be enabled; the Questie map and tracker are optional)

## Languages

All Latin-script game clients. UI: English and German; French, Spanish, Italian and Portuguese follow.

## Works well with

- **DungeonJournal** by ExehnTV – see above
- **AtlasLoot**, **Pawn**, **TomTom** and **Questie** (quest XP) – optional, used when installed
- **LegacyManager** – Legacy points, Quick Swap and the Quick-Gain copilot
- **RecipeManager** – recipe vendors and Limited Supply
- **ConfigManager** – copy keybindings and settings between game versions

## Known limitations

- Entry levels of the new Forever dungeons and some quest givers will be verified in the live game after the launch.
- The overview maps are own schematic drawings, not to scale; uncertain spots are dashed. Maps for the new Forever dungeons follow.

## Feedback

Bugs, wrong quest givers or missing quests: please open an issue on [GitHub](https://github.com/psappz/DungeonManager/issues).

## License

GPL-3.0. Provided as is, without warranty. Source: [github.com/psappz/DungeonManager](https://github.com/psappz/DungeonManager)
