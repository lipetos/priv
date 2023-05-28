--[[
    Area Component
    jojoa
]]
local Debris = game:GetService("Debris")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players           = game:GetService("Players")

local Zone   = require(ReplicatedStorage.Packages.Zone)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@1.5.0"].signal)

local assetsFolder = ReplicatedStorage.Assets
local vfxFolder = assetsFolder.VFX
local templatesFolder = assetsFolder.Templates

--// Const
local EXPONENTIAL_FACTOR = 1.5

local Area = {}
Area.__index = Area

function Area.new(folder: Folder, wallsAmount: number, initialHealth: number, reqLevel: number, trophiesWinAmount: number, reqTrophies: number)
    local self = setmetatable({
        areaFolder = folder,
        wallsAmount = wallsAmount,
        initialHealth = initialHealth,
        reqLevel = reqLevel or 1,
        trophiesWinAmount = trophiesWinAmount,
        playersProgression = {},
        debounces = {},
        reqTrophies = reqTrophies,

        -- events
        Won = Signal.new()
    }, Area)

    local wallsFolder = folder:FindFirstChild("Walls")
    local startPoint = folder:FindFirstChild("StartPoint")
    local winPoint = folder:FindFirstChild("Win")

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

    local zonePart = Zone.new(self.winPoint)

    zonePart.playerEntered:Connect(function(player: Player)
        if player:GetAttribute("MaxLevel") < self.reqLevel then return end
        -- player is not in that area yet

        local character = player.Character
        local rootPart: BasePart = character:WaitForChild("HumanoidRootPart")

        local trophy = vfxFolder.Trophy.Attachment:Clone()

        trophy.Parent = rootPart

        for i,v in trophy:GetChildren() do
            v:Emit(v:GetAttribute("EmitCount"))
        end

        Debris:AddItem(trophy, 1)

        rootPart.CFrame = self.startPoint.CFrame * CFrame.new(0, 0, -5)
        player:SetAttribute("Trophies", player:GetAttribute("Trophies") + self.trophiesWinAmount)

        self.Won:Fire(player)
    end)

    return self
end


function Area:Destroy()
    
end

function Area:LoadWalls()
    local startPointPos: CFrame = self.startPoint.CFrame

    for i = 1, self.wallsAmount do
        local clonedWall: Model = templatesFolder.BreakTemplate:Clone()

        clonedWall.BreakTemplate.Color = Color3.fromRGB(
            math.random(0, 255),
            math.random(0, 255),
            math.random(0, 255)
        )
        clonedWall.BreakTemplate.Transparency = 1
        clonedWall.BreakTemplate.SurfaceGui.Enabled = false
        clonedWall.BreakTemplate.CanCollide = false
        clonedWall.BreakTemplate.CanTouch = false
        clonedWall.BreakTemplate.CanQuery = false
        clonedWall.BreakTemplate.CFrame = startPointPos * CFrame.new(0, 0, i*clonedWall.BreakTemplate.Size.Z)
        clonedWall.Name = i
        clonedWall.Parent = self.wallsFolder

        CollectionService:AddTag(clonedWall, "BreakableWall")

        local maxHealth = math.round(self.initialHealth * EXPONENTIAL_FACTOR ^ i)

        clonedWall:SetAttribute("Level", self.reqLevel)
        clonedWall:SetAttribute("Health", maxHealth)
        clonedWall:SetAttribute("MaxHealth", maxHealth)

        -- self:_updateVisuals(clonedWall.BreakTemplate)

        -- clonedWall:GetAttributeChangedSignal("Health"):Connect(function()
        --     if clonedWall:GetAttribute("Health") <= 0 then
        --         return clonedWall:Destroy()
        --     end

        --     self:_updateVisuals(clonedWall.BreakTemplate)
        -- end)
    end
end

function Area:_updateVisuals(wall: BasePart)
    local surfaceGUI = wall:WaitForChild("SurfaceGui")
    local mainFrame: Frame? = surfaceGUI:FindFirstChild("Main")

    if not mainFrame then return end

    local health = wall.Parent:GetAttribute("Health")
    local maxHealth = wall.Parent:GetAttribute("MaxHealth")

    mainFrame.Bar.Bar.Size = UDim2.fromScale(health/maxHealth, 1)

    mainFrame.TextLabel.Text = `{health}/{maxHealth}`
end

return Area
