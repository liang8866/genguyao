

local AnimationManager = {


}

--特效创建
function AnimationManager:createEffect(name, count, speed)
    local animation = cc.Animation:create()
    for i = 1, count do
        local path = string.format(name, i)
        animation:addSpriteFrameWithFile(path)
    end

    local s = 1
    if speed then
        s = 1 / speed
    end

    animation:setDelayPerUnit(0.083 * s)
    animation:setRestoreOriginalFrame(true)
    return cc.Animate:create(animation)
end

return AnimationManager
--@return typeOrObject