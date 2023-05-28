--[[
    Area Component
    jojoa
]]
local Debris = game:GetService("Debris")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local assetsFolder = ReplicatedStorage.Assets
local templatesFolder = assetsFolder.Templates

--// Const
local EXPONENTIAL_FACTOR = 1.5

local Area = {}
Area.__index = Area

function Area.new(folder: Folder, wallsAmount: number, initialHealth: number, reqLevel: number, trophiesWinAmount: number)
    local self = setmetatable({
        areaFolder = folder,
        wallsAmount = wallsAmount,
        initialHealth = initialHealth,
        reqLevel = reqLevel or 1,
        trophiesWinAmount = trophiesWinAmount,
        playersProgression = {},
    }, Area)

    local wallsFolder = folder:FindFirstChild("Walls")
    local startPoint = folder:FindFirstChild("StartPoint")
    local winPoint = folder:FindFirstChild("Win")
    local hatchingZone = folder:FindFirstChild("HatchingZone")

    if not wallsFolder then
        return warn("WARNING! The Area component had a problem while trying to get the Walls folder of the following area: ", folder.Name)
    end

    if not startPoint then
        return warn("WARNING! The Area component had a problem while trying to get the StartPoint part of the following area: ", folder.Name)
    end

    if not winPoint then
        return warn("WARNING! The Area component had a problem while trying to get the WinPoint part of the following area: ", folder.Name)
    end

    self.wallsFolder = wallsFolder
    self.startPoint = startPoint
    self.winPoint = winPoint
    self.hatchingZone = hatchingZone

    self:UpdateDoor()

    return self
end


function Area:Destroy()
end

function Area:UpdateDoor()
    local player = Knit.player

    -- checks if the area has the req level
    local reqLevelPart = self.areaFolder:FindFirstChild("ReqLevel")

    if not reqLevelPart then return end -- doesnt need to update the door info

    if player:GetAttribute("MaxLevel") >= self.reqLevel then
        reqLevelPart.CanCollide = false
        reqLevelPart.SurfaceGui.Main.TextLabel.Text = self.areaFolder:GetAttribute("ReqTrophies") .. " trophies"
        reqLevelPart.SurfaceGui.Enabled = false
    else
        reqLevelPart.CanCollide = true
        reqLevelPart.SurfaceGui.Main.TextLabel.Text = self.areaFolder:GetAttribute("ReqTrophies") .. " trophies"
        reqLevelPart.SurfaceGui.Enabled = true
    end
end

function Area:LoadWalls()
    local startPointPos: CFrame = self.startPoint.CFrame

    for i,v in self.wallsFolder:GetChildren() do
        local clonedWall: BasePart = v.BreakTemplate:Clone()

        clonedWall.Color = v.BreakTemplate.Color
        clonedWall.Transparency = 0 
        clonedWall.CanCollide = true
        clonedWall.CFrame = v.BreakTemplate.CFrame
        clonedWall.Name = "Display-"..v.BreakTemplate.Name
        clonedWall.Parent = v

        -- local maxHealth = math.round(self.initialHealth * EXPONENTIAL_FACTOR ^ i)

        --clonedWall:SetAttribute("Level", self.reqLevel)
        CollectionService:AddTag(clonedWall, "BreakableWall")
        clonedWall:SetAttribute("Health", v:GetAttribute("Health"))
        clonedWall:SetAttribute("MaxHealth", v:GetAttribute("MaxHealth"))

        self:_updateVisuals(clonedWall, {
            Health = v:GetAttribute("Health"),
            MaxHealth = v:GetAttribute("MaxHealth")
        })

        clonedWall:GetAttributeChangedSignal("Health"):Connect(function()
            if clonedWall:GetAttribute("Health") <= 0 then
                -- the wall has been broken
                clonedWall.Transparency = 1
                clonedWall.CanCollide = false

                clonedWall.SurfaceGui.Enabled = false

                Debris:AddItem(clonedWall, 0.6)

                return
            end

            self:_updateVisuals(clonedWall, {
                Health    = clonedWall:GetAttribute("Health"),
                MaxHealth = clonedWall:GetAttribute("MaxHealth")
            })
        end)
    end
end

function Area:_updateVisuals(wall: BasePart, data)
    local surfaceGUI = wall:WaitForChild("SurfaceGui")
    local mainFrame: Frame? = surfaceGUI:FindFirstChild("Main")

    if not mainFrame then return end

    local health = data.Health
    local maxHealth = data.MaxHealth

    surfaceGUI.Enabled = true
    mainFrame.Bar.Bar.Size = UDim2.fromScale(health/maxHealth, 1)

    mainFrame.TextLabel.Text = `{health}/{maxHealth}`
end

return Area
