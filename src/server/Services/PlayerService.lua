--[[
    Player Service
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService {
    Name = "PlayerService",
    Client = {},
}

function PlayerService:KnitStart()
    self.DataService = Knit.GetService("DataService")
    self.WorldsService = Knit.GetService("WorldsService")
    self.PetService = Knit.GetService("PetService")
end

function PlayerService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        player:SetAttribute("DataLoaded", false)
        self.DataService:WaitForData(player)
        player:SetAttribute("DataLoaded", true)

        -- loads the pets
        self.PetService:LoadInventory(player)

        player:GetAttributeChangedSignal("Trophies"):Connect(function()
            local currentLevel = player:GetAttribute("MaxLevel")
            local currentTrophies = player:GetAttribute("Trophies")

            local nextLevelTrophies = self.WorldsService:GetNextAreaTrophiesAmount(player)

            if not nextLevelTrophies then
                -- theres not a next level
                return
            end

            if currentTrophies >= nextLevelTrophies then
                player:SetAttribute("MaxLevel", player:GetAttribute("MaxLevel") + 1)
            end
        end)
    end)
end

return PlayerService
