local ManegerTask = require("app.views.Task.ManagerTask")
local DataManager = require("app.views.public.DataManager")
local PlayPageTurn = require("app.views.public.PlayPageTurn")

local PlotLayer = class("PlotLayer", function()
    return cc.Layer:create()
end)

local typingSpeed = 0.05
local vibrationTime = 16
local currentTaskId = 0 -- 当前剧情对话的任务ID
function PlotLayer:create(eventBtn, seriesId, callBack)
    local view = PlotLayer.new()
    view:init(eventBtn, seriesId, callBack)
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

function PlotLayer:ctor()

end

function PlotLayer:init(eventBtn, seriesId, callBack)
    self.eventBtn = eventBtn
    self.seriesId = seriesId
    self.callBack = callBack

    audio.playMusic("audioMusic/lundun.mp3", true)
    --audio.setMusicVolume(1.0)
    
    local csb = cc.CSLoader:createNode("csb/PlotLayer.csb")
    self:addChild(csb)
    self.Panel_1 = csb:getChildByName("Panel_1")
    csb:setPositionY(csb:getPositionY() + (display.height - 576)/2)
	self.bgPanel = csb:getChildByName("bgPanel")
    self.topPanel = csb:getChildByName("topPanel")                       -- 获取顶部Panel
    self.bottomPanel = csb:getChildByName("bottomPanel")                 -- 获取底部Panel
    
--    self.bgPanel:setPositionY(self.bgPanel:getPositionY() + (display.height - 576)/2)
    self.topPanel:setPositionY(self.topPanel:getPositionY() + (display.height - 576)/2)
    self.bottomPanel:setPositionY(self.bottomPanel:getPositionY() - (display.height - 576)/2)

    self.role1 = self.topPanel:getChildByName("role1")                   --人物npc
    self.role2 = self.topPanel:getChildByName("role2")
    self.role3 = self.topPanel:getChildByName("role3")
    self.skipBtn = self.topPanel:getChildByName("skip")                  -- 跳过按钮
    self.chatRoleName = self.bottomPanel:getChildByName("roleName")      -- 人物名字Text
    self.nextBtn = self.bottomPanel:getChildByName("next")               -- 跳过本段聊天按钮
    self.chatText1 = self.bottomPanel:getChildByName("chatText1")        -- 聊天内容Text
    self.chatText2 = self.bottomPanel:getChildByName("chatText2")
    self.chatText3 = self.bottomPanel:getChildByName("chatText3")
    self.chatText = self.bottomPanel:getChildByName("chatText")
    self.bg = self.bgPanel:getChildByName("bg")

    self.coordinate = {                                                  --获取三个NPC与聊天框的坐标
        role1 = {posX = self.role1:getPositionX(), posY = self.role1:getPositionY()},
        role2 = {posX = self.role2:getPositionX(), posY = self.role2:getPositionY()},
        role3 = {posX = self.role3:getPositionX(), posY = self.role3:getPositionY()},
        bottomPanel = {posX = self.bottomPanel:getPositionX(), posY = self.bottomPanel:getPositionY()},
        bgPanel = {posX = self.bgPanel:getPositionX(), posY = self.bgPanel:getPositionY()}
    }

    self.nextBtn:setVisible(false)
    self:nextBtnAction()

    self.updateCount = 0

    self.isScale = false
    self.canTouch = false
    self.isJump = {role1 = false, role2 = false, role3 = false}
    self.isShow = {role1 = false, role2 = false, role3 = false}
    self.currentRoleTexture = {role1 = "", role2 = "", role3 = ""}
    self.playEff = {beginPlay = false, endPlay = false}
    
    self.plotEnd = false
    self.isSkip = false

    self.currentId = self.epitasisLineId

    local function onButtonEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
    		if sender == self.skipBtn then
                cclog("onButtonEvent 111111")
    		    self.isSkip = true
                self.nextBtn:stopAllActions()
                self.updateCount = 0
                self:stopSchedule(StaticData.Plot[self.epitasisLineId])
                self:printAllContent(StaticData.Plot[self.epitasisLineId])
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
                self.isScale = false
                self:recordCurScetionRoleTexture()
                self:RecEndNPCTexture()
                if self.eventBtn == nil then
                    if currentTaskId > 0  then
                        ManagerTask:changeTaskStateWhileSkipPlot(currentTaskId)
                    end
                end
                self:changeScene()
    		end
    	end
    end

    cclog("self.skipBtn PlotSection ID = " .. ManagerTask.SectionId)

    self.skipBtn:addTouchEventListener(onButtonEvent)
    self.skipBtn:setPressedActionEnabled(true)
    self.skipBtn:setLocalZOrder(2)

    self:touchEvent()

end

function PlotLayer:onEnter()

    local BeginDialogueId = StaticData.PlotSection[ManagerTask.SectionId].BeginDialogueId
    local EndDialogueId = StaticData.PlotSection[ManagerTask.SectionId].EndDialogueId
    self:PlotBeginAndEnd(BeginDialogueId, EndDialogueId)
    self.epitasisLineId = self.Begin
    self:beginNPCBothShow(StaticData.Plot[self.epitasisLineId])
    
    self.epitasisContent = string.format(StaticData.Plot[self.epitasisLineId].EpitasisContent, UserData.BaseInfo.userName)
    if StaticData.Plot[self.epitasisLineId].NPCPosition ~= 0 then
        if self.isShow[string.format("role%d", StaticData.Plot[self.epitasisLineId].NPCPosition)] ~= true then
            self:NPCShow(StaticData.Plot[self.epitasisLineId]) 
        end
    end

    if StaticData.Plot[self.epitasisLineId].SetBgImage ~= "" then
        self.bg:setTexture(StaticData.Plot[self.epitasisLineId].SetBgImage)
        self.bg:setVisible(true)
        print(StaticData.Plot[self.epitasisLineId].SetBgImage)
    else
        if ManagerTask.SectionId == 270 then
            self.Panel_1:setVisible(false)
        end
    end

    self.epitasisChatContent = 0                        --对话内容
    self.epitasisChatLineEnd = {}                       --出现换行符，或者超过限定行数的位置
    self.isLineBreak = false
    self.chatRoleName:setString(string.format(StaticData.Plot[self.epitasisLineId].Name, UserData.BaseInfo.userName))                         -- 设置正在说话的NPC名字
    self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            self:TypistEffect(self.Begin, self.End)
        end, typingSpeed ,false)

end

function PlotLayer:onExit()

    if self.schedule then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self.isScale = false
    end
    audio.stopMusic(false)
end

function PlotLayer:HideAllRole()

    local fadeOut1 = cc.FadeOut:create(0)
    local fadeOut2 = cc.FadeOut:create(0)
    local fadeOut3 = cc.FadeOut:create(0)

    local function callBack()
        self.role1:setVisible(true)
        self.role2:setVisible(true)
        self.role3:setVisible(true)
    end
    local callFunc = cc.CallFunc:create(callBack)

    local seq1 = cc.Sequence:create(fadeOut1)
    local seq2 = cc.Sequence:create(fadeOut2)
    local seq3 = cc.Sequence:create(fadeOut3, callFunc)
    
    self.role1:runAction(seq1)
    self.role2:runAction(seq2)
    self.role3:runAction(seq3)

end

function PlotLayer:nextBtnAction()                  --右下角快进键
	local FadeOut = cc.FadeOut:create(1.0)
    local FadeIn = cc.FadeIn:create(1.0)
	local seq = cc.Sequence:create(FadeOut, FadeIn)
	local rep = cc.RepeatForever:create(seq)
	self.nextBtn:runAction(rep)
end

function PlotLayer:PlotBeginAndEnd(beginId, endId)  --标记聊天内容和开始ID和结束ID
    self.Begin = beginId
    self.End = endId
end

function PlotLayer:TypistEffect(BeginId, EndId)                                                                                 -- 据情框的打字效果

    if StaticData.Plot[self.epitasisLineId] == nil or self.epitasisLineId > EndId then                                          -- 判断剧情聊天的table是否存在          
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self.isScale = false
        self:RecEndNPCTexture()
        if currentTaskId > 0  then
            local state = ManagerTask:getTaskState(currentTaskId)
            if state == 4 then
                ManagerTask:setTaskState(currentTaskId,state + 1) -- 任务完成可提交
            end
        end
        self:changeScene()
        return 
    end

    if StaticData.Plot[self.epitasisLineId].NPCPosition ~= 0 then
        if self.isShow[string.format("role%d", StaticData.Plot[self.epitasisLineId].NPCPosition)] ~= true then
            self.showTouch = false
            self:NPCShow(StaticData.Plot[self.epitasisLineId]) 
        end

        if self.currentId ~= self.epitasisLineId then
            self:scheduleUpdateWithPriorityLua(function()
                self:vibration(StaticData.Plot[self.epitasisLineId], vibrationTime)
            end, 0)
        
            self.currentId = self.epitasisLineId
        end

        self:selectRole(StaticData.Plot[self.epitasisLineId].NPCPosition)
    end

    if self:judgeContentEnd(StaticData.Plot[self.epitasisLineId]) then
        if self.currentId == self.End then
            if self.eventBtn ~= nil then
                local csb = self.eventBtn(self.seriesId)
                self:addChild(csb, self.seriesId)
            end
        end
        return
    end
    
    local asc = string.byte(self.epitasisContent, self.epitasisChatContent +1)
    if asc < 127 then
        self.epitasisChatContent = self.epitasisChatContent + 1
    else 
        self.epitasisChatContent = self.epitasisChatContent + 3
    end
    
    self:selectChatText(StaticData.Plot[self.epitasisLineId], string.sub(self.epitasisContent, 1, self.epitasisChatContent))

end

function PlotLayer:judgeContentEnd(epitasisLineId)                          --判断句子是否结束

    if self.epitasisChatContent >= string.len(self.epitasisContent) or self.epitasisChatLineEnd[3] ~= nil then

        if epitasisLineId.NPCPosition ~= 0 then
            self.isJump[string.format("role%d", epitasisLineId.NPCPosition)] = false
            self:NPCHide(epitasisLineId)
        end
        
        self.nextBtn:setVisible(true)
        self.epitasisChatContent = 0
        self.epitasisChatLineEnd = {}

        if self.schedule then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
            self.isScale = false
        end
        
        self.canTouch = true
        return true
    end
    
    return false
end

function PlotLayer:selectChatText(epitasisLineId, str)                                                               -- 选择实现打字效果的charText
     
    self.chatText:setString(str)

end

function PlotLayer:printAllContent(epitasisLineId)                                                --打印所有聊天内容
    if epitasisLineId == nil then
        return 
    end
    print(self.epitasisContent)

    local isEnd = false
    self.epitasisChatLineEnd = {}
    self.chatText:setString(self.epitasisContent)
    isEnd = true

end

function PlotLayer:selectRole(NPCPosition)                                             --选在正在说话的NPC
    --1、左边NPC   2、中间NPC   3、右边NPC
    if NPCPosition == 1 then
        self.role1:setLocalZOrder(1)
        self.role2:setLocalZOrder(0)
        self.role3:setLocalZOrder(0)
        self.role1:setColor(cc.c3b(255, 255, 255))
        self.role2:setColor(cc.c3b(80, 80, 80))
        self.role3:setColor(cc.c3b(80, 80, 80))
    elseif NPCPosition == 2 then
        self.role1:setLocalZOrder(0)
        self.role2:setLocalZOrder(1)
        self.role3:setLocalZOrder(0)
        self.role1:setColor(cc.c3b(80, 80, 80))
        self.role2:setColor(cc.c3b(255, 255, 255))
        self.role3:setColor(cc.c3b(80, 80, 80))
    elseif NPCPosition == 3 then
        self.role1:setLocalZOrder(0)
        self.role2:setLocalZOrder(0)
        self.role3:setLocalZOrder(1)
        self.role1:setColor(cc.c3b(80, 80, 80))
        self.role2:setColor(cc.c3b(80, 80, 80))
        self.role3:setColor(cc.c3b(255, 255, 255))
	end
end 

function PlotLayer:vibration(epitasisLine, vibrationTime)                              --实现振动效果

    if self.updateCount == vibrationTime then
        self.updateCount = 0
        self:unscheduleUpdate()
        return
    end

    --JudgeVibration判断震动
    --VibratiionGoal震动目标
    --1、振动NPC     2、振动对话框     3、都振动
    if epitasisLine.JudgeVibration ~= 0 then
        if epitasisLine.VibratiionGoal == 1 then
            self:vibrationWay(epitasisLine, vibrationTime, self[string.format("role%d", epitasisLine.NPCPosition)], self.coordinate[string.format("role%d", epitasisLine.NPCPosition)].posX, self.coordinate[string.format("role%d", epitasisLine.NPCPosition)].posY)
        elseif epitasisLine.VibratiionGoal == 2 then
            self:vibrationWay(epitasisLine, vibrationTime, self.bottomPanel, self.coordinate.bottomPanel.posX, self.coordinate.bottomPanel.posY)
        elseif epitasisLine.VibratiionGoal == 3 then
            self:vibrationWay(epitasisLine, vibrationTime, self[string.format("role%d", epitasisLine.NPCPosition)], self.coordinate[string.format("role%d", epitasisLine.NPCPosition)].posX, self.coordinate[string.format("role%d", epitasisLine.NPCPosition)].posY)
            self:vibrationWay(epitasisLine, vibrationTime, self.bottomPanel, self.coordinate.bottomPanel.posX, self.coordinate.bottomPanel.posY)
    	elseif epitasisLine.VibratiionGoal == 4 then
            self:vibrationWay(epitasisLine, vibrationTime, self.role1, self.coordinate.role1.posX, self.coordinate.role1.posY)
            self:vibrationWay(epitasisLine, vibrationTime, self.role2, self.coordinate.role2.posX, self.coordinate.role2.posY)
            self:vibrationWay(epitasisLine, vibrationTime, self.role3, self.coordinate.role3.posX, self.coordinate.role3.posY)
            self:vibrationWay(epitasisLine, vibrationTime, self.bottomPanel, self.coordinate.bottomPanel.posX, self.coordinate.bottomPanel.posY)
            self:vibrationWay(epitasisLine, vibrationTime, self.bgPanel, self.coordinate.bgPanel.posX, self.coordinate.bgPanel.posY)
    	end

	else
        self:unscheduleUpdate()
	    return
	end

	self.updateCount = self.updateCount + 1
	
end

function PlotLayer:vibrationWay(epitasisLine, vibrationTime, node, nodePosX, nodePosY)

    local posX = math.random(-2, 2) 
    local posY = math.random(-2, 2) 

    if self.updateCount == vibrationTime - 1 then
        node:setPosition(cc.p(nodePosX, nodePosY))
        return
    end

    local function callBack1()
        node:setScale(1.5)
    end
    local function callBack2()
        node:setPosition(cc.p(nodePosX, nodePosY))
    end

    --VibrationWay震动方式
    --1、左右振动   2、上下震动   3、前后震动   4、无规则震动   5、跳动
    if epitasisLine.VibrationWay == 1 then
        node:setPositionX(nodePosX + posX)
    elseif epitasisLine.VibrationWay == 2 then
        node:setPositionY(nodePosY + posY)
    elseif epitasisLine.VibrationWay == 3 then
        if self.isScale == false then 
            self.isScale = true
            local scaleBy = cc.ScaleBy:create(0.2, 1.3)
            local fadeOut = cc.FadeOut:create(0.2)
            local fadeIn = cc.FadeIn:create(0)
            local spa = cc.Spawn:create(scaleBy, fadeOut)
            local callFunc = cc.CallFunc:create(callBack1)
            local seq = cc.Sequence:create(spa, fadeIn, callFunc)
            node:runAction(seq)
       end
    elseif epitasisLine.VibrationWay == 4 then
        node:setPosition(cc.p(nodePosX + posX, nodePosY + posY))
    elseif epitasisLine.VibrationWay == 5 then
        if self.isJump[string.format("role%d", epitasisLine.NPCPosition)] == false then
            self.isJump[string.format("role%d", epitasisLine.NPCPosition)] = true
            local jumpBy = cc.JumpBy:create(1, cc.p(0, 0), 50, 2)
            local callFunc = cc.CallFunc:create(callBack2)
            local seq = cc.Sequence:create(jumpBy, callFunc)
            node:runAction(seq)
        end
    end
end 

function PlotLayer:NPCHide(epitasisLine)                                                --NPC消失效果
    
    self:playEffect(epitasisLine, "endPlay")
    
    if epitasisLine.JudgeDisappear == 1 then
        --self[string.format("role%d", epitasisLine.NPCPosition)]:stopAllActions()
        if epitasisLine.NPCPosition ~= 0 then
            self:WhoNPCHide(epitasisLine)
        end
    end

end

function PlotLayer:WhoNPCHide(epitasisLine)

    if epitasisLine.BothDisappear == 0 then
        self:NPCHideWay(epitasisLine, self[string.format("role%d", epitasisLine.NPCPosition)], epitasisLine.NPCPosition)
    elseif epitasisLine.BothDisappear == 1 then
        self:NPCHideWay(epitasisLine, self.role1, 1)
        self:NPCHideWay(epitasisLine, self.role2, 2)
    elseif epitasisLine.BothDisappear == 2 then
        self:NPCHideWay(epitasisLine, self.role2, 2)
        self:NPCHideWay(epitasisLine, self.role3, 3)
    elseif epitasisLine.BothDisappear == 3 then
        self:NPCHideWay(epitasisLine, self.role1, 1)
        self:NPCHideWay(epitasisLine, self.role3, 3)
    elseif epitasisLine.BothDisappear == 4 then
        self:NPCHideWay(epitasisLine, self.role1, 1)
        self:NPCHideWay(epitasisLine, self.role2, 2)
        self:NPCHideWay(epitasisLine, self.role3, 3)
    end

end

function PlotLayer:NPCHideWay(epitasisLine, node, NPCPosition)

    local posX = node:getPositionX()
    local posY = node:getPositionY()

    local fadeOut = cc.FadeOut:create(0.5)
    local function callBack()
        node:setPosition(cc.p(posX, posY))
        self.isShow[string.format("role%d", NPCPosition)] = false
        print(string.format("role%d is Hide", NPCPosition)) 
    end

    --0：不消失   1：原地渐变消失   2：向左渐变消失   3：向右渐变消失   4：向左跳跃消失   5：向右跳跃消失   6：向下消失
    if epitasisLine.DisappearWay == 1 then 
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(fadeOut, callFunc)
        node:runAction(seq)
    elseif epitasisLine.DisappearWay == 2 then
        local moveByLefe = cc.MoveBy:create(0.5, cc.p(-100, 0))
        local spa = cc.Spawn:create(moveByLefe, fadeOut)
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(spa, callFunc)
        node:runAction(seq)
    elseif epitasisLine.DisappearWay == 3 then
        local moveByRight = cc.MoveBy:create(0.5, cc.p(100, 0))
        local spa = cc.Spawn:create(moveByRight, fadeOut)
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(spa, callFunc)
        node:runAction(seq)
    elseif epitasisLine.DisappearWay == 4 then
        local jumpByLeft = cc.JumpBy:create(0.5, cc.p(-200, 0), 100, 1)
        local spa = cc.Spawn:create(jumpByLeft, fadeOut)
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(spa, callFunc)
        node:runAction(seq)
    elseif epitasisLine.DisappearWay == 5 then
        local jumpByRight = cc.JumpBy:create(0.5, cc.p(200, 0), 100, 1)
        local spa = cc.Spawn:create(jumpByRight, fadeOut)
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(spa, callFunc)
        node:runAction(seq)
    elseif epitasisLine.DisappearWay == 6 then
        local moveByDown = cc.MoveBy:create(0.5, cc.p(0, -500))
        local fOut = cc.FadeOut:create(0)
        local callFunc = cc.CallFunc:create(callBack)
        local seq = cc.Sequence:create(moveByDown, fOut, callFunc)
        node:runAction(seq)
    end
end

function PlotLayer:changeRoleTexture(epitasisLine)

    print(self.currentRoleTexture[string.format("role%d",epitasisLine.NPCPosition)]) 
    if self.currentRoleTexture[string.format("role%d",epitasisLine.NPCPosition)] ~= epitasisLine.ButtonIcon then
        if self.isSkip == false then
            local texTure = string.format(epitasisLine.ButtonIcon, UserData.BaseInfo.userSex)
            self[string.format("role%d", epitasisLine.NPCPosition)]:setTexture(texTure)
        end
        self.currentRoleTexture[string.format("role%d",epitasisLine.NPCPosition)] = epitasisLine.ButtonIcon
        print(self.currentRoleTexture[string.format("role%d",epitasisLine.NPCPosition)])
    end
end

function PlotLayer:recordCurScetionRoleTexture()
    for i = self.epitasisLineId, self.End do
        self:changeRoleTexture(StaticData.Plot[i])
    end
end

function PlotLayer:beginNPCBothShow(epitasisLine)
    
    local function setShow(NPCPos)
        local texTure = DataManager:getStringForKey(string.format("NPC%dtexTure", NPCPos))
        texTure = string.format(texTure, UserData.BaseInfo.userSex)
        if texTure ~= nil or texTure ~= "" then
            self.isShow[string.format("role%d", NPCPos)] = true
            self[string.format("role%d", NPCPos)]:setTexture(texTure)
            self.currentRoleTexture[string.format("role%d", NPCPos)] = texTure
            self[string.format("role%d", NPCPos)]:setOpacity(255)
            self[string.format("role%d", NPCPos)]:setColor(cc.c3b(80, 80, 80))
        end
    end

    if epitasisLine.BothShow == 0 then
--        self:HideAllRole()
    elseif epitasisLine.BothShow == 1 then
        self[string.format("role%d", epitasisLine.NPCPosition)]:setRotationSkewY(epitasisLine.Rotation)
        setShow(1)
        setShow(2)
--        self.role3:runAction(seq)
    elseif epitasisLine.BothShow == 2 then
        self[string.format("role%d", epitasisLine.NPCPosition)]:setRotationSkewY(epitasisLine.Rotation)
        setShow(2)
        setShow(3)
--        self.role1:runAction(seq)
    elseif epitasisLine.BothShow == 3 then
        self[string.format("role%d", epitasisLine.NPCPosition)]:setRotationSkewY(epitasisLine.Rotation)
        setShow(1)
        setShow(3)
--        self.role2:runAction(seq)
    elseif epitasisLine.BothShow == 4 then
        self[string.format("role%d", epitasisLine.NPCPosition)]:setRotationSkewY(epitasisLine.Rotation)
        setShow(1)
        setShow(2)
        setShow(3)
    end

end

function PlotLayer:NPCShow(epitasisLine)                                                        --NPC出现效果

    if self.isShow[string.format("role%d", epitasisLine.NPCPosition)] == false then
        if epitasisLine.NPCPosition ~= 0 then
            print("NPCPosition " .. epitasisLine.NPCPosition)
            self[string.format("role%d", epitasisLine.NPCPosition)]:setRotationSkewY(epitasisLine.Rotation) 
            self:changeRoleTexture(epitasisLine) 
            self:NPCShowWay(epitasisLine, self[string.format("role%d", epitasisLine.NPCPosition)])
        end
    end

    self:playEffect(epitasisLine, "beginPlay")
end

function PlotLayer:NPCShowWay(epitasisLine, node)

    local roleName = string.format("role%d", epitasisLine.NPCPosition)
    self.isShow[roleName] = true
    print(string.format("role%d is show", epitasisLine.NPCPosition))
    
    local fadeIn1 = cc.FadeIn:create(0)
    local fadeIn2 = cc.FadeIn:create(0.5)
    local moveByLeft = cc.MoveBy:create(0.5, cc.p(100, 0))
    local moveByRight = cc.MoveBy:create(0.5, cc.p(-100, 0))

    if epitasisLine.ShowWay == 0 then
        node:runAction(fadeIn1)
    elseif epitasisLine.ShowWay == 1 then
        node:runAction(fadeIn2)
    elseif epitasisLine.ShowWay == 2 then
        local place = cc.Place:create(cc.p(self.coordinate[roleName].posX - 100, self.coordinate[roleName].posY))
        local spa = cc.Spawn:create(moveByLeft, fadeIn2)
        local seq = cc.Sequence:create(place, spa)
        node:runAction(seq)
    elseif epitasisLine.ShowWay == 3 then
        local place = cc.Place:create(cc.p(self.coordinate[roleName].posX + 100, self.coordinate[roleName].posY))
        local spa = cc.Spawn:create(moveByRight, fadeIn2)
        local seq = cc.Sequence:create(place, spa)
        node:runAction(seq)
    end
end

function PlotLayer:RecEndNPCTexture()                  --记录上次剧情结束时，各NPC的texture
    DataManager:setStringForKey("NPC1texTure",self.currentRoleTexture.role1)
    DataManager:setStringForKey("NPC2texTure",self.currentRoleTexture.role2)
    DataManager:setStringForKey("NPC3texTure",self.currentRoleTexture.role3)
end

function PlotLayer:stopSchedule(epitasisLine)                                                   --暂停Schedule

    if epitasisLine ~= nil and epitasisLine.VibrationWay == 5 then
        if self.isJump[string.format("role%d", epitasisLine.NPCPosition)] == true then
            local roleName = string.format("role%d", epitasisLine.NPCPosition)
            self[roleName]:stopAllActions()
            self[roleName]:setPosition(cc.p(self.coordinate[roleName].posX, self.coordinate[roleName].posY))
            self.isJump[roleName] = false
            cclog("self.isjump is false")

            local fade = cc.FadeIn:create(0.0)
            self[roleName]:runAction(fade)
        end
    end
    
    self:unscheduleUpdate()
end

function PlotLayer:playEffect(epitasisLine, playPlace)

    if epitasisLine.JudgeEffect == 1 then
    
        if playPlace == "beginPlay" and self.playEff.beginPlay == false then
            self.playEff.beginPlay = true
            audio.playSound(epitasisLine.BeginPlay, false)
        end
        if playPlace == "endPlay" and self.playEff.endPlay == false then
            self.playEff.endPlay = true
            audio.playSound(epitasisLine.EndPlay, false)
        end

    end

end


function PlotLayer:CheckTaskFinish(currentTaskId)
    if currentTaskId > 0 then
        local lastTalk = tonumber(StaticData.Task[currentTaskId].LastTalk)
        if lastTalk ~= nil and lastTalk > 0 and ManagerTask.SectionId == lastTalk then
            if StaticData.Task[currentTaskId].CityType == 0 then
                local StageMapLayer = require("app.views.StageMap.StageMapLayer")
                StageMapLayer:checkFinishTask()
            elseif StaticData.Task[currentTaskId].CityType > 0 then  -- 城镇地图
                local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer")
                TownInterfaceLayer:checkFinishTask()
            elseif StaticData.Task[currentTaskId].CityType < 0 then  -- 探索地图
                local canFinishTask = ManagerTask:getCanFinishTask()
                if canFinishTask == currentTaskId then
                    --直接弹完成任务界面
                    local TaskMessageBox =  require("app.views.Task.TaskMessageBox")
                    local layer = TaskMessageBox:create()
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:addToGameScene(layer, 40)
                    TaskMessageBox:ShowTaskFinishMessageBox(currentTaskId)
                end
            end
        end

        if lastTalk == 0 then
            local canFinishTask = ManagerTask:getCanFinishTask()
            if canFinishTask == currentTaskId then
                --直接弹完成任务界面
                local TaskMessageBox =  require("app.views.Task.TaskMessageBox")
                local layer = TaskMessageBox:create()
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer, 40)
                TaskMessageBox:ShowTaskFinishMessageBox(currentTaskId)
            end
        else
            if StaticData.Task[currentTaskId].TaskTargetType == 2 then
                --直接弹完成任务界面
                local TaskMessageBox =  require("app.views.Task.TaskMessageBox")
                local layer = TaskMessageBox:create()
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer, 40)
                TaskMessageBox:ShowTaskFinishMessageBox(currentTaskId)
            end
        end
    end
end


function PlotLayer:changeScene()
    if self.eventBtn ~= nil then
        local csb = self.eventBtn(self.seriesId)
        self:addChild(csb, self.seriesId)
        return
    end
    if self.callBack ~= nil then
         self.callBack()
        self:removeFromParent()
        return
    end

    if StaticData.PlotSection[ManagerTask.SectionId] == nil then
        ManagerTask.SectionId = 1
    end

    if currentTaskId == 0 or currentTaskId == nil then
        self:removeFromParent()
        
        if UserData.NewHandLead:getCurrentGuideName() == "ClickTaskNodeList" then
            UserData.NewHandLead:CompleteGuide("ClickTaskNodeList")
            local name = "GodWillLead_levelup"
            local guideState = UserData.NewHandLead:getGuideState(name)
            if guideState == 0 then
                local data = {name = name}
                UserData.NewHandLead.GuideList[name].curStep = 1
                UserData.NewHandLead:startNewGuide(data)
                local SceneManager = require("app.views.SceneManager")
                local TownInterfaceLayer = SceneManager:getGameLayer("TownInterfaceLayer")
                if TownInterfaceLayer ~= nil then
                    TownInterfaceLayer:showNewHand(name)
                end
            end
        end
        return
    end

    local TaskTargetType = 0
    local taskInfo =  ManagerTask:getTaskInfo(currentTaskId)
    if taskInfo == nil then
        cclog("taskInfo is nil , [currentTaskId] = " .. tostring(currentTaskId))
    end
    if taskInfo ~= nil then
        TaskTargetType = taskInfo.TaskTargetType  -- 1：打怪 2：对话
    end

    local taskState = ManagerTask:getTaskState(currentTaskId)
    if TaskTargetType == 2 or taskState == 5  then
        local lastTalk = tonumber(StaticData.Task[currentTaskId].LastTalk)
        if lastTalk <= 0 then
            if TaskTargetType == 2 then
                ManagerTask:setTaskState(currentTaskId,5)
            end
            self:CheckTaskFinish(currentTaskId)
            self:removeFromParent()
        else
            if TaskTargetType == 2 then
                self:CheckTaskFinish(currentTaskId)
                self:removeFromParent()
            end
        end
        return
    end
    
    -- 任务还未完成不可提交
    local taskParameter = ManagerTask:getTaskParameter(currentTaskId)
    --local needShowBeforeFightMessageBox = false
    if (tonumber(taskParameter[2]) == 1 and tonumber(taskParameter[5]) == 0) then
        self:removeFromParent()
        ManagerTask:EnterBeforeFightScene(currentTaskId)
        
        return
    end

    self:CheckTaskFinish(currentTaskId)
    self:removeFromParent()
end



function PlotLayer:initPlotEnterAntExit(AssignId)
    local id = tonumber(AssignId)
    currentTaskId = id
    if StaticData.Task[id] ~= nil then
        DataManager:setIntegerForKey("PreTalk", StaticData.Task[id].PreTalk)
        return true
    else
        return false
    end
end

--function PlotLayer:recordTownNodeAssign(currentTownNode)
--
--    local strTownNodeAssign = DataManager:getStringForKey("townNodeAssign")
--    strTownNodeAssign = strTownNodeAssign .. currentTownNode .. "*1" .. ";"
--    DataManager:setStringForKey("townNodeAssign", strTownNodeAssign)
--
--end

--function PlotLayer:getTownNodeAssign()
--
--    local townNodeAssign = DataManager:getStringForKey("townNodeAssign")
--    if townNodeAssign == nil or townNodeAssign == "" then
--        townNodeAssign = "1001_1002_1*0"
--    end
--
--    local allTownNodeAssign = {}
--    local tableNodeAssign = string.split(townNodeAssign, ";")
--    for i = 1, #tableNodeAssign do
--        local assign = string.split(tableNodeAssign[i], "*")
--        allTownNodeAssign[assign[1]] = assign[2]
--    end
--
--    return allTownNodeAssign
--end


function PlotLayer:touchEvent()

    local function openSchedule()
        if self.schedule then
            self.playEff.beginPlay = false
            self.playEff.endPlay = false
            audio.stopAllSounds()
            self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
                function(dt) 
                    self:TypistEffect(self.Begin, self.End) 
                end, 
                typingSpeed, false)
        end

        self.epitasisChatContent = 0
        self.epitasisChatLineEnd = {}
        self.nextBtn:setVisible(false)
    end

    local function onPlotBgPanelTouched(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            self.canTouch = not self.canTouch

            self.chatText:setString("")
            
            if self.canTouch then 
                if self.plotEnd then
                    return
                end
            
                if self.schedule then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule) 
                    self.isScale = false
                end 
                
                if StaticData.Plot[self.epitasisLineId] ~= nil then
                    self:selectRole(StaticData.Plot[self.epitasisLineId].NPCPosition)
                end
                self.nextBtn:setVisible(true)
                self:printAllContent(StaticData.Plot[self.epitasisLineId])
                if StaticData.Plot[self.epitasisLineId].NPCPsition ~= 0 then
                    self:NPCHide(StaticData.Plot[self.epitasisLineId])
                end
                for i = 1, 3 do
                    if self.isShow[string.format("role%d", i)] then
                        self[string.format("role%d", i)]:setOpacity(255)
                    end
                end
                if self.eventBtn ~= nil then
                    if self.epitasisLineId == self.End then
                        local csb = self.eventBtn(self.seriesId)
                        self:addChild(csb, self.seriesId)
                    end
                end
            else 
                self.updateCount = 0
                self:stopSchedule(StaticData.Plot[self.epitasisLineId])
                self.bottomPanel:setPosition(cc.p(self.coordinate.bottomPanel.posX, self.coordinate.bottomPanel.posY))
                self.epitasisLineId = self.epitasisLineId + 1
                if StaticData.Plot[self.epitasisLineId] ~= nil then
                    self.epitasisContent = string.format(StaticData.Plot[self.epitasisLineId].EpitasisContent, UserData.BaseInfo.userName)
                    self.chatRoleName:setString(string.format(StaticData.Plot[self.epitasisLineId].Name, UserData.BaseInfo.userName))
                end
                if self.epitasisLineId > self.End then
                    self.plotEnd = true
                    self.nextBtn:stopAllActions()
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
                    self.isScale = false
                    self:RecEndNPCTexture()
                    if currentTaskId > 0  then
                        ManagerTask:changeTaskStateWhileSkipPlot(currentTaskId)
                    end

                    self:changeScene()
                    return
                end 
                if StaticData.Plot[self.epitasisLineId].PlayAnimation ~= "" then
                    local pageTurn = PlayPageTurn:create(StaticData.Plot[self.epitasisLineId].PlayAnimation, openSchedule)
                    self.chatText:setString("")
                    self:addChild(pageTurn)
                else
                    openSchedule()
                end
--                openSchedule()
            end
        end
    end
    self.bgPanel:setTouchEnabled(true)
    self.bgPanel:addTouchEventListener(onPlotBgPanelTouched)
end


return PlotLayer