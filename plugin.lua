PLUGIN = nil

ChestArray = {}
NumChests = 0

function Initialize(Plugin)
	Plugin:SetName("DeathChest")
	Plugin:SetVersion(1.1)

	-- Hooks

	cPluginManager:AddHook(cPluginManager.HOOK_KILLING, MyOnKilled);
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_USED_BLOCK, CleanDeathChests);
	-- Command Bindings

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	-- TODO Save chests to file
	--

end

function MyOnKilled(Victim, TDI, DeathMessage)
        if not Victim:IsPlayer() then
                return false
        end
        newChest = DeathChest:new(Victim:GetPosition(), Victim:GetName(), 0)
        newChest:PlaceChest(Victim)
        NumChests = NumChests+1
        ChestArray[NumChests]=newChest
	
	newChest2 = DeathChest:new(Victim:GetPosition(), Victim:GetName(), 1)
        newChest2:PlaceChest(Victim)
        NumChests = NumChests+1
        ChestArray[NumChests]=newChest2

	if newChest:isPlaced() and newChest2:isPlaced() then
		Victim:GetInventory():Clear()
		return true, "A death chest was created"
	else
		return true, "A death chest was not created"
	end
end

function CleanDeathChests()
	for id=1,NumChests do
		if ChestArray[id]:isClean() then
			ChestArray[id]:destroyChest()
		end
	end
end



DeathChest = {x = 0, y = 0, z = 0, user = "", chestNum = 0, placed = false}

function DeathChest:new(Position, PlayerName, ChestNum)
	o = o or {}
	setmetatable(o, self)
	self.__x = math.floor(Position.x)
	self.__y = math.floor(Position.y)+ChestNum
	self.__z = math.floor(Position.z)
	self.__user = PlayerName
	self.__chestNum = ChestNum
	return self
end

function DeathChest:PlaceChest(Player)
	World=Player:GetWorld()
        World:SetBlock(self.__x+1, self.__y, self.__z, E_BLOCK_CHEST, E_META_CHEST_FACING_XM)
        World:SetBlock(self.__x, self.__y, self.__z, E_BLOCK_WALLSIGN, E_META_CHEST_FACING_XM)

        World:SetSignLines(self.__x, self.__y, self.__z, "~~~~~", "Death Chest", self.__user, "~~~~~")

        World:DoWithChestAt(self.__x+1, self.__y, self.__z, 
                function (ChestEntity)
                        Inventory=Player:GetInventory()
                        for i=1,Min(27,Inventory.invNumSlots-self.__chestNum*27)-1 do
                                Item=Inventory:GetSlot(i+self.__chestNum*27)
                                ChestEntity:SetSlot(i, Item)
                        end
			self.__placed = true
                end
        )
	return true;
end

function DeathChest:isClean()

	return false
end

function DeathChest:isPlaced()
	return self.__placed
end

function DeathChest:destroyChest()
	World:SetBlock(self.__x-1, self.__y, self.__z, E_BLOCK_AIR, 0)
	World:SetBlock(self.__x, self.__y, self.__z, E_BLOCK_AIR, 0)	
end


function Min(x,y) 
	if x>y then
		return y
	end
	return x
end
