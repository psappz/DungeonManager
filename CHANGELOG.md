# Changelog

## 1.5.0

### New
- **DungeonJournal (Exehn) integration.** With DungeonJournal installed, DungeonManager leaves the per-dungeon reference to it and keeps its own strengths (recommendations by level, faction and Hardcore safety, run preparation, group and guild comparison):
  - Quest lists come from DungeonJournal, which is maintained for Forever – changed quest chains show up there first. QuestieDB stays for completion state and coordinates; quests QuestieDB does not know yet are still shown.
  - "Open in DungeonJournal" button in the detail view; clicking a quest opens its page in DungeonJournal, right-click sets the map marker.
  - DungeonJournal's maps replace DungeonManager's schematic maps.
  - Pawn upgrade arrow for every quest (DungeonJournal knows the reward items), not only for quests in your log.
  - Shareability from DungeonJournal's audited data.
- Option to switch this off; without DungeonJournal everything works as before.

## 1.4.0

### New
- **Guild quest comparison (opt-in, off by default):** guild members with DungeonManager who need the same quests of their marked dungeons are listed next to the quest (up to three names) – handy to find a group.
- **Manager family bar** in the settings is clickable: opens the other installed Manager addons.

## 1.3.0

### New
- **Group quest comparison (opt-in).** Members with DungeonManager see who still needs a quest of the marked dungeons and who already has it in the log ("can share it"). Off by default; only quest IDs of the marked dungeons are exchanged, only within the group.
- **Post to group.** One click in the run preparation posts what to pick up, zone by zone, to party/raid chat – for members without the addon.
- **Not shareable** quests are marked in the detail view, the run preparation and the chat post.
- **TomTom:** if installed, its arrow points to the quest giver (option).
- **Pawn:** upgrade arrow for rewards of quests in your log (option; QuestieDB has no reward items, so quests not yet accepted have no arrow).
- **AtlasLoot:** "Loot" button in the detail view opens the dungeon in AtlasLoot (AtlasLoot Classic Forever and other AtlasLootClassic forks).
- **Quest XP** from Questie in the detail view and the run preparation (sum of the run).
- **LegacyManager:** dungeons whose range reaches your next Legacy class milestone are marked "+N Legacy at level X".
- **Manager family** line in the settings; public API (`DungeonManagerAPI`) for LegacyManager and the coming RaidManager.
- French, Spanish, Italian and Portuguese interface (map legends: English and German).
- `/dmgr int` shows which integrations were found.

### Fixed
- Quests of the other faction could slip through when QuestieDB lists the giver as friendly to both factions (e.g. "In Search of Thaelrid" from Dawnwatcher Shaedlass in Darnassus for Horde characters). Givers in the other faction's capitals are never shown, and a quest whose prerequisite chain starts on the other side is hidden as well.
- AtlasLoot opened behind the DungeonManager window. The button is now called "Open in AtlasLoot".

### Look
- Own flat buttons, checkboxes, input fields and close button instead of Blizzard's templates; buttons grow with their (translated) text.

## 0.9.0.5

- Fix: maps still showed as a green square when files of an older version were left in the addon folder (the client picked the old BLP file of the same name). Map textures now have their own names (dm_*.tga).

## 0.9.0.4

- Own icon in the style of the Manager addon family (minimap button, addon list)
- Minimap button is created a moment after login, so minimap skins (e.g. EllesmereUI) no longer hide it and collectors (MinimapButtonButton) pick it up

## 0.9.0.3

- Fix: the dungeon maps were still a green square. The client only reads 32-bit TGA textures (with alpha channel); the maps are now 32-bit TGA with RLE compression, like the textures of other addons (e.g. Questie).

## 0.9.0.2

- Fix: the dungeon maps showed as a green square in the Forever client. The maps are now shipped as uncompressed TGA textures.

## 0.9.0.1 (unreleased)

- Schematic overview maps for all 20 classic dungeons (49 map sheets, own drawings, not to scale)
- Larger dungeons: overview plus detail sheets, switchable in the dungeon view (Stratholme: living and undead side)
- Click the map to enlarge or shrink it
- Legend per sheet; uncertain spots are dashed and counted below the legend
- Quest data read through LibQuestieDB (QuestieDB addon, as used by Questie 12.5)
- Quest log check counts the quests itself (the Forever client returns no quest count)
- Events unknown to the client are skipped instead of stopping the addon from loading

## 0.9.0 (unreleased)

First version for WoW Forever, not yet tested in the live client.

- Leveling list with colour logic, −y/+x range per character, Shift-click to mark dungeons for a run
- Detail view: dungeon data, quests from QuestieDB plus a researched hand list, status per quest, prerequisites, class quests, map marker at the quest giver
- Faction filter (no hostile quest givers), hardcore protection for entrances in hostile capitals
- Schematic maps for Blackfathom Deeps and The Stockade
- Run preparation: quests to pick up for the marked dungeons, grouped by place and sorted by route, quest log check
- Endgame and Raids tabs (information)
- UI in English and German
