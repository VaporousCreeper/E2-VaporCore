E2Lib.RegisterExtension("VaporCore", false, "Useful Functions For Major E2s.")

--[[
	Version: 1.0.5

	+ Added cooldowns to advHintPlayer and playLocalSound

]]

---------------------- Startup ----------------------
MsgC(Color(255,161,0),"[VaporCore] ",Color(255,255,255),"Loading expression2 core.\n")

util.AddNetworkString("VaporCore_Send")

local VaporCore = {}

VaporCore.Cooldowns = {}
VaporCore.Cooldowns.advHintPlayer = {}
VaporCore.Cooldowns.playLocalSound = {}

VaporCore.advHintPlayer_enable = CreateConVar("vaporcore_advHintPlayer_enable","1",FCVAR_ARCHIVE,"Enables/Disables advHintPlayer function")
VaporCore.advHintPlayer_cooldown = CreateConVar("vaporcore_advHintPlayer_cooldown","100",FCVAR_ARCHIVE,"Sets the amount of miliseconds for the function to wait before it can excute again.")

VaporCore.playLocalSound_enable = CreateConVar("vaporcore_playLocalSound_enable","1",FCVAR_ARCHIVE,"Enables/Disables playLocalSound function")
VaporCore.playLocalSound_cooldown = CreateConVar("vaporcore_playLocalSound_cooldown","100",FCVAR_ARCHIVE,"Sets the amount of miliseconds for the function to wait before it can excute again.")

---------------------- Timer Support ----------------------
	local timerid = 0

	local function Execute(self, name, should_end)
		local timerName = "e2_" .. self.data['timer'].timerid .. "_" .. name
		self.data.timer.runner = name
	
		if(self.entity and self.entity.Execute) then
			self.entity:Execute()
		end
		
		if should_end then
			if !self.data['timer'].timers[name] and timer.RepsLeft(timerName) <= 0 then
				timer.Remove(timerName)

				self.data['timer'].timers[name] = nil
				self.data.timer.runner = nil
			end
		end
	end
	
	local function AddTimer(self, name, delay, reps)
		if delay < 10 then delay = 10 end
	
		local timerName = "e2_" .. self.data.timer.timerid .. "_" .. name
	
		if self.data.timer.runner == name and timer.Exists(timerName) then
			timer.Adjust(timerName, delay / 1000, reps, function()
				if reps == 0 then Execute(self, name, false) 
				else Execute(self, name, true) end

			end)
			timer.Start(timerName)
		elseif !self.data['timer'].timers[name] then
			timer.Create(timerName, delay / 1000, reps, function()
				if reps == 0 then Execute(self, name, false) 
				else Execute(self, name, true) end
			end)
		end
	
		self.data['timer'].timers[name] = true
	end

---------------------- Functions ----------------------
	local function advHint(target, from, text, enum, delay)
		if not IsValid(target) or not IsValid(from) then return end
		if VaporCore.Cooldowns.advHintPlayer[from] then return end

		net.Start("VaporCore_Send")
			net.WriteEntity(from)
	
			net.WriteString("advHintPlayer")
			net.WriteString("Player '"..from:Nick().."'("..from:SteamID()..") is hinting to You")
		
			net.WriteString(text)
			net.WriteInt(enum,4)
			net.WriteInt(delay,4)
		net.Send(target)

		VaporCore.Cooldowns.advHintPlayer[from] = true
		timer.Simple(VaporCore.advHintPlayer_cooldown:GetInt()/1000, function()
			VaporCore.Cooldowns.advHintPlayer[from] = false
		end)
	end

	local function playLocal(target, from, path)
		if not IsValid(target) or not IsValid(from) then return end
		if VaporCore.Cooldowns.playLocalSound[from] then return end

		net.Start("VaporCore_Send")
			net.WriteEntity(from)

			net.WriteString("playLocalSound")
			net.WriteString("Player '"..from:Nick().."'("..from:SteamID()..") is playing ui sound to You, Path: "..path)
			
			net.WriteString(path)
		net.Send(target)

		VaporCore.Cooldowns.playLocalSound[from] = true
		timer.Simple(VaporCore.playLocalSound_cooldown:GetInt()/1000, function()
			VaporCore.Cooldowns.playLocalSound[from] = false
		end)
	end

---------------------- Adv hinting functions ----------------------
__e2setcost(2)
e2function number canAdvHint()
	if VaporCore.advHintPlayer_enable:GetInt() <= 0 then return 0 end
	if VaporCore.Cooldowns.advHintPlayer[self.player] then return 0 end

	return 1
end

__e2setcost(5)
e2function void entity:advHintPlayer(string text, number delay, number enum)
	if not IsValid(this) then return end
	if VaporCore.advHintPlayer_enable:GetInt() <= 0 then return end
	advHint(this, self.player, text, enum, delay)
end

__e2setcost(5)
e2function void entity:advHintPlayer(string text, number delay)
	if not IsValid(this) then return end
	if VaporCore.advHintPlayer_enable:GetInt() <= 0 then return end
	advHint(this, self.player, text, 0, delay)
end

__e2setcost(5)
e2function void entity:advHintPlayer(string text)
	if not IsValid(this) then return end
	if VaporCore.advHintPlayer_enable:GetInt() <= 0 then return end
	advHint(this, self.player, text, 0, 3)
end

---------------------- playLocalSound ----------------------
__e2setcost(2)
e2function number canPlayLocalSound()
	if VaporCore.playLocalSound_enable:GetInt() <= 0 then return 0 end
	if VaporCore.Cooldowns.playLocalSound[self.player] then return 0 end

	return 1
end

__e2setcost(50)
e2function void entity:playLocalSound(string path)
  	if not IsValid(this) then return end
  	if VaporCore.playLocalSound_enable:GetInt() <= 0 then return end
	
	playLocal(this, self.player, path)
end

---------------------- nearestEntity ----------------------
__e2setcost(20)
e2function entity vector:nearestEntity(array ents)
	local out = nil
	for i,e in pairs(ents) do
		if not out then out = e end
		if this:Distance(e:GetPos()) < this:Distance(out:GetPos()) then out = e end
	end

	return out
end

---------------------- entitys ----------------------
__e2setcost(10)
e2function array entitys()
	local out = {}

	for i,e in pairs(ents.GetAll()) do
		out[i] = e
	end

	self.prf = self.prf + #out/3
	return out
end

__e2setcost(5)
e2function array entitysByModel(string model)
	local out = {}

	for _,e in ipairs(ents.GetAll()) do
		if e:GetModel() == model then table.insert(out, e) end
	end

	self.prf = self.prf + #out/3
	return out
end

__e2setcost(5)
e2function array entitysByClass(string class)
	local out = {}

	for _,e in ipairs(ents.GetAll()) do
		if e:GetClass() == class then table.insert(out, e) end
	end

	self.prf = self.prf + #out/3
	return out
end

---------------------- Timers ----------------------
__e2setcost(5)
e2function void timer(string name, number delay, number reps)
	AddTimer(self, name, delay, reps)
end

__e2setcost(5)
e2function number timerRepsLeft(string name)
	if self.data['timer'].timers[name] then 
		return timer.RepsLeft("e2_" .. self.data['timer'].timerid .. "_" .. name) + 1
	end

	return -1
end

__e2setcost(5)
e2function number timerExists(string name)
	if self.data['timer'].timers[name] then return 1 end
	return 0
end

MsgC(Color(255,161,0),"[VaporCore] ",Color(255,255,255),"Load
