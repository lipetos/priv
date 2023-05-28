local VRService = game:GetService("VRService")
--[[
    World Component
    jojoa
]]

local Area = require(script.Parent.Area)

local World = {}
World.__index = World

function World.new(worldFolder: Folder)
    local self = setmetatable({
        areas = {},
        worldFolder = worldFolder
    }, World)

    for i,v in worldFolder:GetChildren() do
        local wallsAmount = v:GetAttribute("WallsAmount") or 10
        local initialHealth = v:GetAttribute("InitialHealth") or 100
        local reqLevel = v:GetAttribute("Level") or 1
        local trophiesWinAmount = v:GetAttribute("Trophies") or 1
        local reqTrophies = v:GetAttribute("ReqTrophies")

        local area = Area.new(v, wallsAmount,initialHealth, reqLevel, trophiesWinAmount, reqTrophies) 

        self.areas[v.Name] = area
        area:LoadWalls()
    end

    return self
end


function World:Destroy()

end

return World
