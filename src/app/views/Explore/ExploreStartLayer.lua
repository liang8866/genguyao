

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local publicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local ExploreManager = require("app.views.Explore.ExploreManager")
local TimeFormat = require("common.TimeFormat")
local goodsNode = require("app.views.public.goodsNode")
local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")

local progressInfo = {}
local scheduleUpdate = nil
-- 探索开启界面
local ExploreStartLayer = class("ExploreStartLayer", function()
    return cc.Layer:create()
end)

function ExploreStartLayer:create(iExploreMapID)
    local view = ExploreStartLayer.new()
    view:init(iExploreMapID)
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

function ExploreStartLayer:ctor()

end

function ExploreStartLayer:onEnter()
    EventMgr:registListener(EventType.OnRefresh, self, self.OnRefresh)
    EventMgr:registListener(EventType.OnGetExploreInfo, self, self.OnGetExploreInfo)
    
end

function ExploreStartLayer:onExit()
    EventMgr:unregistListener(EventType.OnRefresh, self, self.OnRefresh)
    EventMgr:unregistListener(EventType.OnGetExploreInfo, self, self.OnGetExploreInfo)
    
    if scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        scheduleUpdate = nil
    end
end

function ExploreStartLayer:init(iExploreMapID)
    local visibleSize = cc.Director:getInstance():getVisibleSize()      -- 屏幕大小
    
    self.iExploreMapID = iExploreMapID
    
    local csbLayer = cc.CSLoader:createNode("csb/ExploreStartLayer.csb")
    self:addChild(csbLayer)
    
    local Panel_mark = csbLayer:getChildByName("Panel_mark")
    
    local Button_close = Panel_mark:getChildByName("Button_close")
    local Panel_content = Panel_mark:getChildByName("Panel_content")
    self.Panel_content = Panel_content
    local Sprite_bg_title = Panel_mark:getChildByName("Sprite_bg_title")
    local Sprite_text_title = Sprite_bg_title:getChildByName("Sprite_text_title")
    Sprite_text_title:setVisible(false)
    self.Text_title = Sprite_bg_title:getChildByName("Text_title")
    
--    self.Text_Name = Panel_content:getChildByName("Text_Name")
--    self.Text_Name:setVisible(false)
    self.Text_level = Panel_content:getChildByName("Text_level")  -- 推荐等级:1~10级
    self.Text_items_title = Panel_content:getChildByName("Text_items_title")  -- 本次探索将出现:/探索进度:
    self.Text_description = Panel_content:getChildByName("Text_description")
    self.LoadingBar_progress = Panel_content:getChildByName("LoadingBar_progress")
    self.Text_progress = self.LoadingBar_progress:getChildByName("Text_progress")
    self.Image_Explore_Image = Panel_content:getChildByName("Image_Explore_Image")
    
    local Button_begin = Panel_content:getChildByName("Button_begin")
    local Button_fresh = Panel_content:getChildByName("Button_fresh")
    
    --描边
    local Text_begin = Button_begin:getChildByName("Text_1")
    local Text_fresh = Button_fresh:getChildByName("Text_1")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_begin)    
    outLineLable:setTexOutLine(Text_fresh)
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("ExploreStartLayer onEventTouchButton,name = "  .. senderName)
            if senderName == "Button_close" then
                self:removeFromParent()
            elseif senderName == "Button_begin" then
                local layer = require("app.views.Explore.ExploreLayer"):create(self.iExploreMapID)
                local SceneManager = require("app.views.SceneManager")
                self:removeFromParent()
                SceneManager:addToGameScene(layer, 9)
            elseif senderName == "Button_fresh" then
                local isFreeRefresh = ExploreManager:isFreeRefresh(self.iExploreMapID)
                cclog("isFreeRefresh = " .. tostring(isFreeRefresh))
                UserData.Explore:sendRefreshExploreMap(self.iExploreMapID,isFreeRefresh)
            end
        end
    end
    Button_close:setTouchEnabled(true)
    Button_close:addTouchEventListener(onEventTouchButton)
    Button_close:setPressedActionEnabled(true)
    
    Button_begin:setTouchEnabled(true)
    Button_begin:addTouchEventListener(onEventTouchButton)
    Button_begin:setPressedActionEnabled(true)
    
    Button_fresh:setTouchEnabled(true)
    Button_fresh:addTouchEventListener(onEventTouchButton)
    Button_fresh:setPressedActionEnabled(true)
    
    local Panel_left = Panel_content:getChildByName("Panel_left")
    self.Panel_left = Panel_left
    self.ScrollView_1 = Panel_left:getChildByName("ScrollView_1")
    self.Panel_item_mode = Panel_content:getChildByName("Panel_item_mode")
    self.Panel_item_mode:setVisible(false)
    
    local Panel_page = self.Panel_left:getChildByName("Panel_page")
    Panel_page:setVisible(false)
--    local ExploreProgressNode = cc.CSLoader:createNode("csb/ExploreProgressNode.csb")
    --    self.ScrollView_1 = ExploreProgressNode:getChildByName("ScrollView_1")
    --    self.Panel_item_mode = ExploreProgressNode:getChildByName("Panel_item_mode")
    --    self.Panel_ScrollView_Area:addChild(self.ScrollView_1)

    self:initExploreInfo()
    
    self.publicTipLayer = publicTipLayer:create()
    self:addChild(self.publicTipLayer)
    
    self.remainTime = 0
    scheduleUpdate = nil
    UserData.Explore.sendGetExploreInfo()
end



function ExploreStartLayer:initExploreInfo()
    local mapStaticInfo = StaticData.Map[self.iExploreMapID]
    if mapStaticInfo == nil then return end
    
--    self.Text_Name:setString(mapStaticInfo.ExploreName)
    self.Text_title:setString("探索∙" .. mapStaticInfo.ExploreName)
    self.Text_level:setString(mapStaticInfo.Recommend) 
    --self.Text_items_title:setString("探索进度:")
    self.Text_description:setString(mapStaticInfo.Des)

    --self.LoadingBar_progress
    --self.Text_progress
    local iconID = tonumber(mapStaticInfo.ExploreImage)
    local imagePath = StaticData.Icon[iconID].path
    self.Image_Explore_Image:loadTexture(imagePath)

    -- Type="1-2|2-1|3-1|4-1|5-1|6-1", Type2="7-2-1000-2|8-3-2000-5|9-1-5000-10"
    -- Type="类型数量,1箱子,2事件,3塔,4传送,5交易npc,6商店npc",Type2="7大宝1,8大宝2,9大宝3（类型-数量-概率-必出次数）
    local stringEx = require("common.stringEx")
    local items = string.split(mapStaticInfo.GetGoods,"|")
    --local items = stringEx:splitPrizeItemsStr(mapStaticInfo.Type)

    local ShowNumList = stringEx:splitPrizeItemsStr(mapStaticInfo.ShowNum)  -- ShowNum="1-5|2-2|8-1|9-1|10-1"
    local ShowNum = {}
    for i=1,#ShowNumList do
        ShowNum[tonumber(ShowNumList[i][1])] = tonumber(ShowNumList[i][2])
    end
    
    
    --先计算滚动列表高度
    local szScrollView = self.ScrollView_1:getContentSize()
    local column_num = table.nums(items)  --列数
    local row_num = 1 -- math.ceil(table.nums(items)/column_num) -- 行数

    local SCROLL_ITEM_SIZE = self.Panel_item_mode:getContentSize()
    
    --local totalHeight = SCROLL_ITEM_SIZE.height * row_num
    --totalHeight = (totalHeight < szScrollView.height) and szScrollView.height or totalHeight    
    local totalWidth = SCROLL_ITEM_SIZE.width * column_num
    totalWidth = (totalWidth < szScrollView.width) and szScrollView.width or totalWidth
    self.ScrollView_1:setInnerContainerSize(cc.size(totalWidth,szScrollView.height))
    --local iconTable = ExploreManager:getItemsIconTable(self.iExploreMapID)

--[[
    progressInfo = {}
    for j=1,row_num do  --列循环
        for i=1,column_num do --行循环
            local index = column_num*(j-1) + i
            if items[index] == nil then 
                break
            end
            local itemType = tonumber(items[index][1])
            local limitNum = tonumber(items[index][2])
            if limitNum ~= 0  and ShowNum[itemType] ~= nil then
                limitNum = tonumber(ShowNum[itemType])
            end
            local panel_item = self:createItem(itemType,limitNum,self.ScrollView_1)
            if panel_item ~= nil then
                local x= (i-1)*SCROLL_ITEM_SIZE.width
                local y= totalHeight - (j-1)*SCROLL_ITEM_SIZE.height
                panel_item:setPosition(cc.p(x,y-SCROLL_ITEM_SIZE.height))
            
                local iconPath = ExploreManager:getExploreItemIconPath(iconTable,itemType)
                progressInfo[itemType].Image_icon:loadTexture(iconPath)
            end
        end
    end
]]
    for i=1,column_num do  
        local itemID = tonumber(items[i])
        local itemInfo = StaticData.Item[itemID]
        if itemInfo == nil then
            cclog("item not exist ,itemID = %d",itemID)
        else
            
            local panel_item = self:createItemExtra(itemID,self.ScrollView_1)
            
            if panel_item ~= nil then
                local x= (i-1)*SCROLL_ITEM_SIZE.width
                panel_item:setPosition(cc.p(x,30))
            end
        end
    end
   

    local Panel_right = self.Panel_content:getChildByName("Panel_right")
    self.Text_item_num_need = Panel_right:getChildByName("Text_item_num_need")
    self.Sprite_item_fresh = Panel_right:getChildByName("Sprite_item_fresh")
    self.Text_tips_1 = Panel_right:getChildByName("Text_tips_1")
    self.Text_tips_time = Panel_right:getChildByName("Text_tips_time")
    self.Text_item_num_need:setVisible(false)
    self.Sprite_item_fresh:setVisible(false)
    self.Text_tips_1:setVisible(false)
    self.Text_tips_time:setVisible(false)
    
    
    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            print(sender:getTag())
            local goodsNum = UserData.Bag.items[sender:getTag()]
            local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
            self:addChild(flyMakeMatLayer)
        end
    end
    local item_fresh = goodsNode:create(710001)
    item_fresh:setScale(0.7)
    self.Sprite_item_fresh:addChild(item_fresh)
    item_fresh:setTag(710001)
    item_fresh:btnEvent(touchEvent)
    
    
    for i=1,3 do
        local type = i - 1 + ExploreEnum.BigBox 
        local Panel_item_index = Panel_right:getChildByName("Panel_item_" .. tostring(i))
        progressInfo[type] = {}
        progressInfo[type].Text_num = Panel_item_index:getChildByName("Text_num")
--        progressInfo[type].Image_icon = Panel_item_index:getChildByName("Image_icon")
        progressInfo[type].Panel_item = Panel_item_index
        progressInfo[type].desNum = 0
        progressInfo[type].Panel_item:setVisible(false)
    end

    local itemIDTab = string.split(mapStaticInfo.XiYouGoods,"|")
    local items2 = stringEx:splitPrizeItemsStr(mapStaticInfo.Type2)
    if table.nums(itemIDTab) ~= table.nums(items2) then
        cclog("excel data is error, %s 's length is not equal %s 's lenth ",mapStaticInfo.Type2,mapStaticInfo.XiYouGoods)
        return
    end
         
    for i=1,#items2 do 
        local itemID = tonumber(itemIDTab[i])
        local itemInfo = StaticData.Item[itemID]
        if itemInfo == nil then
            cclog("excel data is error,item is not exist ,itemID = %d",itemID)
        else
            local type = tonumber(items2[i][1])
            local numExist = tonumber(items2[i][4])
            local num = tonumber(items2[i][2])
            local limitNum = tonumber(items2[i][2])
            if progressInfo[type] ~= nil then
                if limitNum ~= 0 and ShowNum[type] ~= nil then
                    limitNum = tonumber(ShowNum[type])
                end
                local function touchEvent(sender, eventType)
                    if eventType == cc.EventCode.ENDED then
                        print(sender:getTag())
                        local goodsNum = UserData.Bag.items[sender:getTag()]
                        local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
                        self:addChild(flyMakeMatLayer)
                    end
                end

             
                progressInfo[type].desNum = limitNum
                progressInfo[type].numExist = numExist
                progressInfo[type].Panel_item:setVisible(true)
                local size = progressInfo[type].Panel_item:getContentSize()
                --local iconPath = ExploreManager:getExploreItemIconPath(iconTable,type)
--                progressInfo[type].Image_icon:loadTexture(itemInfo.ItemIcon)
                local goods = goodsNode:create(itemID, nil, true)
                goods:setTag(itemID)
                goods:btnEvent(touchEvent)
                progressInfo[type].Panel_item:addChild(goods)
                progressInfo[type].Text_num:setString("再刷" .. tostring(numExist) .. "次必出")
            end
        end
    end

end

function ExploreStartLayer:createItemExtra(itemID,parent)

    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            print(sender:getTag())
            local goodsNum = UserData.Bag.items[sender:getTag()]
            local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
            self:addChild(flyMakeMatLayer)
        end
    end

    local itemWnd = goodsNode:create(itemID, nil, true)
    itemWnd:setTag(itemID )
    itemWnd:btnEvent(touchEvent)
    parent:addChild(itemWnd)
    itemWnd:setVisible(true)
    return itemWnd
end

function ExploreStartLayer:createItem(type,num,parent)
    progressInfo[type] = {}
    if self.Panel_item_mode ~= nil then
        local itemWnd = self.Panel_item_mode:clone()
--        local Image_icon = itemWnd:getChildByName("Image_icon")
--        progressInfo[type].Image_icon = Image_icon
        progressInfo[type].Panel_item = itemWnd
        progressInfo[type].desNum = num
        
        --progressInfo[type].Image_icon:loadTexture("ui/Explore/icon_Explore_3.png")
        --progressInfo[type].Text_num:setString( "0/" .. tostring(num))
        parent:addChild(itemWnd)
        itemWnd:setVisible(true)
        return itemWnd
    end
    return nil
end

function ExploreStartLayer:updateProgressInfo()
    local exploreMapData = UserData.Explore.map[self.iExploreMapID]
    local exploreStaticData = StaticData.Map[self.iExploreMapID]
    --local iconTable = ExploreManager:getItemsIconTable(self.iExploreMapID)
    local freshNum = exploreMapData[ExploreEnum.Refresh] -- 当前的刷新次数

    local num,total = ExploreManager:getCurrentProgress(self.iExploreMapID)
    self.Text_progress:setString(string.format("%.1f%%",num/total*100))
    self.LoadingBar_progress:setPercent(num/total) 
    --[[
    for i=1,ExploreEnum.TaskNPC do  -- 7种类型
    local num = exploreMapData ~= nil and exploreMapData[i] or 0
    progressInfo[i].Text_num:setString(tostring(num) .. "/" .. tostring(progressInfo[i].desNum) )
    local iconPath = ExploreManager:getExploreItemIconPath(iconTable,i)
    progressInfo[i].Image_icon:loadTexture(iconPath)
    end
    ]]
    -- ExploreEnum.TaskNPC 不显示出来
    local itemIDTab = string.split(exploreStaticData.XiYouGoods,"|")
    for i=1,table.nums(itemIDTab) do 
        local type = i - 1 + ExploreEnum.BigBox 
        local num = exploreMapData ~= nil and exploreMapData[type] or 0
        local needNum = progressInfo[type].numExist - freshNum
        local itemID = tonumber(itemIDTab[i])
        local itemInfo = StaticData.Item[itemID]
        if num >= 111 then --未刷出来
            progressInfo[type].Text_num:setString("再刷" .. tostring(needNum) .. "次必出")
        else
            if num >= 0 then
                local curNum = progressInfo[type].desNum - num
                curNum = curNum >= 0 and curNum or 0
                progressInfo[type].Text_num:setString("已出现")
--                progressInfo[type].Text_num:setString(tostring(curNum) .. "/" .. tostring(progressInfo[type].desNum) )
            end
        end
        
        --local iconPath = ExploreManager:getExploreItemIconPath(iconTable,i)
--        progressInfo[type].Image_icon:loadTexture(itemInfo.ItemIcon)
    end
    
    local duration = TimeFormat:getSecondsInter(exploreMapData[ExploreEnum.Time])
    duration = duration < 0 and 0 or duration
    local isTimeFull = duration > exploreStaticData.time/1000 
    if isTimeFull then -- 未刷新过，或当前有一次免费机会
        self.Text_tips_1:setVisible(true)
        self.Text_item_num_need:setVisible(false)
        self.Sprite_item_fresh:setVisible(false)
        self.Text_tips_time:setVisible(false)
    else
        self.Text_tips_1:setVisible(false)
        self.Text_item_num_need:setVisible(true)
        self.Sprite_item_fresh:setVisible(true)
        self.Text_tips_time:setVisible(true)  
        local ItemManager = require("app.views.ItemManager")
        local itemID = StaticData.SystemParam['PlaceSymbolID'].IntValue
        local itemNum = StaticData.SystemParam['CostPlaceSymbol'].IntValue
        local itemhave = ItemManager:getItemNum(itemID)
        self.Text_item_num_need:setString(tostring(itemhave) .. "/" .. tostring(itemNum))
        --        local leftTimeStr = TimeFormat:getSecondsInterFromMark(exploreMapData[ExploreEnum.Time])
--        self.Text_tips_time:setString(leftTimeStr .. "后可免费刷新")
    end

    
    --if duration <= exploreStaticData.time/1000 then
        self.remainTime = (duration >= exploreStaticData.time/1000) and 0 or exploreStaticData.time/1000 - duration

        if scheduleUpdate ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
            scheduleUpdate = nil
        end
        if self.remainTime > 0 then
            scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
                self:updateTimer(dt)
            end, 1 ,false)
        end
    --end
end


function ExploreStartLayer:OnRefresh(eventData)
    local data = eventData._usedata
    local mapID = data.nMapID   -- 地图ID
    local byRes = data.byRes    -- 0:成功,1:该地图未开 2:乾坤符不足，3:当前非免费刷新时间
    if byRes == 1 then
        self.publicTipLayer:setTextAction("该地图未解锁！")
    elseif byRes == 2 then
        self.publicTipLayer:setTextAction("乾坤符不足！")
    elseif byRes == 0 then
        self.publicTipLayer:setTextAction("刷新成功！")
        self:updateProgressInfo()
    end
end

function ExploreStartLayer:OnGetExploreInfo(eventData)
    local userdata = eventData._usedata
    local exploreStaticData = StaticData.Map[self.iExploreMapID]
    if userdata[self.iExploreMapID] == nil then 
    
        require("user_data.UserData_Explore")
        local map = {}
        map[ExploreEnum.Box]                    = 0          -- 1、当前关卡开的箱子个数
        map[ExploreEnum.Event]                  = 0          -- 2、当前关卡开的事件个数
        map[ExploreEnum.Tower]                  = 0          -- 3、当前关卡开的塔个数
        map[ExploreEnum.Tp]                     = 0          -- 4、当前传送个数
        map[ExploreEnum.ChangeNPC]              = 0          -- 5、当前关卡遇到商店NPC个数
        map[ExploreEnum.StorNPC]                = 0          -- 6、当前关卡遇交易NPC个数
        map[ExploreEnum.TaskNPC]                = 0          -- 7、当前关卡遇到任务NPC个数
        map[ExploreEnum.BigBox]                 = 111        -- 8、当前关卡剩余大箱子个数
        map[ExploreEnum.Crystal]                = 111        -- 9、当前关卡剩余水晶箱子个数
        map[ExploreEnum.Jewel]                  = 111        -- 10、当前关卡剩余钻石箱子个数
        map[ExploreEnum.Refresh]                = 0          -- 11、已经刷新次数
        map[ExploreEnum.Through]                = 0          -- 12、是否通关   0：未通关，1：通关 
        map[ExploreEnum.Time]                   = "0-0-0 0:0:0"         -- 13、上次免费刷新时间
        UserData.Explore.map[self.iExploreMapID] = map
    end
    self:updateProgressInfo()
    
    
end


function ExploreStartLayer:updateTimer(dt)

    self.remainTime = self.remainTime - dt

    if self.remainTime <= 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        scheduleUpdate = nil
        
        self.Text_tips_1:setVisible(true)
        self.Text_item_num_need:setVisible(false)
        self.Sprite_item_fresh:setVisible(false)
        self.Text_tips_time:setVisible(false)
        self.remainTime = 0
        return
    end
    
    local nh, nm, ns = TimeFormat:getHMS(math.floor(self.remainTime))
    self.Text_tips_time:setString(string.format("(%02d:%02d:%02d)",nh, nm,ns))
    
end

return ExploreStartLayer
