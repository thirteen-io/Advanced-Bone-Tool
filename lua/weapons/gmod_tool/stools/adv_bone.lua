TOOL.Name = "Advanced Bone Tool"
TOOL.Category = "Poser"

if CLIENT then
	language.Add( "tool.adv_bone.name", TOOL.Name )
	language.Add( "tool.adv_bone.desc", "By Th13teen" )
	language.Add( "tool.adv_bone.0", "Click to select object, C to edit bones." )

	language.Add( "tool.adv_bone.bone", "Bone" )

	language.Add( "tool.adv_bone.editangles", "Edit Angles" )
	language.Add( "tool.adv_bone.pitch", "Pitch" )
	language.Add( "tool.adv_bone.Yaw", "Yaw" )
	language.Add( "tool.adv_bone.roll", "Roll" )

	language.Add( "tool.adv_bone.editposition", "Edit Position" )
	language.Add( "tool.adv_bone.editscale", "Edit Scale" )
	language.Add( "tool.adv_bone.x", "X" )
	language.Add( "tool.adv_bone.y", "Y" )
	language.Add( "tool.adv_bone.z", "Z" )

	language.Add( "tool.adv_bone.help", "Thank you for downloading this tool! <3 Th13teen" )

	function UpdateAdvBoneMenu( ent, bone )
		if ( IsValid( ent ) ) then
			print( "Updating list" )

			local panel = controlpanel.Get( "adv_bone" )

			local ang = ent:GetManipulateBoneAngles( bone ) or Angle( 0, 0, 0 )
			local pos = ent:GetManipulateBonePosition( bone ) or Vector( 0, 0, 0 )
			local scale = ent:GetManipulateBoneScale( bone ) or Vector( 1, 1, 1 )

			panel.ent = ent

			panel.combo_bonelist:Clear()
			for i = 0, ent:GetBoneCount() - 1 do
				local name = ent:GetBoneName( i )
				if ( name != "__INVALIDBONE__" ) then
					panel.combo_bonelist:AddChoice( name )
				end
			end

			local name = ent:GetBoneName( bone )
			if ( name == "__INVALIDBONE__" ) then name = "static_prop" end
			panel.combo_bonelist:SetValue( name )

			panel.slider_ang_pitch:SetValue( ang.p )
			panel.slider_ang_yaw:SetValue( ang.y )
			panel.slider_ang_roll:SetValue( ang.r )

			panel.slider_pos_x:SetValue( pos.x )
			panel.slider_pos_y:SetValue( pos.y )
			panel.slider_pos_z:SetValue( pos.z )

			panel.slider_scale_x:SetValue( scale.x )
			panel.slider_scale_y:SetValue( scale.y )
			panel.slider_scale_z:SetValue( scale.z )
		end
	end

	net.Receive( "UpdateAdvBoneMenu", function()
		local ent = net.ReadEntity()
		local bone = net.ReadFloat()
		UpdateAdvBoneMenu( ent, bone )
	end )
else
	util.AddNetworkString( "UpdateAdvBoneMenu" )
	util.AddNetworkString( "UpdateAdvBoneSettings" )
	net.Receive( "UpdateAdvBoneSettings", function()
		local data = net.ReadTable()
		local ent = data.ent
		if ( !IsValid( ent ) ) then return end
		local bone = 0
		for i = 0, ent:GetBoneCount() - 1 do
			local name = ent:GetBoneName( i )
			if ( name == data.bone ) then
				bone = i
			end
		end
		ent:ManipulateBoneAngles( bone, data.ang )
		ent:ManipulateBonePosition( bone, data.pos )
		ent:ManipulateBoneScale( bone, data.scale )
	end )
end

function TOOL:LeftClick( tr )
	-- Find entity that player is looking at
	if CLIENT then return true end
	if ( IsValid( tr.Entity ) ) then
		self.Entity = tr.Entity
		local physbone = tr.PhysicsBone
		self.Bone = self.Entity:TranslatePhysBoneToBone( physbone ) or 0
		self:GetOwner():SetNWEntity( "AdvBoneEntity", self.Entity )
		net.Start( "UpdateAdvBoneMenu" )
			net.WriteEntity( self.Entity )
			net.WriteFloat( self.Bone )
		net.Send( self:GetOwner() )
	end
	return true
end

function TOOL:RightClick( tr )
		-- Get Player
		self.Entity = self:GetOwner()
		local physbone = tr.PhysicsBone
		self.Bone = self.Entity:TranslatePhysBoneToBone( physbone ) or 0
		self:GetOwner():SetNWEntity( "AdvBoneEntity", self.Entity )
		net.Start( "UpdateAdvBoneMenu" )
			net.WriteEntity( self.Entity )
			net.WriteFloat( self.Bone )
		net.Send( self:GetOwner() )
end

function TOOL:BuildCPanel()

	local function UpdateBone()

		local panel = controlpanel.Get( "adv_bone" )
		local data = { ent = panel.ent,
					bone = panel.combo_bonelist:GetValue(),
					ang = Angle( panel.slider_ang_pitch:GetValue(), panel.slider_ang_yaw:GetValue(), panel.slider_ang_roll:GetValue() ),
					pos = Vector( panel.slider_pos_x:GetValue(), panel.slider_pos_y:GetValue(), panel.slider_pos_z:GetValue() ),
					scale = Vector( panel.slider_scale_x:GetValue(), panel.slider_scale_y:GetValue(), panel.slider_scale_z:GetValue() ) }

		net.Start( "UpdateAdvBoneSettings" )
			net.WriteTable( data )
		net.SendToServer()
	end

	self.combo_bonelist = self:AddControl( "ComboBox", { Label = "#tool.adv_bone.bone" } )
	self.combo_bonelist:SetValue( "" )
	self.combo_bonelist.ChooseOption = function( pnl, val )
		pnl:SetValue( val )
		local bone = 0
		local ent = LocalPlayer():GetNWEntity( "AdvBoneEntity" )
		for i = 0, ent:GetBoneCount() - 1 do
			local name = ent:GetBoneName( i )
			if ( name == val ) then
				bone = i
			end
		end
		UpdateAdvBoneMenu( ent, bone )
	end

	--Angles
	self:AddControl( "Header", { Description = "#tool.adv_bone.editangles" } )

	self.slider_ang_pitch = self:AddControl( "Slider", { Label = "#tool.adv_bone.pitch", Type = "Float", Min = -180, Max = 180 } )
	self.slider_ang_pitch:SetValue( 0 )
	self.slider_ang_pitch.OnValueChanged = function() UpdateBone() end

	self.slider_ang_yaw = self:AddControl( "Slider", { Label = "#tool.adv_bone.yaw", Type = "Float", Min = -180, Max = 180 } )
	self.slider_ang_yaw:SetValue( 0 )
	self.slider_ang_yaw.OnValueChanged = function() UpdateBone() end

	self.slider_ang_roll = self:AddControl( "Slider", { Label = "#tool.adv_bone.roll", Type = "Float", Min = -180, Max = 180 } )
	self.slider_ang_roll:SetValue( 0 )
	self.slider_ang_roll.OnValueChanged = function() UpdateBone() end

	--Position
	self:AddControl( "Header", { Description = "#tool.adv_bone.editposition" } )

	self.slider_pos_x = self:AddControl( "Slider", { Label = "#tool.adv_bone.x", Type = "Float", Min = -128, Max = 128 } )
	self.slider_pos_x:SetValue( 0 )
	self.slider_pos_x.OnValueChanged = function() UpdateBone() end

	self.slider_pos_y = self:AddControl( "Slider", { Label = "#tool.adv_bone.y", Type = "Float", Min = -128, Max = 128 } )
	self.slider_pos_y:SetValue( 0 )
	self.slider_pos_y.OnValueChanged = function() UpdateBone() end

	self.slider_pos_z = self:AddControl( "Slider", { Label = "#tool.adv_bone.z", Type = "Float", Min = -128, Max = 128 } )
	self.slider_pos_z:SetValue( 0 )
	self.slider_pos_z.OnValueChanged = function() UpdateBone() end

	--Scale
	self:AddControl( "Header", { Description = "#tool.adv_bone.editscale" } )

	self.slider_scale_x = self:AddControl( "Slider", { Label = "#tool.adv_bone.x", Type = "Float", Min = -20, Max = 20 } )
	self.slider_scale_x:SetValue( 0 )
	self.slider_scale_x.OnValueChanged = function() UpdateBone() end

	self.slider_scale_y = self:AddControl( "Slider", { Label = "#tool.adv_bone.y", Type = "Float", Min = -20, Max = 20 } )
	self.slider_scale_y:SetValue( 0 )
	self.slider_scale_y.OnValueChanged = function() UpdateBone() end

	self.slider_scale_z = self:AddControl( "Slider", { Label = "#tool.adv_bone.z", Type = "Float", Min = -20, Max = 20 } )
	self.slider_scale_z:SetValue( 0 )
	self.slider_scale_z.OnValueChanged = function() UpdateBone() end

	self.button_reset = self:AddControl( "Button", {} )
	self.button_reset:SetText( "Reset" )
	self.button_reset.DoClick = function()
		local panel = controlpanel.Get( "adv_bone" )

		panel.slider_ang_pitch:SetValue( 0 )
		panel.slider_ang_yaw:SetValue( 0 )
		panel.slider_ang_roll:SetValue( 0 )

		panel.slider_pos_x:SetValue( 0 )
		panel.slider_pos_y:SetValue( 0 )
		panel.slider_pos_z:SetValue( 0 )

		panel.slider_scale_x:SetValue( 1 )
		panel.slider_scale_y:SetValue( 1 )
		panel.slider_scale_z:SetValue( 1 )
	end
end
