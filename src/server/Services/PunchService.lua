--[[
    Player Service
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(ReplicatedStorage.Packages.Knit)

--// Consts
local ANTI_CHEAT_DISTANCE_THRESHOLD = 30

local PunchService = Knit.CreateService {
    Name = "PunchService",
    Client = {},
}

function PunchService:KnitStart()
    self.DataService = Knit.GetService("DataService")
    self.PetsService = Knit.GetService("PetService")
end

function PunchService:KnitInit()
    self.validTags = {"PunchBag", "BreakableWall"}
    self.cooldowns = {}
end

function PunchService:CheckForValidTags(obj: Instance): boolean
    for i,v in self.validTags do
        if CollectionService:HasTag(obj, v) then return true end
    end

    return false
end


--===================
-- Client Functions
--===================
function PunchService.Client:RequestPunch(player: Player, hitboxData)
    if not self.Server.cooldowns[player] then
        self.Server.cooldowns[player] = 0
    end

    -- checks if player is in cooldown
    if os.time() - self.Server.cooldowns[player] < 1 then
        return
    end

    -- do some sanity checks, just to make sure no exploiter will try todo some weird stuff
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart: BasePart = character:WaitForChild("HumanoidRootPart")

    local object = hitboxData.Object
    local hittedPart = hitboxData.HittedPart

    -- just one last check if the object is a valid punchable object
    if not self.Server:CheckForValidTags(object) then return end
    if not hittedPart then return end
    if not hittedPart:IsA("BasePart") then
        return warn("WARNING! the hitbox has been fired but the hittedPart variable is not a valid BasePart")
    end

    -- 1# janity check, checks for the distance between the player and the targeted object
    local distance = (hittedPart.Position - rootPart.Position).Magnitude

    if distance > ANTI_CHEAT_DISTANCE_THRESHOLD then
        return -- sends a exploit warning L4
    end

    -- 2# checks if the max player level is the current the one hes trying to punch the PunchableObject
    local playerMaxLevel = player:GetAttribute("MaxLevel")
    local punchableObjectLevel = object:GetAttribute("Level")

    if playerMaxLevel < punchableObjectLevel then
        return -- sends a exploit/bug warning L4
    end

    self.Server.cooldowns[player] = os.time()

    -- calculates the boost multiplier
    local petsBoostMult = math.round(self.Server.PetsService:CalculateBoosts(player))

    -- handles the callback of the punch
    if CollectionService:HasTag(object, "PunchBag") then
        player:SetAttribute("Strength", player:GetAttribute("Strength") + punchableObjectLevel * petsBoostMult)
    elseif CollectionService:HasTag(object, "VIPPunchBag") then
        player:SetAttribute("Strength", player:GetAttribute("Strength") + (punchableObjectLevel*2) * petsBoostMult)
    end
end

return PunchService
