
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


-- "Requires Previous Rank"
local PREV_RANK = TOOLTIP_SUPERCEDING_SPELL_NOT_KNOWN
local function NeedsRank(link)
	ns.scantip:SetHyperlink(link)
	for i=1,ns.scantip:NumLines() do
		if ns.scantip.L[i] == PREV_RANK then return true end
	end
end


ns.unmet_requirements = setmetatable({}, {
	__index = function(t, i)
		local id = ns.ids[i]
		if not id then return end

		if NeedsRank(i) then
			t[i] = true
			return true
		end
	end
})
