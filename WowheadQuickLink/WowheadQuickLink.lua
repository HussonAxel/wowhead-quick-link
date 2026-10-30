local addonName, nameSpace = ...
if IsRetail() then
    nameSpace.baseWowheadUrl = "https://%swowhead.com/%s=%s%s"
end
if IsClassic() then
    nameSpace.baseWowheadUrl = "https://%swowhead.com/classic/%s=%s%s"
end
if IsBCC() then
    nameSpace.baseWowheadUrl = "https://%swowhead.com/tbc/%s=%s%s"
end
if IsMop() then
    nameSpace.baseWowheadUrl = "https://%swowhead.com/mop-classic/%s=%s%s"
end
if IsForever() then
    nameSpace.baseWowheadUrl = "https://%swowhead.com/forever/%s=%s%s"
end

nameSpace.baseWowheadAzEsUrl = "https://%swowhead.com/azerite-essence/%s%s"
nameSpace.baseWowheadTradingPostActivityUrl = "https://%swowhead.com/trading-post-activity/%s%s"
nameSpace.baseArmoryUrl = "https://worldofwarcraft.com/%s/character/%s/%s"
nameSpace.baseRaiderIoUrl = "https://raider.io/characters/%s/%s/%s"

local popupText = "%s Link\nCTRL-C to copy"


local function ShowUrlPopup(header, url)
    StaticPopup_Show("WowheadQuickLinkUrl", header, _, url)
end


local function DescribeFrame(frame)
    if type(frame) ~= "table" then return tostring(frame) end
    local name = frame.GetDebugName and frame:GetDebugName() or "?"
    return string.format("%s (sourceID=%s, itemID=%s)", name, tostring(frame.sourceID), tostring(frame.itemID))
end


local function CreateUrl(dataSources, strategies)
    nameSpace.lastErrors = {}
    for name, strategy in pairs(strategies) do
        local ok, header, url = pcall(strategy, dataSources)
        if not ok then
            table.insert(nameSpace.lastErrors, name .. ": " .. tostring(header))
        elseif header and url then
            ShowUrlPopup(header, url)
            return
        end
    end

    -- Nothing found: say why in the chat instead of failing silently.
    print("|cff33ff99Wowhead Quick Link|r: no link found for " .. DescribeFrame(dataSources.focus))
    local owner = dataSources.tooltip and dataSources.tooltip:IsShown() and dataSources.tooltip:GetOwner()
    if owner then
        print("  tooltip owner: " .. DescribeFrame(owner))
    end
    for _, err in ipairs(nameSpace.lastErrors) do
        print("  error: " .. err)
    end
end

local function GetDataSources()
    local focus = {}
    local foci = GetMouseFoci()
    if foci[1] then
        focus = foci[1]
    end
    local tooltip = GameTooltip
    return {focus = focus, tooltip = tooltip}
end


-- The keyboard fallback below and the key binding can both fire for the same key press.
local lastRun = 0


function RunWowheadQuickLink()
    if GetTime() - lastRun < 0.2 then return end
    lastRun = GetTime()
    CreateUrl(GetDataSources(), nameSpace.strategies)
end


-- The Appearances tab (WardrobeCollectionFrame) handles key presses itself; make sure the
-- binding still works there even if the key does not reach the binding system.
local function GetPressedKey(key)
    local modifiers = ""
    if IsAltKeyDown() then modifiers = modifiers .. "ALT-" end
    if IsControlKeyDown() then modifiers = modifiers .. "CTRL-" end
    if IsShiftKeyDown() then modifiers = modifiers .. "SHIFT-" end
    return modifiers .. key
end


local function HookWardrobeKeys()
    if not WardrobeCollectionFrame or nameSpace.wardrobeHooked then return end
    nameSpace.wardrobeHooked = true
    WardrobeCollectionFrame:HookScript("OnKeyDown", function(_, key)
        local pressed = GetPressedKey(key)
        for _, bound in ipairs({ GetBindingKey("WOWHEAD_QUICK_LINK_NAME") }) do
            if bound == pressed then
                RunWowheadQuickLink()
                return
            end
        end
    end)
end


if EventUtil and EventUtil.ContinueOnAddOnLoaded then
    EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", HookWardrobeKeys)
end


function RunAlternativeQuickLink()
    CreateUrl(GetDataSources(), nameSpace.altStrategies)
end


StaticPopupDialogs["WowheadQuickLinkUrl"] = {
    text = popupText,
    button1 = "Close",
    OnShow = function(self, data)
        local function HidePopup(self) self:GetParent():Hide() end
        
        -- Changed from "if (IsRetail() or IsMop() or IsClassic()) then" to this to make it version agnostic
        local editBox = self.EditBox or self.editBox
        if not editBox then return end

        editBox:SetScript("OnEscapePressed", HidePopup)
        editBox:SetScript("OnEnterPressed", HidePopup)
        editBox:SetScript("OnKeyUp", function(self, key)
            if
                (IsControlKeyDown() and key == "C")
                or (IsKeyDown("C") and (key == "LCTRL" or key == "RCTRL"))
            then
                HidePopup(self)
            end
        end)
        editBox:SetMaxLetters(0)
        editBox:SetText(data)
        editBox:HighlightText()
    end,
    hasEditBox = true,
    editBoxWidth = 240,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


SLASH_WOWHEAD_QUICK_LINK_DEBUG1 = "/wqldebug"
SlashCmdList["WOWHEAD_QUICK_LINK_DEBUG"] = function()
    WowheadQuickLinkCfg.debug = not WowheadQuickLinkCfg.debug
    print("|cff33ff99Wowhead Quick Link|r: debug " .. (WowheadQuickLinkCfg.debug and "on" or "off"))
end
