--[[
    Worlds Service
    jojoa
]]

local root = script.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local WorldComponent = require(root.Components.World)

local WorldsService = Knit.CreateService {
    Name = "WorldsService",
    Client = {
        RegenerateAreas = Knit.CreateSignal()
    },
}


function WorldsService:KnitStart()
    self.worlds = {
        world1 = WorldComponent.new(workspace.Worlds.World1)
    }

    for i,v in self.worlds.world1.areas do
        v.Won:Connect(function(player: Player)
            self.Client.RegenerateAreas:Fire(player, i)
        end)
    end
end

function WorldsService:KnitInit()

end

function WorldsService:GetAvaibleAreas(player: Player)
    local world: string, level: number = player:GetAttribute("World"), player:GetAttribute("MaxLevel")

    for i,v in self.worlds[world].areas do
        if level >= v.reqLevel then

        end
    end
end

function WorldsService:GetNextAreaTrophiesAmount(player: Player)
    local world: string, level: number = player:GetAttribute("World"), player:GetAttribute("MaxLevel")

    local currentArea
    for i,v in self.worlds[world].areas do
        if v.reqLevel == level+1 then
            return v.reqTrophies
        end
    end
end

return WorldsService
