-- DungeonManager - main window: Leveling, Endgame, Raids, Settings + dungeon detail
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM
local L = ns.L
local W = DM.W

local UI = {}
DM.UI = UI

local WIDTH, HEIGHT = 900, 600
local frame, tabs, pages = nil, {}, {}
local C = DM.Logic.COLORS

local STATUS = {
    log = { "In quest log", "8fe39b" }, take = { "Pick up", "ffd100" }, pre = { "Prerequisite open", "f3b77a" },
    inside = { "Starts in dungeon", "a9cbe3" }, low = { "Level too low", "e8903a" }, other = { "Other class", C.graygreen },
    done = { "Done", C.gray }, unknown = { "?", "d9d1bd" },
}

local function groupClasses()
    local set = {}
    local n = GetNumGroupMembers and GetNumGroupMembers() or 0
    local prefix = IsInRaid and IsInRaid() and "raid" or "party"
    for i = 1, n do
        local _, file = UnitClass(prefix .. i)
        if file then set[file] = true end
    end
    return set
end
UI.GroupClasses = groupClasses

function DM:SetWaypoint(area, x, y, label, uiMap)
    local map = uiMap or (area and DM.Quests:AreaToUi(area))
    if map and DM.settings.tomtom and DM.Int:HasTomTom() and DM.Int:TomTomWaypoint(map, x, y, label) then
        DM:Print(string.format(L["TomTom arrow set: %s"], label or ""))
        return
    end
    if map and C_Map and C_Map.SetUserWaypoint and UiMapPoint and (not C_Map.CanSetUserWaypointOnMap or C_Map.CanSetUserWaypointOnMap(map)) then
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, x, y))
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
        DM:Print(string.format(L["Map marker set: %s"], label or ""))
    elseif area then
        DM:Print(string.format("%s - %s (%.1f, %.1f)", label or "", DM:AreaName(area) or "?", (x or 0) * 100, (y or 0) * 100))
    end
end

function UI:QuestRow(e, groupSet, p)
    local st = STATUS[e.status] or STATUS.unknown
    local icon = DM:FactionIcon(e.fac)
    if e.classFile then icon = icon .. DM:ClassIcon(e.classFile) end
    local nameHex = (e.status == "done") and C.gray or ((e.status == "other") and C.graygreen or "ffffff")
    local giver
    if e.fromItem then giver = L["Item / object"]
    elseif e.giver then giver = e.giver .. ((e.area and DM:AreaName(e.area)) and (" - " .. DM:AreaName(e.area)) or "") end
    if e.status == "pre" and e.pre and e.pre[1] then
        giver = (giver or "") .. "  |cfff3b55b" .. L["after:"] .. " " .. DM.Quests:Name(e.pre[1]) .. "|r"
    end
    local highlight = e.classFile and e.status ~= "done" and ((e.own) or (groupSet[e.classFile]))
    local name = DM:Color(nameHex, e.name)
    if DM.settings.pawn and e.status ~= "done" and e.own
        and ((e.status == "log" and DM.Int:QuestHasUpgrade(e.id)) or (e.dj and DM.DJ:RewardUpgrade(e.dj))) then
        name = DM.Int.UPGRADE_ICON .. " " .. name
    end
    if e.shareable == false and e.status ~= "done" then name = name .. " |cff9a9a9a(" .. L["not shareable"] .. ")|r" end
    if DM.Sync:Enabled() then
        local need, has = DM.Sync:Who(e.id)
        if #has > 0 then giver = (giver or "") .. "  |cff8fe39b" .. string.format(L["in log: %s"], table.concat(has, ", ")) .. "|r" end
        if #need > 0 then giver = (giver or "") .. "  |cffffd100" .. string.format(L["also needs it: %s"], table.concat(need, ", ")) .. "|r" end
    end
    if DM.Sync:GuildEnabled() and e.status ~= "done" and e.own then
        local g = DM.Sync:GuildWho(e.id)
        if #g > 0 then
            local shown = {}
            for i = 1, math.min(3, #g) do shown[i] = g[i] end
            giver = (giver or "") .. "  |cff69ccf0" .. string.format(L["guild: %s"], table.concat(shown, ", ") .. (#g > 3 and (" +" .. (#g - 3)) or "")) .. "|r"
        end
    end
    return {
        icon = icon, name = name, status = DM:Color(st[2], L[st[1]]), giver = giver or "-",
        entry = e, border = highlight and { 0.78, 0.63, 0.29 } or nil,
    }
end

---------------------------------------------------------------------------
-- Leveling / Endgame list
---------------------------------------------------------------------------
local LIST_COLS = { { "mark", "", 26 }, { "name", "Dungeon", 330 }, { "range", "Range", 70 }, { "min", "Min.", 50 },
    { "quests", "Quests", 70 }, { "zone", "Location", 320 } }

local function localizedCols(cols)
    local out = {}
    for i, c in ipairs(cols) do out[i] = { c[1], c[2] ~= "" and L[c[2]] or "", c[3], c[4] } end
    return out
end

local function listRows(phase)
    local p = DM:Player()
    local log = DM.Quests:LogSet()
    local hc = DM:IsHardcore()
    local rows = {}
    local msLevel, msPoints
    if DM.settings.legacyMarker then msLevel, msPoints = DM.Int:LegacyMilestone(p.classFile, p.level) end
    for _, d in ipairs(ns.Dungeons) do
        local inPhase = (phase == "end") and (d.phase == "end" or d.both) or (phase ~= "end" and d.phase ~= "end")
        if inPhase then
            local r = DM.Logic:Evaluate(d, p, log)
            if not (hc and r.dangerous) then
                local name = DM:DungeonName(d)
                if d.new then name = name .. " |cffffd100" .. L["NEW"] .. "|r" end
                if r.dangerous then name = name .. " |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:14:14|t" end
                if msLevel and phase ~= "end" and (r.hex == C.green or r.hex == C.graygreen) and d.low <= msLevel and msLevel <= d.high + 1 then
                    name = name .. " |cff4fa3ff" .. string.format(L["+%d Legacy at %d"], msPoints or 1, msLevel) .. "|r"
                end
                local hex = (phase == "end") and C.gray or r.hex
                local q = (r.total > 0) and (r.open .. "/" .. r.total) or (DM.Quests.ready and "0" or "...")
                local note = DM:ZoneText(d)
                if not r.attuned then note = "|cffe05a4f" .. L["Attunement missing"] .. "|r - " .. note end
                table.insert(rows, {
                    mark = DM.char.marked[d.key] and "|cffffd100+|r" or "",
                    name = DM:Color(hex, name), range = d.low .. "-" .. d.high, min = d.min and tostring(d.min) or "-",
                    quests = q, zone = note, d = d, selected = DM.char.marked[d.key],
                })
            end
        end
    end
    return rows
end

local function buildList(page, phase)
    local y = -4
    if phase ~= "end" then
        local lbl = W:Text(page, "GameFontHighlightSmall", L["Widen range:"])
        lbl:SetPoint("TOPLEFT", 8, y - 4)
        local b = W:Number(page, 36, function() return DM.char.below end, function(v) DM.char.below = math.max(0, math.floor(v)) UI:Refresh() end)
        b:SetPoint("LEFT", lbl, "RIGHT", 22, 0)
        local bl = W:Text(page, "GameFontHighlightSmall", "-y") bl:SetPoint("RIGHT", b, "LEFT", -6, 0)
        local a = W:Number(page, 36, function() return DM.char.above end, function(v) DM.char.above = math.max(0, math.floor(v)) UI:Refresh() end)
        a:SetPoint("LEFT", b, "RIGHT", 32, 0)
        local al = W:Text(page, "GameFontHighlightSmall", "+x") al:SetPoint("RIGHT", a, "LEFT", -6, 0)
        page.inputs = { b, a }
        page.hint = W:Text(page, "GameFontDisableSmall", L["Click: details - Shift-click: mark for the run"])
        page.hint:SetPoint("LEFT", a, "RIGHT", 16, 0)
        y = y - 28
    else
        page.hint = W:Text(page, "GameFontDisableSmall", L["Endgame dungeons are completed after the launch."])
        page.hint:SetPoint("TOPLEFT", 8, y - 4)
        y = y - 24
    end
    page.table = W:Table(page, localizedCols(LIST_COLS), 22, phase == "end" and 18 or 17, function(item)
        if IsShiftKeyDown() then
            DM.char.marked[item.d.key] = not DM.char.marked[item.d.key] or nil
            UI:Refresh()
            DM:Fire("MARKED_CHANGED")
        else
            UI:ShowDetail(item.d)
        end
    end)
    page.table:SetPoint("TOPLEFT", page, "TOPLEFT", 4, y)
    page.table:SetPoint("RIGHT", page, "RIGHT", -4, 0)
    page.legend = W:Text(page, "GameFontHighlightSmall")
    page.legend:SetPoint("BOTTOMLEFT", 8, 2)
    page.legend:SetText(string.format("|cff%s%s|r   |cff%s%s|r   |cff%s%s|r   |cff%s%s|r   |cff%s%s|r",
        C.green, L["Recommended, open quests"], C.graygreen, L["Recommended, nothing open"], C.orange, L["Too hard"],
        C.gray, L["Outleveled"], C.red, L["Cannot enter"]))
end

---------------------------------------------------------------------------
-- Detail view
---------------------------------------------------------------------------
local function buildDetail(page)
    local back = W:Button(page, L["Back"], 80, function() UI:ShowTab(UI.detailFrom or "lev") end)
    back:SetPoint("TOPLEFT", 6, -2)
    page.title = W:Text(page, "GameFontNormalLarge") page.title:SetPoint("LEFT", back, "RIGHT", 10, 0)
    page.mark = W:Button(page, "", 150, function()
        local k = UI.detail and UI.detail.key
        if k then DM.char.marked[k] = not DM.char.marked[k] or nil UI:Refresh() DM:Fire("MARKED_CHANGED") end
    end)
    page.mark:SetPoint("TOPRIGHT", -6, -2)
    page.loot = W:Button(page, L["Open in AtlasLoot"], 140, function()
        if UI.detail then DM.Int:OpenAtlasLoot(UI.detail.key) end
    end)
    page.loot:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("AtlasLoot", 1, 0.82, 0)
        GameTooltip:AddLine(L["Opens the loot of this dungeon in AtlasLoot."], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    page.loot:SetScript("OnLeave", function() GameTooltip:Hide() end)
    page.loot:SetPoint("RIGHT", page.mark, "LEFT", -6, 0)
    page.journal = W:Button(page, L["Open in DungeonJournal"], 140, function()
        if UI.detail then DM.DJ:Open(UI.detail) end
    end)
    page.journal:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("DungeonJournal", 1, 0.82, 0)
        GameTooltip:AddLine(L["Bosses, loot, maps and quest pages of this dungeon in DungeonJournal."], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    page.journal:SetScript("OnLeave", function() GameTooltip:Hide() end)
    page.info = W:Text(page, "GameFontHighlightSmall") page.info:SetPoint("TOPLEFT", 8, -30) page.info:SetJustifyH("LEFT")
    page.mapBtn = CreateFrame("Button", nil, page)
    page.mapBtn:SetPoint("TOPLEFT", 6, -48)
    page.mapBtn:SetSize(230, 230)
    page.map = page.mapBtn:CreateTexture(nil, "ARTWORK")
    page.map:SetAllPoints()
    page.mapBtn:SetScript("OnClick", function() UI.mapBig = not UI.mapBig UI:Refresh() end)
    page.mapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Click: enlarge / shrink the map"], 1, 1, 1)
        GameTooltip:Show()
    end)
    page.mapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    page.sheetBtns = {}
    for i = 1, 6 do
        local b = W:Toggle(page, "", 96, function() return UI.sheet == i end, function() UI.sheet = i UI:Refresh() end)
        if i == 1 then b:SetPoint("TOPLEFT", page.mapBtn, "TOPRIGHT", 12, 0)
        else b:SetPoint("LEFT", page.sheetBtns[i - 1], "RIGHT", 4, 0) end
        b:Hide()
        page.sheetBtns[i] = b
    end
    page.legendL = W:Text(page, "GameFontHighlightSmall")
    page.legendL:SetPoint("TOPLEFT", page.mapBtn, "TOPRIGHT", 12, -30)
    page.legendR = W:Text(page, "GameFontHighlightSmall")
    page.legendR:SetPoint("TOPLEFT", page.legendL, "TOPRIGHT", 12, 0)
    for _, fs in ipairs({ page.legendL, page.legendR }) do
        fs:SetWidth(300) fs:SetJustifyH("LEFT") fs:SetJustifyV("TOP") fs:SetHeight(200) fs:SetSpacing(1)
    end
    page.table = W:Table(page, {
        { "icon", "", 40 }, { "name", L["Quest"], 280 }, { "status", L["Status"], 130 }, { "giver", L["Quest giver"], 420 },
    }, 22, 8, function(item, button)
        local e = item.entry
        if not e then return end
        -- with DungeonJournal: left-click opens the quest page there, right-click sets the map marker
        if DM.DJ:Active() and button ~= "RightButton" and UI.detail and DM.DJ:Open(UI.detail, e.id) then return end
        if e.x and (e.uiMap or e.area) then DM:SetWaypoint(e.area, e.x, e.y, e.giver, e.uiMap) end
    end)
    page.table:SetPoint("RIGHT", page, "RIGHT", -4, 0)
    page.empty = W:Text(page, "GameFontDisableSmall") page.empty:SetPoint("BOTTOMLEFT", 8, 2)
    page.credit = W:Text(page, "GameFontDisableSmall") page.credit:SetPoint("BOTTOMRIGHT", -8, 2)
end

function UI:ShowDetail(d)
    self.detail = d
    if self.tab ~= "detail" then self.detailFrom = self.tab end
    self:ShowTab("detail")
end

local function renderDetail(page)
    local d = UI.detail
    if not d then return end
    local p = DM:Player()
    local r = DM.Logic:Evaluate(d, p, DM.Quests:LogSet())
    page.title:SetText(DM:Color(r.hex, DM:DungeonName(d)))
    page.mark:SetText(DM.char.marked[d.key] and L["Marked for the run"] or L["Mark for the run"])
    page.loot:SetShown(DM.Int:HasAtlasLoot(d.key))
    local dj = DM.DJ:Active() and DM.DJ:Name(d) ~= nil
    page.journal:SetShown(dj)
    page.credit:SetShown(dj)
    if dj then page.credit:SetText(DM.DJ:Credit(L["Quests and maps: %s by %s"])) end
    page.journal:ClearAllPoints()
    if page.loot:IsShown() then page.journal:SetPoint("RIGHT", page.loot, "LEFT", -6, 0)
    else page.journal:SetPoint("RIGHT", page.mark, "LEFT", -6, 0) end
    local parts = {
        L["Range"] .. ": " .. d.low .. "-" .. d.high, L["Min."] .. ": " .. (d.min or "-"),
        L["Group finder"] .. ": " .. (d.gf or "-"), L["Bosses"] .. ": " .. (d.bosses or "-"),
        L["Quests"] .. ": " .. r.open .. "/" .. r.total, DM:ZoneText(d),
    }
    if DM.settings.showXP then
        local xp = 0
        for _, e in ipairs(r.quests) do
            if e.own and e.status ~= "done" then xp = xp + (DM.Int:QuestXP(e.id) or 0) end
        end
        if xp > 0 then table.insert(parts, L["Quest XP"] .. ": " .. DM.Int:FormatXP(xp)) end
    end
    if not r.attuned then table.insert(parts, "|cffe05a4f" .. L["Attunement missing"] .. "|r") end
    if r.dangerous then table.insert(parts, "|cffe05a4f" .. L["Entrance in a hostile capital"] .. "|r") end
    page.info:SetText(table.concat(parts, "   "))
    local sheets = ns.MapSheets and ns.MapSheets[d.key]
    if UI.detailKey ~= d.key then UI.detailKey, UI.sheet, UI.mapBig = d.key, 1, false end
    for i, b in ipairs(page.sheetBtns) do
        local sh = sheets and sheets[i]
        b:SetShown(sh ~= nil and #sheets > 1)
        if sh then b.label:SetText(L[sh.label]) b:Refresh() end
    end
    local sh = (not dj) and sheets and sheets[UI.sheet or 1]   -- DungeonJournal has the better maps
    if dj then for _, b in ipairs(page.sheetBtns) do b:Hide() end end
    if sh then
        page.map:SetTexture("Interface\\AddOns\\DungeonManager\\Media\\Maps\\" .. sh.tex)
        page.mapBtn:Show()
        local lines = {}
        for _, m in ipairs(sh.legend or {}) do table.insert(lines, "|cffffd100" .. m[1] .. "|r " .. m[2]) end
        if sh.uncertain and #sh.uncertain > 0 then
            table.insert(lines, "|cff8c8c8c" .. string.format(L["%d uncertain spots (dashed)"], #sh.uncertain) .. "|r")
        end
        table.insert(lines, "|cff8c8c8c" .. L["Schematic, not to scale."] .. "|r")
        local half = math.ceil(#lines / 2)
        page.legendL:SetText(table.concat(lines, "\n", 1, half))
        page.legendR:SetText(half < #lines and table.concat(lines, "\n", half + 1, #lines) or "")
        if UI.mapBig then
            page.mapBtn:SetSize(470, 470)
            page.legendL:SetPoint("TOPLEFT", page.mapBtn, "TOPRIGHT", 12, -30)
            page.legendL:SetHeight(440) page.legendR:SetHeight(440)
            page.legendL:SetWidth(180) page.legendR:SetWidth(180)
            page.table:Hide() page.empty:Hide()
        else
            page.mapBtn:SetSize(230, 230)
            page.legendL:SetHeight(200) page.legendR:SetHeight(200)
            page.legendL:SetWidth(300) page.legendR:SetWidth(300)
            page.table:Show() page.empty:Show()
        end
        page.legendL:Show() page.legendR:Show()
        page.table:SetPoint("TOPLEFT", page, "TOPLEFT", 4, -284)
    else
        page.mapBtn:Hide()
        page.legendL:Hide() page.legendR:Hide()
        page.table:Show() page.empty:Show()
        page.table:SetPoint("TOPLEFT", page, "TOPLEFT", 4, -48)
    end
    local groupSet = groupClasses()
    local rows = {}
    for _, e in ipairs(r.quests) do
        if e.own or DM.settings.otherClass then table.insert(rows, UI:QuestRow(e, groupSet, p)) end
    end
    page.table:SetData(rows)
    if #rows == 0 then
        page.empty:SetText(DM.Quests.ready and L["No quests for your faction in this dungeon."] or L["Loading quest data..."])
    else
        page.empty:SetText(dj and L["Click a quest: open it in DungeonJournal - right-click: map marker."] or L["Click a quest: map marker at the quest giver."])
    end
end

---------------------------------------------------------------------------
-- Raids and settings
---------------------------------------------------------------------------
local function buildRaids(page)
    page.text = W:Text(page, "GameFontHighlight")
    page.text:SetPoint("TOPLEFT", 10, -8) page.text:SetJustifyH("LEFT") page.text:SetSpacing(6)
    local lines = { "|cff8c8c8c" .. L["Raids open on 9 December. Information only for now."] .. "|r", "" }
    for _, r in ipairs(ns.Raids) do
        local name = (DM:IsGerman() and r.de) or r.name
        local zone = (DM:IsGerman() and r.zoneDE) or r.zone
        local att = (r.attune == "yes") and L["yes, per character"] or L["unknown"]
        table.insert(lines, string.format("|cffffd100%s|r  (%d)\n%s - %s: %s", name, r.size, zone, L["Attunement"], att))
    end
    page.text:SetText(table.concat(lines, "\n"))
end

local function buildSettings(page)
    local y = -10
    local function row(widget, label, xOff)
        widget:SetPoint("TOPLEFT", page, "TOPLEFT", xOff or 300, y)
        if label then
            local t = W:Text(page, "GameFontHighlight", label)
            t:SetPoint("TOPLEFT", page, "TOPLEFT", 12, y - 4)
        end
        y = y - 32
        return widget
    end
    local s = DM.settings
    page.controls = {}
    local function add(w) table.insert(page.controls, w) return w end
    add(row(W:Number(page, 40, function() return DM.char.below end, function(v) DM.char.below = math.max(0, math.floor(v)) end), L["Widen range below (-y, per character)"]))
    add(row(W:Number(page, 40, function() return DM.char.above end, function(v) DM.char.above = math.max(0, math.floor(v)) end), L["Widen range above (+x, per character)"]))
    add(row(W:Cycle(page, 140, function() return { { "auto", L["Automatic"] }, { "on", L["On"] }, { "off", L["Off"] } } end,
        function() return s.hardcore end, function(v) s.hardcore = v end), L["Hardcore protection"]))
    add(row(W:Number(page, 40, function() return s.logWarn end, function(v) s.logWarn = math.max(0, math.floor(v)) end), L["Quest log warning below x free slots"]))
    add(row(W:Check(page, L["Show class quests of other classes"], function() return s.otherClass end, function(v) s.otherClass = v end), nil, 8))
    add(row(W:Check(page, L["Show minimap button"], function() return not s.minimap.hide end, function(v)
        s.minimap.hide = not v
        local icon = LibStub("LibDBIcon-1.0", true)
        if icon then if v then icon:Show("DungeonManager") else icon:Hide("DungeonManager") end end
    end), nil, 8))
    add(row(W:Check(page, L["LegacyManager: mark dungeons that reach your next Legacy milestone"], function() return s.legacyMarker end, function(v) s.legacyMarker = v end), nil, 8))
    add(row(W:Check(page, L["TomTom: use its arrow for quest givers (if installed)"], function() return s.tomtom end, function(v) s.tomtom = v end), nil, 8))
    add(row(W:Check(page, L["Pawn: upgrade arrow for quest rewards (if installed)"], function() return s.pawn end, function(v) s.pawn = v DM.Int:ResetUpgradeCache() end), nil, 8))
    add(row(W:Check(page, L["DungeonJournal: use its quest lists, maps and pages (if installed)"], function() return s.useDungeonJournal ~= false end, function(v) s.useDungeonJournal = v UI:Refresh() end), nil, 8))
    if DM.DJ:Installed() then
        local _, _, author = DM.DJ:Info()
        local thanks = W:Text(page, "GameFontDisableSmall", string.format(L["Thanks to %s for DungeonJournal - %s"], author, DM.DJ.URL))
        thanks:SetPoint("TOPLEFT", page, "TOPLEFT", 36, y + 8)
        y = y - 12
    end
    add(row(W:Check(page, L["Questie: show quest XP"], function() return s.showXP end, function(v) s.showXP = v end), nil, 8))
    add(row(W:Check(page, L["Compare quests of marked dungeons with the group"], function() return s.syncGroup end, function(v)
        s.syncGroup = v
        if v then DM.Sync:Broadcast(true) DM.Sync:Request() end
    end), nil, 8))
    add(row(W:Check(page, L["Compare quests of marked dungeons with the guild"], function() return s.syncGuild end, function(v)
        s.syncGuild = v
        if v then DM.Sync:Broadcast(true) DM.Sync:Request() end
    end), nil, 8))
    local note = W:Text(page, "GameFontDisableSmall", L["Group and guild comparison are off by default and must be switched on."])
    note:SetPoint("TOPLEFT", 12, y - 4)
    page.family = ns.Family.Bar(page, L["Manager family"])
    page.family:SetPoint("BOTTOMLEFT", 12, 26)
    local url = W:Text(page, "GameFontDisableSmall", ns.Family.URL)
    url:SetPoint("BOTTOMLEFT", 12, 8)
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local function create()
    frame = W:Panel(UIParent, 0.09, 0.075, 0.05, 0.97)
    frame:SetBackdropBorderColor(0.54, 0.48, 0.33, 1)
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER")
    -- MEDIUM like most addon windows: AtlasLoot and others opened from here come to the front
    frame:SetFrameStrata("MEDIUM")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, "DungeonManagerFrame")
    _G.DungeonManagerFrame = frame

    local title = W:Text(frame, "GameFontNormalLarge", "DungeonManager")
    title:SetPoint("TOPLEFT", 14, -12)
    frame.sub = W:Text(frame, "GameFontDisableSmall")
    frame.sub:SetPoint("LEFT", title, "RIGHT", 12, -1)
    W:Close(frame)

    -- DungeonJournal found: status and credit (hover), click opens it
    local dj = CreateFrame("Button", nil, frame)
    dj:SetPoint("TOPRIGHT", -34, -10)
    dj:SetHeight(18)
    dj.text = W:Text(dj, "GameFontNormalSmall")
    dj.text:SetPoint("RIGHT")
    dj:SetScript("OnClick", function() if SlashCmdList and SlashCmdList.FOREVERDUNGEONJOURNAL then pcall(SlashCmdList.FOREVERDUNGEONJOURNAL, "") end end)
    dj:SetScript("OnEnter", function(self)
        local title, ver, author = DM.DJ:Info()
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:AddLine(string.format(L["%s by %s"], title .. (ver and (" " .. ver) or ""), author), 1, 0.82, 0)
        if DM.DJ:Active() then
            GameTooltip:AddLine(L["Quest lists, maps and quest pages in this window come from DungeonJournal. All credit for that data goes to its author."], 1, 1, 1, true)
        else
            GameTooltip:AddLine(L["Installed but switched off in the settings."], 1, 1, 1, true)
        end
        GameTooltip:AddLine(DM.DJ.URL, 0.6, 0.6, 0.6)
        GameTooltip:AddLine(L["Click: open DungeonJournal"], 0.5, 0.8, 1)
        GameTooltip:Show()
    end)
    dj:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.dj = dj

    local defs = {
        { "lev", L["Leveling"], function(p) buildList(p, "lev") end },
        { "end", L["Endgame"], function(p) buildList(p, "end") end },
        { "raid", L["Raids"], buildRaids },
        { "set", L["Settings"], buildSettings },
    }
    local prev
    for _, def in ipairs(defs) do
        local key = def[1]
        local b = W:Toggle(frame, def[2], 150, function() return UI.tab == key or (key == "lev" and UI.tab == "detail") end, function() UI:ShowTab(key) end)
        if prev then b:SetPoint("LEFT", prev, "RIGHT", 4, 0) else b:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -38) end
        prev = b
        tabs[key] = b
    end
    table.insert(defs, { "detail", "", buildDetail })
    for _, def in ipairs(defs) do
        local page = CreateFrame("Frame", nil, frame)
        page:SetPoint("TOPLEFT", 6, -66)
        page:SetPoint("BOTTOMRIGHT", -6, 26)
        page:Hide()
        def[3](page)
        pages[def[1]] = page
    end
    frame.footer = W:Text(frame, "GameFontDisableSmall", L["Left-click minimap button: this window - right-click: run preparation"])
    frame.footer:SetPoint("BOTTOMLEFT", 14, 8)
    frame.version = W:Text(frame, "GameFontDisableSmall", "v" .. DM.version)
    frame.version:SetPoint("BOTTOMRIGHT", -14, 8)
    frame:SetScript("OnShow", function() UI:Refresh() end)
end

function UI:ShowTab(key)
    self.tab = key
    for k, page in pairs(pages) do page:SetShown(k == key) end
    for _, b in pairs(tabs) do b:Refresh() end
    self:Refresh()
end

function UI:Toggle(tab)
    if not frame then create() end
    if frame:IsShown() and (not tab or tab == self.tab) then frame:Hide() return end
    frame:Show()
    self:ShowTab(tab or self.tab or "lev")
end

function UI:Refresh()
    if not frame or not frame:IsShown() then return end
    if DM.DJ:Installed() then
        frame.dj.text:SetText(DM.DJ:Active() and ("|cff7fd17f" .. L["DungeonJournal active"] .. "|r") or ("|cff8c8c8c" .. L["DungeonJournal found (off)"] .. "|r"))
        frame.dj:SetWidth(frame.dj.text:GetStringWidth() + 4)
        frame.dj:Show()
    else
        frame.dj:Hide()
    end
    local p = DM:Player()
    frame.sub:SetText(string.format("%s - %s %d - %s", UnitName("player") or "", DM:ClassName(p.classFile), p.level,
        DM:IsHardcore() and ("|cffe05a4f" .. L["Hardcore protection active"] .. "|r") or ""))
    local page = pages[self.tab]
    if not page then return end
    if self.tab == "lev" or self.tab == "end" then
        page.table:SetData(listRows(self.tab))
        for _, w in ipairs(page.inputs or {}) do w:Refresh() end
    elseif self.tab == "detail" then
        renderDetail(page)
    elseif self.tab == "set" then
        for _, w in ipairs(page.controls or {}) do if w.Refresh then w:Refresh() end end
        page.family:Refresh()
    end
end
