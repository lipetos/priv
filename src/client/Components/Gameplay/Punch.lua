--[[
    This component handles the punching mechanics
    jojoa

    docs: cooming soon
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris            = game:GetService("Debris")
local TweenService      = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

--// Assets
local assetsFolder = ReplicatedStorage.Assets
local vfxFolder = assetsFolder.VFX

--// Types
export type IHitboxData = {
    HittedPart: BasePart,
    Object: Model | BasePart
}

--// Consts
local HITBOX_DISTANCE = -1
local HITBOX_SIZE     = Vector3.new(2, 4, 3)

local Punch = {}
Punch.__index = Punch

function Punch.new(character)
    local self = setmetatable({
        character = character,
        validTags = {"PunchBag", "BreakableWall", "VIPPunchBag"},

        PunchService = Knit.GetService("PunchService"),
    }, Punch)

    self.validPunchableObjects = self:ParseValidPunchableObjects()

    return self
end

function Punch:Punch()
    -- creates the punch hitbox
    local hitbox: IHitboxData? = self:CreateHitbox(true)

    if not hitbox then return end

    local object: Model | BasePart = hitbox.Object
    local hittedPart: BasePart = hitbox.HittedPart

    -- TweenService:Create(hittedPart, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, true), {
    --     Orientation = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
    -- }):Play()

    self:PunchVFX(hittedPart)

    task.spawn(function()
        local highlight = object:FindFirstChild("Highlight") or Instance.new("Highlight")
        highlight.FillTransparency = 0
        highlight.FillColor = Color3.fromRGB(255, 255, 255)

        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
        highlight.Parent = object

        task.wait(0.05)

        -- for i = 1, 4 do
        --     if i % 2 == 0 then
        --         highlight.Enabled = true
        --     else
        --         highlight.Enabled = false
        --     end

        --     task.wait(math.random(2,5)/100)
        -- end

        highlight.Enabled = false
    end)

    if CollectionService:HasTag(hittedPart, "BreakableWall") then
        hittedPart:SetAttribute("Health", hittedPart:GetAttribute("Health") - Knit.player:GetAttribute("Strength"))
    end

    self.PunchService:RequestPunch(hitbox)
end

function Punch:ParseValidPunchableObjects()
    local objects: {Model | BasePart} = {}

    for i,v in self.validTags do
        for k, j in CollectionService:GetTagged(v) do
            if not j:IsA("Model") and not j:IsA("BasePart") then continue end

            table.insert(objects, j)
        end
    end

    return objects
end

function Punch:CheckForValidTags(obj: Instance): boolean
    for i,v in self.validTags do
        if CollectionService:HasTag(obj, v) then return true end
    end

    return false
end

function Punch:PunchVFX(part: BasePart)
    for i,v in vfxFolder.PunchVFX:GetChildren() do
        local clonedParticle = v:Clone()

        clonedParticle.Parent = part

        clonedParticle:Emit(clonedParticle:GetAttribute("EmitCount"))
        Debris:AddItem(clonedParticle, 2)
    end
end

function Punch:CreateHitbox(debugMode: boolean?): IHitboxData?
    local rootPart: BasePart = self.character:WaitForChild("HumanoidRootPart")
    local baseCF: CFrame = rootPart.CFrame * CFrame.new(0, 0, HITBOX_DISTANCE)

    local oParams: OverlapParams = OverlapParams.new()
    oParams.FilterDescendantsInstances = self.validPunchableObjects
    oParams.FilterType = Enum.RaycastFilterType.Include

    local hitbox = workspace:GetPartBoundsInBox(baseCF, HITBOX_SIZE, oParams)

    if debugMode then
        local debugPart = Instance.new("Part")

        debugPart.Anchored = true
        debugPart.CanCollide = false
        debugPart.CanTouch = false
        debugPart.CanQuery = false

        debugPart.Color = Color3.fromRGB(255, 0, 0)
        debugPart.Transparency = 0.7
        debugPart.CFrame = baseCF
        debugPart.Size = HITBOX_SIZE

        debugPart.Parent = workspace.Debug
        Debris:AddItem(debugPart, 0.15)
    end

    if #hitbox > 0 then
        -- just gets 1 object
        local firstObject: BasePart = hitbox[1]
        --print(hitbox)
        local parent: Model = firstObject.Parent

        if not parent then return end
        if not self:CheckForValidTags(parent) then return end

        -- is a valid object
        return {
            Object     = parent,
            HittedPart = firstObject
        }
    end

    return nil
end

function Punch:Destroy()
    
end


return Punch
