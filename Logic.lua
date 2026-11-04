-- DungeonManager - colour logic and status per dungeon
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM

local Logic = {}
DM.Logic = Logic

Logic.COLORS = {
    green = "5cc46a",     -- in range, open quests for this character
    graygreen = "8fa892", -- in range, nothing open for this character
    orange = "e8903a",    -- can enter, too hard
    gray = "9a9a9a",      -- outleveled
    red = "e05a4f",       -- cannot enter (level or attunement)
}

-- Sorting order of quest states inside a dungeon (done always last)
Logic.STATUS_ORDER = { log = 1, take = 2, pre = 3, inside = 4, low = 5, other = 6, unknown = 7, done = 9 }

function Logic:Attuned(d, p)
    if not d.attune then return true end
    local q = d.attune[p.faction]
    return q and DM.Quests:IsDone(q) or false
end

function Logic:IsDangerous(d, p)
    return d.capital ~= nil and d.capital ~= p.faction
end

function Logic:Evaluate(d, p, log)
    local quests = DM.Quests:ForDungeon(d, p, log)
    local open, total = 0, 0
    for _, e in ipairs(quests) do
        if e.own then
            total = total + 1
            if e.status ~= "done" then open = open + 1 end
        end
    end
    table.sort(quests, function(a, b)
        local sa, sb = Logic.STATUS_ORDER[a.status] or 8, Logic.STATUS_ORDER[b.status] or 8
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)
    local below, above = DM.char.below or 2, DM.char.above or 0
    local minEff = d.min or (d.low - 3)
    local attuned = self:Attuned(d, p)
    local color
    if p.level < minEff or not attuned then color = "red"
    elseif p.level > d.high + above then color = "gray"
    elseif p.level < d.low - below then color = "orange"
    elseif open > 0 then color = "green"
    else color = "graygreen" end
    return {
        d = d, quests = quests, open = open, total = total, color = color, hex = self.COLORS[color],
        attuned = attuned, dangerous = self:IsDangerous(d, p),
    }
end
