-- DungeonManager - DungeonJournal (Exehn) integration.
-- When DungeonJournal is installed, DungeonManager leaves the per-dungeon reference to it (bosses, loot,
-- maps, quest pages) and keeps only its own strengths: recommendations by level, faction / Hardcore
-- safety, run preparation, group and guild comparison. DungeonJournal's quest lists are maintained for
-- Forever and replace DungeonManager's own hand list; QuestieDB stays for completion state and coordinates.
-- DungeonJournal has no public API; its data lives in the global ForeverDungeonJournal_NS. Every access is
-- guarded, so a change there only makes DungeonManager fall back to its own data.
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM

local J = {}
DM.DJ = J

local ALIAS = {
    st = "Sunken Temple", dm = "The Deadmines", str = "Stratholme: Living", stu = "Stratholme: Undead",
    smg = "Scarlet Monastery: Graveyard", sml = "Scarlet Monastery: Library",
    sma = "Scarlet Monastery: Armory", smc = "Scarlet Monastery: Cathedral",
}

local function nsTable()
    local t = _G.ForeverDungeonJournal_NS
    if type(t) == "table" and type(t.DB) == "table" then return t end
end

function J:Installed() return nsTable() ~= nil end

-- Installed and switched on in the settings
function J:Active() return self:Installed() and DM.settings and DM.settings.useDungeonJournal ~= false end

local nameCache = {}
function J:Name(d)
    local t = nsTable()
    if not t or not d then return nil end
    if nameCache[d.key] ~= nil then return nameCache[d.key] or nil end
    local cands = { ALIAS[d.key], d.name, (d.name or ""):gsub(" %- ", ": "), (d.name or ""):gsub("^The ", "") }
    for _, n in ipairs(cands) do
        if n and t.DB[n] then nameCache[d.key] = n return n end
    end
    nameCache[d.key] = false
    return nil
end

-- DungeonJournal's quest list for a dungeon (main list only), or nil
function J:Quests(d)
    if not self:Active() then return nil end
    local name = self:Name(d)
    local entry = name and nsTable().DB[name]
    if type(entry) ~= "table" or type(entry.quests) ~= "table" then return nil end
    local out = {}
    for _, q in ipairs(entry.quests) do
        if type(q) == "table" and type(q.id) == "number" and not q.hideFromMainList then table.insert(out, q) end
    end
    return #out > 0 and out or nil
end

function J:Shareable(questID)
    local t = nsTable()
    if t and type(t.IsQuestShareable) == "function" then
        local ok, v = pcall(t.IsQuestShareable, questID)
        if ok and v ~= nil then return v and true or false end
    end
    return nil
end

-- Opens the journal on a dungeon, or on one of its quests
function J:Open(d, questID)
    local t = nsTable()
    local name = t and self:Name(d)
    if not name then return false end
    local function go()
        if questID and type(t.OpenQuestPage) == "function" then return pcall(t.OpenQuestPage, name, questID) end
        if type(t.OpenBossPage) == "function" then return pcall(t.OpenBossPage, name) end
    end
    local frame = _G.ForeverDungeonJournalFrame
    if type(t.OpenQuestPage) ~= "function" or not (frame and frame:IsShown()) then
        -- first use (the journal builds its window lazily) or journal closed: open it via its own command
        if SlashCmdList and SlashCmdList.FOREVERDUNGEONJOURNAL then pcall(SlashCmdList.FOREVERDUNGEONJOURNAL, "") end
    end
    C_Timer.After(0.05, go)
    return true
end

-- Upgrade check for any quest: DungeonJournal knows the reward items, Pawn rates them
function J:RewardUpgrade(q)
    if not (q and type(q.rewardItems) == "table" and DM.Int:HasPawn()) then return false end
    for _, it in ipairs(q.rewardItems) do
        local id = type(it) == "table" and it[1]
        if type(id) == "number" then
            local _, link = C_Item.GetItemInfo(id)
            if not link then C_Item.RequestLoadItemDataByID(id)
            elseif DM.Int:IsUpgradeLink(link) then return true end
        end
    end
    return false
end
