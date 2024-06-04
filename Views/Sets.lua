local addon = select(2, ...)
local view = {}
addon.views["Sets"] = view
view.first = 1

function view:Init(windowID)
	addon.windows[windowID]:SetTitle("Selection: Set", .1, .1, .1)
	addon.windows[windowID]:SetBackAction(nil)
end

local detailAction = function(f,windowID)
	
	addon.nav[windowID].view = "Type"
	addon.nav[windowID].set = f.id
	addon:RefreshDisplay(nil,windowID)
end

local setLine = function(lineid, setid, title,windowID)
	local set = addon:GetSet(setid)
	local line = addon.windows[windowID]:GetLine(lineid)
	line:SetValues(1, 1)
	if title then
		line:SetLeftText(title)
	else
		line:SetLeftText("%i. %s", setid, set.name)
	end
	local datetext, timetext = addon:GetDuration(set)
	if datetext then
		line:SetRightText("%s  %s", timetext, datetext)
	else
		line:SetRightText("")
	end
	line:SetColor(.3, .3, .3)
	line.id = setid
	line:SetDetailAction(detailAction)
	line:Show()
end

function view:Update(m,windowID)
	
	setLine(0, "total", " Overall Data",windowID)
	setLine(1, "current", " Current Fight",windowID)

	self.first, self.last = addon:GetArea(self.first, #NumerationCharDB+2,windowID)
	if not self.last then return end

	for i = self.first, self.last-2 do
		t = NumerationCharDB[i]
		setLine(i-self.first+2, i,nil,windowID)
	end

end
