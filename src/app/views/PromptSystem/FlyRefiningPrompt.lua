local flyFunction = require("app.views.FlyTechTree.FlyFunction")

FlyRefiningPrompt = {
    flybbleTatle = {},
}

-- 记录飞宝
-- 已点亮为0， 已拥有为1
function FlyRefiningPrompt:initFibbleTable()
    local t = {}
    for i = 1, #FightStaticData.fibbleTree do
        local fibbleID = FightStaticData.fibbleTree[i].fibbleID
        if UserData.Fibble.fibbleTable[fibbleID] ~= nil then                                                    -- 检测是否已拥有
            t[fibbleID] = {type = 1, isPrompt = false}
            if flyFunction:checkFibbleStreng(fibbleID, UserData.Fibble.fibbleTable[fibbleID][1].byStar) then    -- 检测是否能炼制
                t[fibbleID].isPrompt = true
            end
        elseif flyFunction:checkFibbleEnable(fibbleID) == true then                                             -- 检测是否已点亮
            t[fibbleID] = {type = 0, isPrompt = false}
            if flyFunction:checkFibbleCreate(fibbleID) == true then                                             -- 检测是否能打造
                t[fibbleID].isPrompt = true
            end
        end
    end
    FlyRefiningPrompt.flybbleTatle = t
end

return FlyRefiningPrompt