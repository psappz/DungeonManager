-- DungeonManager - run preparation: quests to pick up before the marked dungeons, sorted by route
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM
local L = ns.L
local W = DM.W

local Prep = {}
DM.Prep = Prep
local frame

local function worldPos(area, x, y)
    local map = area and DM.Quests:AreaToUi(area)
    if not (map and x and C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then return end
    local cont, pos = C_Map.GetWorldPosFromMapPos(map, CreateVector2D(x, y))
    if not pos then return end
    local wx, wy = pos:GetXY()
    return cont, wx, wy
end

local function playerPos()
    if not (C_Map and C_Map.GetBestMapForUnit) then return end
    local map = C_Map.GetBestMapForUnit("player")
    local p = map and C_Map.GetPlayerMapPosition(map, "player")
    if not p then return end
    local x, y = p:GetXY()
    local cont, pos = C_Map.GetWorldPosFromMapPos(map, CreateVector2D(x, y))
    if not pos then return end
    local wx, wy = pos:GetXY()
    return cont, wx, wy
end

local function dist(c1, x1, y1, c2, x2, y2)
    if not (c1 and c2) then return 1e9 end
    if c1 ~= c2 then return 1e7 end
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Groups pick-up quests by giver zone; zones in nearest-neighbour order from the player, givers likewise.
function Prep:Plan()
    local p = DM:Player()
    local log = DM.Quests:LogSet()
    local seen, pick, inside, other, names = {}, {}, {}, {}, {}
    local groupSet = DM.UI.GroupClasses()
    for _, d in ipairs(ns.Dungeons) do
        if DM.char.marked[d.key] then
            table.insert(names, DM:DungeonName(d))
            for _, e in ipairs(DM.Logic:Evaluate(d, p, log).quests) do
                if not seen[e.id] then
                    seen[e.id] = true
                    if e.status == "take" or e.status == "pre" then
                        e.dungeon = d
                        table.insert(pick, e)
                    elseif e.status == "inside" then
                        table.insert(inside, e)
                    elseif e.status == "other" and DM.settings.otherClass then
                        e.inGroup = groupSet[e.classFile]
                        table.insert(other, e)
                    end
                end
            end
        end
    end
    local zones, order = {}, {}
    for _, e in ipairs(pick) do
        local k = e.area or 0
        if not zones[k] then zones[k] = { area = e.area, list = {} } table.insert(order, zones[k]) end
        e.c, e.wx, e.wy = worldPos(e.area, e.x, e.y)
        table.insert(zones[k].list, e)
    end
    local c, x, y = playerPos()
    local route = {}
    while #order > 0 do
        local best, bi = 1e10, 1
        for i, z in ipairs(order) do
            local f = z.list[1]
            local dd = dist(c, x, y, f.c, f.wx, f.wy)
            if dd < best then best, bi = dd, i end
        end
        local z = table.remove(order, bi)
        local rest, sorted = { unpack(z.list) }, {}
        while #rest > 0 do
            local b2, j = 1e10, 1
            for i, e in ipairs(rest) do
                local dd = dist(c, x, y, e.c, e.wx, e.wy)
                if dd < b2 then b2, j = dd, i end
            end
            local e = table.remove(rest, j)
            table.insert(sorted, e)
            if e.c then c, x, y = e.c, e.wx, e.wy end
        end
        z.list = sorted
        table.insert(route, z)
    end
    return { names = names, route = route, inside = inside, other = other, need = #pick }
end

local function rows(plan)
    local out = {}
    local n = 0
    for _, z in ipairs(plan.route) do
        n = n + 1
        table.insert(out, { text = string.format("|cffffd100%d. %s|r", n, (z.area and DM:AreaName(z.area)) or L["Unknown place"]) })
        for _, e in ipairs(z.list) do
            local icon = e.classFile and DM:ClassIcon(e.classFile) or ""
            local t = "    " .. icon .. (e.giver or "?") .. ": " .. e.name
            if e.status == "pre" and e.pre and e.pre[1] then
                t = t .. "  |cfff3b55b(" .. L["after:"] .. " " .. DM.Quests:Name(e.pre[1]) .. ")|r"
            end
            table.insert(out, { text = t, entry = e, border = e.classFile and { 0.78, 0.63, 0.29 } or nil })
        end
    end
    if #plan.inside > 0 then
        table.insert(out, { text = "|cffa9cbe3" .. L["Starts in the dungeon"] .. "|r" })
        for _, e in ipairs(plan.inside) do table.insert(out, { text = "    " .. e.name }) end
    end
    if #plan.other > 0 then
        table.insert(out, { text = "|cffffd100" .. L["For the group"] .. "|r" })
        for _, e in ipairs(plan.other) do
            table.insert(out, { text = "    " .. DM:ClassIcon(e.classFile) .. "|cff8fa892" .. e.name .. "|r", entry = e,
                border = e.inGroup and { 0.78, 0.63, 0.29 } or nil })
        end
    end
    return out
end

local function create()
    frame = W:Panel(UIParent, 0.09, 0.075, 0.05, 0.97)
    frame:SetBackdropBorderColor(0.54, 0.48, 0.33, 1)
    frame:SetSize(460, 560)
    frame:SetPoint("RIGHT", UIParent, "RIGHT", -80, 0)
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    _G.DungeonManagerPrepFrame = frame
    local title = W:Text(frame, "GameFontNormalLarge", L["Run preparation"])
    title:SetPoint("TOPLEFT", 14, -12)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    frame.sub = W:Text(frame, "GameFontDisableSmall") frame.sub:SetPoint("TOPLEFT", 14, -34) frame.sub:SetWidth(430) frame.sub:SetJustifyH("LEFT")
    frame.log = W:Text(frame, "GameFontHighlightSmall") frame.log:SetPoint("TOPLEFT", 14, -52)
    frame.table = W:Table(frame, { { "text", "", 440 } }, 20, 22, function(item)
        local e = item.entry
        if e and e.area and e.x then DM:SetWaypoint(e.area, e.x, e.y, e.giver) end
    end)
    frame.table:SetPoint("TOPLEFT", 6, -70)
    frame.table:SetPoint("RIGHT", -6, 0)
    frame.footer = W:Text(frame, "GameFontDisableSmall", L["Click a line: map marker - right-click minimap button: hide"])
    frame.footer:SetPoint("BOTTOMLEFT", 14, 8)
    frame:SetScript("OnShow", function() Prep:Refresh() end)
end

function Prep:Toggle()
    if not frame then create() end
    frame:SetShown(not frame:IsShown())
end

function Prep:Refresh()
    if not frame or not frame:IsShown() then return end
    local plan = self:Plan()
    frame.sub:SetText(#plan.names > 0 and table.concat(plan.names, " + ") or L["Mark dungeons in the main window (Shift-click) to plan a run."])
    local max = DM:QuestLogMax()
    local used = DM:QuestLogCount()
    local free = max - used
    local after = free - plan.need
    local warn = after < (DM.settings.logWarn or 5)
    frame.log:SetText(string.format(L["Quest log: %d to pick up - %d of %d free"], plan.need, free, max)
        .. (warn and ("  |cffe8903a" .. string.format(L["only %d free afterwards!"], after) .. "|r") or ""))
    frame.table:SetData(rows(plan))
end

DM:Listen("MARKED_CHANGED", function() Prep:Refresh() end)
