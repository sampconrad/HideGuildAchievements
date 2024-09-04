---@diagnostic disable: undefined-field
-- Localize globals
local _G = _G
local print = _G.print
local C_Timer = _G.C_Timer
local GetTime = _G.GetTime
local CreateFrame = _G.CreateFrame
local MuteSoundFile = _G.MuteSoundFile
local UnmuteSoundFile = _G.UnmuteSoundFile
local AlertSystem = _G.AchievementAlertSystem
local C_AchievementInfo = _G.C_AchievementInfo
local GetAddOnMetadata = _G.C_AddOns.GetAddOnMetadata
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter

-- Init
local HideGuildAchievements = CreateFrame("Frame")
HideGuildAchievements:RegisterEvent("ACHIEVEMENT_EARNED")

local function FetchDataFromTOC()
  local dataRetuned = {}
  local keysToFetch = {
    "Version",
    "Title"
  }

  for _, key in ipairs(keysToFetch) do
    dataRetuned[string.upper(key)] = GetAddOnMetadata("HideGuildAchievements", key)
  end

  return dataRetuned
end

local METADATA = FetchDataFromTOC()

local TITLE = METADATA["TITLE"] .. " |cffE37527v." .. METADATA["VERSION"] .. "|r"
local SPAM_MSG = TITLE .. "|r|cff909090 • Spam prevented!|r"

-- Helper functions
local lastPrintTime = 0
local function PrintSpamBlockedMsg()
  local currentTime = GetTime()

  if currentTime - lastPrintTime > 1 then
    print(SPAM_MSG)
    lastPrintTime = currentTime
  end
end

local soundID = 569143
local function MuteAlertSound()
  MuteSoundFile(soundID)

  C_Timer.After(2, function()
    UnmuteSoundFile(soundID)
  end)
end

local function IsGuildAlertSpam(ID)
  return ID and C_AchievementInfo.IsGuildAchievement(ID)
end

local function FilterAchievementMsg()
  return true
end

-- Filter achievement spam from chat
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", FilterAchievementMsg)

-- Hook into the Blizz alert
local AchievementAlertSystem_AddAlert = AlertSystem.AddAlert

AlertSystem.AddAlert = function(...)
  local ID = select(2, ...)

  if IsGuildAlertSpam(ID) then
    return
  end

  return AchievementAlertSystem_AddAlert(...)
end

-- On event Callback
HideGuildAchievements:SetScript("OnEvent", function(_, _, ID)
  if IsGuildAlertSpam(ID) then
    MuteAlertSound()
    PrintSpamBlockedMsg()
  end
end)
