PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("DeathChest")
	Plugin:SetVersion(1)

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that
	cPluginManager:AddHook(cPluginManager.HOOK_KILLING, MyOnKilled);
	--cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_USED_BLOCK, CleanDeathChests);
	-- Command Bindings

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end


function MyOnKilled(Victim, TDI, DeathMessage)
 	if not Victim:IsPlayer() then
		return false
	end
	
	World=Victim:GetWorld()
	Position=Victim:GetPosition()
 	World:SetBlock(Position.x-1, Position.y, Position.z, 54, 4)
	World:SetBlock(Position.x-1, Position.y, Position.z+1, 54, 4)
	--World:SetBlock(Position.x, Position.y, Position.z, 68, 2)
	--World:SetBlock(Position.x, Position.y, Position.z+1, 68, 2)

	--World:SetSignLines(Position.x, Position.y, Position.z, "Death Chest", Victim:GetName(), "", "")
	--World:SetSignLines(Position.x, Position.y, Position.z+1, "Death Chest", Victim:GetName(), "", "")

	EmptyItem = new cItem();
	World:DoWithChestAt(Position.x-1, Position.y, Position.z, 
		function (ChestEntity)
			Inventory=Victim:GetInventory()
			for i=1,Min(27,Inventory.invNumSlots)-1 do
				Item=Inventory:GetSlot(i)
				ChestEntity:SetSlot(i, Item)
			end


		        World:DoWithChestAt(Position.x-1, Position.y, Position.z+1,
                		function (ChestEntity)
                        		Inventory=Victim:GetInventory()
                        		for i=1,Min(27,Inventory.invNumSlots-27)-1 do
                                		Item=Inventory:GetSlot(i+27)
                                		ChestEntity:SetSlot(i, Item)
	
                        		end
				Inventory:Clear()
                		end
        		)
		end
	)

        return true, "A death chest might have been created"
end

function Min(x,y) 
	if x>y then
		return y
	end
	return x
end
