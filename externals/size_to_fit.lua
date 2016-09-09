
local myname, ns = ...


-- Resize a frame to fit all its visible children.  Useful for creating frames
-- that adjust to their contents while reducing couping between those frames
--
-- Attach to a frame by using `frame.SizeToFit = ns.SizeToFit`.  Call with colon
-- syntax, i.e. `frame:SizeToFit()` on the eldest frame you want to resize.
-- All children with this helper will be resized if they are currently shown.


local function ResizeChildren(...)
	for i=1,select("#", ...) do
		local child = select(i, ...)
		if child.SizeToFit and child:IsShown() then child:SizeToFit() end
	end
end


function ns.SizeToFit(self)
	-- The frame must be visible for `GetBoundsRect()` to work.  That means it has
	-- to be "Shown" and have non-zero dimensions
	self:Show()
	self:SetSize(1, 1)

	-- Child frames need to be resized first
	ResizeChildren(self:GetChildren())

	-- Now resize ourself
	local _, _, width, height = self:GetBoundsRect()
	self:SetSize(width, height)
end
