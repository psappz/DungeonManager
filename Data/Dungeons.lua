-- DungeonManager - dungeon master data (researched, verify in game after the Forever launch)
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...

-- Fields
--   key, name = English name, de = German name (used when the client gives no localized name)
--   area      = AreaTable ID of the instance (QuestieDB zoneOrSort), nil for new Forever dungeons
--   low, high = recommended range (green with -y/+x), gf = group finder level, min = entry level (nil = unknown)
--   bosses, zone / zoneDE = location text
--   capital   = faction whose capital holds the entrance ("Horde" / "Alliance") -> hardcore protection
--   attune    = { Horde = questID, Alliance = questID } completed quest that grants access
--   quests    = researched quest IDs (hand list), added to the QuestieDB quests of `area`
--   phase     = "level" | "end"
ns.Dungeons = {
    { key = "rfc", name = "Ragefire Chasm", de = "Ragefireabgrund", area = 2437, low = 13, high = 18, gf = 13, min = 10, bosses = 4,
      zone = "Orgrimmar, Cleft of Shadow", zoneDE = "Orgrimmar, Kluft der Schatten", capital = "Horde",
      quests = { 5725, 5723, 5722, 5761, 5728 } },
    { key = "hot", name = "Hall of Thanes", new = true, low = 13, high = 20, gf = 13, bosses = 4,
      zone = "Beneath Ironforge, Dun Morogh", zoneDE = "Unter Eisenschmiede, Dun Morogh", capital = "Alliance",
      quests = { 96394, 96395, 96403, 96393, 98423 } },
    { key = "rol", name = "Ruins of Lordaeron", new = true, low = 15, high = 22, gf = 15, bosses = 7,
      zone = "Ruins above the Undercity, Tirisfal Glades", zoneDE = "Ruinen über Unterstadt, Tirisfal", capital = "Horde",
      quests = { 92422, 92421, 95216, 97288, 95204, 95189, 95250, 95195, 92415 } },
    { key = "wc", name = "Wailing Caverns", de = "Höhlen des Wehklagens", area = 718, low = 15, high = 24, gf = 17, min = 10, bosses = 8,
      zone = "The Barrens, southwest of the Crossroads", zoneDE = "Brachland, südwestlich des Wegekreuzes",
      quests = { 962, 914, 1491, 959, 1487, 1486, 6981 } },
    { key = "dm", name = "The Deadmines", de = "Todesminen", area = 1581, low = 17, high = 26, gf = 16, min = 10, bosses = 7,
      zone = "Westfall, Moonbrook", zoneDE = "Westfall, Mondbruch",
      quests = { 166, 214, 92753, 168, 167, 2040, 373, 1654, 95036 } },
    { key = "sfk", name = "Shadowfang Keep", de = "Burg Schattenfang", area = 209, low = 20, high = 30, gf = 18, min = 14, bosses = 8,
      zone = "Silverpine Forest", zoneDE = "Silberwald",
      quests = { 1013, 1098, 1014, 1740, 1654, 95036 } },
    { key = "bfd", name = "Blackfathom Deeps", de = "Tiefschwarze Grotte", area = 719, low = 24, high = 32, gf = 22, min = 15, bosses = 7,
      zone = "Ashenvale, Zoram Strand", zoneDE = "Eschental, Zoram-Strand",
      quests = { 6563, 6565, 6561, 6921, 6922, 971, 1275, 1199, 1198, 1200, 1740, 1654, 95036 } },
    { key = "sto", name = "The Stockade", de = "Das Verlies", area = 717, low = 24, high = 32, gf = 23, min = 15, bosses = 5,
      zone = "Stormwind City, Mage Quarter", zoneDE = "Sturmwind, Magierviertel", capital = "Alliance",
      quests = { 391, 387, 388, 377, 386, 378 } },
    { key = "es", name = "Excavation Site: Wetlands", new = true, low = 26, high = 33, gf = 26, bosses = 4,
      zone = "Wetlands, above Whelgar's Excavation Site", zoneDE = "Sumpfland, über Whelgars Ausgrabungsstätte",
      quests = { 95697, 95682, 95664, 95772, 95647, 98815, 95646, 95810 } },
    { key = "dal", name = "City of Dalaran", new = true, low = 28, high = 35, gf = 28, bosses = 9,
      zone = "Alterac Mountains", zoneDE = "Alteracgebirge", attune = { Horde = 92434, Alliance = 92432 },
      quests = { 93680, 545, 92434, 96984, 96988, 96986, 96987, 544, 556, 557, 92432, 92458, 92457, 92489, 92456 } },
    { key = "gno", name = "Gnomeregan", area = 133, low = 29, high = 38, gf = 25, min = 19, bosses = 5,
      zone = "Dun Morogh, west of Ironforge", zoneDE = "Dun Morogh, westlich von Eisenschmiede" },
    { key = "rfk", name = "Razorfen Kraul", de = "Der Kral von Razorfen", area = 491, low = 29, high = 38, gf = 24, min = 20, bosses = 6,
      zone = "Southern Barrens", zoneDE = "Südliches Brachland" },
    { key = "smg", name = "Scarlet Monastery - Graveyard", de = "Scharlachrotes Kloster - Friedhof", area = 796, low = 30, high = 38, gf = 30, min = 20, bosses = 2,
      zone = "Tirisfal Glades, northeast", zoneDE = "Tirisfal, Nordosten", wing = true },
    { key = "sml", name = "Scarlet Monastery - Library", de = "Scharlachrotes Kloster - Bibliothek", area = 796, low = 33, high = 41, gf = 30, min = 20, bosses = 2,
      zone = "Tirisfal Glades, northeast", zoneDE = "Tirisfal, Nordosten", wing = true },
    { key = "dc", name = "The Drowned City", new = true, low = 35, high = 40, gf = 35,
      zone = "Off the coast of Stranglethorn Vale", zoneDE = "Vor der Küste des Schlingendorntals" },
    { key = "sma", name = "Scarlet Monastery - Armory", de = "Scharlachrotes Kloster - Waffenkammer", area = 796, low = 36, high = 44, gf = 30, min = 20, bosses = 1,
      zone = "Tirisfal Glades, northeast", zoneDE = "Tirisfal, Nordosten", wing = true },
    { key = "rfd", name = "Razorfen Downs", de = "Die Hügel von Razorfen", area = 722, low = 37, high = 46, gf = 34, min = 28, bosses = 6,
      zone = "Southern Barrens", zoneDE = "Südliches Brachland" },
    { key = "smc", name = "Scarlet Monastery - Cathedral", de = "Scharlachrotes Kloster - Kathedrale", area = 796, low = 38, high = 46, gf = 30, min = 20, bosses = 2,
      zone = "Tirisfal Glades, northeast", zoneDE = "Tirisfal, Nordosten", wing = true },
    { key = "kro", name = "Krol'dok Stronghold", new = true, low = 40, high = 45, gf = 40, bosses = 5,
      zone = "Riverglades", zoneDE = "Riverglades" },
    { key = "uld", name = "Uldaman", area = 1337, low = 41, high = 51, gf = 35, min = 30, bosses = 8,
      zone = "Badlands", zoneDE = "Ödland" },
    { key = "zf", name = "Zul'Farrak", area = 1176, low = 44, high = 54, gf = 42, min = 35, bosses = 8,
      zone = "Tanaris, north", zoneDE = "Tanaris, Norden" },
    { key = "mar", name = "Maraudon", area = 2100, low = 46, high = 55, gf = 42, min = 35, bosses = 8,
      zone = "Desolace, southwest", zoneDE = "Desolace, Südwesten" },
    { key = "alc", name = "Alcaz Prison", new = true, low = 48, high = 53, gf = 48,
      zone = "Alcaz Island, Dustwallow Marsh", zoneDE = "Insel Alcaz, Marschen von Dustwallow" },
    { key = "st", name = "Temple of Atal'Hakkar", de = "Versunkener Tempel", area = 1477, low = 50, high = 60, gf = 45, min = 35, bosses = 8,
      zone = "Swamp of Sorrows", zoneDE = "Sümpfe des Elends" },
    { key = "brd", name = "Blackrock Depths", de = "Schwarzfelstiefen", area = 1584, low = 52, high = 60, gf = 48, min = 40, bosses = 21,
      zone = "Blackrock Mountain", zoneDE = "Schwarzfels", both = true },

    -- Endgame (tab finished after the launch)
    { key = "dme", phase = "end", name = "Dire Maul (East)", de = "Düsterbruch (Ost)", area = 2557, low = 54, high = 60, gf = 54, min = 52, zone = "Feralas", zoneDE = "Feralas" },
    { key = "bmh", phase = "end", name = "Blackmaw Hold", new = true, low = 55, high = 60, gf = 55, zone = "Northern Azshara, behind the furbolg gates", zoneDE = "Nördliches Azshara, hinter den Furbolg-Toren" },
    { key = "lbrs", phase = "end", name = "Lower Blackrock Spire", de = "Untere Schwarzfelsspitze", area = 1583, low = 55, high = 60, gf = 53, min = 44, bosses = 9, zone = "Blackrock Mountain", zoneDE = "Schwarzfels" },
    { key = "dmn", phase = "end", name = "Dire Maul (North)", de = "Düsterbruch (Nord)", area = 2557, low = 56, high = 60, gf = 54, min = 52, zone = "Feralas", zoneDE = "Feralas" },
    { key = "dmw", phase = "end", name = "Dire Maul (West)", de = "Düsterbruch (West)", area = 2557, low = 56, high = 60, gf = 54, min = 52, zone = "Feralas", zoneDE = "Feralas" },
    { key = "sch", phase = "end", name = "Scholomance", area = 2057, low = 58, high = 60, gf = 57, min = 45, bosses = 14, zone = "Western Plaguelands, Caer Darrow", zoneDE = "Westliche Pestländer, Caer Darrow" },
    { key = "sha", phase = "end", name = "Shaper's Terrace", new = true, low = 58, high = 60, gf = 58, zone = "Un'Goro Crater, northern hills", zoneDE = "Un'Goro-Krater, nördliche Hügel" },
    { key = "str", phase = "end", name = "Stratholme", area = 2017, low = 58, high = 60, gf = 55, min = 45, bosses = 19, zone = "Eastern Plaguelands", zoneDE = "Östliche Pestländer" },
    { key = "ubrs", phase = "end", name = "Upper Blackrock Spire", de = "Obere Schwarzfelsspitze", area = 1583, low = 59, high = 60, gf = 58, min = 48, bosses = 5, zone = "Blackrock Mountain", zoneDE = "Schwarzfels" },
}

ns.Raids = {
    { name = "Barrow Deeps", size = 10, zone = "Beneath Blackmaw Hold, Azshara", zoneDE = "Unter Blackmaw Hold, Azshara", attune = "?" },
    { name = "Peak of Hyjal", size = 20, zone = "Mount Hyjal", zoneDE = "Berg Hyjal", attune = "?" },
    { name = "Onyxia's Lair", de = "Onyxias Hort", size = 40, zone = "Dustwallow Marsh", zoneDE = "Marschen von Dustwallow", attune = "yes" },
}
