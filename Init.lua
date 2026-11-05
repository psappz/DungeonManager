-- DungeonManager - startup, minimap button, slash commands
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local ADDON, ns = ...
local DM = ns.DM
local L = ns.L

local LDB = LibStub("LibDataBroker-1.1", true)
local DBIcon = LibStub("LibDBIcon-1.0", true)

local function setupMinimap()
    if not (LDB and DBIcon) then return end
    local obj = LDB:NewDataObject(ADDON, {
        type = "launcher",
        text = "DungeonManager",
        icon = "Interface\\AddOns\\DungeonManager\\Media\\DungeonManager",
        OnClick = function(_, button)
            if button == "RightButton" then DM.Prep:Toggle() else DM.UI:Toggle() end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("DungeonManager")
            tt:AddLine(L["Left-click: dungeon list"], 1, 1, 1)
            tt:AddLine(L["Right-click: run preparation"], 1, 1, 1)
        end,
    })
    DBIcon:Register(ADDON, obj, DM.settings.minimap)
end

function DungeonManager_OnAddonCompartmentClick(_, button)
    if button == "RightButton" then DM.Prep:Toggle() else DM.UI:Toggle() end
end

local pending = false
local function refreshSoon()
    if pending then return end
    pending = true
    C_Timer.After(0.5, function()
        pending = false
        DM.UI:Refresh()
        DM.Prep:Refresh()
    end)
end

-- for tests and other addons
DM.Dungeons = ns.Dungeons
DM.MapSheets = ns.MapSheets

DM:On("PLAYER_LOGIN", function()
    DM:InitDB()
    DM.Quests:Build(refreshSoon)
end)
-- The minimap button is created late on purpose (as in ConfigManager and Questie): button collectors
-- such as MinimapButtonButton take it over right away, before minimap skins (EllesmereUI) rescan the
-- minimap and hide its children.
local minimapDone = false
DM:On("PLAYER_ENTERING_WORLD", function()
    if minimapDone then return end
    minimapDone = true
    C_Timer.After(2, setupMinimap)
end)
for _, ev in ipairs({ "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "PLAYER_LEVEL_UP", "GROUP_ROSTER_UPDATE" }) do
    DM:On(ev, function() if DM.settings then refreshSoon() end end)
end

SLASH_DUNGEONMANAGER1 = "/dungeonmanager"
SLASH_DUNGEONMANAGER2 = "/dmgr"
SlashCmdList.DUNGEONMANAGER = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "" then DM.UI:Toggle()
    elseif msg == "prep" or msg == "run" then DM.Prep:Toggle()
    elseif msg == "settings" or msg == "config" then DM.UI:Toggle("set")
    else DM:Print("/dmgr, /dmgr prep, /dmgr settings") end
end
