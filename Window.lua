local addon = select(2, ...)

local CountWindow = addon.CountWindow;

addon.windows = {}

for i = 1, CountWindow, 1 do
	local window = CreateFrame("Frame", "NumerationFrame" .. i, UIParent)
	addon.CreteWindow:CreteWindow(window, "window", i);
	addon.windows[i] = window;
end

function addon.windows:OnInitialize()
	for i = 1, CountWindow, 1 do
		if (NumerationCharOptions["maxlines"][i]) then
			addon.windowsSettings[i].maxlines = NumerationCharOptions["maxlines"][i];
		end;
		addon.windows[i]:OnInitialize(i)
	end
end

function addon.windows:Update(i, c)
	if (not i or not addon.windows[i]) then return; end
	if (not c or not type(c) == "number") then return; end
	if (addon.windowsSettings[i].maxlines + c <= 0 or addon.windowsSettings[i].maxlines + c >= 25) then return end

	addon.windowsSettings[i].maxlines = addon.windowsSettings[i].maxlines + c;
	NumerationCharOptions["maxlines"][i] = addon.windowsSettings[i].maxlines;
	addon.windows[i]:SetHeight(3 + addon.windowsSettings[i].titleheight +
		addon.windowsSettings[i].maxlines * (addon.windowsSettings[i].lineheight + addon.windowsSettings[i].linegap))
	addon.windows[i].maxlines = addon.windowsSettings[i].maxlines;
	addon:RefreshDisplay(false, i)
	
	--addon.windows[i]:OnInitialize(i)
	-- addon.windows[i]:Hide()
	-- addon.windows[i].scroll:Hide()
	-- local window = CreateFrame("Frame", "NumerationFrame" .. i, UIParent)
	-- addon.CreteWindow:CreteWindow(window, "window", i);
	-- addon.windows[i]:OnInitialize(i)
	-- addon.windows[i]:Show()
	-- for i = 1, addon.CountWindow, 1 do
	-- 	addon:RefreshDisplay(nil, i)
	-- end
end

function addon.windows:Hide()
	for i = 1, CountWindow, 1 do
		addon.windows[i]:Hide();
	end
end

function addon.windows:Show()
	for i = 1, CountWindow, 1 do
		addon.windows[i]:Show();
	end
end

function addon.windows:ShowResetWindow()
	for i = 2, CountWindow, 1 do
		addon.windows[i]:ShowResetWindow();
		break;
	end
end

function addon.windows:UpdateSegment(segment, i)
	addon.windows[i]:UpdateSegment(segment)
end

function addon.windows.IsShown()
	return addon.windows[1]:IsShown()
end

function addon.windows:Clear()
	for i = 1, CountWindow, 1 do
		addon.windows[i]:Clear();
	end
end
