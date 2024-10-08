local addon = select(2, ...)
local view = {}
addon.views["TargetUnits"] = view
view.first = 1

local backAction = function(f,windowID)
	view.first = 1
	addon.nav[windowID].view = "Targets"
	addon.nav[windowID].target = nil
	addon:RefreshDisplay(nil,windowID)
end

local detailAction = function(f,windowID)
	addon.nav[windowID].view = "TargetUnitsSpells"
	addon.nav[windowID].sourceName = f.sourceName;
	addon:RefreshDisplay(nil,windowID)
end

function view:Init(windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then backAction(nil, windowID) return end
	local target = addon.nav[windowID].target
	
	local t = addon.types[addon.nav[windowID].type]
	local text = format("%s: %s", t.name, target)
	addon.windows[windowID]:SetTitle(text , t.c[1], t.c[2], t.c[3])
	addon.windows[windowID]:SetBackAction(backAction)
end

local sorttbl = {}
local unitToValue = {}
local unitToTime = {}

local sorter = function(u1, u2)
	return unitToValue[u1] > unitToValue[u2]
end

local updateTables = function(set, target, etype, merged)
	local total = 0
	for name,u in pairs(set.unit) do
		if u[etype] and u[etype].target and u[etype].target[target] then
			total = total + u[etype].target[target]

			local time = u[etype] and u[etype].time or 0

			local ou = merged and u.owner and set.unit[u.owner] or u
			if unitToValue[ou] then
				unitToValue[ou] = unitToValue[ou] + u[etype].target[target]
				if unitToTime[ou] < time then
					unitToTime[ou] = time
				end
			else
				unitToValue[ou] = u[etype].target[target]
				unitToTime[ou] = time
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
	local target = addon.nav[windowID].target
	local etype = addon.types[addon.nav[windowID].type].id
	local total = updateTables(set, target, etype, merged)
	
	-- display
	self.first, self.last = addon:GetArea(self.first, #sorttbl,windowID)
	if not self.last then return end
	
	local maxvalue = unitToValue[sorttbl[1]]
	for i = self.first, self.last do
		local u = sorttbl[i]
	
		local value = unitToValue[u]
		local  time = unitToTime[u]
		local c = addon.color[u.class]
		
		local line = addon.windows[windowID]:GetLine(i-self.first)
		line:SetValues(value, maxvalue)
		if u.owner then
			line:SetLeftText("%i. %s <%s>", i, u.name, u.owner)
		else
			line:SetLeftText("%i. %s", i, u.name)
		end
		if time ~= 0 then
			line:SetRightText("%i (%.1f, %02.1f%%)", value, value/time, value/total*100)
		else
			line:SetRightText("%i (%02.1f%%)", value, value/total*100)
		end
		line:SetColor(c[1], c[2], c[3])
	--	print("Line.target", target)
		--line.target = target
		line.sourceName = u.name
		line:SetDetailAction(detailAction)
		line:Show()
	end
	
	sorttbl = wipe(sorttbl)
	unitToValue = wipe(unitToValue)
end

function view:Report(merged, num_lines,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	local target = addon.nav[windowID].target
	local etype = addon.types[addon.nav[windowID].type].id
	
	-- compile and sort information table
	local total = updateTables(set, target, etype, merged)
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
