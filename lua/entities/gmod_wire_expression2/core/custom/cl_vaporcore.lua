E2Helper.Descriptions["canAdvHint"] = "Returns 1 if advHintPlayer if the function is enabled and the cooldown has ended, otherwise 0"
E2Helper.Descriptions["advHintPlayer"] = "Hints a player with the 'text' and with the icon enum (https://wiki.facepunch.com/gmod/Enums/NOTIFY use Decimal) and it prints on the console player's who it was from, Defs: enum - 0 and delay - 3 seconds"

E2Helper.Descriptions["canPlayLocalSound"] = "Returns 1 if playLocalSound if the function is enabled and the cooldown has ended, otherwise 0"
E2Helper.Descriptions["playLocalSound"] = "Plays a ui sound that your target can only hear."

E2Helper.Descriptions["nearestEntity"] = "Returns the nearest entity from origin pos in the array"

E2Helper.Descriptions["entities"] = "Returns an array of all existing entities in the world"
E2Helper.Descriptions["entitiesByModel"] = "Returns all entities with the model"
E2Helper.Descriptions["entitiesByClass"] = "Returns all entities with the class"

E2Helper.Descriptions["timer"] = "Starts a timer with X amount of repetitions, 0 for infinite"
E2Helper.Descriptions["timerRepsLeft"] = "Returns the amount of repetitions left of a timer, 0 for infinite and -1 for not existing"
E2Helper.Descriptions["timerExists"] = "Checks for a timer's existence"


net.Receive("VaporCore_Send",function(len)
  local Ply = net.ReadEntity()
  local Type = net.ReadString()

  if Ply != LocalPlayer() then MsgC(Color(255,161,0),"[VaporCore] ",Color(255,255,255),net.ReadString().."\n") else net.ReadString() end
  
  if Type == "advHintPlayer" then
      notification.AddLegacy( net.ReadString(), net.ReadInt(4), net.ReadInt(4))
  elseif Type == "playLocalSound" then
      surface.PlaySound( net.ReadString() )
  end
end)
