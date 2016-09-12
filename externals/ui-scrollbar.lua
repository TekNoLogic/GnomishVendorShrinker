
local myname, ns = ...


local BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 12,
	insets = { left = 0, right = 0, top = 5, bottom = 5 }
}


local function Decrement(self)
	self:SetValue(self:GetValue() - self:GetValueStep())
end


local function Increment(self)
	self:SetValue(self:GetValue() + self:GetValueStep())
end


local function OnClickUp(self)
	self:GetParent():Decrement()
end


local function OnClickDown(self)
	self:GetParent():Increment()
end


local function Sound()
	PlaySound("UChatScrollButton")
end


-- Creates a scrollbar
-- Parent is required, offset and step are optional
function ns.NewScrollBar(parent, offset, step)
	local f = CreateFrame("Slider", nil, parent)
	f:SetWidth(16)

	f:SetPoint("TOP", 0, -16 - (offset or 0))
	f:SetPoint("BOTTOM", 0, 16 + (offset or 0))
	f:SetPoint("RIGHT", 0 - (offset or 0), 0)

	f:SetValueStep(step or 1)

	f.Decrement = Decrement
	f.Increment = Increment

	local up = CreateFrame("Button", nil, f)
	up:SetPoint("BOTTOM", f, "TOP")
	up:SetSize(16, 16)
	up:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
	up:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
	up:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
	up:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")

	up:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	up:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	up:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	up:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	up:GetHighlightTexture():SetBlendMode("ADD")

	up:SetScript("OnClick", OnClickUp)
	up:SetScript("PostClick", Sound)

	local down = CreateFrame("Button", nil, f)
	down:SetPoint("TOP", f, "BOTTOM")
	down:SetSize(16, 16)
	down:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
	down:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
	down:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
	down:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")

	down:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	down:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	down:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	down:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	down:GetHighlightTexture():SetBlendMode("ADD")

	down:SetScript("OnClick", OnClickDown)
	down:SetScript("PostClick", Sound)

	f:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	local thumb = f:GetThumbTexture()
	thumb:SetSize(16, 24)
	thumb:SetTexCoord(1/4, 3/4, 1/8, 7/8)

	local function UpdateUpDown(self)
		local min, max = self:GetMinMaxValues()
		local value = self:GetValue()
		if value == min then up:Disable() else up:Enable() end
		if value == max then down:Disable() else down:Enable() end
	end

	f:HookScript("OnMinMaxChanged", UpdateUpDown)
	f:HookScript("OnValueChanged", UpdateUpDown)

	local border = CreateFrame("Frame", nil, f)
	border:SetPoint("TOPLEFT", up, -5, 5)
	border:SetPoint("BOTTOMRIGHT", down, 5, -3)
	border:SetBackdrop(BACKDROP)
	local r,g = TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g
	local b,a = TOOLTIP_DEFAULT_COLOR.b, 0.5
	border:SetBackdropBorderColor(r,g,b,a)

	return f, up, down, border
end
