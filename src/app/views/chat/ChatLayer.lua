--聊天文字对齐目前只适配了ios平台

local NetMsgId = require("net.NetMsgId")
local Net = require("net.Net")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local UserData = require("user_data.UserData")
local publicTipLayer = require("app.views.public.publicTipLayer")
local TimeFormat = require("common.TimeFormat")


local ChatLayer = class("ChatLayer", function ()
    return cc.Layer:create()
end)


function ChatLayer:create()
    local view = ChatLayer.new()
    view:init()
    local function onNodeEvent(eventType)
        if eventType == "enter" then
            view:onEnter()
        elseif eventType == "exit" then
            view:onExit()
        end
    end
    view:registerScriptHandler(onNodeEvent)
    return view
end


function ChatLayer:ctor()
    --宏
    self.MACRO = {
        TalkLen = 3 * 60,                                              --一条消息最大长度
        RichWidth = 400,                                              --里面聊天富文本宽度
        RichPosX = 370,                                                --里面聊天富文本X位置
        RichPosY = 20,                                                  --里面聊天富文本Y位置
        FontSize = 16,                                                   --里面聊天字体大小
        CustomFont_1 = 'Default/FZLBJW.TTF',              --自定义字体1
        CustomFont_2 = 'Default/FZY1JW.TTF',              --自定义字体2
        InFrameWidth = 892,                                         --里面聊天框宽度
        InFrameHeight = 571,                                        --里面聊天框高度
        OutFrameWidth = 415,                                       --外面聊天框宽度 
        RichPosXEx = 210,                                             --外面聊天富文本X位置
        RichPosYEx = 26,                                               --外面聊天富文本Y位置
        WorldChatFreeNum = 10,                                   --世界聊天免费次数
        ChatDownTime = 5,                                           --聊天内置倒计时限定
    }
    
    self.recvPlayerId = nil                                             --当前私聊被发起人的角色ID
    self.recvPlayerName = nil                                       --当前私聊被发起人的角色名字
    self.pushBlackName = nil                                       --拉黑玩家名字
    self.preChatType = 'WORLD'                                   --当前聊天类型( WORLD, PRIVATE, SHARE, MAINOUT)
    self.isSend = true                                                   --是否倒计时外
    
    self.TipObj = publicTipLayer:create() 
    self:addChild(self.TipObj, 99)  
end


function ChatLayer:onEnter()
    EventMgr:registListener(EventType.ReqWorldChatRet, self, self.ReqWorldChatRet)
    EventMgr:registListener(EventType.ReqNoticeWorldChat, self, self.ReqNoticeWorldChat)
    EventMgr:registListener(EventType.ReqPrivateChatRet, self, self.ReqPrivateChatRet)
    EventMgr:registListener(EventType.OnPullBlack, self, self.OnPullBlack)
    EventMgr:registListener(EventType.ReqReadMail, self, self.ReqReadMail)
    EventMgr:registListener(EventType.ReqPickMail, self, self.ReqPickMail)
    EventMgr:registListener(EventType.ReqDelMail, self, self.ReqDelMail)
    EventMgr:registListener(EventType.ReqNoticeAddMail, self, self.ReqNoticeAddMail)
end


function ChatLayer:onExit()
    EventMgr:unregistListener(EventType.ReqWorldChatRet, self, self.ReqWorldChatRet)
    EventMgr:unregistListener(EventType.ReqNoticeWorldChat, self, self.ReqNoticeWorldChat)
    EventMgr:unregistListener(EventType.ReqPrivateChatRet, self, self.ReqPrivateChatRet)
    EventMgr:unregistListener(EventType.OnPullBlack, self, self.OnPullBlack) 
    EventMgr:unregistListener(EventType.ReqReadMail, self, self.ReqReadMail)
    EventMgr:unregistListener(EventType.ReqPickMail, self, self.ReqPickMail) 
    EventMgr:unregistListener(EventType.ReqDelMail, self, self.ReqDelMail)
    EventMgr:unregistListener(EventType.ReqNoticeAddMail, self, self.ReqNoticeAddMail)
end


function ChatLayer:init()
    local chatLayer = cc.CSLoader:createNode("csb/chat_layer.csb")
    self:addChild(chatLayer)
    self.rootPanel = chatLayer:getChildByName('Panel_root')
    self.rootPanel:setPosition(-self.MACRO.InFrameWidth,-self.MACRO.InFrameHeight) 
    self.widgetTable = {
        Button_world = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_world"),
        Button_private = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_private"),
        Button_mail = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_mail"),
        Button_back = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_back"),
        Text_privateObj = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_privateObj"),
        Image_inputbg = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_inputbg"),
        TextField_1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"TextField_1"),
        Image_restNum = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_restNum"),
        Text_restNum = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_restNum"),
        Button_send = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_send"),
        ListView_world = ccui.Helper:seekWidgetByName(self.rootPanel ,"ListView_world"),
        ListView_private = ccui.Helper:seekWidgetByName(self.rootPanel ,"ListView_private"),
        ListView_mail = ccui.Helper:seekWidgetByName(self.rootPanel ,"ListView_mail"),
        Panel_input = ccui.Helper:seekWidgetByName(self.rootPanel ,"Panel_input"),
        Image_worldPoint = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_worldPoint"),
        Image_privatePoint = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_privatePoint"),
        Image_mailPoint = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_mailPoint"),
    }
        
    local chatOutNode = cc.CSLoader:createNode("csb/chat_outframe_node.csb")
    self:addChild(chatOutNode)
    self.rootPanelEx = chatOutNode:getChildByName('Panel_root')
    self.widgetTableEx = {
        Button_chatToIn = ccui.Helper:seekWidgetByName(self.rootPanelEx ,"Button_chatToIn"),
        Panel_mask = ccui.Helper:seekWidgetByName(self.rootPanelEx ,"Panel_mask"),
    }
    
    if UserData.BaseInfo.nWorldChatNum < self.MACRO.WorldChatFreeNum then
        local num = self.MACRO.WorldChatFreeNum - UserData.BaseInfo.nWorldChatNum
        self.widgetTable.Text_restNum:setString('免费(' .. num .. ')') 
    else
        local num = UserData.BaseInfo.nWorldChatNum - self.MACRO.WorldChatFreeNum + 1
        self.widgetTable.Text_restNum:setString('元宝(' .. num .. ')') 
    end
    
    self:switchState(self.preChatType)
    self:registerButtomEvent()
    self:setButtomState(self.preChatType)
    self:initTipRedPoint() 
end


--切换状态：世界，私聊，邮件
function ChatLayer:switchState(state) 
    if state == 'WORLD' then
        self.widgetTable.ListView_world:setVisible(true)
        self.widgetTable.ListView_private:setVisible(false)
        self.widgetTable.ListView_mail:setVisible(false) 
        self.widgetTable.Text_privateObj:setVisible(false)
        self.widgetTable.Panel_input:setVisible(true) 
        self.widgetTable.Image_inputbg:setContentSize(cc.size(500,46))
        self.widgetTable.TextField_1:setContentSize(cc.size(500,30))
        self.widgetTable.Image_restNum:setVisible(true)
        self.widgetTable.Image_worldPoint:setVisible(false) 
        self:setRedPointTipToOne(state)
    elseif state == 'PRIVATE' then
        self.widgetTable.ListView_world:setVisible(false)
        self.widgetTable.ListView_private:setVisible(true)
        self.widgetTable.ListView_mail:setVisible(false) 
        self.widgetTable.Text_privateObj:setVisible(true)
        self.widgetTable.Panel_input:setVisible(true) 
        self.widgetTable.Image_inputbg:setContentSize(cc.size(387,46))
        self.widgetTable.TextField_1:setContentSize(cc.size(387,30)) 
        self.widgetTable.Image_restNum:setVisible(false)
        self.widgetTable.Image_privatePoint:setVisible(false) 
        self:setRedPointTipToOne(state)
    elseif state == 'MAIL' then
        self.widgetTable.ListView_world:setVisible(false)
        self.widgetTable.ListView_private:setVisible(false)
        self.widgetTable.ListView_mail:setVisible(true) 
        self.widgetTable.Text_privateObj:setVisible(false)
        self.widgetTable.Panel_input:setVisible(false) 
        self.widgetTable.Image_mailPoint:setVisible(false)  
	end
end


--注册按钮响应事件
function ChatLayer:registerButtomEvent()
    self.widgetTable.Button_send:setPressedActionEnabled(true)
    self.widgetTable.Button_send:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self:sendBtnFunc()
        end
    end)
    
    self.widgetTable.Button_back:setPressedActionEnabled(true)
    self.widgetTable.Button_back:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.rootPanel:runAction(cc.MoveTo:create(0.3,cc.p(-self.MACRO.InFrameWidth,-self.MACRO.InFrameHeight)))
            self.rootPanelEx:runAction(cc.MoveTo:create(0.3,cc.p(0, 0)))
        end
    end)
    
    self.widgetTableEx.Button_chatToIn:setPressedActionEnabled(true)
    self.widgetTableEx.Button_chatToIn:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.rootPanel:runAction(cc.MoveTo:create(0.3,cc.p(0, 0)))
            self.rootPanelEx:runAction(cc.MoveTo:create(0.3,cc.p(-self.MACRO.OutFrameWidth, 0)))
        end
    end)
    
    self.widgetTable.Button_world:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.preChatType = 'WORLD'
            self:switchState(self.preChatType)
            self:setButtomState(self.preChatType)
        end
    end)
    
    self.widgetTable.Button_private:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then  
            self.preChatType = 'PRIVATE'
            self:switchState(self.preChatType)
            self:setButtomState(self.preChatType)
            local privatemsg = UserData.Chat.privateChatTable
            for key, var in ipairs(privatemsg) do
                if var.nPlayerId ~= UserData.BaseInfo.userID then
                    self.recvPlayerId = var.nPlayerId
                    self.recvPlayerName = var.sActorName
                end
            end
            if self.recvPlayerId ~= nil then
                self.widgetTable.Text_privateObj:setString(self.recvPlayerName)
            else
                self.widgetTable.Text_privateObj:setString('选择私聊对象')
            end
        end
    end)
    
    self.widgetTable.Button_mail:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.preChatType = 'MAIL'
            self:switchState(self.preChatType)
            self:setButtomState(self.preChatType)
            local isRead = true
            for key, var in ipairs(UserData.Mail.mailList) do
                if var.byIsRead == 0 then
                    isRead = false
                    break
                end
            end
            if isRead == true then
                self:loadMailList()
            else
                Net:sendMsgToSvr(NetMsgId.CL_SERVER_READ_EMAIL, "ui", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID)
            end
        end
    end)
end


--设置菜单按钮高亮显示
function ChatLayer:setButtomState(state)
  
    local function selectButtom(isLight, btnName)
        if isLight then
            btnName:loadTextureNormal("ui/public/public_btn_01.png")
            btnName:loadTexturePressed("ui/public/public_btn_01.png")
            btnName:loadTextureDisabled("ui/public/public_btn_01.png")
            btnName:setTouchEnabled(false)
        else
            btnName:loadTextureNormal("ui/public/public_btn_02.png")
            btnName:loadTexturePressed("ui/public/public_btn_02.png")
            btnName:loadTextureDisabled("ui/public/public_btn_02.png")
            btnName:setTouchEnabled(true)
        end
    end
    if state == 'WORLD' then
        selectButtom(true,self.widgetTable.Button_world)
        selectButtom(false,self.widgetTable.Button_private)
        selectButtom(false,self.widgetTable.Button_mail)
        
    elseif state == 'PRIVATE' then
        selectButtom(false,self.widgetTable.Button_world)
        selectButtom(true,self.widgetTable.Button_private) 
        selectButtom(false,self.widgetTable.Button_mail)
        
    elseif state == 'MAIL' then
        selectButtom(false,self.widgetTable.Button_world)
        selectButtom(false,self.widgetTable.Button_private) 
        selectButtom(true,self.widgetTable.Button_mail)
    
    end

end


--初始化红点提示
function ChatLayer:initTipRedPoint()
    self.widgetTable.Image_worldPoint:setVisible(false) 
    self.widgetTable.Image_privatePoint:setVisible(false) 
    self.widgetTable.Image_mailPoint:setVisible(false) 
    
    for key, var in ipairs(UserData.Chat.worldChatTable) do
        if var.tipRedPoint == 0 and self.preChatType ~= 'WORLD' then
            self.widgetTable.Image_worldPoint:setVisible(true) 
            break 
        end
    end
    
    for key, var in ipairs(UserData.Chat.privateChatTable) do
        if var.tipRedPoint == 0 and self.preChatType ~= 'PRIVATE' then
            self.widgetTable.Image_privatePoint:setVisible(true) 
            break 
        end
    end
    
    for key, var in ipairs(UserData.Mail.mailList) do
        if var.byIsRead == 0 and self.preChatType ~= 'MAIL' then
            self.widgetTable.Image_mailPoint:setVisible(true) 
            break 
        end
    end
    
end


--设置红点提示
function ChatLayer:setRedPointTipToOne(state) 
	if state == 'WORLD' then
        for key, var in ipairs(UserData.Chat.worldChatTable) do
            var.tipRedPoint = 1 
        end
    elseif state == 'PRIVATE' then
        for key, var in ipairs(UserData.Chat.privateChatTable) do
            var.tipRedPoint = 1 
        end
    end
end


--发送聊天
function ChatLayer:sendBtnFunc()
    local senderName = UserData.BaseInfo.userName
    local sendContent = self.widgetTable.TextField_1:getString() 
    --sendContent = 'FJDSLKFJKLDSF束带结发看电视剧弗兰克圣诞节发链接dsjkfljdsklfj神经分裂会计师的路口附近的史莱克jdkls杜绝浪费'
    local sendContentLen = string.len(sendContent) 
    
    if sendContentLen > 0 then
        if sendContentLen > self.MACRO.TalkLen then  
            self.TipObj:setTextAction("文字过长，请重新输入！") 

        else
            if self.preChatType == 'WORLD' then
                self:countDownTime(sendContent)
            elseif self.preChatType == 'PRIVATE' then
                if self.recvPlayerId ~= nil then
                    local isPushBlack = UserData.Friend:searchIsBlackName(self.recvPlayerId)
                    if isPushBlack == true then
                        self.TipObj:setTextAction('玩家 ' .. self.recvPlayerName .. ' 已被你拉入黑名单') 
                    else
                        Net:sendMsgToSvr(NetMsgId.CL_SERVER_PRIVATECHAT, "uiis", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, self.recvPlayerId, sendContent)
                    end
                else
                    self.TipObj:setTextAction("请选择私聊对象！") 
                end
            end
        end 
    end
    
end


--聊天时间间隔限制(目前只对世界聊天做了时间限制)
function ChatLayer:countDownTime(sendContent)
    if self.isSend == true then
        Net:sendMsgToSvr(NetMsgId.CL_SERVER_WORLDCHAT, "uis", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, sendContent)
        local update = function()
            self.MACRO.ChatDownTime = self.MACRO.ChatDownTime - 1
            if self.MACRO.ChatDownTime == 0 then
                self.widgetTable.Button_send:stopAllActions()
                self.MACRO.ChatDownTime = 5 
                self.isSend = true   
            end
        end 
        self.widgetTable.Button_send:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(update)
        )))
        self.isSend = false
    else 
        self.TipObj:setTextAction('发送消息太快(倒计时' .. self.MACRO.ChatDownTime .. 's)') 
    end
end


--显示聊天记录
function ChatLayer:showChatMsg(state) 
    local addHeight = 0
    local layout = ccui.Layout:create()
    local itemNode = cc.CSLoader:createNode("csb/chat_item_node.csb") 
    local imageRoot = itemNode:getChildByName('Image_root')
    local Panel_top = ccui.Helper:seekWidgetByName(imageRoot ,"Panel_top")
    local Image_head = ccui.Helper:seekWidgetByName(imageRoot ,"Image_head")
    local Text_lev = ccui.Helper:seekWidgetByName(imageRoot ,"Text_lev")
    local Text_name = ccui.Helper:seekWidgetByName(imageRoot ,"Text_name")
    local Text_time = ccui.Helper:seekWidgetByName(imageRoot ,"Text_time")
    layout:addChild(itemNode)
    
    local msgTable = nil
    local chatPanle = nil
    if state == 'WORLD' then
        local worldTable = UserData.Chat.worldChatTable
        msgTable = worldTable[#worldTable]
        chatPanle = self.widgetTable.ListView_world
    elseif state == 'PRIVATE' then
        local privateTable = UserData.Chat.privateChatTable
        msgTable = privateTable[#privateTable]
        chatPanle = self.widgetTable.ListView_private
    end
    
    msgTable.tipRedPoint = 1   --将这个消息标记为已读
    local time = self:splitTime(msgTable.strTime)
    local richtext = self:createRichText(msgTable.sChat)
    Text_lev:setString(msgTable.nLevel)
    Text_name:setString(msgTable.sActorName)
    Text_time:setString(string.format('%02d:%02d', time.hour, time.min)) 
    imageRoot:addChild(richtext)
    richtext:setPosition(cc.p(self.MACRO.RichPosX,self.MACRO.RichPosY)) 
    addHeight = richtext:xxgetRichSize().height 
    if addHeight > self.MACRO.FontSize then
        addHeight = addHeight - self.MACRO.FontSize 
        Panel_top:setPositionY(Panel_top:getPositionY() + addHeight)
        local defaultSize = imageRoot:getContentSize()
        imageRoot:setContentSize(cc.size(defaultSize.width, defaultSize.height + addHeight)) 
        layout:setContentSize(imageRoot:getContentSize())
        richtext:setPosition(cc.p(self.MACRO.RichPosX,self.MACRO.RichPosY + addHeight))
    end
    
    chatPanle:pushBackCustomItem(layout)
    self:lookChatTwoFrame(Image_head,msgTable.sActorName, msgTable.nPlayerId, msgTable.nLevel)
    
    local arr = chatPanle:getChildren()
    if #arr > UserData.Chat.chatMaxNum then
        arr[1]:removeFromParent()
    end 
    
    chatPanle:forceDoLayout() 
    chatPanle:jumpToBottom()
    self:inMsgToOutMsg(state, msgTable.sChat,msgTable.sActorName)
end


--切换场景重新加载历史聊天
function ChatLayer:reLoadWorldChatMsg()
    --TODO：同显示聊天
    
end


--查看人物属性
function ChatLayer:lookChatTwoFrame(imageBtn, privateObjName, privateObjId, lev)  
    if UserData.BaseInfo.userName ~= privateObjName then
        imageBtn:setTouchEnabled(true)   --屏蔽了listview...
        imageBtn:addTouchEventListener(function(sender,event)
            if event == cc.EventCode.ENDED then 
                local twoFrame = cc.CSLoader:createNode("csb/chat_twoFrame_node.csb")  
                local Panel_root = twoFrame:getChildByName('Panel_root')
                local Button_close = ccui.Helper:seekWidgetByName(Panel_root ,"Button_close")
                local Button_sendChat = ccui.Helper:seekWidgetByName(Panel_root ,"Button_sendChat")
                local Button_pushBlack = ccui.Helper:seekWidgetByName(Panel_root ,"Button_pushBlack")
                local Text_playName = ccui.Helper:seekWidgetByName(Panel_root ,"Text_playName")
                local Text_playLev = ccui.Helper:seekWidgetByName(Panel_root ,"Text_playLev")
                Text_playName:setString(privateObjName)
                Text_playLev:setString(lev)
                self:addChild(twoFrame) 
                twoFrame:setPosition(display.center.x,display.center.y)

                Button_close:addTouchEventListener(function(sender, event)
                    if event == cc.EventCode.ENDED then 
                        twoFrame:removeFromParent()
                    end
                end)

                local isPushBlack = UserData.Friend:searchIsBlackName(privateObjId)
                if isPushBlack ~= true then
                    Button_sendChat:setTouchEnabled(true)
                    Button_sendChat:setColor(cc.c3b(255,255,255))
                    Button_sendChat:addTouchEventListener(function(sender, event)
                        if event == cc.EventCode.ENDED then 
                            self.widgetTable.Text_privateObj:setString(privateObjName)
                            twoFrame:removeFromParent()
                            self.preChatType = 'PRIVATE'
                            self.recvPlayerId = privateObjId
                            self.recvPlayerName = privateObjName
                            self:switchState(self.preChatType)
                            self:setButtomState(self.preChatType)
                        end
                    end)

                    Button_pushBlack:setTouchEnabled(true)
                    Button_pushBlack:setColor(cc.c3b(255,255,255))
                    Button_pushBlack:addTouchEventListener(function(sender, event)
                        if event == cc.EventCode.ENDED then 
                            --拉黑
                            twoFrame:removeFromParent()
                            UserData.Friend:sendServerPullBlack(privateObjId)
                        end
                    end)
                else
                    Button_sendChat:setTouchEnabled(false)
                    Button_sendChat:setColor(cc.c3b(192,192,192))
                    Button_pushBlack:setTouchEnabled(false)
                    Button_pushBlack:setColor(cc.c3b(192,192,192))
                end
                    
                self.pushBlackName = privateObjName

            end
        end)
    end
end


--时间分割
function ChatLayer:splitTime(strTime)
    local time = {}
    time.year   = tonumber(string.sub(strTime,1,4))
    time.month  = tonumber(string.sub(strTime,6,7))
    time.day    = tonumber(string.sub(strTime,9,10))
    time.hour   = tonumber(string.sub(strTime,12,13))
    time.min    = tonumber(string.sub(strTime,15,16))
    time.sec    = tonumber(string.sub(strTime,18,19))
	return time
end


--创建富文本
function ChatLayer:createRichText(str)
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)  
    richText:setContentSize(cc.size(self.MACRO.RichWidth,0))  

    local res = ccui.RichElementText:create(1 ,cc.c3b(255,255,255), 255, str, self.MACRO.CustomFont_2, self.MACRO.FontSize) 
    richText:pushBackElement(res)
       
    return richText
end

 
--初始化外部聊天显示
function ChatLayer:inMsgToOutMsg( state, strText, sendName) 
    self.widgetTableEx.Panel_mask:removeAllChildren()
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)  
    richText:setContentSize(cc.size(self.MACRO.OutFrameWidth,0)) 
    richText:setPosition(cc.p(self.MACRO.RichPosXEx,self.MACRO.RichPosYEx))  
    
    if state == 'WORLD' then
        local res1 = ccui.RichElementText:create(1,cc.c3b(0,0,255),255,'[世]',self.MACRO.CustomFont_2,25)
        richText:pushBackElement(res1)
        local res2 = ccui.RichElementText:create(2,cc.c3b(228,107,11),255,sendName .. '：' ,self.MACRO.CustomFont_2,25)
        richText:pushBackElement(res2)
        local res3 = ccui.RichElementText:create(3 ,cc.c3b(255,255,255), 255, strText, self.MACRO.CustomFont_2, 25)
        richText:pushBackElement(res3)
    elseif state == 'PRIVATE' then
        local res1 = ccui.RichElementText:create(1,cc.c3b(111,9,191),255,'[私]',self.MACRO.CustomFont_2,25)
        richText:pushBackElement(res1)
        local res2 = ccui.RichElementText:create(2,cc.c3b(228,107,11),255,sendName .. '：' ,self.MACRO.CustomFont_2,25)
        richText:pushBackElement(res2)
        local res3 = ccui.RichElementText:create(3 ,cc.c3b(255,255,255), 255, strText, self.MACRO.CustomFont_2, 25)
        richText:pushBackElement(res3)
    end
    
    self.widgetTableEx.Panel_mask:addChild(richText)
end


--邮件-------------------------------------
function ChatLayer:loadMailList()
    self.widgetTable.ListView_mail:removeAllChildren()
    if #UserData.Mail.mailList > 0 then
        table.sort(UserData.Mail.mailList, function (a,b)
            local time1 =  TimeFormat:getSecondsInter(a.sSendTime)
            local time2 = TimeFormat:getSecondsInter(b.sSendTime) 
            return time1 < time2
        end)   
        for key, var in ipairs(UserData.Mail.mailList) do
            local layout = ccui.Layout:create()
            local mailItem = cc.CSLoader:createNode("csb/chat_mailItem_node.csb")  
            local Image_root = mailItem:getChildByName('Image_root')
            local Text_title = ccui.Helper:seekWidgetByName(Image_root ,"Text_title")
            local Text_content = ccui.Helper:seekWidgetByName(Image_root ,"Text_content")
            local Button_mail = ccui.Helper:seekWidgetByName(Image_root ,"Button_mail")
            local Text_time = ccui.Helper:seekWidgetByName(Image_root ,"Text_time")
            local Panel_loadGoods = ccui.Helper:seekWidgetByName(Image_root ,"Panel_loadGoods")
            layout:addChild(mailItem)
            layout:setContentSize(Image_root:getContentSize())
            self.widgetTable.ListView_mail:pushBackCustomItem(layout)
 
            Text_title:setString(var.sSubject)
            Text_content:setString(var.sContent)
            local timeData = {
                TimeFormat:getSecondsInterFromMark(var.sSendTime)
            }
            Text_time:setString(timeData[3] .. '前')

            self:mailButtonFun(layout,Button_mail, var, Panel_loadGoods)
            self:loadMailGoods(var, Panel_loadGoods)
        end
        self.widgetTable.ListView_mail:forceDoLayout() 
        self.widgetTable.ListView_mail:jumpToTop()
    end
    
end


function ChatLayer:mailButtonFun(layout, Button_mail, var, Panel_loadGoods) 
    local isLOrD = true
    if var.byAttachIsPick == 0 and var.nAttachItemId1 ~= 0 then
        Button_mail:setTitleText('领取')
        isLOrD = true
    else
        Button_mail:setTitleText('删除')
        isLOrD = false
    end
    
    Button_mail:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            if isLOrD == true then--领取
                Button_mail:setTitleText('删除')
                isLOrD = false
                Net:sendMsgToSvr(NetMsgId.CL_SERVER_PICK_ATTACH, "uii", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, var.nEmailId)
                Panel_loadGoods:removeAllChildren()
            else--删除
                layout:removeFromParent() 
                Net:sendMsgToSvr(NetMsgId.CL_SERVER_DEL_EMAIL, "uii", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, var.nEmailId)
            end
        end
    end)
end


--临时做法，还没正式图标
function ChatLayer:loadMailGoods(var, Panel_loadGoods) 
    if var.byAttachIsPick == 0 then
        if var.nAttachItemId1 == 0 then   --没有
            Panel_loadGoods:removeAllChildren()
        elseif var.nAttachItemId2 == 0 then  --1个
            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(78,28)
        elseif var.nAttachItemId3 == 0 then  --2个
            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(35,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(118,28)
        elseif var.nAttachItemId4 == 0 then  -- 3个
            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(-26,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(58,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(140,28)
        else  --4个
            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(-108,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(-23,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(62,28)

            local sprite = cc.Sprite:create('ui/public/public_other_07.png')
            Panel_loadGoods:addChild(sprite)
            sprite:setPosition(146,28)
        end
    else
        Panel_loadGoods:removeAllChildren()
    end

end


--服务端---------------------------------------
--世界聊天服务端返回
function ChatLayer:ReqWorldChatRet(event)
    if event._usedata == 0 then 
        print('世界聊天返回成功')
    else
        self.TipObj:setTextAction("元宝不足！") 
    end
end
 

-- 服务端向客户端通知世界聊天
function ChatLayer:ReqNoticeWorldChat(event)
    self:showChatMsg('WORLD') 
    self.widgetTable.TextField_1:setString("")
    if UserData.BaseInfo.nWorldChatNum < self.MACRO.WorldChatFreeNum then
        local num = self.MACRO.WorldChatFreeNum - UserData.BaseInfo.nWorldChatNum
        self.widgetTable.Text_restNum:setString('免费(' .. num .. ')') 
    else
        local num = UserData.BaseInfo.nWorldChatNum - self.MACRO.WorldChatFreeNum + 1
        self.widgetTable.Text_restNum:setString('元宝(' .. num .. ')') 
    end
    
    if self.preChatType ~= 'WORLD' then
        self.widgetTable.Image_worldPoint:setVisible(true) 
    end
end


--服务端向客户端返回私聊
function ChatLayer:ReqPrivateChatRet(event)
	if event._usedata == 0 then
        self:showChatMsg('PRIVATE') 
        self.widgetTable.TextField_1:setString("")
        
        if self.preChatType ~= 'PRIVATE' then
            self.widgetTable.Image_privatePoint:setVisible(true)  
        end
	else
        self.TipObj:setTextAction("私聊失败！") 
	end
end


-- 服务端向客户端返回玩家拉黑请求
function ChatLayer:OnPullBlack(event) 
	if event._usedata == 0 then
        self.TipObj:setTextAction('玩家 ' .. self.pushBlackName .. ' 已被你拉入黑名单') 
	else 
        self.TipObj:setTextAction('拉黑 ' .. self.pushBlackName .. ' 失败') 
	end
end


-- 服务端向客户端返回邮件读取请求
function ChatLayer:ReqReadMail(event) 
	if event._usedata == 0 then
        self:loadMailList()
	else
        self.TipObj:setTextAction('邮件读取失败！') 
	end
end


--服务端向客户端返回提取邮件附件
function ChatLayer:ReqPickMail(event) 
    if event._usedata == 0 then
        print('邮件提取成功')
    else
        self.TipObj:setTextAction('邮件提取失败！') 
    end
end


-- 服务端向客户端返回删除邮件
function ChatLayer:ReqDelMail(event)
    if event._usedata == 0 then
        print('邮件删除成功')
    else
        self.TipObj:setTextAction('邮件删除失败！')  
    end
end


-- 服务端通知客户端多了一封邮件
function ChatLayer:ReqNoticeAddMail(event) 
    if self.preChatType ~= 'MAIL' then
        self.widgetTable.Image_mailPoint:setVisible(true)    
    end
end


return ChatLayer