-- DungeonManager - Core: namespace, events, saved variables, helpers
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local ADDON, ns = ...

local DM = {}
ns.DM = DM
_G.DungeonManager = DM
DM.name = ADDON
DM.version = (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)(ADDON, "Version") or "?"

local L = ns.L

---------------------------------------------------------------------------
-- Events and internal messages
---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
local handlers = {}

function DM:On(event, fn)
    if not handlers[event] then
        -- events that do not exist in this client (e.g. NEW_RECIPE_LEARNED in Forever) must not abort loading
        if not pcall(frame.RegisterEvent, frame, event) then return false end
        handlers[event] = {}
    end
    table.insert(handlers[event], fn)
end

frame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end
    for i = 1, #list do
        local ok, err = pcall(list[i], event, ...)
        if not ok then geterrorhandler()(err) end
    end
end)

local listeners = {}
function DM:Listen(msg, fn)
    listeners[msg] = listeners[msg] or {}
    table.insert(listeners[msg], fn)
end
function DM:Fire(msg, ...)
    for _, fn in ipairs(listeners[msg] or {}) do fn(...) end
end

---------------------------------------------------------------------------
-- Saved variables
---------------------------------------------------------------------------
local GLOBAL_DEFAULTS = {
    hardcore = "auto",        -- auto | on | off
    otherClass = true,        -- show class quests of other classes
    logWarn = 5,              -- warn when fewer free quest log slots remain
    minimap = { hide = false },
    legacyMarker = true,
    syncGroup = false,        -- later: compare quests with group members (opt-in)
    syncGuild = false,        -- later: compare quests with guild members (opt-in)
}
local CHAR_DEFAULTS = {
    below = 2,                -- -y
    above = 0,                -- +x
    marked = {},              -- [dungeonKey] = true
}

local function applyDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if t[k] == nil then
            if type(v) == "table" then t[k] = {} applyDefaults(t[k], v) else t[k] = v end
        elseif type(v) == "table" and type(t[k]) == "table" then
            applyDefaults(t[k], v)
        end
    end
end

function DM:InitDB()
    DungeonManagerDB = DungeonManagerDB or {}
    DungeonManagerDB.settings = DungeonManagerDB.settings or {}
    applyDefaults(DungeonManagerDB.settings, GLOBAL_DEFAULTS)
    DungeonManagerCharDB = DungeonManagerCharDB or {}
    applyDefaults(DungeonManagerCharDB, CHAR_DEFAULTS)
    self.settings = DungeonManagerDB.settings
    self.char = DungeonManagerCharDB
end

---------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------
function DM:Player()
    local _, classFile, classID = UnitClass("player")
    local _, _, raceID = UnitRace("player")
    return {
        level = UnitLevel("player") or 1,
        classFile = classFile,
        classID = classID,
        raceID = raceID,
        faction = UnitFactionGroup("player"),   -- "Horde" | "Alliance"
        fac = (UnitFactionGroup("player") == "Horde") and "H" or "A",
    }
end

function DM:IsHardcore()
    local mode = self.settings.hardcore
    if mode == "on" then return true end
    if mode == "off" then return false end
    if C_GameRules and C_GameRules.IsHardcoreActive then
        local ok, active = pcall(C_GameRules.IsHardcoreActive)
        if ok then return active and true or false end
    end
    return false
end

function DM:QuestLogMax()
    if C_QuestLog and C_QuestLog.GetMaxNumQuestsCanAccept then
        local ok, n = pcall(C_QuestLog.GetMaxNumQuestsCanAccept)
        if ok and n and n > 0 then return n end
    end
    return MAX_QUESTS or 40
end

function DM:QuestLogCount()
    -- Forever returns only the number of entries (incl. headers): count real quests ourselves
    local n = 0
    for _ in pairs(DM.Quests:LogSet()) do n = n + 1 end
    return n
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
function DM:Print(...)
    print("|cffe3b55bDungeonManager|r:", ...)
end

function DM:IsGerman()
    local l = GetLocale()
    return l == "deDE"
end

function DM:DungeonName(d)
    if self:IsGerman() and d.de then return d.de end
    return d.name
end

function DM:ZoneText(d)
    if self:IsGerman() and d.zoneDE then return d.zoneDE end
    return d.zone
end

function DM:AreaName(areaID)
    if not areaID or areaID <= 0 then return nil end
    if C_Map and C_Map.GetAreaInfo then
        local ok, name = pcall(C_Map.GetAreaInfo, areaID)
        if ok and name and name ~= "" then return name end
    end
    return nil
end

function DM:Color(hex, text)
    return "|cff" .. hex .. tostring(text) .. "|r"
end

function DM:FactionIcon(fac)
    if fac == "H" then return "|TInterface\\TargetingFrame\\UI-PVP-Horde:16:16:0:0:64:64:0:40:0:40|t" end
    if fac == "A" then return "|TInterface\\TargetingFrame\\UI-PVP-Alliance:16:16:0:0:64:64:0:40:0:40|t" end
    return "|TInterface\\COMMON\\Indicator-Gray:14:14|t"
end

function DM:ClassIcon(classFile)
    local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classFile]
    if not c then return "" end
    return string.format("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%d:%d:%d:%d|t",
        c[1] * 256, c[2] * 256, c[3] * 256, c[4] * 256)
end

function DM:ClassName(classFile)
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]) or classFile
end
