--[[
    Gameplay Controller
    jojoa

    docs: cooming soon
]]

local root = script.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PunchComponent = require(root.Components.Gameplay.Punch)

local GameplayController = Knit.CreateController { Name = "GameplayController" }

function GameplayController:KnitStart()
    self.Punch = PunchComponent.new(Knit.character)

    ContextActionService:BindAction("Punch", function(actionName, inputState, _inputObject)
        if inputState == Enum.UserInputState.Begin then
            self.Punch:Punch()
        end
    end, true, Enum.UserInputType.MouseButton1)
end

function GameplayController:KnitInit()
    
end


return GameplayController
