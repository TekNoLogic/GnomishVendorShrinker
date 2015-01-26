
local myname, ns = ...


-- Creates a memoizing table that converts an itemlink string into an itemID int
ns.ids = setmetatable({}, {
	__index = function(t,i)
		if type(i) == "number" then
			t[i] = i
			return i
		elseif type(i) ~= "string" then
			t[i] = false
			return
		end

		local id = tonumber(i:match("item:(%d+)"))
		t[i] = id
		return id
	end,
})
