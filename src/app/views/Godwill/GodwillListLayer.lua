local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local GodwillManager = require("app.views.Godwill.GodwillManager")
local ItemManager =  require("src.app.views.ItemManager")
local publicTipLayer = require("app/views/public/publicTipLayer")

local rootNode = nil    --根节点 
local SEPERATE_SPACE_HEIGHT = 100  -- 中间分隔条所占区域的高度
local SCROLL_ITEM_SIZE =  cc.size(300,120)  --单个滚动item的尺寸
local starImage = {"ui/FlyUI/xing1.png","ui/FlyUI/xing2.png","ui/FlyUI/xing3.png","ui/FlyUI/xing4.png","ui/FlyUI/xing5.png",}
local guideSelectedItemInfo = {}

local GodwillListLayer = class("GodwillListLayer", function()
    return ccui.Layout:create()
end)

function GodwillListLayer:create()
    local view = GodwillListLayer.new()
    view:init()
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

function GodwillListLayer:ctor()

end

function GodwillListLayer:onEnter()
    EventMgr:registListener(EventType.OnCreateGod, self, self.OnCreateGod)                       -- 服务端返回合成神将信息
    EventMgr:registListener(EventType.OnGodLevelUp, self, self.OnGodLevelUp)                     -- 服务端返回神将提升星级请求
    EventMgr:registListener(EventType.OnGodStarUp, self, self.OnGodStarUp)                       -- 服务端返回神将提升星级请求
    
    self:showNewGuide()
    
end

function GodwillListLayer:showNewGuide()

    local name = nil
    local curGuideName = UserData.NewHandLead:getCurrentGuideName()
    if curGuideName == "GodWillLead_levelup" or curGuideName == "GodWillLead_starUp" then
        name = curGuideName
    end

    if name ~= nil and UserData.NewHandLead.GuideList[name] ~= nil and UserData.NewHandLead:getGuideState(name) == 0 then
        if UserData.NewHandLead.GuideList[name].curStep == 1 then
            UserData.NewHandLead.GuideList[name].curStep = 2
            if self.Node_newHand_inView ~= nil then 
                UserData.NewHandLead:addHandTo(self.Node_newHand_inView)
                local unlockedList = GodwillManager:getGodwillUnlockedList() 
                if guideSelectedItemInfo.pos ~= nil then
                    self.Node_newHand_inView:setPosition(cc.p(guideSelectedItemInfo.pos.x+180,guideSelectedItemInfo.pos.y-100))
                end
                if self.ScrollView_1 ~= nil and guideSelectedItemInfo.curHeight ~= nil then
                    if guideSelectedItemInfo.curHeight > guideSelectedItemInfo.scrollViewHeight then
                        self.ScrollView_1:jumpToPercentVertical((guideSelectedItemInfo.curHeight+50)/guideSelectedItemInfo.totalHeight*100)
                    end
                end
            end
        end
    end
end

function GodwillListLayer:onExit()
    EventMgr:unregistListener(EventType.OnCreateGod, self, self.OnCreateGod)                       -- 服务端返回合成神将信息
    EventMgr:unregistListener(EventType.OnGodLevelUp, self, self.OnGodLevelUp)                     -- 服务端返回神将提升星级请求
    EventMgr:unregistListener(EventType.OnGodStarUp, self, self.OnGodStarUp)                       -- 服务端返回神将提升星级请求
--    if self.myScheduleUpdateId then
--        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
--    end
end

--初始化
function GodwillListLayer:init()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    rootNode = cc.CSLoader:createNode("csb/GodwillListLayer.csb")
    self:addChild(rootNode)
    self.Panel_mark = rootNode:getChildByName("Panel_mark")
    self.ScrollView_1 = self.Panel_mark:getChildByName("ScrollView_1")
    self.Panel_mark:setTouchEnabled(true)
    self.ScrollView_1:setTouchEnabled(true)
    --self.ScrollView_1:setAnchorPoint(cc.p(0,0))
--    --item模板
--    self.Panel_item_mode = rootNode:getChildByName("Panel_item")
    
    local Button_close = self.Panel_mark:getChildByName("Button_close")
    local function onCloseButtonClicked(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            
            if senderName == "Button_close" then
                self:removeFromParent()
                
                local name = nil
                local curGuideName = UserData.NewHandLead:getCurrentGuideName()
                
                if curGuideName == "GodWillLead_levelup" or curGuideName == "GodWillLead_starUp" then
                    name = curGuideName
                end
                if curGuideName ==  ""  or name == nil then
                	return
                end
                if name ~= nil and UserData.NewHandLead.GuideList[name] ~= nil then
                    if UserData.NewHandLead:getGuideState(name) == 0 then
                        UserData.NewHandLead.GuideList[name].curStep = 1
                        local SceneManager = require("app.views.SceneManager")
                        local layer = SceneManager:getGameLayer("TownInterfaceLayer")
                        if layer ~= nil then
                            if layer.main_ui_layer ~= nil and layer.main_ui_layer.bottomBar ~= nil then
                                layer.main_ui_layer.bottomBar:showNewHand(curGuideName)
                            end
                        end
                    end
                end

            end
        end
    end
    Button_close:setTouchEnabled(true)
    Button_close:addTouchEventListener(onCloseButtonClicked)
    Button_close:setPressedActionEnabled(true)

    --重新刷新神将数据
    UserData.Godwill:RefreshGodwillData()
    
    self:initScrollViewItems()

    self.publicTipLayer = publicTipLayer:create()
    
    self.Node_newHand = rootNode:getChildByName("Node_newHand")
end


function GodwillListLayer:initScrollViewItems()
    local unlockedList = GodwillManager:getGodwillUnlockedList() 
    local lockedList = GodwillManager:getGodwillLockedList()  

    if self.ScrollView_1:getChildrenCount() > 0 then
        self.ScrollView_1:removeAllChildren()
    end
    self.Node_newHand_inView = cc.Node:create()
    self.ScrollView_1:addChild(self.Node_newHand_inView,10)
    
    --先计算滚动列表高度
    local szScrollView = self.ScrollView_1:getContentSize()
    local seperate_num = szScrollView.width/SCROLL_ITEM_SIZE.width
   
    local totalHeight = SCROLL_ITEM_SIZE.height * math.ceil(table.nums(unlockedList)/seperate_num) 
                  + SEPERATE_SPACE_HEIGHT + SCROLL_ITEM_SIZE.height * math.ceil(table.nums(lockedList)/seperate_num)
    
    totalHeight = (totalHeight < szScrollView.height) and szScrollView.height or totalHeight    
    self.ScrollView_1:setInnerContainerSize(cc.size(szScrollView.width,totalHeight))
    --local hight = self.ScrollView_1:getInnerContainerSize().height
    local sz = self.ScrollView_1:getInnerContainerSize()
    
    
    local ptx= self.ScrollView_1:getAnchorPoint()
	--self.ScrollView_1:setAnchorPoint(cc.p(0,1))
    local lastPosY = totalHeight

    for i=1, #unlockedList do
        local godwillInfo = unlockedList[i]
        local itemNew = self:createItem(godwillInfo)
        if itemNew ~= nil then
            
            itemNew:setName("godwill_" .. tostring(godwillInfo.id))
            self:setItemInfo(itemNew,godwillInfo)
            --self.ScrollView_1:addChild(itemNew)

            local posx = (i-1)%seperate_num * SCROLL_ITEM_SIZE.width
            local posy = totalHeight - math.floor((i-1)/seperate_num) *SCROLL_ITEM_SIZE.height
            itemNew:setPosition(posx,posy)
            lastPosY = posy
            if godwillInfo.id == 413003 then  --猴小六
                guideSelectedItemInfo = {pos = cc.p(posx,posy),curHeight = totalHeight - lastPosY,scrollViewHeight = szScrollView.height,totalHeight = totalHeight}
            end
        end    
    end

    local imageView = ccui.ImageView:create("ui/townAssignment/boundary.png")
    local imageView_height = imageView:getContentSize().height
    local imageView_posY = lastPosY  - SEPERATE_SPACE_HEIGHT/2
    if table.nums(unlockedList) > 0 then
        imageView_posY = imageView_posY - SCROLL_ITEM_SIZE.height
    end
    imageView:setPosition(sz.width/2, imageView_posY)
    self.ScrollView_1:addChild(imageView)
    local text = ccui.Text:create()
    text:setString("未获得的神将")
    text:setFontSize(20)        
    text:setColor(cc.c3b(255, 255, 255))
    text:setAnchorPoint(cc.p(0.5,0.5))
    text:setPosition(cc.p(335,30))
    --text:setPositionY(30)
    imageView:addChild(text)
    
    --
    -- 重置计数
    
    local nextBeginPosY = imageView_posY - SEPERATE_SPACE_HEIGHT/2
    for i=1,#lockedList do
    
        local godwillInfo = lockedList[i]
        local itemNew = self:createItem(godwillInfo)
        if itemNew ~= nil then
            itemNew:setName("godwill_" .. tostring(godwillInfo.id))

            self:setItemInfo(itemNew,godwillInfo)
            
            local posx = (i-1)%seperate_num * SCROLL_ITEM_SIZE.width
            local posy = nextBeginPosY - math.floor((i-1)/seperate_num) *SCROLL_ITEM_SIZE.height
            itemNew:setPosition(posx,posy)
            lastPosY = posy
        end    
    end
    
    self.ScrollView_1:jumpToTop()
end

function GodwillListLayer:createItem(godwillInfo)
    if self.Panel_item_mode == nil then
        self.Panel_item_mode = rootNode:getChildByName("Panel_item")
    end
    
    
    local panel_item = self.Panel_item_mode:clone()
    self.Panel_item_mode:setVisible(false) 
    
    local function onItemClicked(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("GodwillListLayer onItemClicked,name = "  .. senderName)
            local id = string.sub(senderName,string.len("godwill_")+1,string.len(senderName))
            cclog("GodwillListLayer onItemClicked,id = "  .. id)
            if GodwillManager:hasGodwill(tonumber(id)) then
                self:showGodwillInfoUI(tonumber(id))
            else
                self:getNewGodwill(tonumber(id))
            end
            if self.Node_newHand_inView ~= nil then
                self.Node_newHand_inView:removeAllChildren()
            end
        end
    end
    panel_item:setTouchEnabled(true)
    panel_item:setVisible(true)
    panel_item:addTouchEventListener(onItemClicked)
    
    self.ScrollView_1:addChild(panel_item)
    return panel_item
end
  

function GodwillListLayer:setItemInfo(panel_item,godwillInfo)
    if panel_item == nil or godwillInfo == nil then
        return
    end
    
    
    --背景
    --local Image_bg = panel_item:getChildByName("Image_bg")

    --名称
    local Text_name = panel_item:getChildByName("Text_name")
    local name = GodwillManager:getGodwillName(godwillInfo.id,godwillInfo.star)
    Text_name:setString(name)

    --头像
    local Image_head_bg = panel_item:getChildByName("Image_head_bg")
    local Image_head = Image_head_bg:getChildByName("Image_head")
    local headIcon = GodwillManager:getGodwillIcon(godwillInfo.id,godwillInfo.star)
    Image_head:loadTexture(headIcon)

    --品质
    local Image_quality = Image_head:getChildByName("Image_quality")
    local grade = GodwillManager:getGodwillStaticData(godwillInfo.id).grade
    Image_quality:setVisible(false)
    
    --设置是否已拥有，并初始化
    local Panel_owned = panel_item:getChildByName("Panel_owned")
    Panel_owned:setTouchEnabled(false)
    local Panel_not_owned = panel_item:getChildByName("Panel_not_owned")
    Panel_not_owned:setTouchEnabled(false)   
    
    local isOwned = (godwillInfo.unlocked == 1) 
    Panel_owned:setVisible(isOwned)
    Panel_not_owned:setVisible(not isOwned)
    if isOwned then
        local Image_star = Panel_owned:getChildByName("Image_star")
        godwillInfo.star = godwillInfo.star > 5 and 5 or godwillInfo.star
        godwillInfo.star = godwillInfo.star < 0 and 0 or godwillInfo.star
        Image_star:setVisible(false)
        if godwillInfo.star > 0 then
            Image_star:setVisible(true)
            Image_star:loadTexture(starImage[godwillInfo.star])
        end

        local Text_fight_value = Panel_owned:getChildByName("Text_fight_value")
        Text_fight_value:setString(tostring(godwillInfo.fight))
        local Text_level = Panel_owned:getChildByName("Text_level")
        Text_level:setString(tostring(godwillInfo.level))
        --Image_head:setColor(cc.c3b(255,255,255))
    else
        local LoadingBar_item_nums = Panel_not_owned:getChildByName("LoadingBar_item_nums")
        local Text_items = Panel_not_owned:getChildByName("Text_items")
        local Image_item_icon = Panel_not_owned:getChildByName("Image_item_icon")
        Image_item_icon:setVisible(false)
        local itemNeed = GodwillManager:getGodCreateNeedItems(godwillInfo.id)
        local itemID = itemNeed.id
        local itemNeedNum = itemNeed.count
        local itemHaveNum = ItemManager:getItemNum(itemID)
--        local itemStaticInfo = StaticData.Item[itemID]
--        if itemStaticInfo ~= nil then
--            Image_item_icon:loadTexture(itemStaticInfo.ItemIcon)
--        end
        Text_items:setString(tostring(itemHaveNum) .. "/" .. tostring(itemNeedNum))
        LoadingBar_item_nums:setPercent(itemHaveNum/itemNeedNum*100)
        --Image_head:setColor(cc.c3b(128,128,128))
    end

end




function GodwillListLayer:getNewGodwill(id)
    local godwillInfo = UserData.Godwill.godList[id]
    if godwillInfo ~= nil and godwillInfo.unlocked == 0 then
        local itemNeed = GodwillManager:getGodCreateNeedItems(godwillInfo.id)
        local itemID = itemNeed.id
        local itemNeedNum = itemNeed.count
        local itemHaveNum = ItemManager:getItemNum(itemID)
        if itemHaveNum >= itemNeedNum then
             -- 发送消息获得新的神将
             UserData.Godwill:sendCreateGod(godwillInfo.id)
        else
            -- 打开材料获取窗口
            local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
            local flyMakeMatLayer = FlyMakeMatLayer:create(itemID, itemHaveNum)
            self:addChild(flyMakeMatLayer)
        end
    end
end

function GodwillListLayer:showGodwillInfoUI(id)
    local GodwillInfoLayer = require("app.views.Godwill.GodwillInfoLayer")
    local godwillInfoLayer = self:getChildByName("GodwillInfoLayer")
    if godwillInfoLayer == nil then
        godwillInfoLayer = GodwillInfoLayer:create()
        godwillInfoLayer:setName("GodwillInfoLayer")
        self:addChild(godwillInfoLayer,10)
    end
    godwillInfoLayer:initUI(id)

end

function  GodwillListLayer:OnCreateGod(event)
    local eventParam = event._usedata
    local byRes = eventParam.byRes
    local nGodID = eventParam.nGodID
    if byRes == 0 then
        self:initScrollViewItems()
        publicTipLayer:setTextAction("神将合成成功！")
    elseif byRes == 3 then
        publicTipLayer:setTextAction("神将合成材料不足！")
    end
end

function  GodwillListLayer:OnGodLevelUp(event)
    local eventParam = event._usedata
    local byRes = eventParam.byRes
    local nGodID = eventParam.nGodID
    local nLevel = eventParam.nLevel
    if byRes == 0 then
        self:initScrollViewItems()
    end
end

function  GodwillListLayer:OnGodStarUp(event)
    local eventParam = event._usedata
    local byRes = eventParam.byRes
    local nGodID = eventParam.nGodID
    local byStar = eventParam.byStar
    if byRes == 0 then
        self:initScrollViewItems()
    end
end

return GodwillListLayer