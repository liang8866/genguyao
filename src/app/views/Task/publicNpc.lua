local stringEx = require("common.stringEx")



local publicNpc = class("publicNpc", function()
    return cc.Node:create()
end)


function publicNpc:create(taskID,npcId,callback)
    
    local view = publicNpc.new()
    view:init(taskID,npcId,callback)
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

function publicNpc:onCreate()


end

function publicNpc:onEnter()

end


function publicNpc:onExit()
    if self.myScheduleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
    end

end


function publicNpc:init(taskID,npcId,callback)
    self.npcId = npcId
    self.taskID = taskID --一个任务对应多个NPC
    self.myScale = 1.0
    if  StaticData.Npc[npcId] == nil then
    	print("数据读取出错")
    	
    end                                                 
    self.npcData = StaticData.Npc[npcId] --获取对应的NPC数据
    if self.npcData.Image == "" and self.npcData.SpineName == "" then
    	return
    end
    self.callback = callback
    if self.npcData.Image ~= "" then
        self.mySpine = cc.Sprite:create(self.npcData.Image)
        self.BoxSize = self.mySpine:getBoundingBox()
        self.myScale = 80/self.BoxSize.width
    elseif self.npcData.SpineName ~= "" then
        local SpineJson = self.npcData.SpineName..".json"
        local SpineAtlas = self.npcData.SpineName..".atlas"
        if self.npcData.SpineName == nil then
            print("骨骼数据读取出错")
        end
        self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        self.mySpine:setAnimation(0, "load", true)
        self.mySpine.timeScale = math.random(600,1000)/1000
    end
    self.mySpine:setScale(self.myScale)
    self.mySpine:setPosition(0,0)
    self:addChild(self.mySpine)
    self.myScheduleUpdateId = nil
    --获取大小是有延迟的
    local function callback1()
        self:createTouchForPress() 
        --self:showMyselfWord()
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(callback1))
    self:runAction(seq)
   

end

--创建触摸事件
function publicNpc:createTouchForPress() 
    --获取骨骼的大小是有延迟的
    self.BoxSize = self.mySpine:getBoundingBox()
--    dump(self.BoxSize)
    local function touchEvent(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            print("开始调用对话")
            local isNotInTown = StaticData.Task[self.taskID].CityType == 0
            if isNotInTown then 
                local posX,posY = self:getPosition()
                local StageMapLayer = require("app.views.StageMap.StageMapLayer")
                local result = StageMapLayer:MoveToNpc(cc.p(posX,posY))
                if result then
                    return
                end
            end
            if self.callback then
                local data = {npcId = self.npcId,taskID=self.taskID}
                self.callback(data)
            end
            if self.taskID ~= nil and StaticData.Task[self.taskID] ~= nil then
                local StageMapLayer = require("app.views.StageMap.StageMapLayer")
                StageMapLayer:onClickedTaskNpc(self.taskID,self:getParent())
            end
        end
    end         

    local button = ccui.Button:create()
    button:setOpacity(0)
    button:setTouchEnabled(true)
    button:setScale9Enabled(true)
    button:loadTextures("ui/public/public_btn_01.png", "ui/public/public_btn_01.png", "ui/public/public_btn_01.png")
    button:setPosition(cc.p(0,0))
    local w,h = self.BoxSize.width, self.BoxSize.height
    w = w < 120 and 120 or w
    h = h < 120 and 120 or h
    button:setContentSize(cc.size(w, h))
    button:addTouchEventListener(touchEvent)
    self:addChild(button)
end

--显示自言自语的
function publicNpc:showMyselfWord()
	
	--获取所有的自然自语内容的ID
    local strIdTable  = stringEx:split(self.npcData.DialogId,"|")
	local wordData = {}
    local count = 1 --计算
	--存储起来，按顺序
    for i=1, #strIdTable do
        table.insert(wordData,StaticData.taskMonsterDialog[tonumber(strIdTable[i])])
	end
    
    if self.myScheduleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
    end
    
--    self._displayValueLabel = ccui.Text:create("", "Arial", 14)
    self.labelBg = ccui.ImageView:create()
    self.labelBg:loadTexture("ui/public/bgLabel.png")
    self.labelBg:setScale9Enabled(true)
    self:addChild(self.labelBg)
    self.labelBg:setPosition(cc.p(0, self.BoxSize.height + 20))
    
    self._displayValueLabel = cc.LabelTTF:create("", "Arial", 14)
    self._displayValueLabel:setString(wordData[count].content)
    self._displayValueLabel:setFontSize(14)
    self._displayValueLabel:setColor(cc.c3b(0,0,0))
    self._displayValueLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self._displayValueLabel:setDimensions(cc.size(160,00))
    self._displayValueLabel:setHorizontalAlignment(0)--左中友
    self._displayValueLabel:setVerticalAlignment(1)--上中下

    self.labelBg:addChild(self._displayValueLabel)
    
    local size = self._displayValueLabel:getContentSize()
    local bgSize = cc.size(size.width + 10, size.height + 20)
    self.labelBg:setContentSize(bgSize)
    self._displayValueLabel:setPosition(bgSize.width / 2, bgSize.height / 2)
    
    
    -- 定义一个定时器
    count = math.random(1,#wordData)
    local function myupdate(dt)
        count = count + 1
        if count > #wordData then
            count = 1
        end
        self._displayValueLabel:setString(wordData[count].content)
        
        local size = self._displayValueLabel:getContentSize()
        local bgSize = cc.size(size.width + 10, size.height + 20)
        self.labelBg:setContentSize(bgSize)
        self._displayValueLabel:setPosition(bgSize.width / 2, bgSize.height / 2)
    end   
    local t = math.random(500,1000)/100
    self.myScheduleUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(myupdate,t  ,false)
  
	
end




return publicNpc