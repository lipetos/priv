--[[
    This is a game framework made for anime Combat Games

    Main Entry Point
]]

local root = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Input = require(ReplicatedStorage.Packages.Input)
local Knit  = require(ReplicatedStorage.Packages.Knit)
local Animations = require(ReplicatedStorage.Packages.Animations)

local ClientSettings = require(script.ClientSettings)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local componentsFolder = script:WaitForChild("Components")
local controllersFolder = script.Controllers

local Assets = ReplicatedStorage.Assets
local AnimationsFolder = Assets.Animations

-- waits for player data to load
while not player:GetAttribute("DataLoaded") do task.wait() end

local globals = {
    player = player,
    character = character,

    settings = ClientSettings,
    components = componentsFolder,

    animations = Animations.new(character:WaitForChild("Humanoid"), AnimationsFolder:GetDescendants())    
}

for i,v in globals do
    Knit[i] = v
end

-- Setups some globals
-- Updates those globals when player resets
player.CharacterAdded:Connect(function(character)
    Knit.character = character
end)

Knit.AddControllers(controllersFolder)
Knit.Start():andThen(function()
    warn("Knit Started.")
end):catch(function(err)
    warn(err)
end)