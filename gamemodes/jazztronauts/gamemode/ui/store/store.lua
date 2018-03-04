function JazzOpenStore()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 400, 550 )
    frame:Center()
    frame:SetTitle( "Store!!!!!!!" )
    frame:SetVisible( true )
    frame:SetDraggable( true )
    frame:ShowCloseButton( true )
    frame:MakePopup()

    local layout = vgui.Create( "DListLayout", frame )
    layout:Dock(FILL)
    layout.Buttons = {}
    layout.RefreshButtons = function()
        for _, v in pairs(layout.Buttons) do v:RefreshState() end
    end

    for k, v in pairs(jstore.GetItems()) do
        local btn = vgui.Create( "DButton" )
        btn:SetText(" " .. v.name .. " - $" .. v.price)	
        btn:SetIcon("icon16/lock.png")
        btn:SetWidth(400)
        btn.SetPurchased = function()
            btn:SetIcon("icon16/accept.png")
            btn:SetEnabled(false)
        end
        btn.RefreshState = function()
            -- Already purchased
            if unlocks.IsUnlocked("store", LocalPlayer(), k) then
                btn:SetIcon("icon16/accept.png")
                btn:SetEnabled(false)
            -- Locked, can't be purchased yet
            elseif not jstore.IsAvailable(LocalPlayer(), k) then
                btn:SetEnabled(false)

                if v.requires then
                    btn:SetTooltip("Requires " .. v.requires)
                end

            -- Ready to buy
            else
                btn:SetEnabled(true)
            end
        end
        btn.DoClick = function() 
            surface.PlaySound("ambient/materials/smallwire_pluck3.wav")
            jstore.PurchaseItem(k, function(success)
                if IsValid(btn) then layout:RefreshButtons() end
            end )
        end
        
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