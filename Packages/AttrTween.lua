local TweenService = game:GetService("TweenService")

local AttrTween = {}

function AttrTween:Play(inst, attr, goal, tween)
    local value = Instance.new(typeof(goal).."Value")

    value.Changed:Connect(function(property)
        inst:SetAttribute(attr, value.Value)
    end)

    local t = TweenService:Create(value, tween, {
        Value = goal
    })
    t:Play()

    return t
end

return AttrTween