-- Pets Service
-- idk

local root = script.Parent.Parent

--// Services & Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Enums = require(ReplicatedStorage.Common.Enums)
local PetClass = require(root.Components.Pet)

local SELECT_MODES = Enums.SELECT_MODES

--// Assets
local AssetsFolder = ReplicatedStorage.Assets
local PetsFolder = AssetsFolder.Pets

--// Local Functions
local function getEquippedPetsAmount(inventory)
    local l = 0
    for i,v in inventory do
        if v.equipped then
            l += 1
        end
    end
    return l
end

local function getPetsAmount(inventory)
    local l = 0

    for i,v in inventory do
        l += 1
    end

    return l
end

--// Service
local PetService = Knit.CreateService({
    Name = "PetService",
    Client = {
        Equipped   = Knit.CreateSignal(),
        Unequipped = Knit.CreateSignal(),
        Added      = Knit.CreateSignal(),
        Deleted    = Knit.CreateSignal(),
        InventoryLoaded = Knit.CreateSignal()
    }
})

--// Functions
function PetService:KnitInit()

end

function PetService:KnitStart()
    self.DataService = Knit.GetService("DataService")
    self.petsCache = {}
end

-- @Player: Player
-- gets the whole player inventory
function PetService:GetPetsInventory(player: Player)
    return self.petsCache[player]
end

-- @Player: Player
-- calculates the boosts that the pets are giving
function PetService:CalculateBoosts(player: Player)
    local inv = self:GetPetsInventory(player)
    local strBoost = 1

    for i,v in inv do
        local boost = v.strBoost
        if boost and v.equipped then
            strBoost += boost
        end
    end

    return strBoost
end

-- @Pet: string
-- gets the pet model
function PetService:_GetPetModel(Pet: string)
    local pet_model = PetsFolder:FindFirstChild(Pet, true)

    if not pet_model then
        return warn([[[PetsService]:
                        --> The PetModel doesnt exists
        ]])
    end

    return pet_model
end

function PetService:LoadInventory(player: Player)
    local dynamicDataProf = self.DataService:GetDataProfile(player, "Dynamic")
    local data = dynamicDataProf.Data

    -- creates the player pets cache
    self.petsCache[player] = {}

    -- loads the pets
    for i,v in data.Pets do
        local pet = PetClass.new(self:_GetPetModel(v.ModelName), i)
        pet:SetOwner(player)

        if v.Equipped then
            pet:Equip()
        end

        self.petsCache[player][i] = pet
    end

    player:SetAttribute("EquippedPetsAmount", getEquippedPetsAmount(self.petsCache[player]))
    player:SetAttribute("PetsAmount", getPetsAmount(self.petsCache[player]))

    PetService.Client.InventoryLoaded:Fire(player, data.Pets)
end

function PetService:SaveInventory(player: Player)
    local dynamicDataProf = self.DataService:GetDataProfile(player, "Dynamic")
    local data = dynamicDataProf.Data

    local newPetsData = {}

    for i,v in self.petsCache[player] do
        newPetsData[i] = {
            ModelName = v.name,
            Equipped  = v.equipped,
            Id        = i,
        }
    end

    data.Pets = newPetsData
end

function PetService:FindFirstPetCached(player: Player, pet: string)
    for i,v in self.petsCache[player] do
        if v.name == pet then
            return v
        end
    end
end

function PetService:AddPet(player: Player, petName: string)
    local petModel = self:_GetPetModel(petName)
    local pet = PetClass.new(petModel)

    pet:SetOwner(player)
    PetService.Client.Added:Fire(player, {
        id = pet.id,
        name = petName
    })

    player:SetAttribute("PetsAmount", getPetsAmount(self.petsCache[player]))

    self.petsCache[player][pet.id] = pet
end

function PetService:EquipPet(player: Player, UUID: string)
    local pet = self.petsCache[player][UUID]

    if not pet then return end

    pet:Equip():andThen(function()
        player:SetAttribute("EquippedPetsAmount", getEquippedPetsAmount(self.petsCache[player]))

        PetService.Client.Equipped:Fire(player, UUID)
    end)
end

function PetService:UnequipPet(player: Player, UUID: string)
    local pet = self.petsCache[player][UUID]

    if not pet then return end

    pet:Unequip():andThen(function()
        player:SetAttribute("EquippedPetsAmount", getEquippedPetsAmount(self.petsCache[player]))

        PetService.Client.Unequipped:Fire(player, UUID)
    end)
end

function PetService:DeletePet(player: Player, UUID: string)
    local pet = self.petsCache[player][UUID]

    if not pet then return end

    pet:Delete():andThen(function()
        player:SetAttribute("EquippedPetsAmount", getEquippedPetsAmount(self.petsCache[player]))

        self.petsCache[player][UUID] = nil
        PetService.Client.Deleted:Fire(player, UUID)
    end)
end

function PetService:UnequipAllPets(player: Player)
    for i,v in self.petsCache[player] do
        if not v.equipped then continue end

        self:UnequipPet(player, i)
    end
end

function PetService:EquipBest(player: Player)
    local inventory = self.petsCache[player]
    local parsedPets = {}

    -- make this more efficient
    -- local function test_case(normalList)
    --     local commonList = {}
    --     for i,v in normalList do
    --         table.insert(commonList, v)
    --     end

    --     table.sort(commonList, function(a,b)
    --         return a>b		
    --     end)

    --     local top = {}
    --     for i,v in normalList do
    --         for k, j in commonList do
    --             if v == j then
    --                 top[k] = v
    --             end
    --         end
    --     end

    --     return top
    -- end

    -- local topPets = test_case(inventory)

    -- for i = 1, player:GetAttribute("MaxEquippedPets") do
    --     if not topPets[i] then continue end

    --     topPets[i]:Equip()
    -- end
end

function PetService.Client:EquipPet(player: Player, UUID: string)
    self.Server:EquipPet(player, UUID)
end

function PetService.Client:ConfirmAction(player: Player, uuids, action)
    if action == SELECT_MODES.Delete then
        for i,v in uuids do
            self.Server:DeletePet(player, v)
        end
    end
end

function PetService.Client:EquipBest(player: Player)
    self.Server:EquipBest(player)
end

function PetService.Client:UnequipPet(player: Player, UUID: string)
    self.Server:UnequipPet(player, UUID)
end

function PetService.Client:UnequipAll(player: Player)
    self.Server:UnequipAllPets(player)
end

return PetService