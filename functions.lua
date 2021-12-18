local function InExcludeList (ExcludeList, SpellName)
    for index, value in ipairs(ExcludeList) do
        if value == SpellName then
            return true
        end
    end

    return false
end

function DisplaySpell(SpellName, SkillType, SpellSubName, SpellID)
	local ExcludeList = {
		"Auto Attack",
		"Wartime Ability",
		"Garrison Ability",
		"Combat Ally",
		"Activate Empowerment",
		"Sanity Restoration Orb",
		"Construct Ability"		
	}
	if
		SkillType == "SPELL"
		and (SpellSubName == ""
			or SpellSubName == "Racial")
		and IsPassiveSpell(SpellID) == false
		and IsSpellKnown(SpellID) == true
		and InExcludeList(ExcludeList, SpellName) == false
	then
		return true
	end
	
	return false
end

function CreateAnnouncementsVariable()
	Announcements[PlayerClass] = {}
	Announcements[PlayerClass].Spell = {}
	SaveAnnouncements(Announcements)
end

function FetchAnnouncements()
	local i = 1
	while true do
		local SpellName, SpellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not SpellName then
		  do break end
		end
		if GetSpellBookItemInfo(SpellName) then
			local SkillType, SpellID = GetSpellBookItemInfo(SpellName)
			if(DisplaySpell(SpellName, SkillType, SpellSubName, SpellID)) then
				Announcements[PlayerClass].Spell[SpellID] = {}
				Announcements[PlayerClass].Spell[SpellID].SpellID = {}
				Announcements[PlayerClass].Spell[SpellID].SpellName = {}
				Announcements[PlayerClass].Spell[SpellID].Channel = {}
				Announcements[PlayerClass].Spell[SpellID].Text = {}
				Announcements[PlayerClass].Spell[SpellID].SpellID = SpellID
				Announcements[PlayerClass].Spell[SpellID].SpellName = SpellName
				Announcements[PlayerClass].Spell[SpellID].Channel = 
					{
						Party = false,
						Instance = false,
						Say = false,
						Emote = false
					}
				Announcements[PlayerClass].Spell[SpellID].Text = ""
			end
		end
		i = i + 1
	end

	SaveAnnouncements(Announcements)
end

function SaveAnnouncements(a)
	_G[Announcements] = a
end

function Announce()
	SpellCast_EventFrame = CreateFrame("Frame")
	SpellCast_EventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	SpellCast_EventFrame:SetScript("OnEvent",
		function(self, event, unit, arg1, spellID, arg2, arg3)
			if(unit == "player" and Announcements[PlayerClass].Spell[spellID]) then
				for ii, c in pairs(Announcements[PlayerClass].Spell[spellID].Channel) do
					if c == true then
						if (ii ~= "Instance" or IsInGroup(LE_PARTY_CATEGORY_INSTANCE))
						and (ii ~= "Party" or IsInGroup(LE_PARTY_CATEGORY_HOME)) then 
							SendChatMessage(Announcements[PlayerClass].Spell[spellID].Text, ii)
						end
					end
				end
			end
		end)
end



local function CreateButtons(Config, PageValue)

	left = CreateFrame("Button", nil, Config)
	left:SetPoint("BOTTOMLEFT", Config, "BOTTOMLEFT", 150, 20)
	left:SetWidth(80)
	left:SetHeight(20)
	
	left:SetText("< Prev")
	left:SetNormalFontObject("GameFontNormal")
	
	local ntex = left:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	left:SetNormalTexture(ntex)
	
	local htex = left:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	left:SetHighlightTexture(htex)
	
	local ptex = left:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	left:SetPushedTexture(ptex)

	right = CreateFrame("Button", nil, Config)
	right:SetPoint("BOTTOMRIGHT", Config, "BOTTOMRIGHT", -150, 20)
	right:SetWidth(80)
	right:SetHeight(20)
	
	right:SetText("Next >")
	right:SetNormalFontObject("GameFontNormal")
	
	local ntex = right:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	right:SetNormalTexture(ntex)
	
	local htex = right:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	right:SetHighlightTexture(htex)
	
	local ptex = right:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	right:SetPushedTexture(ptex)
	
end

function CreateConfig(pageValue)
	local Config = CreateFrame("Frame", "Announce-iate", UIParent)
	Config:Hide()
	Config.name = "Announce-iate"
	InterfaceOptions_AddCategory(Config)

	local ConfigTitle = Config:CreateFontString("ConfigTitle", "ARTWORK", "GameFontNormalLarge")
	ConfigTitle:SetPoint("TOPLEFT", 10, -20)
	ConfigTitle:SetText("Announce-iate Configuration")	
	local Tooltip = Config:CreateFontString("Tooltip", "ARTWORK", "GameFontNormal")
	Tooltip:SetPoint("TOPLEFT", 10, -50)
	Tooltip:SetText("Please note: /say will not work outdoors and can only be used inside instances.")
	Tooltip:SetTextColor(1, 1, 1)
	Tooltip:SetFont("Fonts\\FRIZQT__.TTF", 12)
	SpellNameText = {}
	SayValue = {}
	CheckBox = {}
	
	if(Announcements[PlayerClass]) then
		local a = 1

		for i, s in pairs(Announcements[PlayerClass].Spell) do
			local distanceFromTop = (-90 + (a - 1) * -20)
			local pageNo = math.floor(a / 20)
			distanceFromTop = distanceFromTop + ((pageNo * 20) * 20)

			SpellNameText[i] = Config:CreateFontString("SpellNameText", "ARTWORK", "GameFontNormal")
			SpellNameText[i]:SetJustifyH("LEFT");
			SpellNameText[i]:SetPoint ("TOPLEFT", "Announce-iate", 10, distanceFromTop)
			SpellNameText[i]:SetWidth(150)
			SpellNameText[i]:SetHeight(20)
			SpellNameText[i]:SetText(s.SpellName)
			SpellNameText[i]:SetTextColor(1, 1, 1)
			SpellNameText[i]:Hide()

			SayValue[i] = CreateFrame("EditBox", nil, Config)
			SayValue[i]:SetPoint ("TOPLEFT", "Announce-iate", 180, distanceFromTop)
			SayValue[i]:SetFontObject(GameFontNormal)
			SayValue[i]:SetWidth(150)
			SayValue[i]:SetHeight(15)
			SayValue[i]:SetText(s.Text)
			SayValue[i].texture = SayValue[i]:CreateTexture(nil, "BACKGROUND")
			SayValue[i].texture:SetAllPoints(true)
			SayValue[i].texture:SetColorTexture(1.0, 1.0, 1.0, 0.1)
			SayValue[i]:Hide()
			
			CheckBox[i] = {}
			local x = 1
			
			for ii, ss in pairs(Announcements[PlayerClass].Spell[i].Channel) do
				CheckBox[i][ii] = CreateFrame("CheckButton", nil, Config, "UICheckButtonTemplate")
				CheckBox[i][ii]:SetPoint("TOPRIGHT", "Announce-iate", (-250 + (x - 1) * 70), 5 + distanceFromTop)
				CheckBox[i][ii]:SetSize(27,27)
				CheckBox[i][ii].text:SetText(ii)
				
				if(Announcements[PlayerClass].Spell[i].Channel[ii] == true) then
					CheckBox[i][ii]:SetChecked(true)
				else
					CheckBox[i][ii]:SetChecked(false)
				end
				x = x + 1
				CheckBox[i][ii]:Hide()

			end
			a = a + 1
		end

	CreateButtons(Config, pageValue)
	
	end

	Config.okay = function (self)
		for i, s in pairs(Announcements[PlayerClass].Spell) do
			Announcements[PlayerClass].Spell[i].Text = SayValue[i]:GetText()
			for ii, ss in pairs(Announcements[PlayerClass].Spell[i].Channel) do
				Announcements[PlayerClass].Spell[i].Channel[ii] = CheckBox[i][ii]:GetChecked()
			end
		end
	end
	
end

function UpdateSpells(pageValue)
	local a = 1
	for i, s in pairs(Announcements[PlayerClass].Spell) do
		if a <= pageValue and a > pageValue - 20 then
		SpellNameText[i]:Show()
		SayValue[i]:Show()
		for ii, ss in pairs(Announcements[PlayerClass].Spell[i].Channel) do
			CheckBox[i][ii]:Show()
			end
			else
				SpellNameText[i]:Hide()
				SayValue[i]:Hide()
		for ii, ss in pairs(Announcements[PlayerClass].Spell[i].Channel) do
			CheckBox[i][ii]:Hide()
			end
		end
		a = a + 1
	end
end
