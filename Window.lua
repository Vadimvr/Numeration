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

		 if( addon.windowsSettings[i] == nil)then
             addon.windowsSettings[i] ={
				pos =  addon.windowsettings.pos,
				width = addon.windowsettings.width,
				maxlines = addon.windowsettings.maxlines,
				backgroundalpha = addon.windowsettings.backgroundalpha,
				scrollbar = addon.windowsettings.scrollbar,

				titleheight = addon.windowsettings.titleheight,
				titlealpha = addon.windowsettings.titlealpha,
				titlefont = addon.windowsettings.titlefont ,
				titlefontsize = addon.windowsettings.titlefontsize,
				titlefontcolor = addon.windowsettings.titlefontcolor,

				lineheight = addon.windowsettings.lineheight,
				linegap = addon.windowsettings.linegap,
				linealpha = addon.windowsettings.linealpha,
				linetexture = addon.windowsettings.linetexture,
				linefont = addon.windowsettings.linefont,
				linefontsize =addon.windowsettings.linefontsize,
				linefontcolor = addon.windowsettings.linefontcolor,
};
        end
        if (NumerationCharOptions["maxlines"][i]) then
			addon.windowsSettings[i].maxlines = NumerationCharOptions["maxlines"][i];
		end;
		addon.windows[i]:OnInitialize(i)
	end
end

function addon.windows:UpdateLines(i, c)
	if (not i or not addon.windows[i]) then return; end
	local point, relativeTo, relativePoint, xOfs, yOfs = addon.windows[i]:GetPoint();
	local top = addon.windows[i]:GetTop();
	local left = addon.windows[i]:GetLeft();
	if (not c or not type(c) == "number") then return; end
	if (addon.windowsSettings[i].maxlines + c <= 0 or addon.windowsSettings[i].maxlines + c >= 25) then return end

	addon.windowsSettings[i].maxlines = addon.windowsSettings[i].maxlines + c;
	NumerationCharOptions["maxlines"][i] = addon.windowsSettings[i].maxlines;
	addon.windows[i]:SetHeight(3 + addon.windowsSettings[i].titleheight +
		addon.windowsSettings[i].maxlines * (addon.windowsSettings[i].lineheight + addon.windowsSettings[i].linegap))
	addon.windows[i].maxlines = addon.windowsSettings[i].maxlines;
	NumerationCharOptions["maxlines"][i] = addon.windows[i].maxlines;
	addon:RefreshDisplay(false, i)
	if(point == "CENTER" or point == "RIGHT" or point == "LEFT")then
		local correctY =  c * (addon.windowsSettings[i].lineheight +1) /2;
			local s = addon.windows[i]:GetEffectiveScale()
            local uis = UIParent:GetScale()
		addon.windows[i]:SetPoint(point, UIParent, point, xOfs, yOfs - correctY)
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
