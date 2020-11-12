-- 扫荡界面
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local CleanupLayer = class("CleanUpLayer", require("app.views.View"))

function CleanupLayer:create(sectionId)
    local cleanup = CleanupLayer:new()
    cleanup:init(sectionId)
    return cleanup
end

function CleanupLayer:init(sectionId)
    
    self.sectionId = sectionId
    self.second = -1
    self.start = false
    self.duration = 3
    
    self.csb = self:createResoueceNode("csb/CleanupLayer.csb")
    local root = self.csb:getChildByName("root")
    root:setPosition(display.center)
    self.item1 = self.csb:getChildByName("item1")
    self.item2 = self.csb:getChildByName("item2")
    self.list = root:getChildByName("list")                 -- 列表容器
    self.list:setItemModel(self.item1)
    self.kuang = root:getChildByName("kuang")
    
    self.timeLabel = root:getChildByName("time")            -- 倒计时
    self.costLabel = root:getChildByName("costaction")      -- 消耗体力
    self.inputtext = root:getChildByName("inputtext")       -- 输入文本
    self.saodang = root:getChildByName("saodang")           -- 扫荡按钮
    local closebtn = root:getChildByName("closebtn")        -- 关闭按钮
    self.addbtn = root:getChildByName("addbtn")             -- 增加按钮
    self.subbtn = root:getChildByName("subbtn")             -- 减少按钮
    
    local copySection = nil
    if self.sectionId<26000 then
        copySection = StaticData.CopySection[self.sectionId]
    else
        copySection = StaticData.EliteCopySection[self.sectionId]
    end
    root:getChildByName("title"):setString(copySection.SectionName)
    
    local function onTextField(sender, type)
        if type==1  then
            self:updateCleanCount(0)
        end
    end
    self.inputtext:addEventListener(onTextField)
    
    
    local function onEventTouchButton(sender,eventType)
      
        if  eventType == cc.EventCode.ENDED     then
     
            if sender == self.saodang then
                self.list:removeAllItems()
                self.start = true          
                self:setBtnEabled(false)   
            elseif sender == closebtn then
                self:removeFromParent()
            elseif sender == self.addbtn then
               self:updateCleanCount(1)
            elseif sender == self.subbtn then
                self:updateCleanCount(-1)
            end
            
        end
    end    
    self.saodang:addTouchEventListener(onEventTouchButton)
    closebtn:addTouchEventListener(onEventTouchButton)
    self.addbtn:addTouchEventListener(onEventTouchButton)
    self.subbtn:addTouchEventListener(onEventTouchButton)
    self.addbtn:setPressedActionEnabled(true)
    self.subbtn:setPressedActionEnabled(true)
    
    self:updateCleanCount(0)
    
end

-- 更新扫荡次数
function CleanupLayer:updateCleanCount(count)
    
    local costAction = 0
    if self.sectionId<26000 then
        costAction = StaticData.CopySection[self.sectionId].CostAction
    else
        costAction = StaticData.EliteCopySection[self.sectionId].CostAction
    end
    local actionNum = UserData.BaseInfo.nAction
    local maxCount = math.floor(actionNum/costAction)
    
    local num = tonumber(self.inputtext:getString())
    if num==nil then
        num = 1
    end
    num = num + count
    if num<0 then
        num = 0 
    end
    
    if num>maxCount then
        num = maxCount
    end
    
    self.inputtext:setString(num)
    self.costLabel:setString(num * costAction)
    
    local second = num * self.duration
    self.second = second
    local min = math.floor(second / 60)
    second = second - 60 * min
    self.timeLabel:setString(string.format("%02d : %02d", min, second))
    
    if num-1 < 0 then
        self.subbtn:setColor(cc.c3b(128,128,128))
    else
        self.subbtn:setColor(cc.c3b(255,255,255))  
    end
    
    if num+1>maxCount then
        self.addbtn:setColor(cc.c3b(128,128,128))
    else    
        self.addbtn:setColor(cc.c3b(255,255,255))
    end
       
end

function CleanupLayer:onEnter()
    EventMgr:registListener(EventType.OnServerCleanUp, self, self.onServerCleanup)
    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)  
        self:update(dt)
    end, 1 ,false)
end

function CleanupLayer:onExit()
    EventMgr:unregistListener(EventType.OnServerCleanUp, self, self.onServerCleanup)
    if self.scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end
end

function CleanupLayer:onServerCleanup(event)
    
    local userdata = event._usedata
    
    if userdata.result==1 then
        return
    end
    
    local prizeId = 0
    if self.sectionId<26000 then
        prizeId = StaticData.CopySection[self.sectionId].PrizeId
    else
        prizeId = StaticData.EliteCopySection[self.sectionId].PrizeId
    end
    
    local prize = StaticData.Prize[prizeId]
    if prize==nil then
        cclog("找不到奖励：id=%d", prizeId)
        return
    end
    
    local item = nil
    local stringEx = require("common.stringEx")
    local strItems = stringEx:split(userdata.itemList, "|")
    if strItems==nil or #strItems<=0 or strItems[1]=="" then
        self.list:setItemModel(self.item2)
        self.list:pushBackDefaultItem()
        local count = #(self.list:getItems())
        item = self.list:getItem(count-1)
    else
        self.list:setItemModel(self.item1)
        self.list:pushBackDefaultItem()
        local count = #(self.list:getItems())
        item = self.list:getItem(count-1)
        
        for i=1, 3 do
            local icon = item:getChildByName("icon" .. tostring(i))
            if i<=#strItems then
                local id = tonumber(stringEx:split(strItems[i], ",")[1])
                local good = StaticData.Item[id]
                if good then
                    icon:loadTexture(good.ItemIcon)
                    icon:setVisible(true)
                else
                    icon:setVisible(false)
                end
             else
                icon:setVisible(false)
             end
        end
        
    end
    
    item:getChildByName("exp"):setString(prize.Exp)
    item:getChildByName("gold"):setString(prize.Gold)
    
    
    self.list:forceDoLayout() 
    self.list:jumpToBottom()
    
end

function CleanupLayer:update(dt)
    
    if self.start==false then
        return
    end
    
    if self.second<=0 then
        self.start = false
        self:setBtnEabled(true)
        return 
    end
    
    self.second = self.second - 1
    local second = self.second
    
    local min = math.floor(second / 60)
    second = second - 60 * min
    self.timeLabel:setString(string.format("%02d : %02d", min, second))
    
    local count = math.ceil(second/self.duration)
    self.inputtext:setString(tostring(count))
    local costAction = 0
    if self.sectionId<26000 then
        costAction = StaticData.CopySection[self.sectionId].CostAction
    else
        costAction = StaticData.EliteCopySection[self.sectionId].CostAction
    end
    self.costLabel:setString(tostring(costAction*count))

    if second%self.duration==0 then
        UserData.Pve:requestPveCleanUp(self.sectionId)
    end  
    
end

function CleanupLayer:setBtnEabled(enable)
    
    if enable==true then
        self.addbtn:setEnabled(true)
        self.subbtn:setEnabled(true)
        self.saodang:setEnabled(true)
        self.inputtext:setEnabled(true)
        self.addbtn:setColor(cc.c3b(255,255,255))
        self.subbtn:setColor(cc.c3b(255,255,255))
        self.saodang:setColor(cc.c3b(255,255,255))
        self.kuang:setColor(cc.c3b(255,255,255))
    else 
        self.addbtn:setEnabled(false)
        self.subbtn:setEnabled(false)
        self.saodang:setEnabled(false)
        self.inputtext:setEnabled(false)
        self.addbtn:setColor(cc.c3b(128,128,128))
        self.subbtn:setColor(cc.c3b(128,128,128))
        self.saodang:setColor(cc.c3b(128,128,128))
        self.kuang:setColor(cc.c3b(128,128,128))
    end
    
end


return CleanupLayer 

