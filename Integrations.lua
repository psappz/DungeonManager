-- DungeonManager - integrations with popular addons. Everything is optional and guarded:
-- we never copy what these addons do, we only hand over to them.
--   TomTom          arrow to the quest giver
--   Pawn            upgrade arrow for quest rewards (quests in the log)
--   AtlasLoot       "Loot" button opens the dungeon's loot table
--   Questie         quest XP (read-only, Questie's own QuestXP module)
--   LegacyManager   next Legacy class milestone
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM

local I = {}
DM.Int = I

local function loaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) end
    return IsAddOnLoaded and IsAddOnLoaded(name)
end
I.Loaded = loaded

---------------------------------------------------------------------------
-- TomTom
---------------------------------------------------------------------------
function I:HasTomTom()
    return type(TomTom) == "table" and type(TomTom.AddWaypoint) == "function"
end

local lastWaypoint
function I:TomTomWaypoint(uiMap, x, y, label)
    if not self:HasTomTom() then return false end
    if lastWaypoint and TomTom.RemoveWaypoint then pcall(TomTom.RemoveWaypoint, TomTom, lastWaypoint) end
    local ok, uid = pcall(TomTom.AddWaypoint, TomTom, uiMap, x, y, { title = label, from = "DungeonManager", persistent = false })
    if ok then lastWaypoint = uid end
    return ok
end

---------------------------------------------------------------------------
-- Pawn: upgrade arrow for rewards of quests in the log
---------------------------------------------------------------------------
function I:HasPawn()
    return type(PawnShouldItemLinkHaveUpgradeArrowUnbudgeted) == "function" or type(PawnIsItemAnUpgrade) == "function"
end

local function isUpgrade(link)
    if not link then return false end
    if type(PawnShouldItemLinkHaveUpgradeArrowUnbudgeted) == "function" then
        local ok, r = pcall(PawnShouldItemLinkHaveUpgradeArrowUnbudgeted, link, true)
        if ok then return r and true or false end
    end
    if type(PawnIsItemAnUpgrade) == "function" and type(PawnGetItemData) == "function" then
        local ok, item = pcall(PawnGetItemData, link)
        if ok and item then
            local ok2, up = pcall(PawnIsItemAnUpgrade, item)
            return ok2 and up and true or false
        end
    end
    return false
end

local upgradeCache = {}
-- Quest rewards are only known to the client for quests in the log (QuestieDB has no reward items).
function I:QuestHasUpgrade(questID)
    if not self:HasPawn() or not questID then return false end
    if upgradeCache[questID] ~= nil then return upgradeCache[questID] end
    local found = false
    if GetQuestLogItemLink then
        for _, kind in ipairs({ "reward", "choice" }) do
            local n = 0
            if kind == "reward" and GetNumQuestLogRewards then
                local ok, v = pcall(GetNumQuestLogRewards, questID) n = ok and v or 0
            elseif kind == "choice" and GetNumQuestLogChoices then
                local ok, v = pcall(GetNumQuestLogChoices, questID, true) n = ok and v or 0
            end
            for i = 1, (n or 0) do
                local ok, link = pcall(GetQuestLogItemLink, kind, i, questID)
                if ok and isUpgrade(link) then found = true break end
            end
            if found then break end
        end
    end
    upgradeCache[questID] = found
    return found
end
function I:ResetUpgradeCache() wipe(upgradeCache) end

I.UPGRADE_ICON = "|TInterface\\AddOns\\Pawn\\Textures\\UpgradeArrow:14:14|t"

---------------------------------------------------------------------------
-- AtlasLoot (any fork of AtlasLootClassic: AtlasLoot Classic Forever, ...)
---------------------------------------------------------------------------
local ATLAS = {
    rfc = "Ragefire", hot = "TheHallOfThanes", rol = "TheRuinsOfLordaeron", wc = "WailingCaverns",
    dm = "TheDeadmines", sfk = "ShadowfangKeep", bfd = "BlackfathomDeeps", sto = "TheStockade",
    es = "ExcavationSiteWetlands", dal = "TheCityOfDalaran", gno = "Gnomeregan", rfk = "RazorfenKraul",
    smg = "ScarletMonasteryGraveyard", sml = "ScarletMonasteryLibrary", sma = "ScarletMonasteryArmory",
    smc = "ScarletMonasteryCathedral", dc = "TheDrownedCity", rfd = "RazorfenDowns", kro = "KroldokStronghold",
    uld = "Uldaman", zf = "Zul'Farrak", mar = "Maraudon", alc = "AlcazPrison", st = "TheTempleOfAtal'Hakkar",
    brd = "BlackrockDepths", dme = "DireMaulEast", bmh = "BlackmawHold", lbrs = "LowerBlackrockSpire",
    dmn = "DireMaulNorth", dmw = "DireMaulWest", sch = "Scholomance", sha = "ShapersTerrace",
    str = "Stratholme", ubrs = "UpperBlackrockSpire",
}
local ATLAS_MODULE = "AtlasLootClassic_DungeonsAndRaids"

function I:HasAtlasLoot(key)
    return type(AtlasLoot) == "table" and type(AtlasLoot.GUI) == "table" and (not key or ATLAS[key] ~= nil)
end

function I:OpenAtlasLoot(key)
    if not self:HasAtlasLoot(key) then return false end
    local GUI = AtlasLoot.GUI
    if not GUI.frame and SlashCmdList and SlashCmdList.ATLASLOOT then pcall(SlashCmdList.ATLASLOOT, "") end
    local f = GUI.frame
    if not f then return false end
    if not f:IsShown() then f:Show() end
    if f.Raise then f:Raise() end
    -- The module loads asynchronously; select once it is there.
    local tries = 0
    local function select()
        tries = tries + 1
        local ok = pcall(function()
            f.moduleSelect:SetSelected(ATLAS_MODULE)
            f.subCatSelect:SetSelected(ATLAS[key])
            if f.boss then f.boss:SetSelected(1) end
        end)
        local db = AtlasLoot.db and AtlasLoot.db.GUI
        if (not ok or not db or db.selected[2] ~= ATLAS[key]) and tries < 10 then C_Timer.After(0.2, select) end
    end
    C_Timer.After(0.05, select)
    return true
end

---------------------------------------------------------------------------
-- Questie: quest XP (read-only)
---------------------------------------------------------------------------
local questXP
function I:QuestXP(questID)
    if questXP == nil then
        questXP = false
        if type(QuestieLoader) == "table" and type(QuestieLoader.ImportModule) == "function" then
            local ok, m = pcall(QuestieLoader.ImportModule, QuestieLoader, "QuestXP")
            if ok and type(m) == "table" and type(m.GetQuestLogRewardXP) == "function" then questXP = m end
        end
    end
    if not questXP then return nil end
    local ok, xp = pcall(questXP.GetQuestLogRewardXP, questXP, questID)
    if ok and type(xp) == "number" and xp > 0 then return xp end
    return nil
end

function I:FormatXP(xp)
    if not xp or xp <= 0 then return nil end
    if BreakUpLargeNumbers then return BreakUpLargeNumbers(xp) end
    return tostring(xp)
end

---------------------------------------------------------------------------
-- LegacyManager: next class milestone (Legacy points)
---------------------------------------------------------------------------
function I:LegacyMilestone(classFile, level)
    local api = _G.LegacyManagerAPI
    if type(api) ~= "table" or type(api.NextClassMilestone) ~= "function" then return nil end
    local ok, msLevel, points = pcall(api.NextClassMilestone, classFile, level)
    if ok and msLevel then return msLevel, points end
    return nil
end
