-- DungeonManager - public API for the other Manager addons (LegacyManager, RaidManager). Read-only, versioned.
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM

local API = { version = 1 }
_G.DungeonManagerAPI = API

-- Recommended dungeons with open quests for the logged-in character, most open quests first.
-- { { key, name, open, total, xp }, ... }
function API.Suggest(limit)
    if not (DM.settings and DM.Quests and DM.Quests.ready) then return {} end
    local p = DM:Player()
    local log = DM.Quests:LogSet()
    local out = {}
    for _, d in ipairs(ns.Dungeons) do
        if d.phase ~= "end" then
            local r = DM.Logic:Evaluate(d, p, log)
            if r.color == "green" and r.open > 0 and not (DM:IsHardcore() and r.dangerous) then
                local xp = 0
                for _, e in ipairs(r.quests) do
                    if e.own and e.status ~= "done" then xp = xp + (DM.Int:QuestXP(e.id) or 0) end
                end
                table.insert(out, { key = d.key, name = DM:DungeonName(d), open = r.open, total = r.total, xp = xp })
            end
        end
    end
    table.sort(out, function(a, b) if a.open ~= b.open then return a.open > b.open end return a.xp > b.xp end)
    if limit then for i = #out, limit + 1, -1 do out[i] = nil end end
    return out
end

-- Attunement state of a dungeon or raid entry for the logged-in character: true / false / nil (unknown).
function API.IsAttuned(key)
    for _, d in ipairs(ns.Dungeons) do
        if d.key == key then return DM.Logic:Evaluate(d, DM:Player(), {}).attuned end
    end
    return nil
end

function API.Open(key)
    for _, d in ipairs(ns.Dungeons) do
        if d.key == key then
            if not (DungeonManagerFrame and DungeonManagerFrame:IsShown()) then DM.UI:Toggle() end
            DM.UI:ShowDetail(d)
            return true
        end
    end
    if not (DungeonManagerFrame and DungeonManagerFrame:IsShown()) then DM.UI:Toggle() end
    return false
end
