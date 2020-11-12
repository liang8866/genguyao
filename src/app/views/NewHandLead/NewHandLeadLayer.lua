local ManagerTask = require("app.views.Task.ManagerTask")

local NewHandLeadLayer = class("NewHandLeadLayer", function()
    return cc.Layer:create()
end)


function NewHandLeadLayer:create(userData)

    local view = NewHandLeadLayer:new()
    view:init(userData)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end
    end
    view:registerScriptHandler(onEventHandler)
    return view
end

function NewHandLeadLayer:ctor()

end

function NewHandLeadLayer:onEnter()

end

function NewHandLeadLayer:onExit()

end

function NewHandLeadLayer:init(userData)
    local csb = cc.CSLoader:createNode("res/csb/NewHandLead.csb")

    self:addChild(csb)
    self.bgPanel = csb:getChildByName("bgPanel")
    self.Node_pointToSprite = self.bgPanel:getChildByName("Node_pointToSprite")
    self.bgPanel:setTouchEnabled(false)

    self.pointToSprite = self.bgPanel:getChildByName("pointToSprite")
    self.pointToSprite:setVisible(false)
    
    self.step = nil


    if userData.name == "TownToMap" 
        or userData.name == "ClickMapEnventPoint" 
        or userData.name == "EnterToJiangDou"
        or userData.name == "ClickTaskNodeList" 
        or userData.name == "FlySkillLead" 
        or userData.name == "GodWillLead_levelup"
        or userData.name == "GodWillLead_starUp" then
        local guideData = UserData.NewHandLead.GuideList[userData.name]
        if guideData ~= nil and guideData.step[1] ~= nil and guideData.step[1].handPos ~= nil and  guideData.step[1].handInLeadUI then
            self.Node_pointToSprite:removeAllChildren()
            local child = self:createHandAnimation("click")
            self.Node_pointToSprite:addChild(child)
            self.Node_pointToSprite:setPosition(guideData.step[1].handPos)
            if guideData.step[1].handRotate ~= nil and tonumber(guideData.step[1].handRotate) ~= nil then
                self.Node_pointToSprite:setRotation(guideData.step[1].handRotate)
            end
        end
        if guideData ~= nil and guideData.step[1] ~= nil and guideData.step[1].PlotSectionID ~= nil then
            ManagerTask.SectionId = guideData.step[1].PlotSectionID
            local PlotLayer = require("app.views.Plot.PlotLayer")
            PlotLayer:initPlotEnterAntExit(0)
            local layer = PlotLayer:create()
            self:addChild(layer)
        end
        self.bgPanel:setBackGroundColorOpacity(0)
    end
    
    self.userData = userData
    if self.userData.name == "Explore_1" or self.userData.name == "Explore_2" then
        self.Node_pointToSprite:removeAllChildren()
        local child = self:createHandAnimation("click")
        self.Node_pointToSprite:addChild(child)
        self.bgPanel:setTouchEnabled(false)
        self.stepNum = 1
        self:ExploreLead_1()
    end
    
    local function setPointToSprite()
        if self.userData.beginStep ~= nil then
            self.stepNum = self.userData.beginStep
        else
            self.stepNum = 2
        end
        self.userData = UserData.NewHandLead.GuideList[userData.name]
        self.Node_pointToSprite:removeAllChildren()
        local child = self:createHandAnimation("click")
        self.Node_pointToSprite:addChild(child)
        self.bgPanel:setTouchEnabled(false)
    end
    
    if self.userData.name == "Fighting_1" then
        self.Node_pointToSprite:removeAllChildren()
        local child = self:createHandAnimation("click")
        child:setTag(1)
        self.Node_pointToSprite:addChild(child)
        self.Node_pointToSprite:setPosition(self.userData.step[1].pos_1.x + 40, self.userData.step[1].pos_1.y - 40)
    end
    
    if self.userData.name == "FlyRefining" then
        setPointToSprite()
        self:FlyRefining()
    elseif self.userData.name == "FlySkillChange" then
        setPointToSprite()
        self:FlySkillChange()
    elseif self.userData.name == "FlyGodChange" then
        setPointToSprite()
        self:FlyGodChange()
    elseif self.userData.name == "FlyFighting" then
        setPointToSprite()
        self:FlyFighting()
    end
    
    if self.userData.name == "ExploreLead" then
        self.userData = UserData.NewHandLead.GuideList[userData.name]
        self.stepNum = 1
        self.Node_pointToSprite:removeAllChildren()
        local child = self:createHandAnimation("click")
        self.Node_pointToSprite:addChild(child)
        self.bgPanel:setTouchEnabled(false)
        
        self:ExploreLead()
    end
    
    self:touchEvent()
    
end

-- 探索第一步新手指引
function NewHandLeadLayer:ExploreLead_1()
    local pos_1 = self.userData.step[self.stepNum].handPos
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)
end

-- 飞宝炼制指引
function NewHandLeadLayer:FlyRefining()
    local pos_1 = self.userData.step[self.stepNum].handPos
    local size_1 = self.userData.step[self.stepNum].nextSize
    self.rect_next = cc.rect(pos_1.x - size_1.width / 2 - 30, pos_1.y - size_1.height / 2 + 40, size_1.width, size_1.height)
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)
    
    local size_2 = cc.size(90, 90)
    if self.stepNum == 4 then
        local pos_2 = cc.p(display.cx * 2 - 60, display.cy*7/4 - 10)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 30, size_2.width, size_2.height)
    end
    if self.userData.step[self.stepNum].PlotSectionID ~= nil then
        ManagerTask.SectionId = self.userData.step[self.stepNum].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create()
        self:addChild(layer)
    end
end

-- 飞宝技能更换指引
function NewHandLeadLayer:FlySkillChange()
    local pos_1 = self.userData.step[self.stepNum].handPos
    local size_1 = self.userData.step[self.stepNum].nextSize
    self.rect_next = cc.rect(pos_1.x - size_1.width / 2 - 30, pos_1.y - size_1.height / 2 + 40, size_1.width, size_1.height)
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)
    
    local size_2 = cc.size(76, 78)
    if self.stepNum == 4 then
        local pos_2 = cc.p(display.cx * 2 - 60, display.cy*7/4 - 10)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    elseif self.stepNum == 5 or self.stepNum == 6 then
        local pos_2 = self.userData.step[7].handPos
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    end
    if self.userData.step[self.stepNum].PlotSectionID ~= nil then
        ManagerTask.SectionId = self.userData.step[self.stepNum].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create()
        self:addChild(layer)
    end
end

-- 神将更换指引
function NewHandLeadLayer:FlyGodChange()
    local pos_1 = self.userData.step[self.stepNum].handPos
    local size_1 = self.userData.step[self.stepNum].nextSize
    self.rect_next = cc.rect(pos_1.x - size_1.width / 2 - 30, pos_1.y - size_1.height / 2 + 40, size_1.width, size_1.height)
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)

    local size_2 = cc.size(76, 78)
    if self.stepNum == 4 then
        local pos_2 = cc.p(display.cx * 2 - 60, display.cy*7/4 - 10)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    elseif self.stepNum == 5 or self.stepNum == 6 then
        local pos_2 = self.userData.step[7].handPos
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    end
    if self.userData.step[self.stepNum].PlotSectionID ~= nil then
        ManagerTask.SectionId = self.userData.step[self.stepNum].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create()
        self:addChild(layer)
    end
end

-- 飞宝出战指引
function NewHandLeadLayer:FlyFighting()
    local pos_1 = self.userData.step[self.stepNum].handPos
    local size_1 = self.userData.step[self.stepNum].nextSize
    self.rect_next = cc.rect(pos_1.x - size_1.width / 2 - 30, pos_1.y - size_1.height / 2 + 40, size_1.width, size_1.height)
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)

    local size_2 = cc.size(76, 78)
    if self.stepNum == 3 then
        local pos_2 = cc.p(display.cx * 2 - 10, display.cy*7/4 - 10)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    elseif self.stepNum == 4 then
        local pos_2 = cc.p(display.cx * 2 - 60, display.cy*7/4 - 10)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    end
    if self.userData.step[self.stepNum].PlotSectionID ~= nil then
        ManagerTask.SectionId = self.userData.step[self.stepNum].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        local layer = PlotLayer:create()
        PlotLayer:initPlotEnterAntExit(0)
        self:addChild(layer)
    end
end

function NewHandLeadLayer:ExploreLead()
    local pos_1 = self.userData.step[self.stepNum].handPos
    local size_1 = self.userData.step[self.stepNum].nextSize
    self.rect_next = cc.rect(pos_1.x - size_1.width / 2 - 30, pos_1.y - size_1.height / 2 + 40, size_1.width, size_1.height)
    self.Node_pointToSprite:setPosition(self.userData.step[self.stepNum].handPos)
    
    local size_2 = cc.size(76, 78)
    if self.stepNum == 2 then
        local pos_2 = cc.p(display.cx * 23 / 12 + 30, display.cy * 5 / 3)
        self.rect_pro = cc.rect(pos_2.x - size_2.width / 2 - 30, pos_2.y - size_2.height / 2 + 40, size_2.width, size_2.height)
    end
    
    
    
    if self.userData.step[self.stepNum].PlotSectionID ~= nil then
        ManagerTask.SectionId = self.userData.step[self.stepNum].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create()
        self:addChild(layer)
    end
end

function NewHandLeadLayer:PointAction(pos)
    self.pointToSprite:setPosition(pos)
    local jump = cc.JumpTo:create(1, pos, 30, 1)
    local action = cc.RepeatForever:create(jump)
    self.pointToSprite:stopAllActions()
    self.pointToSprite:runAction(action)
end


function NewHandLeadLayer:touchEvent()
    
    local listener = cc.EventListenerTouchOneByOne:create()

    listener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    
    listener:registerScriptHandler(function(touch, event)

    end, cc.Handler.EVENT_TOUCH_MOVED)
    
    listener:registerScriptHandler(function(touch, event)
        local stepNum = self.stepNum
        if self.userData.name == "FlyRefining" then
            if cc.rectContainsPoint(self.rect_next, touch:getLocation()) then
                self.stepNum = self.stepNum + 1
            elseif self.stepNum == 4 and cc.rectContainsPoint(self.rect_pro, touch:getLocation()) then
                self:removeFromParent()
                return
            end
            if self.stepNum == 5 then
                UserData.NewHandLead:CompleteGuide(self.userData.name)
                self:removeFromParent()
            end
        elseif self.userData.name == "FlySkillChange" then
            if cc.rectContainsPoint(self.rect_next, touch:getLocation()) then
                self.stepNum = self.stepNum + 1
            elseif cc.rectContainsPoint(self.rect_pro, touch:getLocation()) then
                if self.stepNum == 4 then
                    self:removeFromParent()
                    return
                elseif self.stepNum == 5 or self.stepNum == 6 then
                    self.stepNum = 4
                end
            end
            if self.stepNum ~= 8 then
                if stepNum ~= self.stepNum then
                    self:FlySkillChange()
                end
            else
                UserData.NewHandLead:CompleteGuide(self.userData.name)
                self.stepNum = 4
                self.userData = UserData.NewHandLead.GuideList["FlyGodChange"]
                self:FlyGodChange()
            end
        elseif self.userData.name == "FlyGodChange" then
            if cc.rectContainsPoint(self.rect_next, touch:getLocation()) then
                self.stepNum = self.stepNum + 1
            elseif cc.rectContainsPoint(self.rect_pro, touch:getLocation()) then
                if self.stepNum == 4 then
                    self:removeFromParent()
                    return
                elseif self.stepNum == 5 or self.stepNum == 6 then
                    self.stepNum = 4
                end
            end
            if self.stepNum ~= 8 then
                if stepNum ~= self.stepNum then
                    self:FlyGodChange()
                end
            else
                UserData.NewHandLead:CompleteGuide(self.userData.name)
                self.stepNum = 4
                self.userData = UserData.NewHandLead.GuideList["FlyFighting"]
                self:FlyFighting()
            end
        elseif self.userData.name == "FlyFighting" then
            if cc.rectContainsPoint(self.rect_next, touch:getLocation()) then
                self.stepNum = self.stepNum + 1
            elseif cc.rectContainsPoint(self.rect_pro, touch:getLocation()) then
                if self.stepNum == 4 then
                    self:removeFromParent()
                    return 
                end
            end
            if self.stepNum ~= 5 then
                if stepNum ~= self.stepNum then
                    self:FlyFighting()
                end
            else
                UserData.NewHandLead:CompleteGuide(self.userData.name)
                local SceneManager = require("app.views.SceneManager")
                local layer = SceneManager:getGameLayer("FlyTechTreeLayer")
                layer:removeHand()
                self:removeFromParent()
                return
            end
        elseif self.userData.name == "ExploreLead" then
            if cc.rectContainsPoint(self.rect_next, touch:getLocation()) then
                self.stepNum = self.stepNum + 1
            elseif self.stepNum ~= 1 and cc.rectContainsPoint(self.rect_pro, touch:getLocation()) then
                self.stepNum = self.stepNum - 1
            end
            if self.stepNum ~= 3 then
                if stepNum ~= self.stepNum then
                    self:ExploreLead()
                end
            else
                UserData.NewHandLead:CompleteGuide(self.userData.name)
                self:removeFromParent()
                return
            end
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.bgPanel)
end

function NewHandLeadLayer:createHandAnimation(animName)
    local SpineJson = "spine/ui/ui_shouzhi.json"
    local SpineAtlas = "spine/ui/ui_shouzhi.atlas"

    local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    skeletonNode:setAnimation(0, animName, true)
    skeletonNode:setPosition(0,0)
    return skeletonNode
end

return NewHandLeadLayer