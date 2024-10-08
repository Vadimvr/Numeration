local addon = select(2, ...)
local view = {}
addon.views["SpellUnits"] = view
view.first = 1

local backAction = function(f,windowID)
	view.first = 1
	addon.nav[windowID].view = "Spells"
	addon.nav[windowID].spell = nil
	addon:RefreshDisplay(nil,windowID)
end

local spellName = addon.spellName
function view:Init(windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then backAction(nil, windowID) return end
	local id = addon.nav[windowID].spell
	
	local t = addon.types[addon.nav[windowID].type]
	local text = format("%s: %s", t.name, spellName[id] or id)
	addon.windows[windowID]:SetTitle(text, t.c[1], t.c[2], t.c[3])
	addon.windows[windowID]:SetBackAction(backAction)
end

local sorttbl = {}
local unitToValue = {}
local sorter = function(u1, u2)
	return unitToValue[u1] > unitToValue[u2]
end

local updateTables = function(set, id, etype, merged)
	local total = 0
	for name,u in pairs(set.unit) do
		if u[etype] and u[etype].spell[id] then
			total = total + u[etype].spell[id]
			local ou = merged and u.owner and set.unit[u.owner] or u
			if unitToValue[ou] then
				unitToValue[ou] = unitToValue[ou] + u[etype].spell[id]
			else
				unitToValue[ou] = u[etype].spell[id]
				tinsert(sorttbl, ou)
			end
		end
	end
	table.sort(sorttbl, sorter)
	return total
end

function view:Update(merged,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then backAction(nil, windowID) return end
	local id = addon.nav[windowID].spell
	local etype = addon.types[addon.nav[windowID].type].id
	
	-- compile and sort information table
	local total = updateTables(set, id, etype, merged)
	
	-- display
	self.first, self.last = addon:GetArea(self.first, #sorttbl,windowID)
	if not self.last then return end
	
	local maxvalue = unitToValue[sorttbl[1]]
	for i = self.first, self.last do
		local u = sorttbl[i]
		local value = unitToValue[u]
		local c = addon.color[u.class]
		
		local line = addon.windows[windowID]:GetLine(i-self.first)
		line:SetValues(value, maxvalue)
		if u.owner then
			line:SetLeftText("%i. %s <%s>", i, u.name, u.owner)
		else
			line:SetLeftText("%i. %s", i, u.name)
		end
		line:SetRightText("%i (%02.1f%%)", value, value/total*100)
		line:SetColor(c[1], c[2], c[3])
		line:SetDetailAction(nil)
		line:Show()
	end
	
	sorttbl = wipe(sorttbl)
	unitToValue = wipe(unitToValue)
end

function view:Report(merged, num_lines,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	local id = addon.nav[windowID].spell
	local etype = addon.types[addon.nav[windowID].type].id
	
	-- compile and sort information table
	local total = updateTables(set, id, etype, merged)
	if #sorttbl == 0 then return end
	if #sorttbl < num_lines then
		num_lines = #sorttbl
	end
	
	-- display
	addon:PrintHeaderLine(set,windowID)
	for i = 1, num_lines do
		local u = sorttbl[i]
		local value = unitToValue[u]
		
		local name = u.name
		if u.owner then
			name = format("%s <%s>", u.name, u.owner)
		end

		addon:PrintLine("%i. %s %i (%02.1f%%)", i, name, value, value/total*100)
	end
	
	sorttbl = wipe(sorttbl)
	unitToValue = wipe(unitToValue)
end
