

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")
local DataManager = require("app.views.public.DataManager")

local NewHandLead = {
    currentGuideName = "",
    GuideList = {
        Fighting_1 = {
            name = "Fighting_1",
            TaskID = 510001,  
            step = {[1] = {PlotSectionID = 269, pos_1 = cc.p(display.cx * 7 / 5, display.cy  * 7 / 5),},
                [2] = {PlotSectionID = 270,},
                [3] = {pos_2 = cc.p(display.cx * 7 / 5, display.cy ),},
                [4] = {PlotSectionID = 271, pos_3 = cc.p(display.cx * 7 / 5, display.cy * 3 / 5 ),},
                [5] = {pos_1 = cc.p(display.cx * 6 / 5 - 50, display.cy / 10 - 70), pos_2 = cc.p(display.cx * 6 / 5 - 50, display.cy - 40),}
            },
        }, --战斗指引(第一次战斗)

        Fighting_2 = {
            name = "Fighting_2",
            TaskID = 510002,
            GodID = 413004, -- 唐僧阿三
            step = {[1] = {PlotSectionID = 272},
                [2] = {PlotSectionID = 273},},
        }, --战斗指引(第二次战斗，神将指引1)
        
        TownToMap = {
            name = "TownToMap", 
            TaskID = 510004,  -- 此指引对应的任务
            step = {[1] = {handPos = cc.p(995,480), handInLeadUI = true,PlotSectionID = 274},
            },
        },  -- 出城镇到地图的指引
        
        ClickMapEnventPoint = {
            name = "ClickMapEnventPoint", 
            TaskID = 510004,  -- 此指引对应的任务
            step = {[1] = {handInLeadUI = false, PlotSectionID = 275},
            },
        },  -- 地图第一个支点任务指引  
           
        FightingWithGodwill = {
            name = "FightingWithGodwill",
            TaskID = 510005,
            GodID = 411002, -- 孙悟空 
            step = {[1] = {PlotSectionID = 276},
--                    [2] = {PlotSectionID = 273},
            },
        }, --战斗指引(神将助攻指引2)
        
        EnterToJiangDou = {
            name = "EnterToJiangDou", 
            TaskID = 510007,  -- 此指引对应的任务
            step = {[1] = {handPos = cc.p(383,350), handInLeadUI = false,PlotSectionID = 278},},
        },  -- 进入江都   
        ClickTaskNodeList = {
            name = "ClickTaskNodeList", 
            TaskID = 510007,  -- 此指引对应的任务
            step = {[1] = { PlotSectionID = 279},},
        },    --点击城镇的任务列表
        GodWillLead_levelup = {
            name = "GodWillLead_levelup", 
            preGuideName = "ClickTaskNodeList",
            TaskID = 510006,  -- 开启此指引的需完成的任务ID
            curStep = 1,
            step = {[1] = {handPos = cc.p(542,10), handInLeadUI = false,PlotSectionID = 280},
                [2] = {handInLeadUI = false},
                [3] = {handPos = cc.p(310,45)}, --神将升级界面，强化按钮
                [4] = {handPos = cc.p(885,75)}, --神将升级界面，升级按钮
                [5] = {handPos = cc.p(1005,485)}, -- 关闭按钮
            },
        }, --神将列表
        FlyRefining = {
            name = "FlyRefining",
            preGuideName = "GodWillLead_levelup", 
            TaskID = 510008,
            step = {[1] = {handPos = cc.p(322,10), PlotSectionID = 282}, 
                    [2] = {handPos = cc.p(display.cx - 180, display.cy / 4 - 80), PlotSectionID = 282, nextSize = cc.size(80, 80)},
                    [3] = {handPos = cc.p(display.cx, display.cy - 40), PlotSectionID = 283, nextSize = cc.size(185, 121)},
                    [4] = {handPos = cc.p(display.cx - 140, display.cy / 5 - 30), nextSize = cc.size(180, 64)},
            },
        },  -- 炼制指引
        FlySkillChange = {
            name = "FlySkillChange",
            step = {[1] = {handPos = cc.p(display.cx + 40, -30), nextSize = cc.size(80, 80)},
                    [2] = {handPos = cc.p(display.cx - 180, display.cy / 4 - 80), nextSize = cc.size(80, 80)},
                    [3] = {handPos = cc.p(display.cx, display.cy - 40), PlotSectionID = 282, nextSize = cc.size(185, 121)},
                    [4] = {handPos = cc.p(display.cx / 2 - 20, display.cy / 5), PlotSectionID = 284, nextSize = cc.size(260, 75)},
                    [5] = {handPos = cc.p(display.cx / 2 + 80, display.cy / 4), nextSize = cc.size(260, 75)},
                    [6] = {handPos = cc.p(display.cx / 3 + 20, display.cy * 7 / 5 + 30), nextSize = cc.size(82, 82)},
                    [7] = {handPos = cc.p(display.cx * 7 / 5 - 5, display.cy * 9 / 5 - 30), nextSize = cc.size(76, 78)},
            },
        },  -- 飞宝更换技能
        FlyGodChange = {
            name = "FlyGodChange",
            step = {[1] = {handPos = cc.p(display.cx + 40, -30), nextSize = cc.size(80, 80)},
                [2] = {handPos = cc.p(display.cx - 180, display.cy / 4 - 80), nextSize = cc.size(80, 80)},
                [3] = {handPos = cc.p(display.cx, display.cy - 40), PlotSectionID = 282, nextSize = cc.size(185, 121)},
                [4] = {handPos = cc.p(display.cx * 5 / 4 - 10, display.cy / 5),PlotSectionID = 285, nextSize = cc.size(400, 95)},
                [5] = {handPos = cc.p(display.cx - 50, display.cy * 3 / 2 + 10), nextSize = cc.size(82, 82)},
                [6] = {handPos = cc.p(display.cx + 50, display.cy * 3 / 2 + 10), nextSize = cc.size(82, 82)},
                [7] = {handPos = cc.p(display.cx * 11 / 6 + 20, display.cy * 7 / 4), nextSize = cc.size(76, 78)},
            },
        },  -- 飞宝更换神将
        FlyFighting = {
            name = "FlyFighting",
            step = {[1] = {handPos = cc.p(display.cx + 40, -30), nextSize = cc.size(80, 80)},
                [2] = {handPos = cc.p(display.cx - 180, display.cy / 4 - 80), nextSize = cc.size(80, 80)},
                [3] = {handPos = cc.p(display.cx, display.cy - 40), PlotSectionID = 282, nextSize = cc.size(185, 121)},
                [4] = {handPos = cc.p(display.cx * 5 / 4 - 120, display.cy / 2 + 10), PlotSectionID = 286, nextSize = cc.size(160, 65)},
            },
        },  -- 飞宝出战
        
        FlySkillLead = {
            name = "FlySkillLead", 
            preGuideName = "FlyFighting", 
            TaskID = 510010,  -- 开启此指引的需完成的任务ID
            curStep = 1,
            step = {[1] = {handPos = cc.p(422,10), handInLeadUI = false,PlotSectionID = 288},
                    [2] = {handInLeadUI = false,},
                    [3] = {handPos = cc.p(754,48),},
                    [4] = {handPos = cc.p(655,48),},
                    [5] = {handPos = cc.p(995,485),},
            },
        }, -- 飞宝技能
        
--        GodWillLead_starUp = {
--            name = "GodWillLead_starUp", 
--            preGuideName = "FlySkillLead",
--            TaskID = 510012,  -- 开启此指引的需完成的任务ID
--            curStep = 1,
--            step = {[1] = {handPos = cc.p(552,20), handInLeadUI = false,PlotSectionID = 290},
--                    [2] = {handInLeadUI = false},
--                    [3] = {handPos = cc.p(482,45), handInLeadUI = false}, --神将升星界面，左边升星按钮
--                    [4] = {handPos = cc.p(792,45)}, --神将升星界面，右边升星按钮
--                    [5] = {handPos = cc.p(995,485)}, -- 关闭按钮
--            },
--        }, --神将列表
        
        ExploreLead = {
            name = "ExploreLead",
            preGuideName = "FlySkillLead", 
            TaskID = 510015, --开启此指引的需完成的任务ID
            step = {[1] = {handPos = cc.p(display.cx / 2, display.cy), PlotSectionID = 291, nextSize = cc.size(162, 169)},
                [2] = {handPos = cc.p(display.cx * 2 / 3 - 10, display.cy / 8), PlotSectionID = 292, nextSize = cc.size(162, 80)},
            },
        },  -- 探索引导
        Explore_1 = {
            name = "Explore_1",
            step = {[1] = {handPos = cc.p(720, 640), PlotSectionID = 293, nextSize = cc.size(80, 80)},
--                [2] = {handPos = cc.p(720, 560), PlotSectionID = 294, nextSize = cc.size(80, 80)},
            },
        },  -- 探索地图指引1
        Explore_2 = {
            name = "Explore_2",
            step = {[1] = {handPos = cc.p(240, 560), PlotSectionID = 295, nextSize = cc.size(80, 80)}, 
            },
        },  -- 探索地图指引2


    }

}


function NewHandLead:isPreGuideCompleted(curGuideName)
    local pre = NewHandLead.GuideList[curGuideName].preGuideName
    if pre == nil or pre == "" then
        return true
    end
    return self:getGuideState(pre) == 1
end

--NewHandLead.GuideList.TownToMap.TaskID
function NewHandLead:CompleteGuide(curGuideName)
    DataManager:setIntegerForKey(curGuideName,1)
end

function NewHandLead:getGuideState(curGuideName)
    return DataManager:getIntegerForKey(curGuideName,0)
end
   
--获取当前正在进行的指引名字
function NewHandLead:getCurrentGuideName()
    return NewHandLead.currentGuideName
end

function NewHandLead:closeCurrentGuide()
    NewHandLead.currentGuideName = ""
end

function NewHandLead:startNewGuide(curGuideData)
    if curGuideData.name ~= nil and curGuideData.name ~= "" then
        local layer = require("app.views.NewHandLead.NewHandLeadLayer"):create(curGuideData)
        if layer ~= nil then
            NewHandLead.currentGuideName = curGuideData.name
            if curGuideData.parent == nil then
                local SceneManager = require("app.views.SceneManager")
                if curGuideData.order ~= nil then
                    SceneManager:addToGameScene(layer, curGuideData.order)
                else
                    SceneManager:addToGameScene(layer)
                end
            else
                --curGuideData.parent:addChild(layer)
            end
            return layer
        end
    end
    return nil
end

function NewHandLead:addHandTo(parent)
    if parent == nil then
        return
    end
    parent:removeAllChildren()
    local SpineJson = "spine/ui/ui_shouzhi.json"
    local SpineAtlas = "spine/ui/ui_shouzhi.atlas"
    
    local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    skeletonNode:setAnimation(0, "click", true)
    skeletonNode:setPosition(0,0)
    skeletonNode:setName("skeletonNode")
    parent:addChild(skeletonNode)
end

function NewHandLead:removeHandFrom(parent)
    if parent ~= nil and parent:getChildByName("skeletonNode") ~= nil then
        parent:removeChildByName("skeletonNode")
    end
end

function NewHandLead:GetNewPlayerGuideFightGodID()
    local GodID = 0
    if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_2.TaskID  then
        if UserData.NewHandLead:getGuideState("Fighting_2") == 0 then
            GodID = UserData.NewHandLead.GuideList.Fighting_2.GodID
        end
    elseif UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.FightingWithGodwill.TaskID  then
        if UserData.NewHandLead:getGuideState("FightingWithGodwill") == 0 then
            GodID = UserData.NewHandLead.GuideList.FightingWithGodwill.GodID
        end
    end
    return GodID
end

return NewHandLead