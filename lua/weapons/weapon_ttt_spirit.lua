AddCSLuaFile()

if SERVER then
	resource.AddWorkshop( "925075129" )
	
	util.AddNetworkString("ttt_spirit_register_thrower")
	util.AddNetworkString("ttt_spirit_update_team")
end

SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "Spirit"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Attacks nearby enemies.\nDoes more damage when further away."
   };

   SWEP.Icon = "vgui/ttt/icon_Spirit"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props_c17/suitcase_passenger_physics.mdl"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "9mmRound"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment


SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_CUBE

SWEP.AllowDrop = true

SWEP.NoSights = true

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then
	return end
	
	 self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	 
	 self:CreateSpirit()
	 self:TakePrimaryAmmo ( 1 )
	 if SERVER then
		self:Remove()
	 end
	 
end

function SWEP:DrawWorldModel()

return false
end

SWEP.ENT = nil


function SWEP:CreateSpirit()
	if SERVER then
		local ply = self.Owner
		local spirit = ents.Create("ttt_spirit_proj")
			if IsValid(spirit) and IsValid(ply) then
				local vsrc = ply:GetShootPos()
				local vang = ply:GetAimVector()
				local vvel = ply:GetVelocity()
				local vthrow = vvel + vang * 100
				spirit:SetPos(vsrc + vang * 10)
				spirit:Spawn()
				spirit:SetThrower(ply)
				
				spirit:SetNWEntity("spirit_owner", ply)
				
				if TTT2 then
				local team = TEAMS[ply:GetTeam()]

				spirit.userdata = {
					team = ply:GetTeam()
				}
				timer.Simple( 0.1, function()
					net.Start("ttt_spirit_register_thrower")
					net.WriteEntity(spirit)
					net.WriteString(ply:GetTeam())
					net.Broadcast()
				end)
			end
				
				local phys = spirit:GetPhysicsObject()
				
					if IsValid(phys) then
						phys:SetVelocity(vthrow)
						phys:SetMass(200)
					end 
					self.ENT = spirit
				
			end
		
	end
end


function SWEP:SecondaryAttack()

  if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay)
		if not IsFirstTimePredicted() then return end
	
end


function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

function SWEP:OnDrop()
	self:Remove()
end

if TTT2 then
	if SERVER then
		hook.Add("TTT2UpdateTeam", "tt2_spirit_team", function(ply, old, new)
			net.Start("ttt_spirit_update_team")
			net.WriteString(new)
			net.Send(ply)
		end)
	end
end