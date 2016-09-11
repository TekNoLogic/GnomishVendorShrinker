
local myname, ns = ...


local ItemSearch = LibStub('LibItemSearch-1.0')

local NUMROWS, SCROLLSTEP = 14, 5


local function Hide(frame)
	frame:Hide()
	frame.Show = frame.Hide
end


function ns.OnLoad()
	Hide(MerchantNextPageButton)
	Hide(MerchantPrevPageButton)
	Hide(MerchantPageText)


	local GVS = CreateFrame("frame", nil, MerchantFrame)
	GVS:SetWidth(315)
	GVS:SetHeight(294)
	GVS:SetPoint("TOPLEFT", 8, -67)
	GVS:SetScript("OnEvent", function(self, event, ...)
		if self[event] then return self[event](self, event, ...) end
	end)
	GVS:Hide()


	local rows = {}
	for i=1,NUMROWS do
		local row = ns.NewMerchantItemFrame(GVS)

		if i == 1 then
			row:SetPoint("TOPLEFT")
			row:SetPoint("RIGHT", -19, 0)
		else
			row:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT")
			row:SetPoint("RIGHT", rows[i-1])
		end

		rows[i] = row
	end


	local scrollbar = LibStub("tekKonfig-Scroll").new(GVS, 0, SCROLLSTEP)
	local offset = 0
	local function Refresh()
		local n = GetMerchantNumItems()
		local row, n_searchmatch = 1, 0
		for i=1,n do
			local link = GetMerchantItemLink(i)
			if ItemSearch:Find(link, GVS.searchstring) then
				if n_searchmatch >= offset and n_searchmatch < offset + NUMROWS then
					rows[row]:SetValue(i)
					row = row + 1
				end
				n_searchmatch = n_searchmatch + 1
			end
		end
		scrollbar:SetMinMaxValues(0, math.max(0, n_searchmatch - NUMROWS))
		for i=row,NUMROWS do
			rows[i]:Hide()
		end
	end
	GVS.CURRENCY_DISPLAY_UPDATE = Refresh
	GVS.BAG_UPDATE = Refresh
	GVS.MERCHANT_UPDATE = Refresh


	ns.MakeSearchField(GVS, Refresh)


	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		Refresh()
		return f(self, value, ...)
	end)


	local offset = 0
	GVS:EnableMouseWheel(true)
	GVS:SetScript("OnMouseWheel", function(self, value)
		scrollbar:SetValue(scrollbar:GetValue() - value * SCROLLSTEP)
	end)
	GVS:SetScript("OnShow", function(self, noreset)
		local max = math.max(0, GetMerchantNumItems() - NUMROWS)
		scrollbar:SetMinMaxValues(0, max)
		scrollbar:SetValue(noreset and math.min(scrollbar:GetValue(), max) or 0)
		Refresh()

		GVS:RegisterEvent("BAG_UPDATE")
		GVS:RegisterEvent("MERCHANT_UPDATE")
		GVS:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	end)
	GVS:SetScript("OnHide", function()
		GVS:UnregisterEvent("BAG_UPDATE")
		GVS:UnregisterEvent("MERCHANT_UPDATE")
		GVS:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
		if StackSplitFrame:IsVisible() then StackSplitFrame:Hide() end
	end)


	-- Reanchor the buyback button, it acts weird when switching tabs otherwise...
	MerchantBuyBackItem:ClearAllPoints()
	MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", -7, 33)


	local function Show()
		for i=1,12 do _G["MerchantItem"..i]:Hide() end
		if GVS:IsShown() then GVS:GetScript("OnShow")(GVS, true) else GVS:Show() end
	end
	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", Show)


	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		GVS:Hide()
		for i=1,12 do _G["MerchantItem"..i]:Show() end
	end)


	if MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 1 then Show() end


	-- Clean up our frame factories
	for i,v in pairs(ns) do if i:match("^New") then ns[i] = nil end end
end
