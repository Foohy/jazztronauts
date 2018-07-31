module("jstore", package.seeall) -- Extend jstore module

-- #TODO: Derma skin? Sanity check??? Don't ever let me make UI again. 

-- Background jazzy tile
local bgmat = Material("materials/ui/jazz_grid.png", "noclamp")
local newIcon = "materials/ui/jazztronauts/catcoin.png"
local defaultIcon = "ui/transition_horse"

-- Background for the layout panel
local bgPanelColor = Color(73, 24, 71)

-- Text color states for the button
local textColor = Color(69, 25, 74)
local textColorDisabled = Color(25, 25, 25)
local textColorHighlight = Color(202, 68, 217)

-- Background color states for the button
local bgColor = Color(217, 180, 102)
local bgDisabledColor = Color(132, 112, 76)
local bgPressedColor = Color(117, 75, 02)
local bgPurchased = Color(189, 217, 102)

-- Width of the upgrade item gradient
local upGradWidth = ScreenScale(10)
local bgUpgradeColor = Color(17, 17, 17)
local bgUpgradeColorHighlight = Color(88, 88, 88)
local bgUpgradeColorPurchased = Color(105, 143, 85)

local bgUpgradePriceColor = Color(116, 192, 74)
local bgUpgradePriceDisabledColor = Color(20, 65, 58)

-- The color of the rounded bright border on the button
local borderColor = Color(227, 210, 167)

local storeFilters = 
{
    ["upgrades"] = function(itm) return itm.type == "upgrade" end,
    ["tools"] = function(itm) return itm.type != "upgrade" end
}

surface.CreateFont( "JazzStoreName", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(15),
	weight    = 700,
	antialias = true
})
surface.CreateFont( "JazzUpgradeName", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(12),
	weight    = 500,
	antialias = true
})
surface.CreateFont( "JazzStoreDescription", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(8),
	weight    = 500,
	antialias = true
})
surface.CreateFont( "JazzUpgradePrice", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(9),
	weight    = 500,
	antialias = true,
    strikethrough = true
})

-- Adds a new styled button, hooked up for purchasin'
local function addButton(parent, item)
    local btnSize = ScreenScale(30)
    local btn = vgui.Create( "DButton" )
    btn:SetText("")	
    btn:SetIcon("icon16/lock.png")
    btn:SetHeight(btnSize)

    local margin = ScreenScale(2)
    btn:DockMargin(0, margin, 0, margin)
    btn.Paint = function(self, w, h) 
        local thick = ScreenScale(1.25)
        draw.RoundedBox(5, 0, 0, w, h, borderColor)
        draw.RoundedBox(5, thick, thick, w - thick*2, h - thick*2, self.BGColor or color_white)
    end
    btn.SetBackgroundColor = function(self, col) self.BGColor = col end

    -- Create image thumbnail
    local img = vgui.Create("DImage", btn)
    img:SetImage(item.icon, defaultIcon)
    img:Dock(LEFT)
    img:DockMargin(margin, margin, margin, margin)  
    img:SetSize(btnSize, btnSize)
    img:SetKeepAspect(true)

    -- Optional "NEW" informative marker
    local newImg = vgui.Create("DImage", img)
    newImg:SetImage(newIcon)
    newImg:NoClipping(true)
    newImg:SetPos(ScreenScale(-8), ScreenScale(-8))
    newImg:SetSize(ScreenScale(16), ScreenScale(16))
    newImg:SetVisible(IsItemNewlyAffordable(item.unlock))
    function btn:SetIsNew(isNew) newImg:SetVisible(isNew) end

    -- Wrap in a DListLayout so our name/description lays out correctly
    local itemInfo = vgui.Create("DListLayout", btn)
    itemInfo:Dock(FILL)
    itemInfo:SetMouseInputEnabled(false)

    -- Create the name text
    local name = vgui.Create("DLabel")
    name:SetFont("JazzStoreName")
    name:SetTextColor(textColor)
    name:SetText(" " .. item.name .. " - $" .. string.Comma(item.price))
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
    btn.SetButtonStyle = function(self, textColor, bgColor)
        desc:SetTextColor(textColor)
        name:SetTextColor(textColor) 
        btn:SetBackgroundColor(bgColor)
    end

    -- Update button colors depending on current state
    btn.UpdateColours = function(self, skin)
        local purchCol = self.Purchased and bgPurchased or bgDisabledColor
        if ( !self:IsEnabled() )                    then self:SetButtonStyle(textColorDisabled, purchCol) return end
        if ( self:IsDown() || self.m_bSelected )	then self:SetButtonStyle(textColorHighlight, bgPressedColor) return end
        if ( self.Hovered )							then self:SetButtonStyle(textColorHighlight, bgColor) return end

        self:SetButtonStyle(textColor, bgColor) 
    end 

    -- Update current button state with unlock status
    btn.RefreshState = function()
        local tooltip = item.desc or ""

        -- Already purchased
        if unlocks.IsUnlocked("store", LocalPlayer(), item.unlock) then
            btn:SetIcon("icon16/accept.png")
            btn:SetEnabled(false)
            btn.Purchased = true
        -- Locked, can't be purchased yet
        elseif not jstore.IsAvailable(LocalPlayer(), item.unlock) then
            btn:SetEnabled(false)

            if item.requires then
                tooltip = tooltip .. "\n" .. "REQUIRES " .. string.upper(item.requires)
            end

        -- Ready to buy
        else
            btn:SetEnabled(true)
        end

        btn:SetTooltip(tooltip)

        -- Newly available
        btn:SetIsNew(IsItemNewlyAffordable(item.unlock))
    end

    -- Purchase
    btn.DoClick = function() 
        surface.PlaySound("ambient/materials/smallwire_pluck3.wav")
        jstore.PurchaseItem(item.unlock, function(success)
            print(success)
            if IsValid(btn) then parent:RefreshButtons() end
        end )
    end

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
    label:DockMargin(0, first and 0 or ScreenScale(7), 0, 0)

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
    local vmargin = ScreenScale(1)
    local hmargin = ScreenScale(11)

    local btn = vgui.Create( "DButton" )
    btn:SetText("   " .. item.name) -- please no bully
    btn:SetFont("JazzUpgradeName")
    btn:SetColor(bgColor)
    btn:SetContentAlignment(4)
    btn:DockMargin(hmargin, vmargin, hmargin, vmargin)
    btn:SetAutoStretchVertical(true)
    btn:SizeToChildren(false, true)
    btn.SetBackgroundColor = function(self, col) self.BGColor = col end

    local newMat = Material(newIcon)
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
            surface.SetMaterial(newMat)
            surface.DisableClipping(true)
                surface.DrawTexturedRect(h * -0.4, 0, h, h)
            surface.DisableClipping(false)

            if self:IsHovered() then
                MarkItemSeen(item.unlock)
            end
        end
    end

    function btn:UpdateColours(skin)
        local purchCol = self.Purchased and bgUpgradeColorPurchased or bgDisabledColor
        if ( !self:IsEnabled() )                    then self:SetButtonStyle(textColorDisabled, purchCol, bgUpgradePriceDisabledColor) return end
        if ( self:IsDown() || self.m_bSelected )	then self:SetButtonStyle(bgColor, bgPressedColor, bgUpgradePriceColor) return end
        if ( self.Hovered )							then self:SetButtonStyle(bgColor, bgUpgradeColorHighlight, bgUpgradePriceColor) return end

        self:SetButtonStyle(bgColor, bgUpgradeColor, bgUpgradePriceColor) 
    end 

    -- Add price information to right side
    local priceDock = ScreenScale(1)
    local price = vgui.Create("DLabel", btn)
    price:SetText(" $" .. string.Comma(item.price) .. " ")
    price:SetFont("JazzUpgradePrice")
    price:SetColor(textColor)
    price:SetContentAlignment(5)
    price:SetAutoStretchVertical(true)
    price:SizeToContentsX()
    price:DockMargin(0, priceDock, upGradWidth, priceDock)
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
        btn:SetTextColor(textColor)
        btn:SetBackgroundColor(bgColor)
        price:SetBackgroundColor(bgPriceCol)
    end
   
    -- Set the state of the button given store unlock status
    function btn:RefreshState()
        local tooltip = item.desc or ""
        -- Already purchased
        if unlocks.IsUnlocked("store", LocalPlayer(), item.unlock) then
            self:SetEnabled(false)
            price:Hide()
            self.Purchased = true

        -- Locked, can't be purchased yet
        elseif not jstore.IsAvailable(LocalPlayer(), item.unlock) then
            self:SetEnabled(false)

            if item.requires then
                tooltip = tooltip .. "\n" .. "REQUIRES" .. string.upper(item.requires)
            end

        -- Ready to buy
        else
            self:SetEnabled(true)
        end

        self:SetTooltip(tooltip)
        
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
    function btn:DoClick()
        surface.PlaySound("ambient/materials/smallwire_pluck3.wav")
        jstore.PurchaseItem(item.unlock, function(success)
            if IsValid(self) then parent:RefreshButtons() end
        end )
    end

    return btn
end

local function getHeaderName(item)
    -- Category overrides everything
    if item.cat then return item.cat end

    -- If no category specified, try to get an unlock this item requires
    local reqs = jstore.GetRequirements(item)
    local baseitem = #reqs > 0 and jstore.GetItem(reqs[1]) -- Grab top level requirement
    if baseitem then 
        return baseitem.name 
    end

    return nil
end

local function createSpacerPanel(parent)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(bgColor)
    panel:SetHeight(10)
    panel:SetPaintBackground(true)

    return panel
end

local function createCategoryButton(parent, item, createSpacer)
    if not parent.Categories then parent.Categories = {} end

    -- #TODO: This probably doesn't handle enough cases. 
    -- This requires every upgrade requires a base item/unlock.
    local category = getHeaderName(item)
    if not category then
        print("WARNING: Upgrade without a category/unlock item: ", item.name)
        return
    end

    -- Create the category if it doesn't exist
    local layout = parent.Categories[category]
    if not layout then
        layout = vgui.Create( "DListLayout", parent )
        
        -- Create the header
        local header = createHeader(category, item, table.Count(parent.Categories) == 0)
        layout:Add(header)

        parent.Categories[category] = layout
    end

    if createSpacer then
        layout:Add(createSpacerPanel())
    end

    -- Add the button to purchase the item itself
    local btn = createListButton(parent, item)
    layout:Add(btn)

    return btn
end

local function createStoreFrame(title)
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScreenScale(300), ScreenScale(200) )
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
    local pad = ScreenScale(2)  
    local framepad = ScreenScale(5)
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(framepad, framepad, pad, framepad)
    
    -- Place each button in a vertical list
    local layout = vgui.Create( "DListLayout", scroll )
    layout:SetBackgroundColor(bgPanelColor)
    layout:SetDrawBackground(true)
    layout:DockPadding(pad, pad, pad, pad)
    layout:DockMargin(0, 0, pad, 0)
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
    local frame, layout = createStoreFrame("Tools")

    -- Create a button for each store item
    local items = GetStoreItems("tools")
    table.sort(items, function(a, b)
        if a.thirdparty != b.thirdparty then return b.thirdparty end
    end)

    local hasspacer = false
    for k, v in pairs(items) do
        if not hasspacer and v.thirdparty then
            hasspacer = true
            layout:Add(createSpacerPanel())
        end
        
        local btn = addButton(layout, v)

        btn:RefreshState()
        layout:Add(btn)
        table.insert(layout.Buttons, btn)
    end

    layout:InvalidateLayout(true)
    layout:SizeToChildren(true, true)

end

local function getBaseItem(item)
    if item.baseseries then
        local itm = jstore.GetSeriesList()[item.baseseries]
        if itm and itm[1] then return jstore.GetItem(itm[1]) end
    end

    return item
end

function OpenUpgradeStore()
    local frame, layout = createStoreFrame("Upgrades")

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

        -- Sort by name
        return ab.name > bb.name
    end )

    local hasRecurringSpacer = false
    for k, v in pairs(items) do
        -- Insert a small spacer element to separate recurring from non-recurring upgrades
        -- Assumes that recurring upgrades are sorted after normal ones
        local createSpacer = false
        if not hasRecurringSpacer and k > 1 and v.baseseries then
            hasRecurringSpacer = true
            createSpacer = true
        end

        local btn = createCategoryButton(layout, v, createSpacer)
        
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
    return not LocalPlayer():GetPData("jazz_seenitems_" .. item.name, false)
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

    LocalPlayer():SetPData("jazz_seenitems_" .. item.name, true)
end

function ResetSeenItems()
    for _, v in pairs(jstore.GetItems()) do
        LocalPlayer():RemovePData("jazz_seenitems_" .. v.name)
    end
end

concommand.Add("jazz_reset_seen", ResetSeenItems)

-- #TODO: Actually hook this up
concommand.Add("jazz_open_store", function(ply, cmd, args)
    OpenStore()
end )