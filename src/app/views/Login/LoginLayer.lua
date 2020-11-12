local stringEx =  require("common.stringEx")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local lNet = require ("net.Net")

local LoginLayer = class("LoginLayer", require("app.views.View"))

function LoginLayer:onCreate()
    local loginLayer = self:createResoueceNode("csb/loginLayer.csb")--创建CSB
    local selectSerPanel = loginLayer:getChildByName("selectSerPanel")
    selectSerPanel:setPositionY(selectSerPanel:getPositionY() + display.height/2-576/2)
    local root = loginLayer:getChildByName("Panel1")
    root:setPosition(display.center)
    local btn_login = ccui.Helper:seekWidgetByName(root ,"login_btn_ok")

    local loginAccountKey = "loginAccountTest"
    local loginAccount = cc.UserDefault:getInstance():getStringForKey(loginAccountKey)--获取曾经输入的账号
    local loginTextField = ccui.Helper:seekWidgetByName(root, "login_textfield")
   
   
     --test
--    local PublicNpc = require("app.views.Task.publicNpc")
--    local npc = PublicNpc:create(510001,420001)
--    npc:setPosition(200,300)
--    self:addChild(npc)
          
    local plistFile = cc.FileUtils:getInstance():fullPathForFilename("res/xml/boss.plist")
    local md = cc.FileUtils:getInstance():getValueMapFromFile("xml/boss.plist")
    --local md = cc.FileUtils:getInstance():getValueMapFromFile("xml/1.xml")
   
    if loginAccount ~= ""  then
        loginTextField:setString(loginAccount)
    else 
        local str = self:getRandAccount()
        loginTextField:setString(str)
       
    end  
    
    -- 按钮事件回调函数
    local function onEventTouchButton(sender,eventType)
        if eventType ~= cc.EventCode.BEGAN then
            --return
        end
        
        if eventType == cc.EventCode.ENDED then
            self:recentLogin(cc.UserDefault:getInstance():getIntegerForKey("currentServerId"))
            UserData.BaseInfo.userServAddrTable = StaticData.SelectServer[cc.UserDefault:getInstance():getIntegerForKey("currentServerId")]

            local strAccount = ccui.Helper:seekWidgetByName(root, "login_textfield"):getString()
            local indexflag = stringEx:checkInputIsCorrect(strAccount)
            if indexflag == 0 then
                
                self:login()
                UserData.BaseInfo.userAccount = strAccount --记录登陆账号
                print(UserData.BaseInfo.userAccount.."  --    "..strAccount) 
                
                cc.UserDefault:getInstance():setStringForKey(loginAccountKey,strAccount)

                UserData.BaseInfo:sendServerLogin(strAccount,"Develop")
                
--                local SceneManager = require("app.views.SceneManager")
--                SceneManager:switch(SceneManager.SceneName.SCENE_SELECTROLE)
--                lNet:sendMsgToSvr(netMsgId.CL_SERVER_LOGIN,"s",strAccount)
--                lNet:sendMsgToSvr(netMsgId.CL_PROXY_SERVERTIME,"")--发送时间请求
--                --显示加载层遮罩
--                self.loading = MaskLayer:create();
--                self.loading:loadinglayer() 
--                self:addChild(self.loading,10)
--
--                --重新一遍做新手引导
--                --                local myKey = UserData.BaseInfo.servAddrTable.NetAddr..UserData.BaseInfo.sAccount
--                --                cc.UserDefault:getInstance():setStringForKey(myKey,1)

            elseif indexflag == 1 then --表示过短或过长
             
                PublicTipLayer:setTextAction("您输入的字符过短或者过长")
            elseif indexflag == 2 then--非法
                --self:createTip("您输入的字符包含有非法字符")
                PublicTipLayer:setTextAction("您输入的字符包含有非法字符")
            end

        end
    end
    btn_login:setPressedActionEnabled(true)
    btn_login:addTouchEventListener(onEventTouchButton)
    
    self.selectServer_btn = selectSerPanel:getChildByName("selectServer_btn")
    self.serConditionText = selectSerPanel:getChildByName("serConditionText")
    self.serverNameText = selectSerPanel:getChildByName("serverNameText")    
    self.selectServerLayer = self:createSelectServer()
    
    self.selectServerLayer:setPosition(0, display.cy * 3)
    self:addChild(self.selectServerLayer)

    local fadeOut = cc.FadeOut:create(0)
    self.selectServerLayer:runAction(fadeOut)
    
    local function onTouchEvent(sender, eventType)
    	if eventType == cc.EventCode.ENDED then
    	    self.selectServerLayer:setPosition(0, 0)
            local fadeIn = cc.FadeIn:create(0.5)
            local function callBack()
                self.recentServerListView:setVisible(true)
                self.allServerListView:setVisible(true)
            end
            local callFunc = cc.CallFunc:create(callBack)
            local seq = cc.Sequence:create(fadeIn, callFunc)
            self.selectServerLayer:runAction(seq)
    	end
    end
    self.selectServer_btn:addTouchEventListener(onTouchEvent)
    self.selectServer_btn:setPressedActionEnabled(true)
    self:setSelectServerBtn(self.curServerId)
    
    UserData.BaseInfo.userServAddrTable = StaticData.SelectServer[cc.UserDefault:getInstance():getIntegerForKey("currentServerId")]    
    local ser = UserData.BaseInfo.userServAddrTable
    lNet:init(ser["NetAddr"],ser["NetPort"]) 
    
--    local view = require("app/views/Assets/UpdateUILayer.lua")
--    local updateUILayer = view:create()
--    self:addChild(updateUILayer)
end

--进入
function LoginLayer:onEnter()
    print("LoginLayer:onEnter")
    EventMgr:registListener(EventType.onServerLogin, self, self.onServerLogin)
end

--退出
function LoginLayer:onExit()
    print("LoginLayer:onExit")
    EventMgr:unregistListener(EventType.onServerLogin, self, self.onServerLogin)
end

function LoginLayer:getRandAccount() --随机账号

    local len = math.random(7,13)
    local ltter1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ltter2 = "abcdefghijklmnopqrstuvwxyz"
    local numStr = "0123456789"
    local str = {}
    for i=1, len do
        if i == 1 then
            local rand = math.random(1,2)
            local index = math.random(1,#ltter1)
            if rand == 1 then
                str[i] = string.sub(ltter1,index,index)
            elseif rand == 2 then   
                str[i] = string.sub(ltter2,index,index)
            end
        else

            local rand = math.random(1,3)
            if rand == 1 then
                local index = math.random(1,#ltter1)
                str[i] = string.sub(ltter1,index,index)
            elseif rand == 2 then   
                local index = math.random(1,#ltter2)
                str[i] = string.sub(ltter2,index,index)
            elseif rand == 3 then  
                local index = math.random(1,10) 
                str[i] = string.sub(numStr,index,index)
            end

        end

    end

    return table.concat(str,"")

end

function LoginLayer:onServerLogin(event)
    
    local result = event._usedata --登陆结果 0，成功，2未创建角色 1平台错误
    --登陆成功在基本信息那边请求验证码了，验证码之后请求基本信息，基本信息成功后自动转主界面
end

function LoginLayer:createSelectServer()
    local selectServerLayer = cc.CSLoader:createNode("csb/selectServerLayer.csb")
--    local confirmBtn = selectServerLayer:getChildByName("confirmBtn")
    
--    local function onTouchEvent(sender, eventType)
--        if eventType == cc.EventCode.ENDED then
--           self:setSelectServerBtn(self.curServerId)
--           self.recentServerListView:setVisible(false)
--           self.allServerListView:setVisible(false)
--    	   local fadeOut = cc.FadeOut:create(0.5)
--    	   local place = cc.Place:create(cc.p(0, display.cy * 3))
--    	   local seq = cc.Sequence:create(fadeOut, place)
--    	   selectServerLayer:runAction(seq)
--    	end
--    end
--    confirmBtn:addTouchEventListener(onTouchEvent)
--    confirmBtn:setPressedActionEnabled(true)
    local recentServerPanel = selectServerLayer:getChildByName("recentServerPanel")
    self.recentServerListView = recentServerPanel:getChildByName("recentServerListView")
    self:initListView(self.recentServerListView)
    self:initRecentServerLV()
    
    local allServerPanel = selectServerLayer:getChildByName("allServerPanel")
    self.allServerListView = allServerPanel:getChildByName("allServerListView")
    self:initListView(self.allServerListView)
    self:initAllServerLV()
    
    return selectServerLayer
end

function LoginLayer:initListView(listView)
    listView:setTouchEnabled(true)
    listView:setBounceEnabled(true)
    listView:setSwallowTouches(true)
    listView:refreshView()
    listView:jumpToTop()
    listView:setVisible(false)
end

function LoginLayer:initRecentServerLV()
    local allRecentLogin = self:getRecentLogin()
    if allRecentLogin == nil then
        return
    end
    
    for i = 1, #allRecentLogin do
        local serverId = tonumber(allRecentLogin[i])
        if serverId <= #StaticData.SelectServer then
            break
        end

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(257, 84))
        local serverNode = cc.CSLoader:createNode("csb/serverNode.csb")
        local Panel = serverNode:getChildByName("Panel")
        local text = Panel:getChildByName("serConditionText")
        local btn = Panel:getChildByName("serverBtn")
        
        local function onTouchEvent(sender, eventType)
            if eventType == cc.EventCode.ENDED then
                self.curServerId = serverId
                print("checked serverId is   " .. self.curServerId)
                self:setSelectServerBtn(self.curServerId)
                self.recentServerListView:setVisible(false)
                self.allServerListView:setVisible(false)
                local fadeOut = cc.FadeOut:create(0.5)
                local place = cc.Place:create(cc.p(0, display.cy * 3))
                local seq = cc.Sequence:create(fadeOut, place)
                self.selectServerLayer:runAction(seq)
            end
        end
        
        btn:setPressedActionEnabled(true)
        btn:addTouchEventListener(onTouchEvent)
        btn:setTitleText(StaticData.SelectServer[serverId].ServerName)
        
        self:setTextStrAndColor(text, StaticData.SelectServer[serverId].ServerCondition)
        
        layout:addChild(serverNode)
        layout:setTouchEnabled(true)
        layout:setAnchorPoint(0, 0)
        self.recentServerListView:addChild(layout)
    end
end

function LoginLayer:initAllServerLV()
    local serverTable = StaticData.SelectServer
    for i = 1, #serverTable do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(534, 80))
        layout:setTouchEnabled(true)
        layout:setAnchorPoint(0, 0)
        if i % 2 == 1 then
            local childNode1 = self:createChildNode(i)
            childNode1:setPosition(cc.p(0, 10))
            layout:addChild(childNode1)
            if i + 1 <= #serverTable then
                local childNode2 = self:createChildNode(i + 1)
                childNode2:setPosition(cc.p(277, 10))
                layout:addChild(childNode2)
            end
            self.allServerListView:addChild(layout)
        end
    end
end

function LoginLayer:createChildNode(serverId)
    local serverNode = cc.CSLoader:createNode("csb/serverNode.csb")
    local Panel = serverNode:getChildByName("Panel")
    local btn = Panel:getChildByName("serverBtn")
    local serConditionText = Panel:getChildByName("serConditionText")
    
    local strConditionText = StaticData.SelectServer[serverId].ServerCondition
    self:setTextStrAndColor(serConditionText, strConditionText)
    
    local function onTouchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            self.curServerId = serverId
            print("checked serverId is   " .. self.curServerId)
            self:setSelectServerBtn(self.curServerId)
            self.recentServerListView:setVisible(false)
            self.allServerListView:setVisible(false)
            local fadeOut = cc.FadeOut:create(0.5)
            local place = cc.Place:create(cc.p(0, display.cy * 3))
            local seq = cc.Sequence:create(fadeOut, place)
            self.selectServerLayer:runAction(seq) 
        end
    end
    
    btn:addTouchEventListener(onTouchEvent)
    btn:setTitleText(StaticData.SelectServer[serverId].ServerName)
    btn:setPressedActionEnabled(true)
    
    return serverNode
end

function LoginLayer:setSelectServerBtn(chooseServerId)
    local currentServerId = cc.UserDefault:getInstance():getIntegerForKey("currentServerId")
    local serverId = 0
    if currentServerId == 0 and chooseServerId == nil then
        serverId = #StaticData.SelectServer
    elseif chooseServerId ~= nil then
        serverId = chooseServerId
    elseif currentServerId ~= 0 then
        serverId = currentServerId
    end
    cc.UserDefault:getInstance():setIntegerForKey("currentServerId", serverId)
    
    local strConditionText = StaticData.SelectServer[serverId].ServerCondition
    self:setTextStrAndColor(self.serConditionText, strConditionText)
    
--    self.selectServer_btn:setTitleText(StaticData.SelectServer[serverId].ServerName)
    self.serverNameText:setString(StaticData.SelectServer[serverId].ServerName)
end

function LoginLayer:setTextStrAndColor(text, str)
    text:setString(str)
    if str == "流畅" then
        text:setColor(cc.c3b(0, 255, 0))
    elseif str == "普通" then
        text:setColor(cc.c3b(255, 214, 0))
    elseif str == "爆满" then
        text:setColor(cc.c3b(255, 0, 0))
    end
end

function LoginLayer:recentLogin(serverId)
    local isSame = 0
    local loginId = tostring(serverId)
    local allRecentLogin = self:getRecentLogin()
    if cc.UserDefault:getInstance():getStringForKey("recentLogin") == "" then
        cc.UserDefault:getInstance():setStringForKey("recentLogin", loginId)
        return
    else
        for i = 1, #allRecentLogin do
            if allRecentLogin[i] == loginId then
                isSame = i
                break
            end
        end
    end
    
    if isSame ~= 0 then
        for i = isSame, 1, -1 do
            if i ~= 1 then
                allRecentLogin[i] = allRecentLogin[i - 1]
            else
                allRecentLogin[i] = serverId
            end
        end
    else
        for i = #allRecentLogin, 1, -1 do
            if #allRecentLogin == 1 then
                allRecentLogin[i + 1] = allRecentLogin[i]
                allRecentLogin[i] = serverId
            else
                if i ~= 1 then
                    allRecentLogin[i + 1] = allRecentLogin[i]
                else
                    allRecentLogin[i + 1] = allRecentLogin[i]
                    allRecentLogin[i] = serverId
                end
            end
        end
    end
    
    local strRencentLogin = tostring(allRecentLogin[1])
    for i = 2, #allRecentLogin do
        if i <= 3 then
            strRencentLogin = strRencentLogin .. "*" .. allRecentLogin[i]
        else
            break
        end
    end
    cc.UserDefault:getInstance():setStringForKey("recentLogin", strRencentLogin)
end

function LoginLayer:getRecentLogin()
    local strRecentLogin = cc.UserDefault:getInstance():getStringForKey("recentLogin")
    if strRecentLogin == "" or strRecentLogin == nil then
        return nil
    end
    local allRecentLogin = string.split(strRecentLogin, "*")
    
    return allRecentLogin
end

function LoginLayer:login()
    UserData.BaseInfo:sendServerRandomName(1)--请求随机名字，开始进来默认是男的，用在创建角色那边  
end


return LoginLayer