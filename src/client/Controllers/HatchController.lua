--[[
    Hatch Controller
    lp_ts

    docs
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Zone = require(ReplicatedStorage.Packages.Zone)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Viewport = require(ReplicatedStorage.Packages.Viewport)
local AttributeTween = require(ReplicatedStorage.Packages.AttrTween)

local AssetsFolder = ReplicatedStorage.Assets
local PetsFolder = AssetsFolder.Pets
local VFXFolder = AssetsFolder.VFX

--// Local Functions
local function emitAllParticles(inst)
    for i,v in inst:GetDescendants() do
        if v:IsA("ParticleEmitter") then
            v:Emit(v:GetAttribute("EmitCount"))
        end
    end
end

local function weld(a, b)
    local weldInst = Instance.new("WeldConstraint")
    weldInst.Part0 = a
    weldInst.Part1 = b
    weldInst.Parent = a
    return weldInst
end

local HatchController = Knit.CreateController { Name = "HatchController" }

function HatchController:KnitInit()
    self.GuiController = Knit.GetController("GuiController")
    self.PetService = Knit.GetService("PetService")
end

function HatchController:KnitStart()
    self.hatchFrame = self.GuiController:GetMenuFrame("Hatch")
    self.hatchEggFrame = self.GuiController:GetMenuFrame("HatchEgg")
    self.mainFrame = self.hatchFrame:WaitForChild("Main")
    self.hatchPetsFrame = self.mainFrame:WaitForChild("Pets")
    self.leftButtons = self.mainFrame:WaitForChild("L")
    self.EButton = self.leftButtons:WaitForChild("E")

    self.EButton.MouseButton1Click:Connect(function()
        self:HatchEgg()
    end)
end

function HatchController:Open(hatchingData)
    -- checks if theres alr a menu open, if so close it
    if self.GuiController.currentFrame then
        self.GuiController:CloseFrame(self.GuiController.currentFrame.Name)
    end

    self:LoadRaritiesIntoUI(hatchingData)
    self.GuiController:OpenFrame("Hatch")
end

function HatchController:DoHatchAnimation()
    self.GuiController:CloseFrame(self.GuiController.currentFrame.Name)


end

function HatchController:HatchEgg(amount)
    self.GuiController:CloseFrame(self.GuiController.currentFrame.Name)

    task.wait(0.5)

    local originalSize = Vector3.new(0.51, 4.485, 4.71)
    local starMesh = VFXFolder.Star
    local initCF = CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(90), 0)
    local star = Viewport.displayOntoScreen(starMesh, initCF, {
        Size = Vector3.new(0.1, 0.1, 0.1)
    })

    local sizeTween = TweenService:Create(star, TweenInfo.new(.6, Enum.EasingStyle.Elastic), {
        Size = originalSize*0.2
    })
    sizeTween:Play()
    sizeTween.Completed:Wait()

    -- emits the particles
    emitAllParticles(star)

    for i = 1, 15 do
        -- if i % 2 == 0 then
        --     AttributeTween:Play(star, "Offset", initCF * CFrame.Angles(math.rad(-45), 0, 0), TweenInfo.new(0.4))
        -- else
        --     AttributeTween:Play(star, "Offset", initCF * CFrame.Angles(math.rad(45), 0, 0), TweenInfo.new(0.4))
        -- end
        task.wait(0.4)
        emitAllParticles(star)
    end

    sizeTween = TweenService:Create(star, TweenInfo.new(.6, Enum.EasingStyle.Elastic), {
        Size = Vector3.new(0.1, 0.1, 0.1)
    })
    sizeTween:Play()
    sizeTween.Completed:Wait()

    -- loads the pet model into the viewport
    star:Destroy()
    local clonedTemplate = self.hatchEggFrame.Template.Template:Clone()
    clonedTemplate.TextLabel.Visible = true
    clonedTemplate.Parent = self.hatchEggFrame

    local model, camera = Viewport.loadIntoViewModel(PetsFolder.Law, clonedTemplate, {})
    camera.CFrame = model.Root.CFrame * CFrame.new(0, 1, -3.5) * CFrame.Angles(0, math.rad(180), 0)

    --self:DoHatchAnimation()
end

function HatchController:LoadRaritiesIntoUI(pets)
    for i,v in self.hatchPetsFrame:GetChildren() do
        if v:IsA("ImageLabel") then
            v:Destroy() -- destroys the previous pets in the display
        end
    end

    -- parses the rarities
    for i,v in pets do
        local clonedTemplate = self.hatchPetsFrame.Template.Template:Clone()
        clonedTemplate.text.Text = v .. "%"
        clonedTemplate.Parent = self.hatchPetsFrame

        -- loads the model to the viewport
        local model = PetsFolder:FindFirstChild(i)

        if model then
            local viewport = clonedTemplate.Viewport
            local camera = Instance.new("Camera")
            camera.CameraType = Enum.CameraType.Scriptable
            camera.Parent = viewport

            viewport.CurrentCamera = camera

            local clonedModel = model:Clone()
            clonedModel.Parent = viewport

            camera.CFrame = clonedModel.Root.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.rad(180), 0)
        end
    end
end

function HatchController:Close()
    self.GuiController:CloseFrame("Hatch")
end

return HatchController
