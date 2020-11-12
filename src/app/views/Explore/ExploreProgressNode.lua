

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local ExploreManager = require("app.views.Explore.ExploreManager")

local progressInfo = {}
local hideState = true
-- 探索开启界面
local ExploreProgressNode = class("ExploreProgressNode", function()
    return cc.Node:create()
end)

function ExploreProgressNode:create(iExploreMapID)
    local node = ExploreProgressNode.new()
    node:init(iExploreMapID)
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

function ExploreProgressNode:ctor()

end

function ExploreProgressNode:onEnter()
--    EventMgr:registListener(EventType.OnGetCell, self, self.onGetCell)
end

function ExploreProgressNode:onExit()
--    EventMgr:unregistListener(EventType.OnGetCell, self, self.onGetCell)
end

function ExploreProgressNode:init(iExploreMapID)
    local csbNode = cc.CSLoader:createNode("csb/ExploreProgressNode.csb")
    self:addChild(csbNode)
    
    local Panel_root = csbNode:getChildByName("Panel_root")
    self.Panel_root = Panel_root
    self.ScrollView_1 = Panel_root:getChildByName("ScrollView_1")
    self.Panel_item_mode = csbNode:getChildByName("Panel_item_mode")
    self.Panel_item_mode:setVisible(false)
    
    self.Text_progress = Panel_root:getChildByName("Text_progress")
    self.Panel_item_list = {}
    for i=1,3 do
        self.Panel_item_list[i] = {}
        self.Panel_item_list[i].Panel_item = Panel_root:getChildByName("Panel_item_" .. tostring(i))
    end
    
--    local Button_center = Panel_root:getChildByName("Button_center")
--    local Button_back = Panel_root:getChildByName("Button_back")
    local Button_hide = Panel_root:getChildByName("Button_hide")
    
    self.Image_hide_btn = Button_hide:getChildByName("Image_hide_btn")
    self.Image_hide_btn:loadTexture("ui/Explore/button_Explore_2.png")
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("ExploreProgressNode onEventTouchButton,name = "  .. senderName)
--            if senderName == "Button_center" then
--
--            elseif senderName == "Button_back" then
--                local iExploreMapID = self.iExploreMapID
--                local parent = self:getParent()
--                parent:removeFromParent()
--                
--                local ExploreStartLayer = require("app.views.Explore.ExploreStartLayer")
--                local layer = ExploreStartLayer:create(iExploreMapID)
            --                local SceneManager = require("app.views.SceneManager")
            --                SceneManager:addToGameScene(layer,10)
            --                layer:updateProgressInfo()
--            else
            if senderName == "Button_hide" then
                self:changeHideState()
            end
        end
    end
--    Button_center:setTouchEnabled(true)
--    Button_center:addTouchEventListener(onEventTouchButton)
--    Button_center:setPressedActionEnabled(true)
--    Button_center:setVisible(false)
--    
--    Button_back:setTouchEnabled(true)
--    Button_back:addTouchEventListener(onEventTouchButton)
--    Button_back:setPressedActionEnabled(true)
    
    Button_hide:setTouchEnabled(true)
    Button_hide:addTouchEventListener(onEventTouchButton)
    Button_hide:setPressedActionEnabled(true)
    
    self.iExploreMapID = iExploreMapID
    self:initExploreInfo()
    self:updateProgressInfo()
    
    self.Panel_root:setPosition(cc.p(246,0))
end

function ExploreProgressNode:changeToHide()
	
	if self.Image_hide_btn == nil or self.Panel_root == nil then
        return
    end
    hideState = false
	self:changeHideState()
end

function ExploreProgressNode:changeHideState()
    cclog("hideState = " .. tostring(hideState))
    
    
    if self.Image_hide_btn == nil or self.Panel_root == nil then
        return
    end

    
    local rootPos = nil
    if hideState then
        hideState = false
        self.Image_hide_btn:loadTexture("ui/Explore/button_Explore_1.png")
        rootPos = cc.p(0,0)
        self:updateProgressInfo()
    else
        hideState = true
        self.Image_hide_btn:loadTexture("ui/Explore/button_Explore_2.png")
        rootPos = cc.p(246,0)
    end
    cclog("hideState 2= " .. tostring(hideState))
    local move = cc.MoveTo:create(0.5,rootPos)
    self.Panel_root:runAction(move)

end

function ExploreProgressNode:initTypeLimit(iExploreMapID)
    local mapStaticInfo = StaticData.Map[iExploreMapID]
    local exploreMapData = UserData.Explore.map[iExploreMapID]
    if exploreMapData == nil or mapStaticInfo == nil then
        return
    end
    local stringEx = require("common.stringEx")
    local limitNumList = ExploreManager:getLimitNumList(iExploreMapID)
    
    for i=ExploreEnum.Box,ExploreEnum.Jewel do
        local type = i
        if progressInfo[type] == nil then
            progressInfo[type] = {}
        end
        progressInfo[type].desNum = 0
        if limitNumList[type] ~= nil then
            progressInfo[type].desNum = limitNumList[type]
        end
    end
    
end

function ExploreProgressNode:initExploreInfo()
    
    local mapStaticInfo = StaticData.Map[self.iExploreMapID]
    if mapStaticInfo == nil then return end
    self.initTypeLimit(self.iExploreMapID)
    local items = string.split(mapStaticInfo.TypeIcon,"|")

    local itemsNum = table.nums(items)
    local stringEx = require("common.stringEx")
    local ShowNumList = stringEx:splitPrizeItemsStr(mapStaticInfo.ShowNum)  -- ShowNum="1-5|2-2|8-1|9-1|10-1"
    local ShowNum = {}
    for i=1,#ShowNumList do
        ShowNum[tonumber(ShowNumList[i][1])] = tonumber(ShowNumList[i][2])
    end
    
    
    
    --先计算滚动列表高度
    local szScrollView = self.ScrollView_1:getContentSize()
    local column_num = table.nums(items)  --列数
    local row_num = 1 -- 行数
    local SCROLL_ITEM_SIZE = self.Panel_item_mode:getContentSize()
    local totalHeight = SCROLL_ITEM_SIZE.height
    local totalWidth = SCROLL_ITEM_SIZE.width * column_num
    --totalHeight = (totalHeight < szScrollView.height) and szScrollView.height or totalHeight    
    totalWidth = (totalWidth < szScrollView.width) and szScrollView.width or totalWidth    
    self.ScrollView_1:setInnerContainerSize(cc.size(totalWidth,szScrollView.height))
    
    for i=1,column_num do 
        local iconInfo = StaticData.Icon[tonumber(items[i])]
        local panel_item = self:createItemExtra(iconInfo,self.ScrollView_1)
        if panel_item ~= nil then
            local x= (i-1)*SCROLL_ITEM_SIZE.width
            panel_item:setPosition(cc.p(x,0))
        end
    end

    
    for i=1,3 do
        local type = i - 1 + ExploreEnum.BigBox 
        local Panel_item_index = self.Panel_item_list[i].Panel_item
        if progressInfo[type] == nil then
            progressInfo[type] = {}
        end
        progressInfo[type].Text_num = Panel_item_index:getChildByName("Text_num")
        progressInfo[type].Image_icon = Panel_item_index:getChildByName("Image_icon")
        progressInfo[type].Text_name = Panel_item_index:getChildByName("Text_name")
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

                progressInfo[type].desNum = limitNum
                progressInfo[type].Panel_item:setVisible(true)
                --local iconPath = ExploreManager:getExploreItemIconPath(iconTable,type)
                progressInfo[type].Image_icon:loadTexture(itemInfo.ItemIcon)
                progressInfo[type].Text_num:setString("0/0")
                progressInfo[type].Text_name:setString(itemInfo.ItemName)
            end
        end
    end
    
end



function ExploreProgressNode:createItemExtra(iconInfo,parent)

    if self.Panel_item_mode ~= nil then
        local itemWnd = self.Panel_item_mode:clone()
        local Text_name = itemWnd:getChildByName("Text_name")
        
        local Image_item_bg = itemWnd:getChildByName("Image_item_bg")
        local Image_icon = itemWnd:getChildByName("Image_icon")
        Image_item_bg:loadTexture("ui/Explore/bg_Explore_1.png")
        Image_icon:loadTexture(iconInfo.path)
        Text_name:setString(iconInfo.des)
        parent:addChild(itemWnd)
        itemWnd:setVisible(true)
        return itemWnd
    end
    return nil
end



function ExploreProgressNode:createItem(type,num,parent)
    progressInfo[type] = {}
    if self.Panel_item_mode ~= nil then
        local itemWnd = self.Panel_item_mode:clone()
        local Text_num = itemWnd:getChildByName("Text_num")
        local Image_icon = itemWnd:getChildByName("Image_icon")
        local Text_name = itemWnd:getChildByName("Text_name")
        progressInfo[type].Text_name = Text_name
        progressInfo[type].Text_num = Text_num
        progressInfo[type].Image_icon = Image_icon
        progressInfo[type].Panel_item = itemWnd
        progressInfo[type].desNum = num

        --progressInfo[type].Image_icon:loadTexture("ui/Explore/icon_Explore_3.png")
        progressInfo[type].Text_num:setString("0/" .. tostring(num))
        parent:addChild(itemWnd)
        itemWnd:setVisible(true)
        return itemWnd
    end
    return nil
end


function ExploreProgressNode:updateProgressInfo()
    local exploreMapData = UserData.Explore.map[self.iExploreMapID]
    local exploreStaticData = StaticData.Map[self.iExploreMapID]
    --local iconTable = ExploreManager:getItemsIconTable(self.iExploreMapID)
    --local freshNum = exploreMapData[ExploreEnum.Refresh] -- 当前的刷新次数
    local stringEx = require("common.stringEx")
    local ShowNumList = stringEx:splitPrizeItemsStr(exploreStaticData.ShowNum)  -- ShowNum="1-5|2-2|8-1|9-1|10-1"
    local ShowNum = {}
    for i=1,#ShowNumList do
        ShowNum[tonumber(ShowNumList[i][1])] = tonumber(ShowNumList[i][2])
    end
    
    local itemIDTab = string.split(exploreStaticData.XiYouGoods,"|")
    for i=1,table.nums(itemIDTab) do 
        local type = i - 1 + ExploreEnum.BigBox 
        local num = exploreMapData ~= nil and exploreMapData[type] or 0

        local itemID = tonumber(itemIDTab[i])
        local itemInfo = StaticData.Item[itemID]
        if num >= 111 then --未刷出来
            progressInfo[type].Text_num:setString("0/0")
        else
            if num >= 0 then
                local curNum = progressInfo[type].desNum - num
                curNum = curNum >= 0 and curNum or 0
                progressInfo[type].Text_num:setString(tostring(curNum) .. "/" .. tostring(progressInfo[type].desNum) )
            end
        end

        --local iconPath = ExploreManager:getExploreItemIconPath(iconTable,i)
        --progressInfo[type].Image_icon:loadTexture(itemInfo.ItemIcon)
    end
    
    local items = stringEx:splitPrizeItemsStr(exploreStaticData.Type)
    local itemsTab = {}
    for i=1,table.nums(items) do
        local itemInfo = items[i]
        itemsTab[tonumber(itemInfo[1])] = tonumber(itemInfo[2])
    end
    
    local totalNum = 0
    if ShowNum[ExploreEnum.Box] ~= nil then
        totalNum = totalNum + ShowNum[ExploreEnum.Box]
    else
        totalNum = totalNum + ( (itemsTab[ExploreEnum.Box] ~= nil) and itemsTab[ExploreEnum.Box] or 0 )
    end
    if ShowNum[ExploreEnum.Event] ~= nil then
        totalNum = totalNum + ShowNum[ExploreEnum.Event]
    else
        totalNum = totalNum + ( (itemsTab[ExploreEnum.Event] ~= nil) and itemsTab[ExploreEnum.Event] or 0 )
    end
    if ShowNum[ExploreEnum.Tower] ~= nil then
        totalNum = totalNum + ShowNum[ExploreEnum.Tower]
    else
        totalNum = totalNum + ( (itemsTab[ExploreEnum.Tower] ~= nil) and itemsTab[ExploreEnum.Tower] or 0 )
    end
    
    local totalHave = exploreMapData[ExploreEnum.Box] + exploreMapData[ExploreEnum.Event] + exploreMapData[ExploreEnum.Tower]
    self.Text_progress:setString(tostring(totalHave) .. "/" .. tostring(totalNum))
end

function ExploreProgressNode:onGetCell(userdata)
--    local userdata = eventData._usedata
    if userdata.res == 0 then
        local type = StaticData.ExploreMap[userdata.seriesID].Type
        local num = UserData.Explore.map[userdata.mapId][type]
        if num ~= nil then
            if type <= 7 or type >= 11 then
                --progressInfo[type].Text_num:setString(tostring(num) .. "/" .. tostring(progressInfo[type].desNum) )
            else
                progressInfo[type].Text_num:setString(tostring(progressInfo[type].desNum - num) .. "/" .. tostring(progressInfo[type].desNum) )
            end
	    end
	end
end

return ExploreProgressNode