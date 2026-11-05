# Changelog

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
