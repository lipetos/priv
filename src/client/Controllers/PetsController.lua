--[[
    Pets Controller
    idk
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Enums = require(ReplicatedStorage.Common.Enums)

local SELECT_MODES = Enums.SELECT_MODES

local AssetsFolder = ReplicatedStorage.Assets
local PetsFolder = AssetsFolder.Pets

local PetsController = Knit.CreateController { Name = "PetsController" }

function PetsController:KnitInit()
    self.PetService = Knit.GetService("PetService")
    self.GuiController = Knit.GetController("GuiController")
end

function PetsController:KnitStart()
    self.petsFrame = self.GuiController:GetMenuFrame("Pets")
    self.petsFrameContent = self.petsFrame.Main
    self.displayScrollingFrame = self.petsFrameContent.Scroll

    self.infoFrame = self.petsFrameContent.Info
    self.utilityButtons = self.petsFrameContent.R

    self.cachedFrames = {}
    self.selectedPool = {}
    self.currentSelectedSlot = nil

    self.selectMode = SELECT_MODES.Default

    -- UI Related
    self.PetService.InventoryLoaded:Connect(function(data)
        for i,v in data do
            if not v.Id then continue end

            self:_createSlot({
                id = v.Id,
                name = v.ModelName,
                multiplier = 1
            })

            self:_setPetSlot(v.Id, v.Equipped)
        end
    end)

    self.PetService.Added:Connect(function(data: any)
        local id = data.id
        local name = data.name

        -- a basic data conversion, from the server version
        -- to the client acceptable UI version.
        self:_createSlot({
            id = id,
            name = name,
            multiplier = 1
        })
    end)

    self.PetService.Deleted:Connect(function(uuid: string)
        local slot = self:_getSlot(uuid)

        slot:Destroy()
        self.cachedFrames[uuid] = nil
    end)

    self.PetService.Equipped:Connect(function(uuid: string)
        self:_setPetSlot(uuid, true)
    end)

    self.PetService.Unequipped:Connect(function(uuid: string)
        self:_setPetSlot(uuid, false)
    end)

    -- Some basic info, such as how much pets the player has equipped
    self.infoFrame.equip.Title.Text = `{Knit.player:GetAttribute("EquippedPetsAmount")}/{Knit.player:GetAttribute("MaxEquippedPets")}` 
    self.infoFrame.storage.Title.Text = `{Knit.player:GetAttribute("PetsAmount")}/{Knit.player:GetAttribute("MaxPets")}`

    Knit.player:GetAttributeChangedSignal("EquippedPetsAmount"):Connect(function()
        self.infoFrame.equip.Title.Text = `{Knit.player:GetAttribute("EquippedPetsAmount")}/{Knit.player:GetAttribute("MaxEquippedPets")}` 
    end)

    Knit.player:GetAttributeChangedSignal("PetsAmount"):Connect(function()
        self.infoFrame.storage.Title.Text = `{Knit.player:GetAttribute("PetsAmount")}/{Knit.player:GetAttribute("MaxPets")}`
    end)

    -- Delete button
    self.petsFrameContent.Delete.MouseButton1Click:Connect(function()
        if self.selectMode == SELECT_MODES.Delete then
            -- clears the selection pool
            for i,v in self.selectedPool do
                self:RemoveFromSelection(i)
            end

            self.utilityButtons.Visible = false
            self.selectMode = SELECT_MODES.Default
        else
            self.utilityButtons.Visible = true
            self.selectMode = SELECT_MODES.Delete
        end
    end)

    self.petsFrameContent.EquipBest.MouseButton1Click:Connect(function()
        self.PetService:EquipBest()
    end)

    -- Confirm related
    self.utilityButtons.confirm.MouseButton1Click:Connect(function()
        -- parses the UUIds
        local uuids = {}

        for i,v in self.selectedPool do
            table.insert(uuids, i)
        end

        self.PetService:ConfirmAction(uuids, self.selectMode)

        for i,v in self.selectedPool do
            self:RemoveFromSelection(i)
        end
        self.utilityButtons.Visible = false
        self.selectMode = SELECT_MODES.Default
    end)

    self.utilityButtons.cancel.MouseButton1Click:Connect(function()
        -- parses the UUIds
        -- clears the selection pool
        for i,v in self.selectedPool do
            self:RemoveFromSelection(i)
        end

        self.utilityButtons.Visible = false
        self.selectMode = SELECT_MODES.Default
    end)

    self.utilityButtons.selectall.MouseButton1Click:Connect(function()
        for i,v in self.cachedFrames do
            if not v:GetAttribute("Equipped") then
                self:AddToSelection(v)
            end
        end
    end)

    -- Unequip all buttons
    self.utilityButtons.unequipall.MouseButton1Click:Connect(function()
        self.PetService:UnequipAll()
    end)
end

function PetsController:_getSlot(uuid: string)
    return self.cachedFrames[uuid]
end

function PetsController:_setPetSlot(uuid: string, state)
    local slot = self:_getSlot(uuid)

    if state then
        slot:SetAttribute("Equipped", true)
        slot.LayoutOrder = -1
        slot.button.equipped.Visible = true
    else
        slot.LayoutOrder = slot:GetAttribute("DefaultLayoutOrder") or 1
        slot:SetAttribute("Equipped", false)
        slot.button.equipped.Visible = false
    end
end

function PetsController:IsSelected(uuid: string)
    return self.selectedPool[uuid]
end

function PetsController:AddToSelection(frame)
    self.selectedPool[frame.Name] = frame

    if self.selectMode == SELECT_MODES.Delete then
        frame.button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

function PetsController:RemoveFromSelection(uuid: string)
    local frame = self.selectedPool[uuid]

    self.selectedPool[uuid] = nil

    if self.selectMode == SELECT_MODES.Delete then
        frame.button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function PetsController:_createSlot(data)
    local templateFrame = self.displayScrollingFrame.Template.new_slot
    local slot = templateFrame:Clone()
    local viewport = slot.button.ViewportFrame

    -- loads the model to the viewport
    local model = PetsFolder:FindFirstChild(data.name)

    if model then
        local camera = Instance.new("Camera")
        camera.CameraType = Enum.CameraType.Scriptable
        camera.Parent = viewport

        viewport.CurrentCamera = camera

        local clonedModel = model:Clone()
        clonedModel.Parent = viewport

        camera.CFrame = clonedModel.Root.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.rad(180), 0)
    end

    slot.button.energy.Text = data.multiplier .. "x"
    slot.Name = data.id
    slot.Parent = self.displayScrollingFrame

    self.cachedFrames[data.id] = slot

    slot.button.MouseButton1Click:Connect(function()
        if self.selectMode == SELECT_MODES.Delete then
            if self:IsSelected(slot.Name) then
                self:RemoveFromSelection(slot.Name)
            else
                self:AddToSelection(slot)
            end
        elseif self.selectMode == SELECT_MODES.Default then
            -- checks if player already has the max pets equipped
            local equippedPets = Knit.player:GetAttribute("EquippedPetsAmount")
            local maxEquippedPets = Knit.player:GetAttribute("MaxEquippedPets")
            if equippedPets >= maxEquippedPets and not slot:GetAttribute("Equipped") then
                self.GuiController:SendMessage(`Reached the max equipped pets! {equippedPets}/{maxEquippedPets}`)

                return
            end

            if not slot:GetAttribute("Equipped") then
                self.PetService:EquipPet(data.id)
            else
                self.PetService:UnequipPet(data.id)
            end
        end
    end)

    return slot
end

return PetsController
