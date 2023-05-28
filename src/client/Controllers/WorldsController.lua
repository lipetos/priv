--[[
    Worlds Controller
    jojoa
]]

local root = script.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local WorldComponent = require(root.Components.World)

local WorldsController = Knit.CreateController {
    Name = "WorldsController",
    Client = {},
}

function WorldsController:KnitStart()
    self.WorldsService = Knit.GetService("WorldsService")
    self.HatchController = Knit.GetController("HatchController")

    local world1 = WorldComponent.new(workspace.Worlds.World1)

    world1.EnteredHatchingZone:Connect(function(area: Folder)
        local areaData = require(area:FindFirstChild("Data"))

        self.HatchController:Open(areaData.Hatching)
    end)

    world1.LeftHatchingZone:Connect(function(area: Folder)
        self.HatchController:Close()        
    end)

    self.WorldsService.RegenerateAreas:Connect(function(areaName: string)
        world1.areas[areaName]:LoadWalls()
    end)

    Knit.player:GetAttributeChangedSignal("MaxLevel"):Connect(function()
        world1:UpdateAreas()
    end)
end

function WorldsController:KnitInit()

end

return WorldsController
