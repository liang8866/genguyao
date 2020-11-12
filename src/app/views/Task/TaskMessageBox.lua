
require("cocos/cocos2d/bitExtend.lua")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local goodsNode = require("app.views.public.goodsNode")


local taskMessageBoxUI = {
    begin = {},
    finish = {},
    currentTaskID = 0,
}  -- 保存ui中的控件


local TaskMessageBox = class("TaskMessageBox", function()
    return cc.Node:create()
end)

function TaskMessageBox:create()
    local node = TaskMessageBox.new()
    node:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            node:onEnter() 
        elseif eventType == "exit" then
            node:onExit() 
        end  
    end  
    node:registerScriptHandler(onEventHandler)
    return node
end

function TaskMessageBox:ctor()
end

function TaskMessageBox:onEnter()
end

function TaskMessageBox:onExit()
    
    taskMessageBoxUI.currentTaskID = 0
end

function TaskMessageBox:init()
    local node =  cc.CSLoader:createNode("csb/TaskMessageBoxLayer.csb")
    self:addChild(node)
    
    local Panel_root = node:getChildByName("Panel_root")
    self.Panel_root = Panel_root
        
    -- begin ui
    local Node_taskBegin = Panel_root:getChildByName("Node_taskBegin")
    local Text_taskDescription = Node_taskBegin:getChildByName("Text_taskDescription")
    local Panel_require = Node_taskBegin:getChildByName("Panel_require")
    local Text_power = Panel_require:getChildByName("Text_power")
    local Button_cancel = Node_taskBegin:getChildByName("Button_cancel")
    Button_cancel:setTouchEnabled(true)
    Button_cancel:setPressedActionEnabled(true)
    Button_cancel:addTouchEventListener(
        function (sender,eventType)
            if eventType == cc.EventCode.ENDED then
                cclog("Button_cancel clicked 11" )
                if self:getParent() ~= nil then
                    self:getParent():removeChild(self)
                end
                taskMessageBoxUI.currentTaskID = 0
            end
        end)
    local Button_enterFight = Node_taskBegin:getChildByName("Button_enterFight")
    Button_enterFight:setTouchEnabled(true)
    Button_enterFight:setPressedActionEnabled(true)
    
    local function OnEnterFightButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("Button_enterFight clicked taskID=" .. tostring(taskMessageBoxUI.currentTaskID) )
            -- 任务战斗前的数据获取
            local ManagerTask = require("app.views.Task.ManagerTask")
            local MyFightingCtrl = require("app.views.MyFighting.MyFightingCtrl")
            local npcId = ManagerTask:GetTaskNpcID(taskMessageBoxUI.currentTaskID)
            
            local needCostAction = StaticData.Npc[npcId].TiLi -- 需要的体力
            if needCostAction > UserData.BaseInfo.nAction then
                local publicTipLayer = require("app/views/public/publicTipLayer")
                publicTipLayer:setTextAction("体力不足")
            else
                UserData.BaseInfo:setCostAction(needCostAction) --请求体力消耗    

                MyFightingCtrl:getFightingFibbleGodData(npcId)
                UserData.BaseInfo.myFightTaskId = tonumber(taskMessageBoxUI.currentTaskID) -- 记录战斗是任务的
                if self:getParent() ~= nil then
                    self:getParent():removeChild(self)
                end
                local SceneManager = require("app.views.SceneManager")
                local myFightingLayer = require("app.views.MyFighting.MyFightingLayer"):create()
                SceneManager:addToGameScene(myFightingLayer, 100)

                taskMessageBoxUI.currentTaskID = 0

            end
            
            
            
            
         
        end
    end
    Button_enterFight:addTouchEventListener(OnEnterFightButtonClicked)
    
    local beginUITable = {}
    beginUITable.root = Node_taskBegin
    beginUITable.Text_taskDescription = Text_taskDescription
    beginUITable.Text_power = Text_power
    taskMessageBoxUI.begin = beginUITable
    
    
    -- finish ui
    local Node_taskFinish =  Panel_root:getChildByName("Node_taskFinish")
    
    local Button_close = Node_taskFinish:getChildByName("Button_close")
    Button_close:setTouchEnabled(false)
    Button_close:setPressedActionEnabled(true)
    local function onCloseButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            if self:getParent() ~= nil then
                self:getParent():removeChild(self)
            end
        end
    end
    Button_close:addTouchEventListener(onCloseButtonClicked)
    Button_close:setVisible(false)
    
    local Text_taskName = Node_taskFinish:getChildByName("Text_taskName")
    local Text_taskState = Node_taskFinish:getChildByName("Text_taskState")
    
    local Panel_reward = Node_taskFinish:getChildByName("Panel_reward")
    local Text_exp = Panel_reward:getChildByName("Text_exp")
    local Text_money = Panel_reward:getChildByName("Text_money")
    local Sprite_exp = Panel_reward:getChildByName("Sprite_exp")
    local Sprite_money = Panel_reward:getChildByName("Sprite_money")
    
    local Button_OK = Node_taskFinish:getChildByName("Button_OK")
    Button_OK:setTouchEnabled(true)
    Button_OK:setPressedActionEnabled(true)
    
    local ScrollView = Panel_reward:getChildByName("ScrollView_1")
    
    local function OnOKButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("Button_OK clicked 11" )
            if taskMessageBoxUI.currentTaskID > 0 then
               
                local function callback()

                    -- 发送请求完成任务消息
                    local ManagerTask = require("app.views.Task.ManagerTask")
                    local taskType = ManagerTask:getTaskType(taskMessageBoxUI.currentTaskID)
                    UserData.Task:sendFinishTask(taskMessageBoxUI.currentTaskID,taskType)

                    if self:getParent() ~= nil then
                        self:getParent():removeChild(self)
                    end
                    taskMessageBoxUI.currentTaskID = 0
                end
                
                local delay = cc.DelayTime:create(0.5)      
                local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
                self:runAction(sequence)
                
            end
        end
    end
    Button_OK:addTouchEventListener(OnOKButtonClicked)
    

    local finishUITable = {}
    finishUITable.root = Node_taskFinish
    finishUITable.Text_taskName = Text_taskName
    finishUITable.Text_taskState = Text_taskState
    finishUITable.Text_exp = Text_exp
    finishUITable.Text_money = Text_money
    finishUITable.Sprite_exp = Sprite_exp
    finishUITable.Sprite_money = Sprite_money
    finishUITable.ScrollView = ScrollView
    
    finishUITable.rewardGoods_image = {}
    finishUITable.rewardGoods_text = {}
    for i=1,4 do
        finishUITable.rewardGoods_image[i] = Panel_reward:getChildByName("rewardGoods_" .. tostring(i))
        finishUITable.rewardGoods_text[i] = Panel_reward:getChildByName("Text_rewardGoods_num_" .. tostring(i))
    end
    
    taskMessageBoxUI.finish = finishUITable
    
    
    -- 对字体进行描边
    local Text_OK = Button_OK:getChildByName("Text_1_0")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_OK)     
   
end

function TaskMessageBox:scheduleUpdate()

end

function TaskMessageBox:ShowTaskBeginMessageBox(taskID)
    taskMessageBoxUI.currentTaskID = taskID
    if taskMessageBoxUI.finish.root ~= nil then
        taskMessageBoxUI.finish.root:setVisible(false)
    end
    if taskMessageBoxUI.begin.root ~= nil then
        taskMessageBoxUI.begin.root:setVisible(true)

    end
    
    local npcId = ManagerTask:GetTaskNpcID(taskID)
    local npcInfo = StaticData.Npc[tonumber(npcId)]
    
    cclog("ShowTaskBeginMessageBox: taskID = " .. tostring(taskID))
    local ManagerTask = require("app.views.Task.ManagerTask")
    taskMessageBoxUI.begin.Text_taskDescription:setString( npcInfo ~= nil and npcInfo.Desc or "")
    taskMessageBoxUI.begin.Text_power:setString(tostring(ManagerTask:getTaskNeedPower(taskID)))
    
end

function TaskMessageBox:ShowTaskFinishMessageBox(taskID)
    taskMessageBoxUI.currentTaskID = taskID
    if taskMessageBoxUI.begin.root ~= nil then
        taskMessageBoxUI.begin.root:setVisible(false)
    end
    if taskMessageBoxUI.finish.root ~= nil then
        taskMessageBoxUI.finish.root:setVisible(true)
    
    end
    cclog("ShowTaskFinishMessageBox: taskID = " .. tostring(taskID))
    local ManagerTask = require("app.views.Task.ManagerTask")
    local taskInfo = ManagerTask:getTaskInfo(taskID)
    local prizeId = taskInfo.PrizeID
    local prizeInfo = StaticData.Prize[prizeId]
    taskMessageBoxUI.finish.Text_taskName:setString(taskInfo.TaskName)
    local parentPosX, parentPosY = taskMessageBoxUI.finish.root:getPosition()
    local posX,posY = taskMessageBoxUI.finish.Text_taskName:getPosition()
    local sz = taskMessageBoxUI.finish.Text_taskName:getContentSize()
    taskMessageBoxUI.finish.Text_taskState:setString("[完成]")
    local newPosX =  sz.width/2 - 30
    taskMessageBoxUI.finish.Text_taskName:setPosition(cc.p( newPosX, posY))
    taskMessageBoxUI.finish.Text_taskState:setPosition(cc.p(newPosX +10,posY))
    
    if prizeInfo.Exp > 0 then  -- 经验
        taskMessageBoxUI.finish.Text_exp:setVisible(true)
        taskMessageBoxUI.finish.Text_exp:setString(tostring(prizeInfo.Exp))
        taskMessageBoxUI.finish.Sprite_exp:setVisible(true)
        taskMessageBoxUI.finish.Sprite_exp:setTexture("ui/public/public_other_30.png")
    else
        taskMessageBoxUI.finish.Text_exp:setVisible(false)
        taskMessageBoxUI.finish.Sprite_exp:setVisible(false)
    end
    if prizeInfo.Gold > 0 then -- 金币奖励
        taskMessageBoxUI.finish.Text_money:setVisible(true)
        taskMessageBoxUI.finish.Text_money:setString(tostring(prizeInfo.Gold))
        taskMessageBoxUI.finish.Sprite_money:setVisible(true)
        taskMessageBoxUI.finish.Sprite_money:setTexture("ui/public/public_other_26.png")
    else
        taskMessageBoxUI.finish.Text_money:setVisible(false)
        taskMessageBoxUI.finish.Sprite_money:setVisible(false)
    end
 
    for i = 1,4 do
        taskMessageBoxUI.finish.rewardGoods_image[i]:setVisible(false)
        taskMessageBoxUI.finish.rewardGoods_text[i]:setVisible(false)
    end 
    
    if prizeInfo.Items ~= nil and prizeInfo.Items ~= "" then --物品奖励  --格式: 711001-2|712001-3
        local stringEx = require("common.stringEx")
        local itemsTab = stringEx:splitPrizeItemsStr(prizeInfo.Items)
        
        local function touchEvent(sender, eventType)
            if eventType == cc.EventCode.ENDED then
                print(sender:getTag())
                local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
                local goodsNum = UserData.Bag.items[sender:getTag()]
                local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
                local SceneManager = require("app.views.SceneManager")  
                local layer = SceneManager:getGameLayer("TaskMessageBox")
                layer:addChild(flyMakeMatLayer)
            end
        end
        
        for i=1, #itemsTab do
            local layout = ccui.Layout:create()
            layout:setEnabled(true)

            local id = itemsTab[i][1]
            local num = itemsTab[i][2]
            local prizeNode = goodsNode:create(tonumber(id),tonumber(num))
            prizeNode:btnEvent(touchEvent)

            layout:addChild(prizeNode)           
            taskMessageBoxUI.finish.ScrollView:addChild(layout) 
            
            local size = taskMessageBoxUI.finish.ScrollView:getContentSize()
            local x = (i-1)* size.height
            layout:setPosition(cc.p(x,0))
  
--[[        
            local itemID = tonumber(itemsTab[i][1])
            local itemNum = tonumber(itemsTab[i][2])

            taskMessageBoxUI.finish.rewardGoods_image[i]:setVisible(true)
            taskMessageBoxUI.finish.rewardGoods_text[i]:setVisible(true)

            local itemStaticInfo = StaticData.Item[itemID]
            if itemStaticInfo ~= nil then
                taskMessageBoxUI.finish.rewardGoods_image[i]:setTexture(itemStaticInfo.ItemIcon)
                taskMessageBoxUI.finish.rewardGoods_text[i]:setString(tostring(itemNum))                                
            end
--]]            
        end
    end

end

return TaskMessageBox