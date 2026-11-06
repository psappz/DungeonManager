-- DungeonManager - dungeon quests from QuestieDB plus the researched hand list
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM
local L = ns.L

local Q = {}
DM.Quests = Q
Q.byDungeon = {}   -- [dungeonKey] = { questID, ... }
Q.ready = false

local band = bit and bit.band or function(a, b)
    local r, m = 0, 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then r = r + m end
        a, b, m = math.floor(a / 2), math.floor(b / 2), m * 2
    end
    return r
end

-- LibQuestieDB (QuestieDB addon): Quest.Get(id, key) / Npc.Get(id, key) as used by Questie 12.5;
-- older builds expose global QuestDB / NpcDB with one accessor per key.
local function get(kind, key, id)
    local lib = type(LibQuestieDB) == "table" and LibQuestieDB[kind]
    if type(lib) == "table" and type(lib.Get) == "function" then
        local ok, v = pcall(lib.Get, id, key)
        if ok then return v end
    end
    local db = (kind == "Quest") and QuestDB or NpcDB
    if type(db) ~= "table" then return nil end
    local f = db[key]
    if type(f) == "function" then
        local ok, v = pcall(f, id)
        if ok then return v end
    end
    if type(db.GetRaw) == "function" then
        local ok, v = pcall(db.GetRaw, id, key)
        if ok then return v end
    end
    return nil
end

local function allQuestIds()
    local lib = type(LibQuestieDB) == "table" and LibQuestieDB.Quest
    for _, fn in ipairs({ "GetAllIds", "GetAllIDs", "GetIds" }) do
        if lib and type(lib[fn]) == "function" then
            local ok, ids = pcall(lib[fn])
            if ok and type(ids) == "table" then return ids end
        end
    end
    if type(QuestDB) == "table" and type(QuestDB.GetAllIds) == "function" then return QuestDB.GetAllIds() end
    return {}
end

function Q:Available()
    if type(LibQuestieDB) ~= "table" then return false end
    return (type(LibQuestieDB.Quest) == "table" and type(LibQuestieDB.Npc) == "table")
        or (type(QuestDB) == "table" and type(NpcDB) == "table")
end

local areaToUi
local function loadAreaToUiMap()
    if areaToUi then return areaToUi end
    areaToUi = {}
    if not (LibQuestieDB and LibQuestieDB.Support) then return areaToUi end
    local ok, zdb = pcall(LibQuestieDB.Support.Get, "ZoneDB")
    if not ok or not zdb or not zdb.private then return areaToUi end
    local m = zdb.private.areaIdToUiMapId
    if type(m) == "string" then
        local f = loadstring(m)
        local ok2, t = pcall(f or function() end)
        m = ok2 and t or nil
    end
    if type(m) == "table" then areaToUi = m end
    return areaToUi
end
Q.AreaToUi = function(_, area) return loadAreaToUiMap()[area] end

-- Collect quests per dungeon: hand list + QuestieDB quests whose zoneOrSort is the dungeon area.
function Q:Build(onDone)
    local byArea = {}
    for _, d in ipairs(ns.Dungeons) do
        local list, seen = {}, {}
        for _, id in ipairs(d.quests or {}) do
            if not seen[id] then seen[id] = true table.insert(list, id) end
        end
        self.byDungeon[d.key] = list
        d._seen = seen
        if d.area then
            byArea[d.area] = byArea[d.area] or {}
            table.insert(byArea[d.area], d)
        end
    end
    if not self:Available() then
        DM:Print(L["QuestieDB is missing or disabled. Only the built-in quest list is used."])
        self.ready = true
        if onDone then onDone() end
        return
    end
    local ids = allQuestIds()
    local i, n, SLICE = 1, #ids, 500
    local ticker
    ticker = C_Timer.NewTicker(0, function()
        local stop = math.min(i + SLICE - 1, n)
        for k = i, stop do
            local id = ids[k]
            local zs = get("Quest", "zoneOrSort", id)
            local list = zs and byArea[zs]
            if list then
                for _, d in ipairs(list) do
                    if not d._seen[id] then
                        d._seen[id] = true
                        table.insert(self.byDungeon[d.key], id)
                    end
                end
            end
        end
        i = stop + 1
        if i > n then
            ticker:Cancel()
            self.ready = true
            if onDone then onDone() end
        end
    end)
end

---------------------------------------------------------------------------
-- Player state
---------------------------------------------------------------------------
function Q:IsDone(id)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then return C_QuestLog.IsQuestFlaggedCompleted(id) end
    if IsQuestFlaggedCompleted then return IsQuestFlaggedCompleted(id) end
    return false
end

function Q:LogSet()
    local set = {}
    if GetNumQuestLogEntries and GetQuestLogTitle then
        local n = GetNumQuestLogEntries()
        for i = 1, n do
            local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
            if not isHeader and questID then set[questID] = true end
        end
    elseif C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and info.questID then set[info.questID] = true end
        end
    end
    return set
end

local function friendly(npc, fac)
    local f = get("Npc", "friendlyToFaction", npc)
    if type(f) ~= "string" then return nil end
    if f == "AH" then return "N" end
    if f:find(fac, 1, true) then return fac end
    return false
end

local function classFileFromMask(mask)
    for cid = 1, 13 do
        if band(mask, 2 ^ (cid - 1)) > 0 and GetClassInfo then
            local _, file = GetClassInfo(cid)
            if file then return file end
        end
    end
end

function Q:Name(id)
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local t = C_QuestLog.GetTitleForQuestID(id)
        if t and t ~= "" then return t end
    end
    return get("Quest", "name", id) or ("Quest " .. id)
end

local function firstSpawn(npc)
    local spawns = get("Npc", "spawns", npc)
    if type(spawns) ~= "table" then return nil end
    for area, coords in pairs(spawns) do
        if type(coords) == "table" and coords[1] and coords[1][1] and coords[1][1] >= 0 then
            return area, coords[1][1] / 100, coords[1][2] / 100
        end
    end
end

-- Capitals of the other faction: a quest giver standing there is never shown (also when QuestieDB lists
-- the NPC as friendly to both factions, e.g. Dawnwatcher Shaedlass in Darnassus).
local HOSTILE_CAPITALS = {
    H = { [1519] = true, [1537] = true, [1657] = true },   -- Stormwind, Ironforge, Darnassus
    A = { [1637] = true, [1638] = true, [1497] = true },   -- Orgrimmar, Thunder Bluff, Undercity
}

local function spawnAreas(npc)
    local spawns = get("Npc", "spawns", npc)
    local out = {}
    if type(spawns) == "table" then for area in pairs(spawns) do out[area] = true end end
    return out
end

local function giverOk(npc, p)
    if not friendly(npc, p.fac) then return false end
    for area in pairs(spawnAreas(npc)) do
        if HOSTILE_CAPITALS[p.fac][area] then return false end
    end
    return true
end

-- Can this character get the quest at all (race mask, giver, turn-in)? Prerequisites are checked
-- recursively, so a quest whose chain starts on the other faction's side is hidden too.
local reachCache = {}
function Q:Reachable(id, p, depth)
    depth = depth or 0
    local key = id .. p.fac .. (p.raceID or 0)
    if reachCache[key] ~= nil then return reachCache[key] end
    if depth > 6 then return true end
    local ok = true
    local races = get("Quest", "requiredRaces", id) or 0
    if races > 0 and p.raceID and band(races, 2 ^ (p.raceID - 1)) == 0 then ok = false end
    if ok then
        local sb = get("Quest", "startedBy", id)
        local npcs = sb and sb[1]
        if type(npcs) == "table" and #npcs > 0 then
            local any = false
            for _, npc in ipairs(npcs) do if giverOk(npc, p) then any = true break end end
            if not any then ok = false end
        end
    end
    if ok then
        local fb = get("Quest", "finishedBy", id)
        local fnpcs = fb and fb[1]
        if type(fnpcs) == "table" and #fnpcs > 0 then
            local any = false
            for _, npc in ipairs(fnpcs) do if giverOk(npc, p) then any = true break end end
            if not any then ok = false end
        end
    end
    if ok then
        local group = get("Quest", "preQuestGroup", id)
        if type(group) == "table" then
            for _, q in ipairs(group) do
                if not self:IsDone(q) and not self:Reachable(q, p, depth + 1) then ok = false break end
            end
        end
    end
    if ok then
        local single = get("Quest", "preQuestSingle", id)
        if type(single) == "table" and #single > 0 then
            local any = false
            for _, q in ipairs(single) do
                if self:IsDone(q) or self:Reachable(q, p, depth + 1) then any = true break end
            end
            if not any then ok = false end
        end
    end
    reachCache[key] = ok
    return ok
end

-- Returns nil when the quest must not be shown for this character (faction rules), else an entry.
function Q:Evaluate(id, d, p, log)
    if not self:Available() then
        return { id = id, name = "Quest " .. id, status = self:IsDone(id) and "done" or (log[id] and "log" or "unknown"), fac = "N", own = true }
    end
    local races = get("Quest", "requiredRaces", id) or 0
    if races > 0 and p.raceID and band(races, 2 ^ (p.raceID - 1)) == 0 then return nil end
    if not self:IsDone(id) and not log[id] and not self:Reachable(id, p) then return nil end

    local e = { id = id, name = self:Name(id), own = true }
    local classes = get("Quest", "requiredClasses", id) or 0
    if classes > 0 then
        e.classFile = classFileFromMask(classes)
        if p.classID and band(classes, 2 ^ (p.classID - 1)) == 0 then e.own = false end
    end

    local sb = get("Quest", "startedBy", id)
    local npcs, objs, items = sb and sb[1], sb and sb[2], sb and sb[3]
    if type(npcs) == "table" and #npcs > 0 then
        for _, npc in ipairs(npcs) do
            local f = giverOk(npc, p) and friendly(npc, p.fac)
            if f then
                e.fac, e.npc = f, npc
                break
            end
        end
        if not e.npc then return nil end           -- only hostile or unknown givers: never shown
        e.giver = get("Npc", "name", e.npc)
        e.area, e.x, e.y = firstSpawn(e.npc)
    elseif (type(items) == "table" and #items > 0) or (type(objs) == "table" and #objs > 0) then
        e.fac = races > 0 and p.fac or "N"
        e.fromItem = true
    else
        return nil                                 -- no start data: do not guess
    end

    local fb = get("Quest", "finishedBy", id)
    local fnpcs = fb and fb[1]
    if type(fnpcs) == "table" and #fnpcs > 0 then
        local ok = false
        for _, npc in ipairs(fnpcs) do if giverOk(npc, p) then ok = true break end end
        if not ok then return nil end              -- turn-in in hostile hands
    end

    e.inside = e.fromItem or (d.area and e.area == d.area) or false
    e.level = get("Quest", "requiredLevel", id) or 0
    local flags = get("Quest", "questFlags", id) or 0
    e.shareable = band(flags, 8) > 0

    local pre = {}
    local single = get("Quest", "preQuestSingle", id)
    local group = get("Quest", "preQuestGroup", id)
    local preOk = true
    if type(single) == "table" and #single > 0 then
        local any = false
        for _, q in ipairs(single) do if self:IsDone(q) then any = true end table.insert(pre, q) end
        if not any then preOk = false end
    end
    if type(group) == "table" then
        for _, q in ipairs(group) do
            table.insert(pre, q)
            if not self:IsDone(q) then preOk = false end
        end
    end
    e.pre = pre

    if not e.own then e.status = "other"
    elseif self:IsDone(id) then e.status = "done"
    elseif log[id] then e.status = "log"
    elseif e.level > p.level then e.status = "low"
    elseif not preOk then e.status = "pre"
    elseif e.inside then e.status = "inside"
    else e.status = "take" end
    return e
end

-- Entry for a quest that QuestieDB does not know yet (new or changed Forever quest), from DungeonJournal
function Q:FromJournal(q, d, p, log)
    local e = {
        id = q.id, name = q.name or ("#" .. q.id), own = true, giver = q.pickup,
        fac = (q.faction == "Both" or not q.faction) and "N" or p.fac,
        level = q.requires or q.level or 0, inside = q.startsInDungeon and true or false, fromJournal = true,
    }
    if type(q.startMap) == "table" then e.uiMap, e.x, e.y = q.startMap.mapID, q.startMap.x, q.startMap.y end
    if q.classOnly then
        e.classFile = q.classOnly
        e.own = (p.classFile == q.classOnly)
    end
    if not e.own then e.status = "other"
    elseif self:IsDone(q.id) then e.status = "done"
    elseif log[q.id] then e.status = "log"
    elseif e.level > p.level then e.status = "low"
    elseif e.inside then e.status = "inside"
    else e.status = "take" end
    return e
end

local FAC = { Horde = "H", Alliance = "A" }

function Q:ForDungeon(d, p, log)
    local dj = DM.DJ and DM.DJ:Quests(d)
    if dj then
        local out, seen = {}, {}
        for _, q in ipairs(dj) do
            local qf = FAC[q.faction or ""]
            if not seen[q.id] and (not qf or qf == p.fac) then
                seen[q.id] = true
                local e
                if get("Quest", "name", q.id) then
                    e = self:Evaluate(q.id, d, p, log)       -- our faction / Hardcore rules still apply
                else
                    e = self:FromJournal(q, d, p, log)
                end
                if e then
                    e.dj = q
                    if q.classOnly and not e.classFile then
                        e.classFile = q.classOnly
                        if p.classFile ~= q.classOnly then e.own = false e.status = "other" end
                    end
                    local share = DM.DJ:Shareable(q.id)
                    if share ~= nil then e.shareable = share end
                    table.insert(out, e)
                end
            end
        end
        return out
    end
    local out = {}
    for _, id in ipairs(self.byDungeon[d.key] or d.quests or {}) do
        local e = self:Evaluate(id, d, p, log)
        if e then table.insert(out, e) end
    end
    return out
end
DM:On("QUEST_TURNED_IN", function() wipe(reachCache) end)
