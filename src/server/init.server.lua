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

local ServerSettings = require(script.ServerSettings)

local componentsFolder = script:WaitForChild("Components")
local servicesFolder = script.Services

local Assets = ReplicatedStorage.Assets

local globals = {
    settings = ServerSettings,
    components = componentsFolder,
}

for i,v in globals do
    Knit[i] = v
end

Knit.AddServices(servicesFolder)
Knit.Start():andThen(function()
    warn("Knit Started.")
end):catch(function(err)
    warn(err)
end)