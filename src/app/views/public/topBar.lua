

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local StrengthTips = require("app.views.Main.StrengthTips")


local topBar = class("topBar", function()
    return cc.Node:create()
end)

function topBar:create()
    local node = topBar.new()
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

function topBar:ctor()

end

function topBar:onEnter()
end

function topBar:onExit()
end

function topBar:init()
    local topBarNode = cc.CSLoader:createNode("csb/top_bar.csb")

    self:addChild(topBarNode)

    local panel_top = topBarNode:getChildByName("panel_top")
    
   
    self.Image_1 = panel_top:getChildByName("Image_1")
    self.Text_userGold = self.Image_1:getChildByName("Text_userGold")
    self.btn_add_userGold = self.Image_1:getChildByName("btn_add_userGold")
    
    self.Image_2 = panel_top:getChildByName("Image_2")
    self.Text_userIngot = self.Image_2:getChildByName("Text_userIngot")
    self.btn_add_userIngot = self.Image_2:getChildByName("btn_add_userIngot")
    
    self.Image_3 = panel_top:getChildByName("Image_3")
    self.Text_tili = self.Image_3:getChildByName("Text_tili")
    self.btn_add_tili = self.Image_3:getChildByName("btn_add_tili")
    self.icon_tili = self.Image_3:getChildByName("icon_tili")
    
    local Image_head_icon_frame = panel_top:getChildByName("Image_head_icon_frame")
    self.Image_head_icon = Image_head_icon_frame:getChildByName("Image_head_icon")
    
    self.Text_level = panel_top:getChildByName("Text_level")
    self.Text_name = panel_top:getChildByName("Text_name")
    
    local Image_exp = panel_top:getChildByName("Image_exp")
    self.LoadingBar_exp = Image_exp:getChildByName("LoadingBar_exp")
    self.Text_exp = Image_exp:getChildByName("Text_exp")
    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(20,2)
    self.Text_userGold = outLineLable:setTexOutLine(self.Text_userGold)
    self.Text_userIngot = outLineLable:setTexOutLine(self.Text_userIngot)
    self.Text_tili = outLineLable:setTexOutLine(self.Text_tili)
    self.Text_level = outLineLable:setTexOutLine(self.Text_level)
    self.Text_name = outLineLable:setTexOutLine(self.Text_name)
    
    local function onImageClicked(sender,eventType)
        if  eventType == cc.EventCode.BEGAN then
            if sender == self.Image_3 then
                if self.tipsIsVisible == true then
                    self.ProjectNode_tips:setVisible(false)
                    self.tipsIsVisible = false
                else
                    self.ProjectNode_tips:setVisible(true)
                    self.tipsIsVisible = true
                end
            end
        elseif  eventType == cc.EventCode.ENDED then
            if sender == self.Image_1 or self.btn_add_userGold == sender then  --元宝
                local function onYes()
                    --UserData.BaseInfo:sendBuyActionMoney(1)
                end
                YesCancelLayer:create("确定购买元宝吗?", onYes)
            end
            if sender == self.Image_2 or self.btn_add_userIngot == sender  then  --游戏币
                --打开商城
            end
            if self.btn_add_tili == sender then
                local function onYes()
                    UserData.BaseInfo:sendBuyAction()
                end
                YesCancelLayer:create(string.format("花费 %d 元宝购买 %d 点体力?", (UserData.BaseInfo.nBuyActionNum + 1) * StaticData.SystemParam['BuyActionSpend'].IntValue,StaticData.SystemParam['BuyActionNum'].IntValue),onYes)
                
            end
            if self.icon_tili == sender then
                self:createActionBagFrame()
            end
        end
        
    end
    
    self.Image_1:setTouchEnabled(true)
    self.Image_1:addTouchEventListener(onImageClicked)

    self.Image_2:setTouchEnabled(true)
    self.Image_2:addTouchEventListener(onImageClicked)
    
    self.Image_3:setTouchEnabled(true)
    self.Image_3:addTouchEventListener(onImageClicked)
    
    self.btn_add_userGold:setTouchEnabled(true)
    self.btn_add_userGold:addTouchEventListener(onImageClicked)
    self.btn_add_userGold:setPressedActionEnabled(true)
    
    self.btn_add_userIngot:setTouchEnabled(true)
    self.btn_add_userIngot:addTouchEventListener(onImageClicked)
    self.btn_add_userIngot:setPressedActionEnabled(true)
    
    self.btn_add_tili:setTouchEnabled(true)
    self.btn_add_tili:addTouchEventListener(onImageClicked)
    self.btn_add_tili:setPressedActionEnabled(true)
    
    self.icon_tili:setTouchEnabled(true)
    self.icon_tili:addTouchEventListener(onImageClicked)
    
    self.tipsIsVisible = false
    self.ProjectNode_tips = topBarNode:getChildByName("ProjectNode_tips")
    local tips = StrengthTips:new()
    self.ProjectNode_tips:addChild(tips)
    self.ProjectNode_tips:setVisible(false)
    
end

function topBar:refreshTopUI()
    local baseInfo = UserData.BaseInfo
    self.Text_userGold:setString(baseInfo.userGold)
    self.Text_userIngot:setString(baseInfo.userIngot)
    self.Text_tili:setString(baseInfo.nAction .. string.format("/%d", acTionUpperBound(baseInfo.userLevel)))
    
    local iconData = StaticData.Icon[baseInfo.userImageID+10]
    if iconData ~= nil and iconData.path ~= "" then
        self.Image_head_icon:loadTexture(iconData.path)
    else
        self.Image_head_icon:loadTexture("res/items/role/box.png")  -- 无图片资源，表示出错
    end
    
    self.Text_level:setString(tostring(baseInfo.userLevel))
    self.Text_name:setString(baseInfo.userName)
    
    local nextExpNeed = StaticData.Level[baseInfo.userLevel].Experience
    self.LoadingBar_exp:setPercent(baseInfo.userExp/nextExpNeed *100)
    self.Text_exp:setString(tostring(baseInfo.userExp) .. "/" .. tostring(nextExpNeed))

end


function topBar:createActionBagFrame()
    local baseInfo = UserData.BaseInfo

    local layer = cc.CSLoader:createNode("csb/getActionBagFrame.csb")
    layer.__cname = "getActionBagFrame"
    local SceneManager = require("app.views.SceneManager")
    SceneManager:addToGameScene(layer)

    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            baseInfo:sendGetActionBag()
            layer:removeFromParent()
        end
    end
    layer:setPosition(cc.p(0,0))
    local panel = layer:getChildByName("Panel")
    local noonText = panel:getChildByName("noonText")
    local afternoonText = panel:getChildByName("afternoonTexg")
    local getButton = panel:getChildByName("getButton")
    getButton:setTouchEnabled(true)
    getButton:setPressedActionEnabled(true)
    getButton:addTouchEventListener(touchEvent)
    
    local titleText = getButton:getChildByName("titleText")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(titleText)

    if baseInfo.h < 12 then
        titleText:setString("确定")
    elseif baseInfo.h >= 12 and baseInfo.h <= 14 or baseInfo.h >= 18 and baseInfo.h <= 20 then
        titleText:setString("领取")
    elseif baseInfo.h >= 14 and baseInfo.h <= 18 then
        noonText:setString("中午           已过")
        titleText:setString("确定")
    elseif baseInfo.h >= 20 then
        noonText:setString("中午           已过")
        afternoonText:setString("下午           已过")
        titleText:setString("确定") 
    end
end

return topBar
