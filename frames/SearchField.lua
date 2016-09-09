
local myname, ns = ...


function ns.MakeSearchField(GVS, Refresh)
  local editbox = ns.NewTextInput(GVS)

  editbox:SetScript("OnEditFocusGained", function(self)
  	if not GVS.searchstring then
  		self:SetText("")
  		self:SetTextColor(1,1,1,1)
  	end
  end)

  editbox:SetScript("OnEditFocusLost", function(self)
  	if self:GetText() == "" then
  		self:SetText("Search...")
  		self:SetTextColor(0.75, 0.75, 0.75, 1)
  	end
  end)

  editbox:SetScript("OnTextChanged", function(self)
  	local t = self:GetText()
  	GVS.searchstring = t ~= "" and t ~= "Search..." and t:lower() or nil
  	Refresh()
  end)

  editbox:SetScript("OnShow", function(self)
  	self:SetText("Search...")
  	self:SetTextColor(0.75, 0.75, 0.75, 1)
  end)

  editbox:SetScript("OnEnter", function(self)
  	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
  	GameTooltip:AddLine("Enter an item name to search")
  	GameTooltip:AddLine(" ")
  	GameTooltip:AddDoubleLine("Type search:", "bop   boe   bou", nil,nil,nil, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "boa   quest", 255,255,255, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "ilvl>=378  ilvl=359", 255,255,255, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "q=rare   q<4", 255,255,255, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "t:leather   t:shield", 255,255,255, 255,255,255)
  	GameTooltip:AddDoubleLine("Modifiers:", "&   Match both", nil,nil,nil, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "|   Match either", 255,255,255, 255,255,255)
  	GameTooltip:AddDoubleLine(" ", "!   Do not match", 255,255,255, 255,255,255)
  	GameTooltip:Show()
  end)

  editbox:SetScript("OnLeave", GameTooltip_Hide)

  ns.MakeSearchField = nil
end
