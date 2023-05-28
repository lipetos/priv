--[[
    Viewport.lua
    lp_ts
]]

--// Services & Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Assets
local assets = ReplicatedStorage.Assets
local actorsFolder = assets.Actors

local camera = workspace.CurrentCamera

--// Vars
local cameraUpdateQueue = {}

--// Types
export type IViewportSettings = {
    CleanUp: boolean?,
    Distance: number?
}

--// Viewport
local Viewport = {}

function Viewport.displayOntoScreen(model: Model, offset, props)
    local clonedModel = model:Clone()
    clonedModel.Parent = camera

    local root = clonedModel.PrimaryPart or clonedModel:FindFirstChild("HumanoidRootPart") or clonedModel:FindFirstChildWhichIsA("BasePart")

    props = props or {}

    for i,v in props do
        if i == "Scale" then
            clonedModel:ScaleTo(v)

            continue
        end

        root[i] = v
    end

    root:SetAttribute("Offset", offset)
    table.insert(cameraUpdateQueue, root)

    return root
end

function Viewport.loadIntoViewModel(model: Model, viewport: ViewportFrame, settings: IViewportSettings)
    local camera = viewport:FindFirstChild("Camera")

    local distance = settings.Distance or 4
    local cleanup = settings.CleanUp or false

    if cleanup then
        for i,v in viewport:GetChildren() do
            if v:IsA("Model") then
                v:Destroy()
            end
        end
    end

    if not camera then
        camera = Instance.new("Camera")
        camera.Parent = viewport
    end

    local clonedModel = model:Clone()
    clonedModel.Parent = viewport

    local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    camera.CFrame = primaryPart.CFrame * CFrame.new(0, 0, distance)

    viewport.CurrentCamera = camera

    return clonedModel, camera
end

-- Main Loop
RunService.RenderStepped:Connect(function(deltaTime)
    for i,v in cameraUpdateQueue do
        local offset = v:GetAttribute("Offset")

        if not offset then continue end

        v.CFrame = camera.CFrame * offset
    end
end)

return Viewport