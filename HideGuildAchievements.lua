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

-- Init
local HideGuildAchievements = CreateFrame("Frame")

HideGuildAchievements:RegisterEvent("PLAYER_ENTERING_WORLD")
HideGuildAchievements:RegisterEvent("ACHIEVEMENT_EARNED")
HideGuildAchievements:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

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
local GREET_MSG = TITLE .. "|r|cff909090 • Loaded.|r"
local SPAM_MSG = TITLE .. "|r|cff909090 • Spam prevented!|r"

-- Helper functions
local function IsGuildAlertSpam(ID)
  return ID and C_AchievementInfo.IsGuildAchievement(ID)
end

local soundID = 569143
local function MuteAlertSound()
  MuteSoundFile(soundID)

  C_Timer.After(2, function()
    UnmuteSoundFile(soundID)
  end)
end

-- To prevent spam prevention print messages
local lastPrintTime = 0
local function PrintSpamPrevented()
  local currentTime = GetTime()

  if currentTime - lastPrintTime > 1 then
    print(SPAM_MSG)
    lastPrintTime = currentTime
  end
end

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
HideGuildAchievements:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    print(GREET_MSG)

  elseif event == "ACHIEVEMENT_EARNED" then
    local ID = ...

    if IsGuildAlertSpam(ID) then
      MuteAlertSound()
      PrintSpamPrevented()
    end

  elseif event == "CHAT_MSG_GUILD_ACHIEVEMENT" then
    return true -- stops msg from showing
  end

end)
