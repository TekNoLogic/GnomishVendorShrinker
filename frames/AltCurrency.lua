
local myname, ns = ...


local function NewItemFrame(self, i)
	local item = self.NewAltCurrencyItemFrame(self.parent)

	if i == 1 then
		item:SetPoint("LEFT")
	else
		item:SetPoint("LEFT", self[i-1], "RIGHT")
	end

	self[i] = item
	return item
end


local itemframesets = {}
local function SetValue(self, i)
	local items = itemframesets[self]
	for _,item in ipairs(items) do item:Hide() end

	local num = GetMerchantItemCostInfo(i)
	self:SetShown(num > 0)

	if num > 0 then
		for j=1,num do items[j]:SetValue(i, j) end
		self:SizeToFit()
	else
		self:SetWidth(0)
	end
end


local frames = {}
local MT = {__index = NewItemFrame}
function ns.NewAltCurrencyFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(1,1)

	local t = {
		parent = frame,
		NewAltCurrencyItemFrame = ns.NewAltCurrencyItemFrame,
	}
	itemframesets[frame] = setmetatable(t, MT)

	frame.SetValue = SetValue
	frame.SizeToFit = ns.SizeToFit

	return frame
end
