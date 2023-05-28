-- Data Service
-- lipz
-- 12 Mar, 2022

--[[
  
]]

--// Services & Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
local Knit = require(ReplicatedStorage.Packages.Knit)

--// Assets
local AssetsFolder = ReplicatedStorage.Assets

--// Consts Vars
local ATTRIBUTES_EXECPTIONS = {
	"SkinColor", "ClothesData", "R", "G", "B"
}
local DYNAMIC_TEMPLATE = require(ReplicatedStorage.Common.DynamicDataTemplate)
local STATIC_TEMPLATE = require(ReplicatedStorage.Common.StaticDataTemplate)

local DEBUG_WIPE_MODE = false
local VERSION = 4
local DEBUG_MODE = false

--// Local Functions
local function AdaptDataTemplate(Template, SlotsAmount: number)
	local Index = 0
	for i,v in pairs(Template) do
		Index += 1

		if Index == 1 then
			-- pending stuff
		else
			v.SLOT_UNLOCKED = false
		end
	end
end

local function ConvertTableDataToAttributes(Data, Player, _t)
	_t = _t or Data

	for i,v in pairs(_t) do
		if typeof(v) == "table" then
			if v.NotConvertable then continue end

			ConvertTableDataToAttributes(Data, Player, v)
		elseif not table.find(ATTRIBUTES_EXECPTIONS, i) then
			Player:SetAttribute(i, v)

			Player:GetAttributeChangedSignal(i):Connect(function()
				_t[i] = Player:GetAttribute(i)

				local LeaderboardFolder = Player:FindFirstChild("leaderstats")			

				if LeaderboardFolder then
					local InstanceValue = LeaderboardFolder:FindFirstChild(i)

					if InstanceValue then
						InstanceValue.Value = Player:GetAttribute(i)
					end
				end
			end)
		end
	end
end

--// Service
local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {}
})

function DataService:KnitInit()
	self.Profiles = {}
end

function DataService:KnitStart()
	-- adapts dynamic template to data slots
	-- cooming soon

	local DynamicDsId = "Dynamic-" .. VERSION
	local StaticDsId  = "Static-" .. VERSION

	local DynamicDs = ProfileService.GetProfileStore(DynamicDsId, DYNAMIC_TEMPLATE)
	local StaticDs = ProfileService.GetProfileStore(StaticDsId, STATIC_TEMPLATE)

	for _, Player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			self.Profiles[Player] = {}

			self:LoadData(DynamicDsId, Player, DynamicDs, false)
			local StaticData = self:LoadData(StaticDsId, Player, StaticDs, true)

			ConvertTableDataToAttributes(StaticData, Player)
		end)()
	end

	--// Events
	Players.PlayerAdded:Connect(function(Player)
		self.Profiles[Player] = {}

		self:LoadData(DynamicDsId, Player, DynamicDs, false)
		local StaticData = self:LoadData(StaticDsId, Player, StaticDs, true)

		ConvertTableDataToAttributes(StaticData, Player)

		if StaticData.Leaderboard then
			local LeaderboardFolder = Instance.new("Folder")

			LeaderboardFolder.Name = "leaderstats"
			LeaderboardFolder.Parent = Player

			for i,v in pairs(StaticData.Leaderboard) do
				local ValueType = typeof(v)
				local ValueName = string.sub(ValueType, 1, 1):upper() .. string.sub(ValueType, 2)

				local Inst = Instance.new(ValueName .. "Value")
				Inst.Value = v
				Inst.Name = i
				Inst.Parent = LeaderboardFolder
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(Player)
		Player:SetAttribute("FirstTime", false)

		self.PetService:SaveInventory(Player)

		self:UnloadData(DynamicDsId, Player)
		self:UnloadData(StaticDsId, Player)
	end)

	self.PetService = Knit.GetService("PetService")
end

--// Methods
function DataService:LoadData(DataStore: string, Player: Player, DataStoreProfile: any, ShouldReconcile: boolean?)
	local UserId = Player.UserId
	local Id = string.format("id-%s:" .. UserId, DataStore)

	local Profile = DataStoreProfile:LoadProfileAsync(Id, "ForceLoad")

	-- players has data
	if Profile then
		if DEBUG_WIPE_MODE then
			if DataStore == "Dynamic-"..VERSION then
				Profile.Data = DYNAMIC_TEMPLATE
			else
				Profile.Data = STATIC_TEMPLATE
			end
		end

		if ShouldReconcile then
			Profile:Reconcile()
		end

		Profile:ListenToRelease(function()
			self.Profiles[Player][DataStore] = nil -- clears player profile from temp profiles cache

			-- the data has been loaded in anther roblox server...:
			Player:Kick("Trouble while trying to load your data... ERRORCODE: 1")
		end)

		if Player:IsDescendantOf(Players) then
			-- saves players profile to the temp cache
			self.Profiles[Player][DataStore] = Profile
		else
			-- player left before the data been loaded
			Profile:Release()
		end

		warn("======================================")
		warn(DataStore, " DataStore loaded data: ", Profile.Data)
		warn("======================================")
		return Profile.Data
	else
		Player:Kick("Trouble while trying to load your data... ERRORCODE: 2")
	end
end

function DataService:UnloadData(DataStore:string, Player:Player)
	if not self.Profiles[Player] then
		return
	end

	local Profile = self.Profiles[Player][DataStore]

	if Profile then
		warn("======================================")
		warn(DataStore, " DataStore unloaded data: ", Profile.Data)
		warn("======================================")
		Profile:Release()

		self.Profiles[Player][DataStore] = nil
	end
end

function DataService:WipeData(Player)
	self.Profiles[Player]["Dynamic-" .. VERSION].Data = DYNAMIC_TEMPLATE
	self.Profiles[Player]["Static-" .. VERSION].Data = STATIC_TEMPLATE
	Player:Kick("You data has been wiped, please rejoin.")
end

function DataService:GetDataProfile(Player:Player, Profile: string)
	local PlayerProfile = self.Profiles[Player]

	if PlayerProfile then
		if Profile == "Dynamic" then
			return PlayerProfile["Dynamic-" .. VERSION]
		else
			return PlayerProfile["Static-" .. VERSION]
		end
	end
end

function DataService:WaitForData(Player: Player)
	while true do
		if self.Profiles[Player] then
			if self.Profiles[Player]["Dynamic-" .. VERSION] and self.Profiles[Player]["Static-" .. VERSION] then
				break
			end
		end

		task.wait()
	end
end

return DataService