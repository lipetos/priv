-- Animations Handler
-- lipz
-- last uptd idk

--[[
    TODOO: Add support for AnimationsController.

]]

--// Services & Modules

--// Types
export type Array<T> = {[number]: T}

--// Lib
local Animations = {}
Animations.__index = Animations

--// Constructor
function Animations.new(Humanoid: Humanoid, AnimationsTable: Array<Animation>)
    local self = setmetatable({
        AnimationsTable       = AnimationsTable,
        Humanoid              = Humanoid,

        LoadedAnimations = {}
    }, Animations)

    for i, v: Animation in AnimationsTable do
        if not v:IsA("Animation") then continue end

        local LoadedAnimation = Humanoid:LoadAnimation(v)

        self.LoadedAnimations[v.Name] = LoadedAnimation
    end

    return self
end

--// Methods
function Animations:GetTrack(AniamtionName: string)
    return self.LoadedAnimations[AniamtionName]
end

function Animations:Play(AnimationName: string, ...): AnimationTrack?
    local Track: AnimationTrack = self.LoadedAnimations[AnimationName]

    if not Track then
        return warn("Couldn't Play the animation, because it doesn't exists or it has been labeled in the wrong way: ", AnimationName)
    end

    warn("playing tracks")

    Track:Play(...)

    return Track
end

function Animations:Stop(AnimationName: string): AnimationTrack
    local Track: AnimationTrack = self.LoadedAnimations[AnimationName]

    if not Track then
        return warn("Couldn't Stop the animation, because it doesn't exists or it has been labeled in the wrong way: ", AnimationName)
    end

    Track:Stop()

    return Track
end

return Animations