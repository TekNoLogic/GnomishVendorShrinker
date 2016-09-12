
local myname, ns = ...


local ItemSearch = ns.LibItemSearch
ns.LibItemSearch = nil


local NUMROWS, SCROLLSTEP = 14, 5


local function Hide(frame)
	frame:Hide()
	frame.Show = frame.Hide
end


function ns.OnLoad()
	Hide(MerchantNextPageButton)
	Hide(MerchantPrevPageButton)
	Hide(MerchantPageText)


	local GVS = ns.NewMainFrame()
	GVS:SetWidth(315)
	GVS:SetHeight(294)
	GVS:SetPoint("TOPLEFT", 8, -67)
	GVS:Hide()


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
