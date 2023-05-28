--[[
	Script: Input
	Author: LipzDev
	
	Date: 01/26/2021
	
	DOCUMENTATAION
	
		Input.Bind(Input [ string ], Function [ function ], EventType [ string ], ... [ varargs ]) -> boolean 
		Input.Unbind(Input [ string ]) -> boolean
		
]]
--// Services & Modules
local UIS = game:GetService("UserInputService")

--// Local Functions
local function ReturnWarn(Warn)
	warn("[InputLib]:", Warn)

	return
end

local function GetEnumItems(EnumName)
	local Enums = Enum[EnumName]:GetEnumItems()
	local NewEnumTable = {}

	for i,v in ipairs(Enums) do
		table.insert(NewEnumTable, v.Name)
	end

	return NewEnumTable
end

--// Module 
local Input = {
	Binds   = {}
}

function Input.Bind(DesiredInput, EventType, Function, ...)
	local Args = {...}
	local KeyCodeItems = GetEnumItems("KeyCode")

	local DesiredInputType = table.find(KeyCodeItems, DesiredInput) and "KeyCode" or "UserInputType"

	EventType = EventType or "InputBegan"

	UIS[EventType]:Connect(function(CurrentInput, GPE)
		if GPE then return end

		local InputType = CurrentInput.UserInputType.Name == "Keyboard" and "KeyCode" or "UserInputType"

		if CurrentInput[InputType] == Enum[DesiredInputType][DesiredInput] then
			Function(unpack(Args))
		end
	end)

	return true --> means it binded successfuly 
end

return Input