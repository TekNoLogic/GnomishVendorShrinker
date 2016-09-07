
local myname, ns = ...


local function HasHeirloom(id)
	return C_Heirloom.IsItemHeirloom(id) and C_Heirloom.PlayerHasHeirloom(id)
end


local function IsKnown(link)
	ns.scantip:SetHyperlink(link)
	for i=1,ns.scantip:NumLines() do
		if ns.scantip.L[i] == ITEM_SPELL_KNOWN then return true end
	end
end


ns.knowns = setmetatable({}, {
	__index = function(t, i)
		local id = ns.ids[i]
		if not id then return end

		if HasHeirloom(id) or IsKnown(i) then
			t[i] = true
			return true
		end
	end
})
