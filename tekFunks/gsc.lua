
local myname, ns = ...

function ns.GSC(cash, colorblind)
	if not cash then return end
	local g, s, c = floor(cash/10000), floor((cash/100)%100), cash%100
	if colorblind or GetCVarBool("colorblindMode") then
		if g > 0 then return string.format(" |cffffd700%d.|cffc7c7cf%02d.|cffeda55f%02d", g, s, c)
		elseif s > 0 then return string.format(" |cffc7c7cf%d.|cffeda55f%02d", s, c)
		else return string.format(" |cffeda55f%d", c) end
	else
		if g > 0 and s == 0 and c == 0 then return string.format(" |cffffd700%d", g)
		elseif g > 0 and c == 0 then return string.format(" |cffffd700%d.|cffc7c7cf%02d", g, s)
		elseif g > 0 then return string.format(" |cffffd700%d.|cffc7c7cf%02d.|cffeda55f%02d", g, s, c)
		elseif s > 0 and c == 0 then return string.format(" |cffc7c7cf%d", s)
		elseif s > 0 then return string.format(" |cffc7c7cf%d.|cffeda55f%02d", s, c)
		else return string.format(" |cffeda55f%d", c) end
	end
end
