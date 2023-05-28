local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local AssetsFolder = ReplicatedStorage.Assets
local VFXFolder = AssetsFolder.VFX

-- local CameraShaker = require(ReplicatedStorage.CameraShaker)
-- local camera = workspace.CurrentCamera
-- local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
-- 	camera.CFrame = camera.CFrame * shakeCf
-- end)

-- camShake:Start()

local EffectsHandler = {
    skills_cache = {},
    -- camera_shaker = camShake,
    -- camera_presets = CameraShaker.Presets
}

function EffectsHandler.emitAllParticles(part: Instance)
    for i,v in part:GetDescendants() do
        if v.Name == "GoToParent" then
            v.Parent = part.Parent
        end

        if v:IsA("ParticleEmitter") then
            v:Emit(v:GetAttribute("EmitCount"))
        end
    end
end

function EffectsHandler.disableAndDestroy(delay: number, instance)
    for i,v in instance:GetDescendants() do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false

            Debris:AddItem(v, delay)
        end
    end
end

function EffectsHandler.flash()
    game.Lighting.C1Blur.Enabled = true
    task.wait(0.05)

    game.Lighting.C1.Contrast = -6
    game.Lighting.C1.Enabled = true
    task.wait(0.05)
    game.Lighting.C1.Contrast = 6
    task.wait(0.05)

    game.Lighting.C1.Contrast = -6
    task.wait(0.05)
    game.Lighting.C1.Enabled = false
    game.Lighting.C1Blur.Enabled = false

    return
end

function EffectsHandler.applyProperties(inst, props)
    for i,v in props do
        inst[i] = v
    end
end

function EffectsHandler.weld(p1, p2)
    return EffectsHandler.newInst("WeldConstraint", {
        Part0 = p1,
        Part1 = p2,
        Parent = p1,
        Name = p1.Name .. p2.Name .. "Weld"
    })
end

function EffectsHandler.getVFX(vfx: string)
    return VFXFolder:FindFirstChild(vfx)
end

function EffectsHandler.cleanUpCache(effect: string)
    -- do somje stuff such as destroy instances and disconenct stuff
    EffectsHandler.skills_cache[effect] = nil
end

function EffectsHandler.getEffectModule(effect: string)
    for i,v in script:GetDescendants() do
        if v.Name == effect then
            return v
        end
    end
end

function EffectsHandler.fireServerCode()
    
end

function EffectsHandler.execInRealTimeEffect(effect: string, ...)
    local current_effect = nil
    local current_cloned = nil

    for i,v in script:GetDescendants() do
        if v.Name == effect then
            local cloned_module = v:Clone()
            current_effect = require(cloned_module)
            current_cloned = cloned_module
        end
    end

    if not EffectsHandler.skills_cache[effect] then
        EffectsHandler.skills_cache[effect] = {}
    end

    current_effect(EffectsHandler, ...)
    current_cloned:Destroy()
end

function EffectsHandler.execEffect(effect: string, ...)
    local current_effect = nil

    for i,v in script:GetDescendants() do
        if v.Name == effect then
            current_effect = require(v)
        end
    end

    if not EffectsHandler.skills_cache[effect] then
        EffectsHandler.skills_cache[effect] = {}
    end

    current_effect(EffectsHandler, ...)
end

function EffectsHandler.newInst(class: string, props)
    local inst = Instance.new(class)

    for i,v in props do
        inst[i] = v
    end

    return inst
end

function EffectsHandler.clone(inst: Instance, newProps)
    local cloned_inst = inst:Clone()

    for i,v in newProps do
        cloned_inst[i] = v
    end

    return cloned_inst
end

return EffectsHandler