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
		addon.windows[i]:OnInitialize(i)
	end
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
	addon.windows[1]:ShowResetWindow(true)
	for i = 2, CountWindow, 1 do
		addon.windows[i]:ShowResetWindow(false);
	end
end

function addon.windows:UpdateSegment(segment,i)
	--print("Window",39, i);
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
