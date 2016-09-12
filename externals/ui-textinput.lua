
local myname, ns = ...


local BORDER_TEXTURE = "Interface\\Common\\Common-Input-Border"


local function OnEditFocusGained(self)
  self.placeholder:Hide()
end


local function ShowPlaceholderIfEmpty(self)
	if self:GetText() == "" then self.placeholder:Show() end
end


local FONT = "GameFontHighlightSmall"
function ns.NewTextInput(parent)
  local editbox = CreateFrame("EditBox", nil, parent)
  editbox:SetAutoFocus(false)
  editbox:SetSize(105, 32)
  editbox:SetFontObject(FONT)

  local left = editbox:CreateTexture(nil, "BACKGROUND")
  left:SetSize(8, 20)
  left:SetPoint("LEFT", -5, 0)
  left:SetTexture(BORDER_TEXTURE)
  left:SetTexCoord(0, 0.0625, 0, 0.625)

  local right = editbox:CreateTexture(nil, "BACKGROUND")
  right:SetSize(8, 20)
  right:SetPoint("RIGHT")
  right:SetTexture(BORDER_TEXTURE)
  right:SetTexCoord(0.9375, 1, 0, 0.625)

  local center = editbox:CreateTexture(nil, "BACKGROUND")
  center:SetHeight(20)
  center:SetPoint("TOPLEFT", left, "TOPRIGHT")
  center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
  center:SetTexture(BORDER_TEXTURE)
  center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

  local placeholder = editbox:CreateFontString(nil, nil, FONT)
  placeholder:SetPoint("LEFT")
  placeholder:SetTextColor(0.75, 0.75, 0.75, 1)
  editbox.placeholder = placeholder

  editbox:HookScript("OnEditFocusGained", OnEditFocusGained)
  editbox:HookScript("OnEditFocusLost", ShowPlaceholderIfEmpty)
  editbox:HookScript("OnTextSet", ShowPlaceholderIfEmpty)
  
  editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
  editbox:SetScript("OnEnterPressed", editbox.ClearFocus)

  return editbox
end
