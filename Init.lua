
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
	GVS:SetPoint("TOPLEFT", MerchantFrame, 8, -67)
	GVS:Hide()


	-- Reanchor the buyback button, it acts weird when switching tabs otherwise...
	MerchantBuyBackItem:ClearAllPoints()
	MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", -7, 33)


	hooksecurefunc("SetMerchantFilter", function() GVS:GetScript("OnShow")(GVS) end)


	if MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 1 then
		GVS:Show()
	end


	-- Clean up our frame factories
	for i,v in pairs(ns) do if i:match("^New") then ns[i] = nil end end
end
