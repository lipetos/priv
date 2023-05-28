local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
    World Component
    jojoa
]]

local Area = require(script.Parent.Area)
local Zone = require(ReplicatedStorage.Packages.Zone)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@1.5.0"].signal)

local World = {}
World.__index = World

function World.new(worldFolder: Folder)
    local self = setmetatable({
        areas = {},
        worldFolder = worldFolder,

        EnteredHatchingZone = Signal.new(),
        LeftHatchingZone    = Signal.new(),
    }, World)

    for i,v in worldFolder:GetChildren() do
        local wallsAmount = v:GetAttribute("WallsAmount") or 10
        local initialHealth = v:GetAttribute("InitialHealth") or 100
        local reqLevel = v:GetAttribute("Level") or 1
        local trophiesWinAmount = v:GetAttribute("Trophies") or 1

        local area = Area.new(v, wallsAmount,initialHealth, reqLevel, trophiesWinAmount)
        local hatchingZone = Zone.new(area.hatchingZone)

        hatchingZone.localPlayerEntered:Connect(function()
            self.EnteredHatchingZone:Fire(v)
        end)

        hatchingZone.localPlayerExited:Connect(function()
            self.LeftHatchingZone:Fire(v)
        end)

        self.areas[v.Name] = area
        area:LoadWalls()
    end

    self:UpdateAreas()

    return self
end

function World:UpdateAreas()
    for i,v in self.areas do
        v:UpdateDoor()
    end
end

function World:Destroy()

end

return World
