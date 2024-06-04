local addon = select(2, ...)
local view = {}
addon.views["Targets"] = view
view.first = 1

local backAction = function(f,windowID)
	view.first = 1
	addon.nav[windowID].view = "Type"
	addon.nav[windowID].type = nil
	addon:RefreshDisplay(false,windowID)
end

local detailAction = function(f,windowID)
	addon.nav[windowID].view = "TargetUnits"
	addon.nav[windowID].target = f.target
	addon:RefreshDisplay(false,windowID)
end

function view:Init(windowID)
	local v = addon.types[addon.nav[windowID].type]
	local c = v.c
	addon.windows[windowID]:SetTitle(v.name, c[1], c[2], c[3])
	addon.windows[windowID]:SetBackAction(backAction)
end

local sorttbl = {}
local targetToValue = {}
local sorter = function(n1, n2)
	return targetToValue[n1] > targetToValue[n2]
end

local updateTables = function(set, etype)
	local total = 0
	for name,u in pairs(set.unit) do
		if u[etype] then
			total = total + u[etype].total
			if u[etype].target then
				for target,amount in pairs(u[etype].target) do
					if targetToValue[target] then
						targetToValue[target] = targetToValue[target] + amount
					else
						targetToValue[target] = amount
						tinsert(sorttbl, target)
					end
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
	local maxvalue = targetToValue[sorttbl[1]]
	for i = self.first, self.last do
		local target = sorttbl[i]
		local value = targetToValue[target]
		
		local line = addon.windows[windowID]:GetLine(i-self.first)
		line:SetValues(value, maxvalue)
		line:SetLeftText("%i. %s", i, target)
		line:SetRightText("%i (%02.1f%%)", value, value/total*100)
		line:SetColor(c[1], c[2], c[3])
		line.target = target
		line:SetDetailAction(detailAction)
		line:Show()
	end
	
	sorttbl = wipe(sorttbl)
	targetToValue = wipe(targetToValue)
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
		local target = sorttbl[i]
		local value = targetToValue[target]
		
		addon:PrintLine("%i. %s %i (%02.1f%%)", i, target, value, value/total*100)
	end
	
	sorttbl = wipe(sorttbl)
	targetToValue = wipe(targetToValue)
end
