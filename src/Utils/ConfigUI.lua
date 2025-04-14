local _, addon = ...

local ConfigUI = {}
addon.ConfigUI = ConfigUI

function ConfigUI:InitializeOptions()
	local panel = CreateFrame("Frame")
	panel.name = "PeaversAlwaysSquare"

	panel.layoutIndex = 1
	panel.OnShow = function(self)
		return true
	end

	addon.mainCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	addon.mainCategory.ID = panel.name
	Settings.RegisterAddOnCategory(addon.mainCategory)

	panel.OnRefresh = function()
	end
	panel.OnCommit = function()
	end
	panel.OnDefault = function()
	end

	return panel
end

function ConfigUI:Initialize()
	self:InitializeOptions()
end
