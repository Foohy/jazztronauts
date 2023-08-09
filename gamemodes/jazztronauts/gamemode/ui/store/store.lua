module("jstore", package.seeall) -- Extend jstore module

local function ScreenScale(size)
	-- if it goes under 2 it looks stupid, it fits into 640x480 who cares
	return size * math.max( ScrW() / 640.0, 2)
end

-- #TODO: Derma skin? Sanity check??? Don't ever let me make UI again.

-- Background jazzy tile
local bgmat = Material("materials/ui/jazz_grid.png", "noclamp")
local newIcon = Material("materials/ui/jazztronauts/catcoin.png")
local defaultIcon =  Material("ui/transition_horse")

-- Background for the layout panel
local bgPanelColor = Color(73, 24, 71)

-- Text color states for the button
local textColor = bgPanelColor -- cool negative space effect
local textColorDisabled = Color(25, 25, 25)
local textColorHighlight = Color(244, 144, 255)

-- Background color states for the button
local bgColor = Color(217, 180, 102)
local bgHoverColor = Color(255, 230, 175)
local bgDisabledColor = Color(132, 112, 76)
local bgPressedColor = Color(117, 75, 02)
local bgPurchased = Color(189, 217, 102)

-- Width of the upgrade item gradient
local upGradWidth = ScreenScale(20)
local bgUpgradeColor = Color(17, 17, 17)
local bgUpgradeColorHighlight = Color(88, 88, 88)
local bgUpgradeColorPurchased = Color(105, 143, 85)

local bgUpgradePriceColor = Color(116, 192, 74)
local bgUpgradePriceDisabledColor = Color(20, 65, 58)

-- The color of the rounded bright border on the button
local borderColor = Color(227, 210, 167)
local borderColorDisabled = Color(157, 147, 122)

-- Margin that universally looks nice for everything, multiply or divide as needed
local uniPad = ScreenScale(4)

local storeFilters =
{
	["upgrades"] = function(itm) return itm.type == "upgrade" end,
	["tools"] = function(itm) return itm.type != "upgrade" end
}

surface.CreateFont( "JazzStoreName", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(15),
	weight	= 700,
})
surface.CreateFont( "JazzStoreDescription", {
	font	  = "KG Red Hands",
	size	  = ScreenScale(8.5),
})
surface.CreateFont( "JazzUpgradeName", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(12),
})
surface.CreateFont( "JazzUpgradePrice", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(9),
})

local function buttonPurchase(btn, item, parent)
	jstore.PurchaseItem(item.unlock, function(success)
		if success then
			if IsValid(btn) then parent:RefreshButtons() end
		else
			surface.PlaySound("buttons/button10.wav")
		end
	end )
end

local function buttonRefresh(btn, item, thingtohide)
	local tip = nil

	-- Already purchased
	if unlocks.IsUnlocked("store", LocalPlayer(), item.unlock) then
		btn:SetEnabled(false)
		btn.Purchased = true
		tip = jazzloc.Localize("jazz.store.purchased")

		if thingtohide then thingtohide:Hide() end

	-- Locked, can't be purchased yet
	elseif not jstore.IsAvailable(LocalPlayer(), item.unlock) then
		btn:SetEnabled(false)

		if item.requires then
			tip = jazzloc.Localize("jazz.store.requires", GetItem(item.requires).name )
		end

	-- Ready to buy
	else
		btn:SetEnabled(true)
	end

	return tip
end

-- Adds a new styled button, hooked up for purchasin'
local function addButton(parent, item)
	local btnSize = ScreenScale(40)
	local btn = vgui.Create( "DButton" )
	btn:SetText("")
	btn:SetHeight(btnSize)

	btn:DockMargin(0, 0, 0, uniPad)
	btn.Paint = function(self, w, h)
		local thick = ScreenScale(1.25)
		draw.RoundedBox(5, 0, 0, w, h, self.BorderColor or color_white)
		draw.RoundedBox(5, thick, thick, w - thick*2, h - thick*2, self.BGColor or color_white)
	end
	btn.SetBackgroundColor = function(self, col) self.BGColor = col end
	btn.SetBorderColor = function(self, col) self.BorderColor = col end

	-- Create image thumbnail
	local img = vgui.Create("DImage", btn)
	img:SetMaterial(item.icon or defaultIcon)
	img:Dock(LEFT)
	img:DockMargin(uniPad, uniPad, uniPad, uniPad)
	img:SetKeepAspect(true)
	img:SetWidth(ScreenScale(32))

	-- Optional "NEW" informative marker
	local newImg = vgui.Create("DImage", img)
	newImg:SetMaterial(newIcon)
	newImg:NoClipping(true)
	newImg:SetPos(ScreenScale(-8), ScreenScale(-8))
	newImg:SetSize(ScreenScale(16), ScreenScale(16))
	newImg:SetVisible(IsItemNewlyAffordable(item.unlock))
	function btn:SetIsNew(isNew) newImg:SetVisible(isNew) end

	-- Wrap in a DListLayout so our name/description lays out correctly
	local itemInfo = vgui.Create("DListLayout", btn)
	itemInfo:Dock(FILL)
	itemInfo:DockMargin(0, uniPad, uniPad, uniPad)
	itemInfo:SetMouseInputEnabled(false)

	-- Create the name text
	local name = vgui.Create("DLabel")
	name:SetFont("JazzStoreName")
	name:SetTextColor(textColor)
	name:SetText(jazzloc.Localize("jazz.store.listing",item.name,string.Comma(item.price)))
	name:SizeToContents()
	itemInfo:Add(name)

	-- Create description text
	local desc = vgui.Create("DLabel")
	desc:SetFont("JazzStoreDescription")
	desc:SetTextColor(textColor)
	desc:SetContentAlignment(8)
	desc:SetText(item.desc or "")
	desc:SetWrap(true)
	desc:SetAutoStretchVertical(true)
	desc:SetMultiline(true)
	itemInfo:Add(desc)
	desc:Dock(TOP)

	-- Utility function to update the button's 'style'
	btn.SetButtonStyle = function(self, text, bg, border)
		desc:SetTextColor(text)
		name:SetTextColor(text)
		btn:SetBackgroundColor(bg)
		if not border then border = borderColor end
		btn:SetBorderColor(border)
	end

	-- Update button colors depending on current state
	btn.UpdateColours = function(self, skin)
		local purchCol = self.Purchased and bgPurchased or bgDisabledColor
		if ( !self:IsEnabled() )					then self:SetButtonStyle(textColorDisabled, purchCol, borderColorDisabled) return end
		if ( self:IsDown() || self.m_bSelected )	then self:SetButtonStyle(textColorHighlight, bgPressedColor) return end
		if ( self.Hovered )							then self:SetButtonStyle(textColor, bgHoverColor) return end

		self:SetButtonStyle(textColor, bgColor)
	end

	-- Update current button state with unlock status
	btn.RefreshState = function()
		local tip = buttonRefresh(btn, item)

		if tip then btn:SetTooltip(tip) end

		-- Newly available
		btn:SetIsNew(IsItemNewlyAffordable(item.unlock))
	end

	-- Purchase
	btn.DoClick = function() buttonPurchase(btn, item, parent) end

	function btn:Think()
		if self:IsHovered() and IsItemNewlyAffordable(item.unlock) then
			MarkItemSeen(item.unlock)
			self:SetIsNew(IsItemNewlyAffordable(item.unlock))
		end
	end

	return btn
end

local function createHeader(category, item, first)
	local label = vgui.Create("DLabel")
	label:SetText(" " .. category)
	label:SetFont("JazzStoreName")
	label:SetColor(textColor)
	label:SetAutoStretchVertical(true)
	label:SizeToChildren(false, true)
	label:DockMargin(0, first and 0 or uniPad * 2, 0, uniPad / 2)

	function label:Paint(w, h)
		local thick = ScreenScale(1.25)
		draw.RoundedBox(5, 0, 0, w, h, borderColor)
		draw.RoundedBox(5, thick, thick, w - thick*2, h - thick*2, bgColor)
	end

	return label
end

local alpha_stops = {
	{-1, ColorAlpha(color_white, 0) },
	{ 1, ColorAlpha(color_white, 255) },
}
CacheGradient( "upgrade_item_left", Rect(0, 0, 3, 1), 0, alpha_stops, 0 )
CacheGradient( "upgrade_item_right", Rect(0, 0, 3, 1), 180, alpha_stops, 0 )
local function createListButton(parent, item)
	local btn = vgui.Create( "DButton" )
	btn:SetText("")
	btn:SetFont("JazzUpgradeName") -- needed for proper vertical size
	btn:SetAutoStretchVertical(true)
	btn:DockMargin(0, 0, 0, uniPad / 2)
	btn:DockPadding(upGradWidth * 1.2, uniPad / 3, upGradWidth * 1.2, uniPad / 3)
	btn.SetBackgroundColor = function(self, col) self.BGColor = col end

	function btn:Paint(w, h)
		-- Left gradient
		local rect = Rect(0, 0, upGradWidth, h)
		LinearGradientCached( "upgrade_item_left", rect, self.BGColor)

		-- Solid background
		surface.SetDrawColor(self.BGColor or bgUpgradeColor)
		surface.DrawRect(upGradWidth, 0, w - upGradWidth * 2, h)

		-- Right gradient
		local rect = Rect(w - upGradWidth, 0, upGradWidth, h)
		LinearGradientCached( "upgrade_item_right", rect, self.BGColor)

		-- "New" icon
		if IsItemNewlyAffordable(item.unlock) then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(newIcon)
			--surface.DisableClipping(true)
				surface.DrawTexturedRect(h * 0.8, 0, h, h)
			--surface.DisableClipping(false)

			if self:IsHovered() then
				MarkItemSeen(item.unlock)
			end
		end
	end

	function btn:UpdateColours(skin)
		local purchCol = self.Purchased and bgUpgradeColorPurchased or bgDisabledColor
		if ( !self:IsEnabled() )					then self:SetButtonStyle(textColorDisabled, purchCol, bgUpgradePriceDisabledColor) return end
		if ( self:IsDown() || self.m_bSelected )	then self:SetButtonStyle(bgColor, bgPressedColor, bgUpgradePriceColor) return end
		if ( self.Hovered )							then self:SetButtonStyle(bgColor, bgUpgradeColorHighlight, bgUpgradePriceColor) return end

		self:SetButtonStyle(bgColor, bgUpgradeColor, bgUpgradePriceColor)
	end

	local name = vgui.Create("DLabel", btn)
	name:SetText(item.name)
	name:SetFont("JazzUpgradeName")
	name:SetColor(bgColor)
	name:SetContentAlignment(4)
	name:CenterVertical()
	name:Dock(FILL)

	local price = vgui.Create("DLabel", btn)
	price:SetText(jazzloc.Localize("jazz.store.price",string.Comma(item.price)))
	price:SetFont("JazzUpgradePrice")
	price:SetColor(textColor)
	price:SetContentAlignment(5)
	price:SizeToContentsX(uniPad)
	price:Dock(RIGHT)
	price.SetBackgroundColor = function(self, col) self.BGColor = col end

	-- Allow large prices but enforce a min width
	function price:PerformLayout()
		local minWidth = ScreenScale(40)
		if self:GetWide() < minWidth then self:SetWidth(minWidth) end
	end

	function price:Paint(w, h)
		draw.RoundedBox(5, 0, 0, w, h, self.BGColor or bgUpgradePriceColor)
	end


	btn.SetButtonStyle = function(self, textColor, bgColor, bgPriceCol)
		name:SetColor(textColor)
		btn:SetBackgroundColor(bgColor)
		price:SetBackgroundColor(bgPriceCol)
	end

	-- Update current button state with unlock status
	function btn:RefreshState()
		local tip = buttonRefresh(btn, item, price)

		if tip then
			self:SetTooltip(item.desc.."\n"..tip)
		else
			self:SetTooltip(item.desc)
		end

		-- If upgrade, hide if already purchased and there's one after this
		if item.baseseries then
			local unlockedLevel = jstore.GetSeries(LocalPlayer(), item.baseseries)
			local maxLevel = jstore.GetSeriesMax(item.baseseries)

			if item.level == unlockedLevel + 1 or (item.level == maxLevel and unlockedLevel == maxLevel) then
				self:Show()
			else
				self:Hide()
			end
		end

	end

	-- Purchase
	btn.DoClick = function() buttonPurchase(btn, item, parent) end

	return btn
end

local function getHeaderName(item)
	-- Category overrides everything
	if item.cat then return item.cat end

	-- If no category specified, try to get an unlock this item requires
	local reqs = jstore.GetRequirements(item)
	local baseitem = #reqs > 0 and jstore.GetItem(reqs[1]) -- Grab top level requirement

	if baseitem then
		-- Don't return if it's a series upgrade
		local baseitemsplit = string.Explode(" - ", baseitem.name)[1]
		local itemsplit = string.Explode(" - ", item.name)[1]

		if not string.match(baseitemsplit, itemsplit) then
			return baseitem.name
		end
	end

	return "uncat"
end

local function createSpacerPanel(pad)
	local panel = vgui.Create("DPanel")
	panel:SetBackgroundColor(bgColor)
	panel:SetHeight( ScreenScale(2) )
	panel:DockMargin(0, 0, 0, pad or 0)
	panel:SetPaintBackground(true)

	return panel
end

local function createCategoryButton(parent, item, category, createSpacer)
	if not parent.Categories then parent.Categories = {} end

	-- Create the category if it doesn't exist
	local layout = parent.Categories[category]
	if not layout then
		if category != "uncat" then
			-- Create the header
			local header = createHeader(category, item, table.Count(parent.Categories) == 0)
			parent:Add(header)
		end

		layout = vgui.Create( "DListLayout", parent )
		layout:DockMargin(ScreenScale(11), 0, ScreenScale(11), 0)

		parent.Categories[category] = layout
	end

	if createSpacer then
		layout:Add(createSpacerPanel(uniPad / 2))
	end

	-- Add the button to purchase the item itself
	local btn = createListButton(parent, item)
	layout:Add(btn)

	return btn
end

local function createStoreFrame(title)
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( ScreenScale(300), ScreenScale(210) )
	frame:Center()
	frame:SetTitle(title )
	frame:SetVisible( true )
	frame:SetDraggable( true )
	frame:ShowCloseButton( true )
	frame:SetSizable(true)
	frame:MakePopup()

	-- Override background paint
	function frame:Paint(w, h)
		local mw = 64
		local mh = 64
		local offset = RealTime() * -0.05

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(bgmat)
		surface.DrawTexturedRectUV(0, 0, w, h, offset, offset, w / mw + offset, h / mh + offset)
	end

	-- Make sure it can scroll
	local framepad = 10 -- title bar doesnt change size with resolution, so this should feel proportional to that
	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)
	scroll:DockMargin(framepad, 0, framepad, framepad)

	-- Place each button in a vertical list
	local layout = vgui.Create( "DListLayout", scroll )
	layout:SetBackgroundColor(bgPanelColor)
	layout:SetPaintBackground(true)
	layout:DockPadding(uniPad, uniPad, uniPad, uniPad)
	layout:DockMargin(0, 0, 0, 0)
	layout:Dock(FILL)

	-- Utility function to refresh the state of all buttons when a store change happens
	layout.Buttons = {}
	function layout:RefreshButtons()
		for _, v in pairs(self.Buttons) do v:RefreshState() end
	end

	return frame, layout, scroll
end

function GetStoreItems(storeName)
	if not storeFilters[storeName] then return {} end
	local filtered = {}
	local items = jstore.GetItems()
	for k, v in pairs(items) do
		if storeFilters[storeName](v) then
			table.insert(filtered, v)
		end
	end

	return filtered
end

function OpenStore()
	local frame, layout = createStoreFrame(jazzloc.Localize("jazz.store.toollabel"))

	-- Create a button for each store item
	local items = GetStoreItems("tools")
	table.sort(items, function(a, b)
		-- Keep thirdparty at bottom
		if a.thirdparty != b.thirdparty then
			return b.thirdparty
		end

		-- Keep purchased at bottom
		local unlockedA = unlocks.IsUnlocked("store", LocalPlayer(), a.unlock)
		local unlockedB = unlocks.IsUnlocked("store", LocalPlayer(), b.unlock)
		if unlockedA != unlockedB then
			return unlockedB
		end

		-- Sort by # of requirements, easily purchaseable up top
		if a.numreqs < b.numreqs then return true end
		if a.numreqs > b.numreqs then return false end

		-- Sort by price
		return a.price < b.price
	end)

	local hasspacer = false
	for k, v in pairs(items) do
		if not hasspacer and v.thirdparty then
			hasspacer = true
			layout:Add(createSpacerPanel(uniPad))
		end

		local btn = addButton(layout, v)

		btn:RefreshState()
		layout:Add(btn)
		table.insert(layout.Buttons, btn)
	end

	layout:InvalidateLayout(true)
	layout:SizeToChildren(true, true)

	-- Resize to the items plus (hardcoded) outer frame, max out to just enough to show default + a bit of another listing
	frame:SetHeight( math.Min( layout:GetTall() + 44, ScreenScale(210) ) )

end

local function getBaseItem(item)
	if item.baseseries then
		local itm = jstore.GetSeriesList()[item.baseseries]
		if itm and itm[1] then return jstore.GetItem(itm[1]) end
	end

	return item
end

function OpenUpgradeStore()
	local frame, layout = createStoreFrame(jazzloc.Localize("jazz.store.upgradelabel"))

	-- Create a button for each store item
	-- Sort the items by number of requirements, and then by name
	-- Use the #reqs of the first item for series upgrades
	local items = GetStoreItems("upgrades")
	table.sort(items, function(a, b)
		local ab, bb = getBaseItem(a), getBaseItem(b)

		-- All series-based items go to bottom
		if tobool(ab.baseseries) != tobool(bb.baseseries) then return bb.baseseries != nil end

		-- Sort by # of requirements, easily purchaseable up top
		if ab.numreqs < bb.numreqs then return true end
		if ab.numreqs > bb.numreqs then return false end

		-- Sort by name, not price since that changes and would be inconsistent and weird
		return ab.name < bb.name
	end )

	local hasSpacer = {}
	for k, v in pairs(items) do
		-- Insert a small spacer element to separate recurring from non-recurring upgrades
		-- Assumes that recurring upgrades are sorted after normal ones
		local createSpacer = false
		local category = getHeaderName(v)
		if v.baseseries and not table.HasValue(hasSpacer, category) then
			table.insert(hasSpacer, category)
			-- only add spacer if at least one non-series upgrade
			if layout.Categories[category] then createSpacer = true end
		end

		local btn = createCategoryButton(layout, v, category, createSpacer)

		btn:RefreshState()
		table.insert(layout.Buttons, btn)
	end


end

function IsItemNewlyAffordable(itemName)
	local item = jstore.GetItem(itemName)
	if not item then return false end

	-- If not available, its not available
	if not jstore.IsAvailable(LocalPlayer(), item.unlock) then return false end

	-- If not enough money, not new
	if LocalPlayer():GetNotes() < item.price then return false end

	-- Check if already seen
	return not LocalPlayer():GetPData("jazz_seenitems_" .. item.unlock, false)
end

function HasNewItems(storeName)
	local items = GetStoreItems(storeName)

	for _, v in pairs(items) do
		if IsItemNewlyAffordable(v.unlock) then
			return true
		end
	end

	return false
end

function MarkItemSeen(itemName)
	local item = jstore.GetItem(itemName)
	if not item then return end

	LocalPlayer():SetPData("jazz_seenitems_" .. item.unlock, true)
end

function ResetSeenItems()
	for _, v in pairs(jstore.GetItems()) do
		LocalPlayer():RemovePData("jazz_seenitems_" .. v.unlock)
	end
end

concommand.Add("jazz_reset_seen", ResetSeenItems)

-- #TODO: Actually hook this up
concommand.Add("jazz_open_store", function(ply, cmd, args)
	OpenStore()
end )
