--[[
    Collisions Service
    jojoa
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService    = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players           = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CollisionsService = Knit.CreateService {
    Name = "CollisionsService",
    Client = {},
}

function CollisionsService:KnitStart()
    self:DefineToCollGroup(workspace, "Map")

    Players.PlayerAdded:Connect(function(player)
        local char = player.Character or player.CharacterAdded:Wait()

        self:DefineToCollGroup(char, "Characters")

        player.CharacterAdded:Connect(function(newChar)
            self:DefineToCollGroup(char, "Characters")
        end)
    end)

    CollectionService:GetInstanceAddedSignal("NoMapCollision"):Connect(function(inst)
        self:DefineToCollGroup(inst, "NoMapCollision")
    end)

    PhysicsService:CollisionGroupSetCollidable("Characters", "Characters", false);

    PhysicsService:CollisionGroupSetCollidable("NoMapCollision", "Map", false);
    PhysicsService:CollisionGroupSetCollidable("NoMapCollision", "Characters", false);
end

function CollisionsService:KnitInit()
    -- creates the collissions groups
    PhysicsService:RegisterCollisionGroup("Map")
    PhysicsService:RegisterCollisionGroup("Characters")
    PhysicsService:RegisterCollisionGroup("NoMapCollision")

    -- PhysicsService:CollisionGroupSetCollidable(npcGroup, npcGroup, false);
    -- PhysicsService:CollisionGroupSetCollidable(playerGroup, defaultGroup, true);
    -- PhysicsService:CollisionGroupSetCollidable(npcGroup, defaultGroup, true);
end

function CollisionsService:DefineToCollGroup(instance: Instance, groupName: string)
    if instance:IsA("BasePart") and instance.Name ~= "Win" then
        local p: BasePart = instance :: BasePart
        p.CollisionGroup = groupName
    end

    for i,v in instance:GetDescendants() do
        if v:IsA("BasePart") and v.Name ~= "Win" and v.Name ~= "HatchingZone" then
            local p: BasePart = v :: BasePart
            p.CollisionGroup = groupName
        end
    end
end

return CollisionsService
