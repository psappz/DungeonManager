-- DungeonManager - group quest comparison (opt-in) and posting the run plan to group chat
-- Only quest IDs of the marked dungeons are exchanged, only within the party/raid, only when the
-- player switched it on in the settings.
-- Copyright (C) 2026 psappz - GPL-3.0-or-later
local _, ns = ...
local DM = ns.DM
local L = ns.L

local S = {}
DM.Sync = S
S.peers = {}            -- [name] = { need = {[id]=true}, log = {[id]=true}, class = "SHAMAN", t = time }

local PREFIX = "DMGR1"
local registered = false
local function register()
    if registered then return true end
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        registered = C_ChatInfo.RegisterAddonMessagePrefix(PREFIX) and true or false
        if not registered and C_ChatInfo.IsAddonMessagePrefixRegistered then
            registered = C_ChatInfo.IsAddonMessagePrefixRegistered(PREFIX) and true or false
        end
    end
    return registered
end

local function channel()
    if IsInGroup and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
    if IsInRaid and IsInRaid() then return "RAID" end
    if IsInGroup and IsInGroup() then return "PARTY" end
end

function S:Enabled()
    return DM.settings and DM.settings.syncGroup and channel() ~= nil
end

local function send(msg)
    local ch = channel()
    if not ch or not register() then return end
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, ch) end
end

-- My state for the marked dungeons: quests I still need (not done, own class) and quests in my log.
local function myState()
    local p = DM:Player()
    local log = DM.Quests:LogSet()
    local need, inLog = {}, {}
    for _, d in ipairs(ns.Dungeons) do
        if DM.char.marked[d.key] then
            for _, e in ipairs(DM.Logic:Evaluate(d, p, log).quests) do
                if e.own and e.status ~= "done" then
                    if e.status == "log" then table.insert(inLog, e.id) else table.insert(need, e.id) end
                end
            end
        end
    end
    return need, inLog
end

-- Messages: "S|<class>|<n|l>|<ids>" in chunks (addon messages are limited to 255 bytes).
local lastSent = 0
function S:Broadcast(force)
    if not self:Enabled() then return end
    if not force and GetTime() - lastSent < 5 then
        C_Timer.After(5, function() S:Broadcast(true) end)
        return
    end
    lastSent = GetTime()
    local _, classFile = UnitClass("player")
    local need, inLog = myState()
    send("R|" .. classFile)                         -- reset my entry on the receivers
    for _, part in ipairs({ { "n", need }, { "l", inLog } }) do
        local buf = {}
        local function flush()
            if #buf > 0 then send("S|" .. classFile .. "|" .. part[1] .. "|" .. table.concat(buf, ",")) end
            buf = {}
        end
        local len = 0
        for _, id in ipairs(part[2]) do
            local s = tostring(id)
            if len + #s + 1 > 220 then flush() len = 0 end
            table.insert(buf, s)
            len = len + #s + 1
        end
        flush()
    end
end

function S:Request()
    if not self:Enabled() then return end
    send("Q")
end

local function short(name) return (name or ""):match("^[^-]+") or name end

local function onMessage(prefix, msg, _, sender)
    if prefix ~= PREFIX or not DM.settings or not DM.settings.syncGroup then return end
    local me = UnitName("player")
    if short(sender) == me then return end
    local who = short(sender)
    local kind, a, b, c = strsplit("|", msg)
    if kind == "Q" then
        S:Broadcast()
    elseif kind == "R" then
        S.peers[who] = { need = {}, log = {}, class = a, t = time() }
    elseif kind == "S" then
        local peer = S.peers[who] or { need = {}, log = {}, class = a, t = time() }
        S.peers[who] = peer
        local set = (b == "l") and peer.log or peer.need
        for id in (c or ""):gmatch("%d+") do set[tonumber(id)] = true end
        peer.t = time()
        DM:Fire("SYNC_CHANGED")
    end
end

-- Group members (with DungeonManager) that still need a quest, and those who have it in their log.
function S:Who(questID)
    local need, has = {}, {}
    for name, peer in pairs(self.peers) do
        if UnitInParty(name) or UnitInRaid(name) then
            if peer.log[questID] then table.insert(has, name)
            elseif peer.need[questID] then table.insert(need, name) end
        end
    end
    table.sort(need) table.sort(has)
    return need, has
end

function S:PeerCount()
    local n = 0
    for name in pairs(self.peers) do if UnitInParty(name) or UnitInRaid(name) then n = n + 1 end end
    return n
end

DM:On("CHAT_MSG_ADDON", function(_, prefix, msg, dist, sender) onMessage(prefix, msg, dist, sender) end)
DM:On("GROUP_ROSTER_UPDATE", function()
    if not channel() then wipe(S.peers) return end
    if S:Enabled() then C_Timer.After(2, function() S:Broadcast() S:Request() end) end
end)
DM:On("QUEST_TURNED_IN", function() C_Timer.After(1, function() S:Broadcast() end) end)
DM:On("QUEST_ACCEPTED", function() C_Timer.After(1, function() S:Broadcast() end) end)
DM:Listen("MARKED_CHANGED", function() S:Broadcast() end)

---------------------------------------------------------------------------
-- Posting the run plan to the group chat (button in the run preparation)
---------------------------------------------------------------------------
local lastPost = 0
function S:PostPlan(plan)
    local ch = channel()
    if not ch then DM:Print(L["You are not in a group."]) return end
    if GetTime() - lastPost < 30 then DM:Print(L["Please wait a moment before posting again."]) return end
    lastPost = GetTime()
    local lines = {}
    local head = "[DungeonManager] " .. table.concat(plan.names, " + ") .. ": " .. L["pick up before the run"]
    table.insert(lines, head)
    local cur = ""
    for _, z in ipairs(plan.route) do
        local zone = (z.area and DM:AreaName(z.area)) or "?"
        local parts = {}
        for _, e in ipairs(z.list) do
            local extra = e.giver or ""
            if e.shareable == false then extra = extra .. ", " .. L["not shareable"] end
            table.insert(parts, e.name .. (extra ~= "" and (" (" .. extra .. ")") or ""))
        end
        local seg = zone .. ": " .. table.concat(parts, "; ")
        if #cur + #seg + 3 > 250 then table.insert(lines, cur) cur = seg
        else cur = (cur == "") and seg or (cur .. " | " .. seg) end
    end
    if cur ~= "" then table.insert(lines, cur) end
    for i = 1, math.min(#lines, 4) do
        local text = lines[i]
        C_Timer.After((i - 1) * 0.6, function() pcall(SendChatMessage, text, ch) end)
    end
end
