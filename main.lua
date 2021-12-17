local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");
PlayerClass = UnitClass("player")
local pageValue = 20
		
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Announce-iate" then
		if event == "ADDON_LOADED" then
				if Announcements == nil then
					CreateAnnouncementsVariable()
				end
				
				FetchAnnouncements()
				
				CreateConfig(pageValue)
				
				UpdateSpells(pageValue)
				
				Announce()
			end
		end
		
		if event == "PLAYER_LOGOUT" then
			SaveAnnouncements(Announcements)
		end
				
		right:SetScript("OnClick", function()
		pageValue = pageValue + 20
		UpdateSpells(pageValue)
		end)
		
		left:SetScript("OnClick", function()
		if pageValue > 20 then
			pageValue = pageValue - 20
			UpdateSpells(pageValue)
		end
		end)
	end
)