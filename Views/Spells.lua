local addon = select(2, ...)
local view = {}
addon.views["Spells"] = view
view.first = 1

local spellName = addon.spellName
local spellIcon = addon.spellIcon

local backAction = function(f,windowID)
	view.first = 1
	addon.nav[windowID].view = "Type"
	addon.nav[windowID].type = nil
	addon:RefreshDisplay(nil,windowID)
end

local detailAction = function(f,windowID)
	addon.nav[windowID].view = "SpellUnits"
	addon.nav[windowID].spell = f.spell
	addon:RefreshDisplay(nil,windowID)
end

function view:Init(windowID)
	local v = addon.types[addon.nav[windowID].type]
	local c = v.c
	addon.windows[windowID]:SetTitle(v.name, c[1], c[2], c[3])
	addon.windows[windowID]:SetBackAction(backAction)
end

local sorttbl = {}
local spellToValue = {}
local sorter = function(s1, s2)
	return spellToValue[s1] > spellToValue[s2]
end

local updateTables = function(set, etype)
	local total = 0
	for name,u in pairs(set.unit) do
		if u[etype] then
			total = total + u[etype].total
			for id,amount in pairs(u[etype].spell) do
				if spellToValue[id] then
					spellToValue[id] = spellToValue[id] + amount
				else
					spellToValue[id] = amount
					tinsert(sorttbl, id)
				end
			end
		end
	end
	table.sort(sorttbl, sorter)
	return total
end

function view:Update(merged,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then return end
	local etype = addon.types[addon.nav[windowID].type].id
	
	-- compile and sort information table
	local total = updateTables(set, etype)
	
	-- display
	self.first, self.last = addon:GetArea(self.first, #sorttbl,windowID)
	if not self.last then return end
	
	local c = addon.types[addon.nav[windowID].type].c
	local maxvalue = spellToValue[sorttbl[1]]
	for i = self.first, self.last do
		local id = sorttbl[i]
		local value = spellToValue[id]
		local name, icon = spellName[id], spellIcon[id]
		
		if name == nil then
			name = id
			icon = ""
		elseif id == 0 or id == 75 then
			icon = ""
		end
		
		local line = addon.windows[windowID]:GetLine(i-self.first)
		line:SetValues(value, maxvalue)
		line:SetLeftText("%i. %s", i, name)
		line:SetRightText("%i (%02.1f%%)", value, value/total*100)
		line:SetColor(c[1], c[2], c[3])
		line:SetIcon(icon)
		line.spellId = id
		line.spell = id
		line:SetDetailAction(detailAction)
		line:Show()
	end
	
	sorttbl = wipe(sorttbl)
	spellToValue = wipe(spellToValue)
end

function view:Report(merged, num_lines,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then return end
	local etype = addon.types[addon.nav[windowID].type].id
	
	-- compile and sort information table
	local total = updateTables(set, etype)
	if #sorttbl == 0 then return end
	if #sorttbl < num_lines then
		num_lines = #sorttbl
	end
	
	-- display
	addon:PrintHeaderLine(set,windowID)
	for i = 1, num_lines do
		local value = spellToValue[sorttbl[i]]
		local name = spellName[sorttbl[i]] or sorttbl[i]

		addon:PrintLine("%i. %s %i (%02.1f%%)", i, name, value, value/total*100)
	end
	
	sorttbl = wipe(sorttbl)
	spellToValue = wipe(spellToValue)
end
