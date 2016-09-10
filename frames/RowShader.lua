
local myname, ns = ...



local RECIPE = GetItemClassInfo(LE_ITEM_CLASS_RECIPE)
local MISC = GetItemClassInfo(LE_ITEM_CLASS_MISCELLANEOUS)
local GARRISON_ICONS = {[1001489] = true, [1001490] = true, [1001491] = true}


local function Knowable(link)
	local id = ns.ids[link]
	if C_Heirloom.IsItemHeirloom(id) then return true end

	local _, _, _, _, _, class, _, _, _, texture = GetItemInfo(link)
	if class == MISC and select(2, C_ToyBox.GetToyInfo(id)) then return true end
	if class == RECIPE or GARRISON_ICONS[texture] then return true end
end


local function RecipeNeedsRank(link)
	local _, _, _, _, _, class = GetItemInfo(link)
	if class ~= RECIPE then return end
	return ns.unmet_requirements[link]
end


local DEFAULT_GRAD = {0,1,0,0.75, 0,1,0,0} -- green
local GRADS = {
	red = {1,0,0,0.75, 1,0,0,0},
	[1] = {1,1,1,0.75, 1,1,1,0}, -- white
	[2] = DEFAULT_GRAD, -- green
	[3] = {0.5,0.5,1,1, 0,0,1,0}, -- blue
	[4] = {1,0,1,0.75, 1,0,1,0}, -- purple
	[7] = {1,.75,.5,0.75, 1,.75,.5,0}, -- heirloom
}
GRADS = setmetatable(GRADS, {
	__index = function(t,i)
		t[i] = DEFAULT_GRAD
		return DEFAULT_GRAD
	end
})


function ns.GetRowGradient(index)
	local gradient = DEFAULT_GRAD
	local shown = false

	local _, _, _, _, _, isUsable = GetMerchantItemInfo(index)
	if not isUsable then
		gradient = GRADS.red
		shown = true
	end

	local link = GetMerchantItemLink(index)
	if not (link and Knowable(link)) then return gradient, shown end

	if ns.knowns[link] then
		return gradient, false
	elseif RecipeNeedsRank(link) then
		return GRADS.red, true
	else
		local _, _, quality = GetItemInfo(link)
		return GRADS[quality], true
	end
end


local QUALITY_COLORS = setmetatable({}, {
	__index = function(t,i)
		-- GetItemQualityColor only takes numbers, so fall back to white
		local _, _, _, hex = GetItemQualityColor(tonumber(i) or 1)
		t[i] = "|c".. hex
		return "|c".. hex
	end
})


function ns.GetRowTextColor(index)
	local link = GetMerchantItemLink(index)
	if not link then return QUALITY_COLORS.default end

	-- Grey out if already known
	if Knowable(link) and ns.knowns[link] then return QUALITY_COLORS[0] end

	local _, _, quality = GetItemInfo(link)
	return QUALITY_COLORS[quality]
end


function ns.GetRowVertexColor(index)
	local _, _, _, _, _, isUsable = GetMerchantItemInfo(index)
	if isUsable then return 1.0, 1.0, 1.0
	else             return 0.9, 0.0, 0.0
	end
end
