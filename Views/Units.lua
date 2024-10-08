local addon = select(2, ...)
local view = {}
addon.views["Units"] = view
view.first = 1

local backAction = function(f,i)
	view.first = 1
	addon.nav[i].view = "Type"
	addon.nav[i].type = nil
	addon:RefreshDisplay(nil,i)
end

local detailAction = function(f,i)
	addon.nav[i].view = "UnitSpells"
	addon.nav[i].unit = f.unit
	addon:RefreshDisplay(nil,i)
end

function view:Init(i)
	local v = addon.types[addon.nav[i].type]
	local c = v.c
	addon.windows[i]:SetTitle(v.name, c[1], c[2], c[3])
	addon.windows[i]:SetBackAction(backAction)
end

local sorttbl = {}
local nameToValue = {}
local nameToTime = {}
local calcValueTime = function(set, name, etype, merged)
	local u = set.unit[name]
	if not u then return false end
	local value = u[etype] and u[etype].total or 0
	local time = u[etype] and u[etype].time or 0
	if merged and u.pets then
		for petname,_ in pairs(u.pets) do
			local pu_event = set.unit[petname][etype]
			if pu_event then
				value = value + pu_event.total
				if pu_event.time and pu_event.time > time then
					time = pu_event.time
				end
			end
		end
	end
	if value == 0 and u[etype] == nil then
		return false
	end
	if nameToValue[name] then
		nameToValue[name] = nameToValue[name] + value
		if nameToTime[name] < time then
			nameToTime[name] = time
		end
	else
		nameToValue[name] = value
		nameToTime[name] = time
	end
	return true
end

local sorter = function(n1, n2)
	return nameToValue[n1] > nameToValue[n2]
end

local updateTables = function(set, etype, etype2, merged)
	local total = 0
	for name,u in pairs(set.unit) do
		if u[etype] then
			total = total + u[etype].total
		end
		if etype2 and u[etype2] then
			total = total + u[etype2].total
		end
		if not merged or not u.owner then
			local added = calcValueTime(set, name, etype, merged)
			if etype2 then
				added = calcValueTime(set, name, etype2, merged) or added
			end
			if added then
				tinsert(sorttbl, name)
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
	local etype2 = addon.types[addon.nav[windowID].type].id2
	
	-- compile and sort information table
	local total = updateTables(set, etype, etype2, merged)
	
	-- display
	self.first, self.last = addon:GetArea(self.first, #sorttbl,windowID)
	if not self.last then return end
	
	local maxvalue = nameToValue[sorttbl[1]]
	for i = self.first, self.last do
		local u = set.unit[sorttbl[i]]
		local value, time = nameToValue[sorttbl[i]], nameToTime[sorttbl[i]]
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
		line.unit = sorttbl[i]
		line:SetDetailAction(detailAction)
		line:Show()
	end
	
	sorttbl = wipe(sorttbl)
	nameToValue = wipe(nameToValue)
	nameToTime = wipe(nameToTime)
end

function view:GetXps(set, name, etype, merged)
	calcValueTime(set, name, etype, merged)
	local value, time = nameToValue[name], nameToTime[name]
	nameToValue[name], nameToTime[name] = nil, nil
	if not value then
		return "n/a"
	elseif time == 0 then
		return tostring(value)
	end
	return format("%.1f", value/time)
end

function view:Report(merged, num_lines,windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then return end
	local etype = addon.types[addon.nav[windowID].type].id
	local etype2 = addon.types[addon.nav[windowID].type].id2
	
	-- compile and sort information table
	local total = updateTables(set, etype, etype2, merged)
	if #sorttbl == 0 then return end
	if #sorttbl < num_lines then
		num_lines = #sorttbl
	end
	
	-- display
	addon:PrintHeaderLine(set,windowID)
	for i = 1, num_lines do
		local u = set.unit[sorttbl[i]]
		local value, time = nameToValue[sorttbl[i]], nameToTime[sorttbl[i]]
		
		local name = u.name
		if u.owner then
			name = format("%s <%s>", u.name, u.owner)
		end
		
		if time ~= 0 then
			addon:PrintLine("%i. %s %i (%.1f, %02.1f%%)", i, name, value, value/time, value/total*100)
		else
			addon:PrintLine("%i. %s %i (%02.1f%%)", i, name, value, value/total*100)
		end
	end
	
	sorttbl = wipe(sorttbl)
	nameToValue = wipe(nameToValue)
	nameToTime = wipe(nameToTime)
end
