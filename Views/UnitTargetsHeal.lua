local addon = select(2, ...)
local view = {}
addon.views["UnitTargetsHeal"] = view
view.first = 1

local backAction = function(f, windowID)
	view.first = 1
	addon.nav[windowID].view = "UnitSpells"
	addon:RefreshDisplay(nil, windowID)
end
local detailAction = function(f, windowID)
	addon.nav[windowID].view = "UnitTargetsHealSpell"
	addon.nav[windowID].unitTargetsHeal = f.unitTargetsHeal
	addon:RefreshDisplay(nil, windowID)
end
function view:Init(windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then
		backAction(nil, windowID)
		return
	end
	local u = set.unit[addon.nav[windowID].unit]
	if not u then
		backAction(nil, windowID)
		return
	end

	local t = addon.types[addon.nav[windowID].type]
	local text
	if u.owner then
		text = format("%s Targets: %s <%s>", t.name, u.name, u.owner)
	else
		text = format("%s Targets: %s", t.name, u.name)
	end
	addon.windows[windowID]:SetTitle(text, t.c[1], t.c[2], t.c[3])
	addon.windows[windowID]:SetBackAction(backAction)
end

local sorttbl = {}
local nameToValue = {}
local nameToPetName = {}
local nameToTarget = {}
local sorter = function(n1, n2)
	return nameToValue[n1] > nameToValue[n2]
end

local updateTables = function(set, u, etype, merged)
	if not etype then return 0 end
	local total = 0
	if u[etype] then
		total = u[etype].total
		for target, amount in pairs(u[etype].target) do
			local name = format("%s%s", u.name, target)
			if not nameToValue[name] then
				nameToValue[name] = amount
				nameToTarget[name] = target
				tinsert(sorttbl, name)
			else
				nameToValue[name] = nameToValue[name] + amount
			end
		end
	end
	if merged and u.pets then
		for petname, v in pairs(u.pets) do
			local pu = set.unit[petname]
			if pu[etype] then
				total = total + pu[etype].total
				for target, amount in pairs(pu[etype].target) do
					local name = format("%s%s", pu.name, target)
					if not nameToValue[name] then
						nameToValue[name] = amount
						nameToPetName[name] = pu.name
						nameToTarget[name] = target
						tinsert(sorttbl, name)
					else
						nameToValue[name] = nameToValue[name] + amount
					end
				end
			end
		end
	end
	table.sort(sorttbl, sorter)
	return total
end

function view:Update(merged, windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	if not set then
		backAction(nil, windowID)
		return
	end
	local u = set.unit[addon.nav[windowID].unit]
	if not u then
		backAction(nil, windowID)
		return
	end
	local etype = addon.types[addon.nav[windowID].type].id
	local etype2 = addon.types[addon.nav[windowID].type].id2

	-- compile and sort information table
	local total = updateTables(set, u, etype, merged)
	total = total + updateTables(set, u, etype2, merged)

	-- display
	self.first, self.last = addon:GetArea(self.first, #sorttbl, windowID)
	if not self.last then return end

	local c = addon.color[u.class]
	local maxvalue = nameToValue[sorttbl[1]]
	for i = self.first, self.last do
		local petName = nameToPetName[sorttbl[i]]
		local value = nameToValue[sorttbl[i]]
		local target = nameToTarget[sorttbl[i]]

		local line = addon.windows[windowID]:GetLine(i - self.first)
		line:SetValues(value, maxvalue)
		if petName then
			line:SetLeftText("%i. %s <%s>", i, target, petName)
		else
			line:SetLeftText("%i. %s", i, target)
		end
		line:SetRightText("%i (%02.1f%%)", value, value / total * 100)
		line:SetColor(c[1], c[2], c[3])
		line:SetIcon(icon)
		line.unitTargetsHeal = target;
		line:SetDetailAction(detailAction)
		line:Show()
	end

	sorttbl = wipe(sorttbl)
	nameToValue = wipe(nameToValue)
	nameToPetName = wipe(nameToPetName)
	nameToTarget = wipe(nameToTarget)
end

function view:Report(merged, num_lines, windowID)
	local set = addon:GetSet(addon.nav[windowID].set)
	local u = set.unit[addon.nav[windowID].unit]
	local etype = addon.types[addon.nav[windowID].type].id
	local etype2 = addon.types[addon.nav[windowID].type].id2

	-- compile and sort information table
	local total = updateTables(set, u, etype, merged)
	total = total + updateTables(set, u, etype2, merged)
	if #sorttbl == 0 then return end
	if #sorttbl < num_lines then
		num_lines = #sorttbl
	end

	-- display
	addon:PrintHeaderLine(set, windowID)
	for i = 1, num_lines do
		local petName = nameToPetName[sorttbl[i]]
		local value = nameToValue[sorttbl[i]]
		local target = nameToTarget[sorttbl[i]]

		if petName then
			target = format("%s <%s>", target, petName)
		end
		addon:PrintLine("%i. %s %i (%02.1f%%)", i, target, value, value / total * 100)
	end

	sorttbl = wipe(sorttbl)
	nameToValue = wipe(nameToValue)
	nameToPetName = wipe(nameToPetName)
	nameToTarget = wipe(nameToTarget)
end
