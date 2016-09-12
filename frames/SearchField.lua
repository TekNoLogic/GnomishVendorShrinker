
local myname, ns = ...


function ns.NewSearchField(parent)
  local editbox = ns.NewTextInput(parent)
  editbox:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 55, 9)

  editbox.placeholder:SetText("Search...")

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
  editbox:SetScript("OnShow", function(self) self:SetText("") end)

  return editbox
end
