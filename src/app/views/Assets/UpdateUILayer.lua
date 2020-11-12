
local UpdateLogicLayer = require('app.views.Assets.UpdateLogicLayer')
local LoginLayer = require("app.views.Login.LoginLayer")
local lNet = require ("net.Net")
local UpdateUILayer = class("UpdateUILayer", cc.Layer)

function UpdateUILayer:create()
    local view = UpdateUILayer.new()
    local function onNodeEvent(eventType)
        if eventType == "enter" then
            view:onEnter()
        elseif eventType == "exit" then
            view:onExit()
        end
    end
    view:registerScriptHandler(onNodeEvent)
    view:init()
    return view
end

function UpdateUILayer:ctor()
    self.updateLogicLayer = nil
end

function UpdateUILayer:onEnter()
   
end

function UpdateUILayer:onExit()
    
end

function UpdateUILayer:init()
    self.updateLogicLayer = UpdateLogicLayer:create()
    self:addChild(self.updateLogicLayer)
    self.updateLogicLayer:init(function(sender,eventType) self:onEventCallBack(sender,eventType) end)
end
 
function UpdateUILayer:onEventCallBack(sender,eventType)
    if eventType == sender.EventType.StartGame then
                
    elseif eventType == sender.EventType.StartUpdate then
        self:initAssetsUI()
                
    elseif eventType == sender.EventType.Progress then
        self:updateProgress(sender.updatePath, sender.updateResTable, sender.updateProgress)
        
    elseif eventType == sender.EventType.Finish then
        self:updateFinish()        
    end
end

--UI界面初始化
function UpdateUILayer:initAssetsUI()
    local assetsLayer = cc.CSLoader:createNode("csb/assetsUpdate_layer.csb") 
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    assetsLayer:setAnchorPoint(cc.p(0.5,0.5))
    assetsLayer:setPosition(visibleSize.width/2, visibleSize.height/2)
    self:addChild(assetsLayer)
    
    self.rootPanel = assetsLayer:getChildByName("Panel_root")
    self.bk = self.rootPanel:getChildByName("bk")
    self.bk_progress = self.rootPanel:getChildByName("bk_progress")
    self.progress = ccui.Helper:seekWidgetByName(self.rootPanel ,"progress")
    self.txt_progress = ccui.Helper:seekWidgetByName(self.rootPanel ,"txt_progress")
    self.txt_res = ccui.Helper:seekWidgetByName(self.rootPanel ,"txt_res")
    self.btn_ok = ccui.Helper:seekWidgetByName(self.rootPanel ,"btn_ok")
    self.btn_cancel = ccui.Helper:seekWidgetByName(self.rootPanel ,"btn_cancel")
    
    -- 对字体进行描边
    local Text_OK = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_3")
    local Text_Cancel = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_4")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_OK)    
    outLineLable:setTexOutLine(Text_Cancel)

    self:setPanel(true)
    self.progress:setPercent(0)
    self.txt_progress:setString('0%')
    local totalsize = math.floor(self.updateLogicLayer.resVerServer[1].totalsize / 1024 / 1024)
    self.txt_res:setString("文件总大小为" .. totalsize .. "M, 是否更新....")

    local function onTouchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            if sender == self.btn_ok then
                self:setPanel(false)
                self.updateLogicLayer:updateRes()
            elseif sender == self.btn_cancel then
                local wsLuaFunc = lNet.cppFunc
                wsLuaFunc:endGame()
            end    
        end
    end

    self.btn_ok:addTouchEventListener(onTouchEvent)
    self.btn_cancel:addTouchEventListener(onTouchEvent)
--[[    
    --延迟1秒
    local function callback()
        self.updateLogicLayer:updateRes()
    end
    
    local seq = cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(callback))
    self:runAction(seq)
--]]    
end

-- 资源更新完成
function UpdateUILayer:updateFinish()
    self.progress:setPercent(100)
    self.txt_progress:setString('100%')
    self.txt_res:setString('资源更新完成...') 
    self:setVisible(false)
end

-- 资源更新中
function UpdateUILayer:updateProgress(resPath, updateResTable, updateResProgress)
    local percentMaxNum = #updateResTable
    local percentNum = math.floor(updateResProgress  / percentMaxNum  *100)
    self.progress:setPercent(percentNum)
    self.txt_progress:setString(percentNum .. '%')
    self.txt_res:setString(resPath)
end

function UpdateUILayer:setPanel(v)
    if v then
        self.bk:setVisible(true)
        self.bk_progress:setVisible(false)
    else
        self.bk:setVisible(false)
        self.bk_progress:setVisible(true)
    end
end

return UpdateUILayer