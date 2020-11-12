local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local FlyAllViewLayer = require("app.views.FlyTechTree.FlyAllViewLayer")
local FlyRefiningLayer = require("app.views.FlyTechTree.FlyRefiningLayer")

local nowPage = nil

local FlyMainUILayer = class("FlyMainUILayer.lua",function()
    return cc.Layer:create()
end)

function FlyMainUILayer:create(flyTechId)
    local view = FlyMainUILayer.new()
    view:init(flyTechId)
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

function FlyMainUILayer:ctor()

end

function FlyMainUILayer:onEnter()

end

function FlyMainUILayer:onExit()
    nowPage = nil
end

--初始化
function FlyMainUILayer:init(flyTechId)

    local csb = cc.CSLoader:createNode("csb/Fly_UI_Layer.csb")
    self:addChild(csb)
    self.flyTechId = flyTechId
    
    local function btnTouchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            self:setButtonGray(sender)
            if sender == self.exitBtn then
                self:removeFromParent()
            else
                self:setButtonNormal(self.allviewBtn)
                self:setButtonNormal(self.flytechBtn)
                self:setButtonGray(sender)
                self:initPageLayer(sender)
            end
        end
    end
    
    local panel = csb:getChildByName("Panel")               
    self.exitBtn = panel:getChildByName("exitBtn")
    self.allviewBtn = panel:getChildByName("allviewBtn")    -- 总览按钮
    self.flytechBtn = panel:getChildByName("flytechBtn")    -- 飞宝按钮
    
    self.allViewTitle =  self.allviewBtn:getChildByName("allViewTitle")
    self.flytechTitle =  self.flytechBtn:getChildByName("flytechTitle")
    
    
        
    self.exitBtn:addTouchEventListener(btnTouchEvent)
    self.exitBtn:setPressedActionEnabled(true)
    
    self.allviewBtn:addTouchEventListener(btnTouchEvent)
    self:setButtonGray(self.allviewBtn)
    self:initPageLayer(self.allviewBtn)
    self:setTitle(self.allviewBtn)
    
    self.flytechBtn:addTouchEventListener(btnTouchEvent)
    
    if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.FlyRefining.TaskID) and UserData.NewHandLead:isPreGuideCompleted("FlyRefining") then
        if UserData.NewHandLead:getGuideState("FlySkillChange") == 0 then
            local data = {name = "FlySkillChange", order = 20, beginStep = 4}
            UserData.NewHandLead:startNewGuide(data)
        elseif UserData.NewHandLead:getGuideState("FlyGodChange") == 0 then
            local data = {name = "FlyGodChange", order = 20, beginStep = 4}
            UserData.NewHandLead:startNewGuide(data)
        elseif UserData.NewHandLead:getGuideState("FlyFighting") == 0 then
            local data = {name = "FlyFighting", order = 20, beginStep = 4}
            UserData.NewHandLead:startNewGuide(data)
        end
    end
end

function FlyMainUILayer:setButtonGray(btn)
    btn:setTouchEnabled(false)
    btn:setBright(false)
    self:setTitle(btn)
end
--设置还原
function FlyMainUILayer:setButtonNormal(btn)
    btn:setTouchEnabled(true)
    btn:setBright(true)
end

function  FlyMainUILayer:setTitle(btn)
    if btn == self.allviewBtn then
        self.allViewTitle:setTexture("ui/FlyUI/allViewTitle_1.png")
    else
        self.allViewTitle:setTexture("ui/FlyUI/allViewTitle_2.png")
    end
    if btn == self.flytechBtn then
        self.flytechTitle:setTexture("ui/FlyUI/FlyTechTitle_1.png")
    else
        self.flytechTitle:setTexture("ui/FlyUI/FlyTechTitle_2.png")
    end
    
end

function FlyMainUILayer:initPageLayer(btn)

    if btn == self.allviewBtn then
        if nowPage ~= 1 then
            self:removePage(nowPage)
            nowPage = 1
            self.flyAllViewLayer = FlyAllViewLayer:create(self.flyTechId)
            self:addChild(self.flyAllViewLayer)
        end
    elseif btn == self.flytechBtn then
        if nowPage ~= 2 then
            self:removePage(nowPage)
            nowPage = 2
            self.flyRefiningLayer = FlyRefiningLayer:create(self.flyTechId)
            self:addChild(self.flyRefiningLayer)
        end
    end
end

function FlyMainUILayer:removePage(page)
    if page == 1 then
        self.flyAllViewLayer:removeFromParent()
        
    elseif page == 2 then
        self.flyRefiningLayer:removeFromParent()
    end
end

return FlyMainUILayer