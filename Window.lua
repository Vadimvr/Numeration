local addon = select(2, ...)
print("window")

local window = CreateFrame("Frame", "NumerationFrame1", UIParent)
local window1 = CreateFrame("Frame", "NumerationFrame2", UIParent)
addon.CreteWindow:CreteWindow(window,"window" );
addon.CreteWindow:CreteWindow(window1,"window1");
addon.window = window;
addon.window1 = window1;

addon.windows ={}
function addon.windows:OnInitialize()
	window:OnInitialize()
	window1:OnInitialize()
end


function addon.windows:Hide()
	window:Hide()
	window1:Hide()
end


function addon.windows:Show()
	window:Show()
	window1:Show()
end

function addon.windows:ShowResetWindow()
	window:ShowResetWindow(true)
	window1:ShowResetWindow(false)
end

function addon.windows:UpdateSegment(segment)
	window:UpdateSegment(segment)
	window1:UpdateSegment(segment)
end

function addon.windows.IsShown ()
	return window:IsShown()
end
function addon.windows:Clear()
	window.Clear()
	window1.Clear()
end
