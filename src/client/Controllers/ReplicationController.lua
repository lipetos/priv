-- Replication Controller
-- lipz
-- last uptd

--// Services & Modules
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Effects    = require(ReplicatedStorage.Common.Effects)
local Knit       = require(ReplicatedStorage.Packages.Knit)

--// Controller
local Controller = Knit.CreateController({
    Name = 'ReplicationController'
})

function Controller:KnitInit() end

function Controller:KnitStart()
    self.ReplicationService = Knit.GetService("ReplicationService")
    self.ReplicationService.ReplicateRequest:Connect(function(effect: string, ...)
        Effects.execEffect(effect, ...)
    end)
end

function Controller:ExecEffect(effect: string, ...)
    Effects.execEffect(effect, ...)
end

function Controller:RequestEffect(effect: string, ...)
    self.ReplicationService:TryReplicate(effect, ...)
end

return Controller