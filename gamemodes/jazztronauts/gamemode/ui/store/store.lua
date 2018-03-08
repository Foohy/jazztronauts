
-- #TODO: Derma skin? Sanity check??? Don't ever let me make UI again. 

-- Background jazzy tile
local bgmat = Material("materials/ui/jazz_grid.png", "noclamp")

-- Text color states for the button
local textColor = Color(69, 25, 74)
local textColorDisabled = Color(25, 25, 25)
local textColorHighlight = Color(202, 68, 217)

-- Background color states for the button
local bgColor = Color(217, 180, 102)
local bgDisabledColor = Color(132, 112, 76)
local bgPressedColor = Color(117, 75, 02)
local bgPurchased = Color(189, 217, 102)

-- The color of the rounded bright border on the button
local borderColor = Color(227, 210, 167)

surface.CreateFont( "JazzStoreName", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(15),
	weight    = 700,
	antialias = true
})
surface.CreateFont( "JazzStoreDescription", {
	font      = "KG Shake it Off Chunky",
	size      = ScreenScale(7),
	weight    = 700,
	antialias = true
})

-- Adds a new styled button, hooked up for purchasin'
local function AddButton(parent, item)
    local btn = vgui.Create( "DButton" )
    btn:SetText("")	
    btn:SetIcon("icon16/lock.png")
    btn:SetHeight(ScreenScale(30))

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
    img:Dock(LEFT)
    img:DockMargin(margin, margin, margin, margin)
    img:SetKeepAspect(true)
    img:SetImage("scripted/breen_fakemonitor_1")

    -- Wrap in a DListLayout so our name/description lays out correctly
    local itemInfo = vgui.Create("DListLayout", btn)
    itemInfo:Dock(FILL)
    itemInfo:SetMouseInputEnabled(false)

    -- Create the name text
    local name = vgui.Create("DLabel")
    name:SetFont("JazzStoreName")
    name:SetTextColor(textColor)
    name:SetText(" " .. item.name .. " - $" .. item.price)
    name:SizeToContents()
    itemInfo:Add(name)

    -- Create description text
    local desc = vgui.Create("DLabel")
    desc:SetFont("JazzStoreDescription")
    desc:SetTextColor(textColor)
    desc:SetContentAlignment(8)
    desc:SetText("This is a pretty good description, except that it actually says nothing at all. Gotcha.")
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
        -- Already purchased
        if unlocks.IsUnlocked("store", LocalPlayer(), item.unlock) then
            btn:SetIcon("icon16/accept.png")
            btn:SetEnabled(false)
            btn.Purchased = true
        -- Locked, can't be purchased yet
        elseif not jstore.IsAvailable(LocalPlayer(), item.unlock) then
            btn:SetEnabled(false)

            if item.requires then
                btn:SetTooltip("Requires " .. item.requires)
            end

        -- Ready to buy
        else
            btn:SetEnabled(true)
        end
    end

    -- Purchase
    btn.DoClick = function() 
        surface.PlaySound("ambient/materials/smallwire_pluck3.wav")
        jstore.PurchaseItem(item.unlock, function(success)
            print(success)
            if IsValid(btn) then parent:RefreshButtons() end
        end )
    end

    return btn
end

function JazzOpenStore()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScreenScale(300), ScreenScale(200) )
    frame:Center()
    frame:SetTitle( "Store!!!!!!!" )
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
    layout:SetBackgroundColor(Color(69, 25, 74))
    layout:SetDrawBackground(true)
    layout:DockPadding(pad, pad, pad, pad)
    layout:DockMargin(0, 0, pad, 0)
    layout:Dock(FILL)
    layout.Buttons = {}

    -- Utility function to refresh the state of all buttons when a store change happens
    layout.RefreshButtons = function()
        for _, v in pairs(layout.Buttons) do v:RefreshState() end
    end

    -- Create a button for each store item
    for k, v in pairs(jstore.GetItems()) do
        local btn = AddButton(layout, v)
        
        btn:RefreshState()
        layout:Add(btn)
        table.insert(layout.Buttons, btn)
    end

    layout:InvalidateLayout(true)
    layout:SizeToChildren(true, true)

end

-- #TODO: Actually hook this up
concommand.Add("jazz_open_store", function(ply, cmd, args)
    JazzOpenStore()
end )