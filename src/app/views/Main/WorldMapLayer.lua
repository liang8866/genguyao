
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ShaderEffect = require("src.app.views.public.ShaderEffect")

local WorldMapLayer = class("WorldMapLayer", require("app.views.View"))

function WorldMapLayer:onCreate()
    
    UserData.Bag:sendBagItemList()                                                                  -- 客户端想服务端请求物品 
    UserData.Friend:sendServerFriendList()                                                          -- 客户端向服务端请求好友列表以及好友申请列表
    UserData.Friend:sendServerBlackList()                                                           -- 客户端向服务端请求黑名单列表
    
    local bg = cc.Sprite:create("ui/worldMap/worldMap_bg.png")
    bg:setPosition(display.center)
    self:addChild(bg,-2)
    
    self:showMainback()
    
end

function WorldMapLayer:onEnter()

end

function WorldMapLayer:onExit()

end


function WorldMapLayer:showMainback()
    self.backLayer_RootNode    = cc.CSLoader:createNode("csb/main_back_Layer.csb")
    self.backLayer_RootNode:setAnchorPoint(cc.p(0.5,0.5))
    self.backLayer_RootNode:setPosition(display.center)
    self:addChild(self.backLayer_RootNode,-1)
	
    local Image_current = self.backLayer_RootNode:getChildByName("Image_current")
    Image_current:ignoreContentAdaptWithSize(true)
   
    local Button_back = self.backLayer_RootNode:getChildByName("Button_back")
    Button_back:addTouchEventListener(function(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            audio.stopMusic(false)
            self:removeFromParent()
            local SceneManager = require("app.views.SceneManager")
            SceneManager:switch(SceneManager.SceneName.SCENE_LOGIN)

        end
    end)
    Button_back:setPressedActionEnabled(true)
    
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED     then
            local tag =  sender:getTag()
            cclog("switch to world map id=%d",tag)
            local userData = {worldMapID = tag}                                                                      
            self:removeFromParent()
            
            local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
            local layer = StageMapLayer:create(tag)
            local SceneManager = require("app.views.SceneManager")
            SceneManager:addToGameScene(layer)
            
            UserData.Map:SaveRoleStayWorldMapID(tonumber(tag))
        end
    end
    
    local roleStayWorldMapID = UserData.Map:getRoleStayWorldMapID()
    local worldMapOpened = UserData.Map:getOpenedWolrdMapID()
    local mapID = {}
    for i=1,table.nums(worldMapOpened) do
        mapID[tonumber(worldMapOpened[i])] = 1
    end
    
    for i=1,7 do --1 人界，2 洞天福地 3 海底 4 仙界 5 小西天  6 地府  7 极乐世界
        local Panel_item = self.backLayer_RootNode:getChildByName("Panel_" .. tostring(i))
        Panel_item:setTag(611000+i)   
        
        Panel_item:addTouchEventListener(onEventTouchButton)
        if mapID[611000+i] ~= nil and mapID[611000+i] == 1 then
            Panel_item:setColor(cc.c3b(255,255,255))
            Panel_item:setTouchEnabled(true)
        else
            Panel_item:setColor(cc.c3b(130,130,130))   
            Panel_item:setTouchEnabled(false)         
        end
        
        if roleStayWorldMapID == 611000+i then
            local posX,posY = Panel_item:getPosition()
            Image_current:stopAllActions()
            Image_current:setPosition(cc.p(posX,posY+50))
            local posX,posY = Image_current:getPosition()
            local moveto1 = cc.MoveTo:create(0.3, cc.p(posX,posY-5))
            local moveto2 = cc.MoveTo:create(0.3, cc.p(posX,posY+5))
            Image_current:runAction(cc.RepeatForever:create(cc.Sequence:create(moveto1,moveto2)))
        end
	end
    
end


return WorldMapLayer