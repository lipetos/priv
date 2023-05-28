-- Replication Service
-- lipz
-- last uptd

--// Services & Modules
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Packages.Knit)

--// Controller
local Service = Knit.CreateService({
    Name = 'ReplicationService',
    Client = {
        ReplicateRequest = Knit.CreateSignal()
    }
})

function Service:KnitInit()

end

function Service:KnitStart()

end

function Service:ReplicateToPlayers(blacklist, effect, ...)
    local player_list = Players:GetPlayers()

    for i,v in player_list do
        if not table.find(blacklist, v) then
            self.Client.ReplicateRequest:Fire(v, effect, ...)
        end
    end
end

function Service.Client:TryReplicate(plr, effect, ...)
    self.Server:ReplicateToPlayers({plr}, effect, ...)
end

return Service