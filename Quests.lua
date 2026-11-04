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

local function get(db, key, id)
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

function Q:Available()
    return type(LibQuestieDB) == "table" and type(QuestDB) == "table" and type(NpcDB) == "table"
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
    local ids = (QuestDB.GetAllIds and QuestDB.GetAllIds()) or {}
    local i, n, SLICE = 1, #ids, 500
    local ticker
    ticker = C_Timer.NewTicker(0, function()
        local stop = math.min(i + SLICE - 1, n)
        for k = i, stop do
            local id = ids[k]
            local zs = get(QuestDB, "zoneOrSort", id)
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
    local f = get(NpcDB, "friendlyToFaction", npc)
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
    return get(QuestDB, "name", id) or ("Quest " .. id)
end

local function firstSpawn(npc)
    local spawns = get(NpcDB, "spawns", npc)
    if type(spawns) ~= "table" then return nil end
    for area, coords in pairs(spawns) do
        if type(coords) == "table" and coords[1] and coords[1][1] and coords[1][1] >= 0 then
            return area, coords[1][1] / 100, coords[1][2] / 100
        end
    end
end

-- Returns nil when the quest must not be shown for this character (faction rules), else an entry.
function Q:Evaluate(id, d, p, log)
    if not self:Available() then
        return { id = id, name = "Quest " .. id, status = self:IsDone(id) and "done" or (log[id] and "log" or "unknown"), fac = "N", own = true }
    end
    local races = get(QuestDB, "requiredRaces", id) or 0
    if races > 0 and p.raceID and band(races, 2 ^ (p.raceID - 1)) == 0 then return nil end

    local e = { id = id, name = self:Name(id), own = true }
    local classes = get(QuestDB, "requiredClasses", id) or 0
    if classes > 0 then
        e.classFile = classFileFromMask(classes)
        if p.classID and band(classes, 2 ^ (p.classID - 1)) == 0 then e.own = false end
    end

    local sb = get(QuestDB, "startedBy", id)
    local npcs, objs, items = sb and sb[1], sb and sb[2], sb and sb[3]
    if type(npcs) == "table" and #npcs > 0 then
        for _, npc in ipairs(npcs) do
            local f = friendly(npc, p.fac)
            if f then
                e.fac, e.npc = f, npc
                break
            end
        end
        if not e.npc then return nil end           -- only hostile or unknown givers: never shown
        e.giver = get(NpcDB, "name", e.npc)
        e.area, e.x, e.y = firstSpawn(e.npc)
    elseif (type(items) == "table" and #items > 0) or (type(objs) == "table" and #objs > 0) then
        e.fac = races > 0 and p.fac or "N"
        e.fromItem = true
    else
        return nil                                 -- no start data: do not guess
    end

    local fb = get(QuestDB, "finishedBy", id)
    local fnpcs = fb and fb[1]
    if type(fnpcs) == "table" and #fnpcs > 0 then
        local ok = false
        for _, npc in ipairs(fnpcs) do if friendly(npc, p.fac) then ok = true break end end
        if not ok then return nil end              -- turn-in in hostile hands
    end

    e.inside = e.fromItem or (d.area and e.area == d.area) or false
    e.level = get(QuestDB, "requiredLevel", id) or 0
    local flags = get(QuestDB, "questFlags", id) or 0
    e.shareable = band(flags, 8) > 0

    local pre = {}
    local single = get(QuestDB, "preQuestSingle", id)
    local group = get(QuestDB, "preQuestGroup", id)
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

function Q:ForDungeon(d, p, log)
    local out = {}
    for _, id in ipairs(self.byDungeon[d.key] or d.quests or {}) do
        local e = self:Evaluate(id, d, p, log)
        if e then table.insert(out, e) end
    end
    return out
end
