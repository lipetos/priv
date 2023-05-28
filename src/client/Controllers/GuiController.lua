--[[
    Gui Controller
    idk
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GuiController = Knit.CreateController { Name = "GuiController" }

function GuiController:KnitStart()

end

function GuiController:KnitInit()
    self.playerGui = Knit.player:WaitForChild("PlayerGui")
    self.currentFrame = nil
    self.leftButtons = self.playerGui:WaitForChild("Buttons")
    self.frames = self.playerGui:WaitForChild("Frames")
    self.messageScreen = self.playerGui:WaitForChild("Messages")
    self.messageFrame = self.messageScreen:WaitForChild("Frame")

    for i,v in self.leftButtons.L:GetChildren() do
        local frame = self.frames:FindFirstChild(v.Name)

        if not frame then continue end

        local mainFrame = frame.Main
        local closeButton = mainFrame.Close

        v.MouseButton1Click:Connect(function()
            -- opens the frame
            self:OpenFrame(v.Name)
        end)

        closeButton.MouseButton1Click:Connect(function()
            if not self.currentFrame then return end

            self:CloseFrame(self.currentFrame.Name)
        end)
    end
end

function GuiController:GetMenuFrame(frame: string)
    self.frames = self.playerGui:FindFirstChild("Frames")

    return self.frames:FindFirstChild(frame)
end

function GuiController:GetButton(button: string)
    self.leftButtons = self.playerGui:FindFirstChild("Buttons")

    return self.leftButtons.L:FindFirstChild(button)
end

function GuiController:CloseFrame(frame: string)
    local frame = self:GetMenuFrame(frame)
    local mainFrame = frame.Main

    self.currentFrame = nil

    TweenService:Create(mainFrame, TweenInfo.new(0.1), {
        Position = UDim2.fromScale(0.5, -1.5)
    }):Play()
end

function GuiController:OpenFrame(frame: string)
    if self.currentFrame then
        local frameName = self.currentFrame.Name
        self:CloseFrame(self.currentFrame.Name)

        if frameName == frame then
            return -- if the button that the player is trying to open is alredy opened, its just going to close it.
        end
    end

    local frame = self:GetMenuFrame(frame)
    local mainFrame = frame.Main

    mainFrame.Position = UDim2.fromScale(0.5, -1.5)
    frame.Visible = true

    self.currentFrame = frame

    TweenService:Create(mainFrame, TweenInfo.new(0.1), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
end

function GuiController:SendMessage(msg: string, c: Color3?, d: number?)
    local template = self.messageFrame.Template.Template:Clone()

    template.TextLabel.TextColor3 = c or Color3.fromRGB(255, 255, 255)
    template.TextLabel.Text = msg

    template.TextLabel.Size = UDim2.fromScale(0, 0)
    template.Parent = self.messageFrame

    TweenService:Create(template.TextLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        Size = UDim2.fromScale(1, 1)
    }):Play()

    task.wait(2)

    local transparency = TweenService:Create(template.TextLabel, TweenInfo.new(), {
        TextTransparency = 1
    })
    TweenService:Create(template.TextLabel.UIStroke, TweenInfo.new(), {
        Transparency = 1
    }):Play()

    transparency:Play()
    transparency.Completed:Connect(function(playbackState)
        template:Destroy()
    end)
end

return GuiController
