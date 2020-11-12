
local StartScene = class("StartScene", require("app.views.View"))

function StartScene:onCreate()

    self.rootNode = self:createResoueceNode("res/csb/startAnimationLayer.csb") --获取根目录
    self.Panel1 = self.rootNode:getChildByName("Panel_1")--获取panel1
    self.Panel1:setPosition(display.center)--放到位中心去
    
    self.Panel2 = self.rootNode:getChildByName("Panel_2")--获取panel2
    self.Panel2:setPosition(display.center)--放到位中心去
    
    self.Panel3 = self.rootNode:getChildByName("Panel_3")--获取panel2
    self.Panel3:setPosition(display.center)--放到位中心去
    
    self.scheduleUpdate = nil
    
    local huoqiu1 =  self.Panel1:getChildByName("Image_huoqiu1")
    local huoqiu2 =  self.Panel1:getChildByName("Image_huoqiu2")
    local huoqiu3 =  self.Panel1:getChildByName("Image_huoqiu3")
    local huoqiu4 =  self.Panel1:getChildByName("Image_huoqiu4")
    local huoqiu5 =  self.Panel1:getChildByName("Image_huoqiu5")
    local Image_heiyan1 =  self.Panel1:getChildByName("Image_heiyan1")
    
    --回调切换
    local function callback()

        local function setNoVisible()
            self.Panel1:setVisible(false)
        end
        huoqiu1:setVisible(false)
    	local  fade = cc.FadeTo:create(0.5,0)
        local seq = cc.Sequence:create(fade,cc.CallFunc:create(setNoVisible))
    	self.Panel1:runAction(seq)
       
    end
    self:guangComeOut()
    
    local seq = cc.Sequence:create(self:createMoveAction(cc.p(501,-270)),cc.CallFunc:create(callback))
    huoqiu1:runAction(seq)
    
    huoqiu2:runAction(self:createMoveAction(cc.p(645,-401)))
    
    huoqiu3:runAction(self:createMoveAction(cc.p(600,-500)))
    
    huoqiu4:runAction(self:createMoveAction(cc.p(690,-461)))
    
    huoqiu5:runAction(self:createMoveAction(cc.p(650,-441)))
    
    Image_heiyan1:runAction(self:createMoveAction(cc.p(200,0)))
    
    self:updateData() --定时器创建和更新数据
    self. musicHandle =  audio.playMusic("audioMusic/background.mp3",true)
    --audio.playMusic("lundun.mp3",true)

end

--进入
function StartScene:onEnter()
    
end

--退出
function StartScene:onExit()
    
    if self.scheduleUpdate~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end
  
end

function StartScene:createMoveAction(pos)
	
    local move = cc.MoveBy:create(5.0,pos)
    
    return move
	
end

function StartScene:logoComeOut()
   self.Panel2:setVisible(true)
    local Text_1 =  self.Panel2:getChildByName("Text_1")
    Text_1:setOpacity(0)
    local function callback()
        audio.stopMusic(false)
        local DataManager = require("app.views.public.DataManager")
        --local roleStayPointID = DataManager:getStringForKey("roleStayPointID")
        --DataManager:setStringForKey("town" .. roleStayPointID, "")
        --DataManager:setStringForKey("stageOverInfo","")
        --DataManager:setStringForKey("roleStayPointID","612001")
        --DataManager:setStringForKey("townNodeAssign", "")
        ManagerTask.SectionId = 1

--		local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
--        local layer = StageMapLayer:create(611001)
--        local SceneManager = require("app.views.SceneManager")
--        SceneManager:addToGameScene(layer)
        
        DataManager:setStringForKey("roleStayPointID","612001")
        DataManager:setIntegerForKey("roleStayWorldMapID",(611001))
        
        local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer"):create()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:addToGameScene(TownInterfaceLayer)
        local userdata = {needShowPlot = false,  currentTownID = "612001"}
        TownInterfaceLayer:initUI(userdata)
        
        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5, SceneManager:getGameSceneRoot(), cc.c3b(255,255,255)))
        
        local ManagerTask = require("app.views.Task.ManagerTask")
        local nextTaskId =  ManagerTask:getNextCanAcceptedMainTask()
        if nextTaskId > 0 then
            UserData.Task:sendAcceptTask(nextTaskId,1)
        end
    end
   
    local fade =  cc.FadeIn:create(1.0)
    local seq = cc.Sequence:create(fade,cc.DelayTime:create(0.5),cc.CallFunc:create(callback))
    Text_1:runAction(seq)

end

function StartScene:guangComeOut()
   
    local Image_guang =  self.Panel3:getChildByName("Image_guang")
    Image_guang:setScale(0.05)
    local function callback1(parameters)
        audio.playSound("audioEffect/bomb.mp3",false)
        self.Panel3:setVisible(true)
    end
    local function callback2()
        self:logoComeOut()
        
    end
    local sca = cc.ScaleTo:create(0.8,1)
    local fade =  cc.FadeTo:create(0.2,0)
    local roat = cc.RotateTo:create(0.2,10)
    local spa = cc.Spawn:create(fade,roat)
    local seq = cc.Sequence:create(cc.DelayTime:create(4.5),cc.CallFunc:create(callback1),sca,spa,cc.CallFunc:create(callback2))
    Image_guang:runAction(seq)
    
end



--定时器的创建和更新数据
function StartScene:updateData()
    local dTime = 0
    local x1 = -3
    local x2 =  3
    local y1 = -2
    local y2 =  2

    
    local function update(dt)
        
        local x = math.random(x1,x2)
        local y = math.random(y1,y2)
        x1 = x1 - dt
        x2 = x1 + dt
        y1 = y1 - dt
        y2 = y2 + dt
        if x1 < -21 then
            x1 = -21
        end
        if x2 > 21 then
            x2 = 21
        end
        if y1 < -14 then
            y1 = -14
        end
        if y2 > 14 then
            y2 = 14
        end
        
        self.Panel1:setPosition(cc.p(display.center.x + x,display.center.y + y))--放到位中心去
 
    end

    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1/25 ,false)
end




return StartScene
