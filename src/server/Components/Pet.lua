-- Pet Component
-- lpz
-- idk

--// Services & Modules
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local promise = require(ReplicatedStorage.Packages._Index["evaera_promise@4.0.0"].promise)

--// Assets
local assets = ReplicatedStorage.Assets
local actors = assets.Actors

--// Local Functions
local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

local function createPetsFolder(character)
    local folder = Instance.new("Folder")
    folder.Name = "Pets"
    folder.Parent = character

    return folder
end

--// Class
local PetClass = {
    ERRORS = makeEnum("ERRORS", {
        "NoOwner",
        "AlreadyUnequipped",
        "AlreadyEquipped"
    })
}
PetClass.__index = PetClass

function PetClass.new(model: Model, id: string?)
    local self = setmetatable({
        owner = nil,

        equipped = false,
        id = id or HttpService:GenerateGUID(),

        name = model.Name,

        strBoost = model:GetAttribute("Multiplier"),

        model = model,
        currentInstance = nil
    }, PetClass)

    return self
end

function PetClass:SetOwner(owner: Player)
    local character = owner.Character or owner.CharacterAdded:Wait()

    self.owner = owner

    self.character = character
    self.charRootPart = character:WaitForChild("HumanoidRootPart")

    -- pets folder
    self.petsFolder = self.character:FindFirstChild("Pets") or createPetsFolder(character)
end

function PetClass:Equip()
    return promise.new(function(resolve, reject, onCancel)
        if not self.owner then
            reject(PetClass.ERRORS.NoOwner)
        end

        if self.equipped then
            reject(PetClass.ERRORS.AlreadyEquipped)
        end

        if self.currentInstance and self.currentInstance.Parent then
            self.currentInstance:Destroy()
            self.currentInstance = nil

            reject()
        end

        local clonedModel = self.model:Clone()
        clonedModel.Root.CFrame = self.charRootPart.CFrame
        clonedModel.Parent = self.petsFolder

        self.equipped = true
        self.currentInstance = clonedModel

        local bp = Instance.new("BodyPosition")
        bp.D = 500
        bp.Position = self.charRootPart.Position
        bp.MaxForce = Vector3.new(10000000, 10000000, 10000000)
        bp.Parent = clonedModel.Root

        local bg = Instance.new("BodyGyro")
        bg.P = 8000
        bg.MaxTorque = Vector3.new(10000000, 10000000, 10000000)
        bg.Parent = clonedModel.Root

        clonedModel.Root:SetNetworkOwner(self.owner)

        -- gives the pet movementation actor
        local petMovimentation = actors.PetFollowingActor:Clone()
        petMovimentation.PrimaryPart = clonedModel.Root
        petMovimentation.Parent = clonedModel.Root

        -- rearrenges all the positions
        for i,v in self.petsFolder:GetChildren() do
            local root = v.Root
            root:SetAttribute("Index", i)
        end

        CollectionService:AddTag(clonedModel, "NoMapCollision")

        resolve()
    end)
end

function PetClass:Delete()
    return promise.new(function(resolve, reject, onCancel)
        local currentPetModel = self.currentInstance

        if currentPetModel then
            currentPetModel:Destroy()
        end

        self.equipped = false
        self.currentInstance = nil
        self = nil

        resolve()
    end)
end

function PetClass:Unequip()
    return promise.new(function(resolve, reject, onCancel)
        if not self.equipped then
            reject(PetClass.ERRORS.AlreadyUnequipped)
        end

        local currentPetModel = self.currentInstance

        currentPetModel:Destroy()
        self.equipped = false
        self.currentInstance = nil

        resolve()
    end)
end
    
return PetClass