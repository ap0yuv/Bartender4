--[[ $Id: ActionBars.lua 60964 2008-02-11 18:12:12Z nevcairiel $ ]]

--[[ Generic Template for a Bar which contains Buttons ]]

local Bar = Bartender4.Bar.prototype
local ButtonBar = setmetatable({}, {__index = Bar})
local ButtonBar_MT = {__index = ButtonBar}

local defaults = Bartender4:Merge({
	['**'] = {
		padding = 2,
		rows = 1,
	}
}, Bartender4.Bar.defaults)

Bartender4.ButtonBar = {}
Bartender4.ButtonBar.prototype = ButtonBar
Bartender4.ButtonBar.defaults = defaults

function Bartender4.ButtonBar:Create(id, template, config)
	local bar = setmetatable(Bartender4.Bar:Create(id, template, config), ButtonBar_MT)
	
	return bar
end

--[[===================================================================================
	Bar Options
===================================================================================]]--

-- option utilty functions
local optGetter, optSetter
do
	local getBar, optionMap, callFunc
	local barregistry = Bartender4.Bar.barregistry
	-- maps option keys to function names
	optionMap = {
		rows = "Rows",
		padding = "Padding",
	}
	
	-- retrieves a valid bar object from the barregistry table
	function getBar(id)
		local bar = barregistry[tostring(id)]
		assert(bar, "Invalid bar id in options table.")
		return bar
	end
	
	-- calls a function on the bar
	function callFunc(bar, type, option, ...)
		local func = type .. (optionMap[option] or option)
		assert(bar[func], "Invalid get/set function.")
		return bar[func](bar, ...)
	end
	
	-- universal function to get a option
	function optGetter(info)
		local bar = getBar(info[2])
		local option = info[#info]
		return callFunc(bar, "Get", option)
	end
	
	-- universal function to set a option
	function optSetter(info, ...)
		local bar = getBar(info[2])
		local option = info[#info]
		return callFunc(bar, "Set", option, ...)
	end
end

local options
function ButtonBar:GetOptionObject()
	local obj = Bar.GetOptionObject()
	local otbl_general = {
		padding = {
			order = 40,
			type = "range",
			name = "Padding",
			desc = "Configure the padding of the buttons.",
			min = -10, max = 20, step = 1,
			set = optSetter,
			get = optGetter,
		},
		rows = {
			order = 70,
			name = "Rows",
			desc = "Number of rows.",
			type = "range",
			min = 1, max = 12, step = 1,
			set = optSetter,
			get = optGetter,
		},
	}
	obj:AddElementGroup("general", otbl_general)
	return obj
end


function ButtonBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)
	-- any module inherting this template should call UpdateButtonLayout after setting up its buttons, we cannot call it here
	--self:UpdateButtonLayout()
end

-- get the current padding
function ButtonBar:GetPadding()
	return self.config.padding
end

-- set the padding and refresh layout
function ButtonBar:SetPadding(pad)
	if pad ~= nil then
		self.config.padding = pad
	end
	self:UpdateButtonLayout()
end


-- get the current number of rows
function ButtonBar:GetRows()
	return self.config.rows
end

-- set the number of rows and refresh layout
function ButtonBar:SetRows(rows)
	if rows ~= nil then
		self.config.rows = rows
	end
	self:UpdateButtonLayout()
end

local math_floor = math.floor
-- align the buttons and correct the size of the bar overlay frame
function ButtonBar:UpdateButtonLayout()
	local buttons = self.buttons
	local numbuttons = #buttons
	local pad = self:GetPadding()
	
	local Rows = self:GetRows()
	local ButtonPerRow = math_floor(numbuttons / Rows + 0.5) -- just a precaution
	Rows = math_floor(numbuttons / ButtonPerRow + 0.5)
	
	self:SetSize((36 + pad) * ButtonPerRow - pad + 8, (36 + pad) * Rows - pad + 8)
	
	-- anchor button 1 to the topleft corner of the bar
	buttons[1]:ClearSetPoint("TOPLEFT", self, "TOPLEFT", 6, -3)
	-- and anchor all other buttons relative to our button 1
	for i = 2, numbuttons do
		-- jump into a new row
		if ((i-1) % ButtonPerRow) == 0 then
			buttons[i]:ClearSetPoint("TOPLEFT", buttons[i-ButtonPerRow], "BOTTOMLEFT", 0, -pad)
		-- align to the previous button
		else
			buttons[i]:ClearSetPoint("TOPLEFT", buttons[i-1], "TOPRIGHT", pad, 0)
		end
	end
end