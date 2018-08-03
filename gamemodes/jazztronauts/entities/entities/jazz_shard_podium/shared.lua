-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Prop" )
	self:NetworkVar( "Entity", 1, "FakeOwner" )
	self:NetworkVar( "Bool", 0, "Pressed" )
	self:NetworkVar( "Bool", 1, "Open" )
    self:NetworkVar( "Bool", 2, "Friendly")

end

function ENT:Initialize()

	--self:SetModel( Model("models/jazztronauts/zak/podium.mdl") )
	--self:SetModel( Model("models/props_combine/combine_door01.mdl") )
	--self:PhysicsInit( SOLID_VPHYSICS )
	--self:SetMoveType( MOVETYPE_PUSH )
	--self:RemoveFlags( FL_STATICPROP )
	--self:Activate()
	--self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:PhysicsInitBox(Vector(-4,-4,0), Vector(8,8,36))
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	self.basepos = self:GetPos()
	self.playing = false

	if SERVER then
		self:SetUseType( SIMPLE_USE )

		local pos = self:GetPos()

		print(tostring(pos))

		self.prop = ents.Create("prop_dynamic")
		self.prop:SetKeyValue("model", "models/jazztronauts/zak/podium.mdl")
		--self.prop:SetKeyValue("DefaultAnim", "idle")
		self.prop:SetKeyValue("solid", "6")
		self.prop:SetPos( self:GetPos() - Vector(0,0,2) )
		self.prop:SetAngles( self:GetAngles() + Angle(0,180,0) )
		self.prop:Spawn()
		self.prop:Activate()
		self.prop:SetUseType(SIMPLE_USE)
		self.prop.parent = self
		self.prop:SetParent(self)

		self:SetProp( self.prop )
		self:SetPressed( false )
		self:SetOpen( false )


		print( self.prop:GetSolidFlags() )

		self.next_anim = "idle"
		self.playing = self.next_anim
	end

	self:DrawShadow(false)

	if SERVER then

		timer.Simple(1, function() 
			self:Raise()
		end )

	else

		self.screen = worldcanvas.New( 400, 300, self:GetPos(), self:GetAngles() )

	end

end

function ENT:Use( activator, caller, usetype, value )
	self:Close()
end

function ENT:Raise()

	if not self.raised then

		self:SetNextAnimation("raise")
		self:EmitSound(Sound("doors/doormove3.wav"))

		timer.Simple(2, function() 
			self:SetSolid( SOLID_BBOX )
			self:SetNextAnimation("open")
			self:EmitSound(Sound("doors/door_metal_thin_move1.wav"), 80, 125, 1)
			self:SetOpen( true )
		end )

		self.raised = true

	end

end

function ENT:Lower()

	if not self.lowered then

		self:SetNextAnimation("lower",.35)
		self:EmitSound(Sound("doors/doormove3.wav"), 100, 70, 1)

		self.lowered = true

	end

end

function ENT:Close()

	if not self.closed then

		self:SetPressed( true )
		self:SetOpen( false )

		self:SetSolid( SOLID_NONE )

		self:SetNextAnimation("close")
		self:EmitSound(Sound("buttons/button6.wav"), 100, 80, 1)

		self.closed = true

	end

end

function ENT:SetNextAnimation( anim, rate )

	self.next_anim = anim
	self.anim_rate = rate or 1
	rate = rate or 1

	if not self.prop then
		self:ResetSequence( anim )
		self.playing = anim
	else
		
	end

end

function ENT:Think()

	if SERVER and self.prop and self.playing ~= self.next_anim then
		self.prop:Input("SetAnimation", nil, nil, self.next_anim)
		self.prop:Input("SetPlaybackRate", nil, nil, tostring(self.anim_rate) )
		self.playing = self.next_anim
	end

	self:NextThink( CurTime() )
	return true

end

function ENT:OnRemove()

	if SERVER and self.prop then self.prop:Remove() end

end

local eclipseMat = Material("sprites/jazzeclipse")

function ENT:Draw()

end

function ENT:DrawScreen()

	local ang = self:GetAngles()
	self.screen = worldcanvas.New()
	self.screen:EnableDebug( false )
	self.screen:SetAngles( ang )
	self.screen:SetPos( self:GetPos() + Vector(0,0,25) + ang:Forward()*4)
	self.screen:SetSize( 100, 20 )
	self.screen:SetResolution( 400, 80 )
	self.screen:SetDrawFunc( function()

		draw.SimpleText( self:GetFakeOwner():Nick(), "DermaLarge", 200, 40, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end )
	self.screen:Draw()

end

function ENT:DrawEclipse()
	--ang:RotateAroundAxis(ang:Right(), 90)
	local pos = self:GetPos() + Vector(0,0,34)

	cam.IgnoreZ( true )
	render.OverrideDepthEnable( true, false )
	render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_ONE, BLENDFUNC_ADD )

	for i=1, 1 do

		local s2 = math.sin( CurTime() + i + self:EntIndex() )
		local s = 32 + math.sin( i*s2 + CurTime() * 1 ) * 10

		render.SetMaterial(eclipseMat)
		render.DrawSprite(pos, s, s, color_white)

	end

	render.OverrideBlend( false, BLEND_SRC_COLOR, BLEND_ONE, BLENDFUNC_ADD )
	render.OverrideDepthEnable( false, false )
	cam.IgnoreZ( false )
end

function ENT:DrawShard()
	local t = RealTime()
	local pos = self:GetPos() + Vector(0,0,34)
	local ang = Angle(t, math.sin(t/2) * 360, math.cos(t/3) * 360)
    local scale = Vector(1, 1, 1) + 
    Vector(math.sin(t*2.5) * 0.1, math.cos(t*3) * 0.1, math.cos(t*4 + math.pi/2) * 0.1)

	local minishard = ManagedCSEnt("podiumshard" .. tostring(self), "models/sunabouzu/jazzshard.mdl")
	minishard:SetPos(pos)
	minishard:SetAngles(ang)
	minishard:SetModelScale(0.15)
	minishard:SetNoDraw(true)
	minishard:DrawModel()
end

function ENT:DrawTranslucent()

	local prop = self:GetProp()
	if not IsValid(prop) then return end
	--self:DrawModel()
	local drawfriendly = self.GetFriendly and self:GetFriendly() 

	if self:GetOpen() then

		if drawfriendly then
			self:DrawShard()
		else
			self:DrawEclipse()
		end

		if IsValid( self:GetFakeOwner() ) then
			render.OverrideDepthEnable( true, false )
			self:DrawScreen()
			render.OverrideDepthEnable( false, false )
		end

	end

	if drawfriendly then
		local _, shell = jazzvoid.GetVoidOverlay()
		render.MaterialOverride(shell)
		prop:DrawModel()
		render.MaterialOverride()
	end
end
