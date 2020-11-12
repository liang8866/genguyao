local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local MySkillHand = require("app.views.MyFighting.MySkillHand")
local MyFightingOver = require("app.views.MyFighting.MyFightingOver")



local MyFlyRole = require("app.views.MyFighting.MyFlyRole")


require("app.views.MyFighting.MyFightingConfig")
require "fight_static_data.FightStaticData"
require("app.views.MyFighting.MyFightingCtrl")

local TimeFormat = require("common.TimeFormat")

local MyFightingLayer = class("MyFightingLayer", function()
    return ccui.Layout:create()
end)

function MyFightingLayer:create()
    local view = MyFightingLayer.new()
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

function MyFightingLayer:ctor()
    
end

function MyFightingLayer:onEnter()
    
end

function MyFightingLayer:onExit()
    if self.scheduleUpdate~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end
    
    
end

--初始化
function MyFightingLayer:init()
    
    self.visibleSize = cc.Director:getInstance():getVisibleSize()

   
    --创建滚动背景
    self.bg1 = cc.Sprite:create("res/ui/myFighting/b1.jpg")
    --获取背景有图片的大小
    self.bgWidth = self.bg1:getContentSize().width
    
    self.bg1:setPosition(cc.p(self.bgWidth/2 ,display.center.y))
    self:addChild(self.bg1,-4)

    self.bg2 = cc.Sprite:create("res/ui/myFighting/b1.jpg")
    self.bg2:setPosition(cc.p(self.bgWidth / 2 * 3 - 0.2   ,display.center.y))
    self:addChild(self.bg2,-4)
    self.bg2:setRotation3D(cc.p(0,180,0))
    
    self.bg3 = cc.Sprite:create("res/ui/myFighting/b1.jpg")
    self.bg3:setPosition(cc.p(self.bgWidth / 2 * 5 - 0.4  ,display.center.y))
    self:addChild(self.bg3,-4)
    
    
    self.bgSpeed = 0.20 -- 移动速度
    
    
    
    self.skillIcons = {}      -- 技能图标的
    
 
    MyFightingCtrl:init() -- 重新初始化
    
    -- ui界面层
    local rootNode = cc.CSLoader:createNode("csb/MyFightingLayer.csb")
    self:addChild(rootNode,30)
    rootNode:setPositionY(rootNode:getPositionY() + (display.height - 576)/2)
    self.scheduleUpdate = nil
    self:showLayerUI(rootNode)
    MyFightingCtrl.battleLayer = self
   
    self.isCountTimeFlag = false     -- 是否开始计算
    self.isUpDateFlag    = true      -- 定时器是否可以用
    

    --主动技能轨道
    self.battlePathNode = cc.CSLoader:createNode("csb/battle_showpath_node.csb")
    self:addChild(self.battlePathNode,10)
    self.battlePathNode:setPosition(display.center)
    local Panel_root = self.battlePathNode:getChildByName('Panel_root')
    Panel_root:setContentSize(cc.size(display.width, display.height))
  
    local path1 = Panel_root:getChildByName('Image_path1')
    local path2 = Panel_root:getChildByName('Image_path2')
    local path3 = Panel_root:getChildByName('Image_path3')
    path1:setPositionY(path1:getPositionY()+display.height/2- 576/2)
    path2:setPositionY(path2:getPositionY()+display.height/2- 576/2)
    path3:setPositionY(path3:getPositionY()+display.height/2- 576/2)
    
    
    self.Image_path = {
        Panel_root:getChildByName('Image_path1'),
        Panel_root:getChildByName('Image_path2'),
        Panel_root:getChildByName('Image_path3')    
    }
    
    self.battlePathNode:setVisible(false)

    self:startGame()    
 
    self:updateData() --定时器创建和更新数据
    
    audio.playMusic("audioMusic/fighting.mp3", true) 
   
    local layout = Panel_root:clone()
    layout:setContentSize(cc.size(display.width, display.height))
    layout:setPosition(display.center)
    self:addChild(layout,-20)
    layout:setTouchEnabled(true)
    
    -- 新手引导用的
    MyFightingCtrl.guideGodID = 0
    if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_2.TaskID  then
        if UserData.NewHandLead:getGuideState("Fighting_2") == 0 then
            MyFightingCtrl.guideGodID = UserData.NewHandLead.GuideList.Fighting_2.GodID
        end
    end
    --MyFightingCtrl.guideGodID = UserData.NewHandLead:GetNewPlayerGuideFightGodID()  --特殊战斗滞后设置
    self.guideHouziMaxTime = 8
    self.guideHouziCountTime = 9
   
   
   self.godSpine = nil
   
end

-- 获取UI信息
function MyFightingLayer:showLayerUI(rootNode)
--    self.downPanel = rootNode:getChildByName("Panel_down")  --Panel_top
--
--    self.downPanel:setVisible(true)
--    local image_left =  self.downPanel:getChildByName("Image_left")
--    local image_right =  self.downPanel:getChildByName("Image_right")
--    
--    self.LoadingBar_1 = ccui.Helper:seekWidgetByName(image_left  ,"LoadingBar_1")    -- 左边人物血条
--    self.LoadingBar_2 = ccui.Helper:seekWidgetByName(image_right ,"LoadingBar_1")    -- 右边敌人血条
--    self.left_textHp = ccui.Helper:seekWidgetByName(image_left  ,"Text_hp")
--    self.right_textHp = ccui.Helper:seekWidgetByName(image_right  ,"Text_hp")
--    self.LoadingBar_1:setPercent(100)
--    self.LoadingBar_2:setPercent(100)
--    
--    self.leftNum = ccui.Helper:seekWidgetByName(image_left ,"Text_ep_num")    -- 左边人物能量条
--    self.rightNum = ccui.Helper:seekWidgetByName(image_right ,"Text_ep_num")    -- 右边敌人能量条
--    self.leftNum:setString("0")
--    self.rightNum:setString("0")
--    local leftImageIcon = ccui.Helper:seekWidgetByName(image_left  ,"Image_left_head") 
--    local rightImageIcon = ccui.Helper:seekWidgetByName(image_right  ,"Image_right_head") 
--    leftImageIcon:setLocalZOrder(-1)
--    rightImageIcon:setLocalZOrder(-1)
--    if UserData.BaseInfo.userSex == 1 then --1 男 2女
--        leftImageIcon:loadTexture("items/fightIcon/000001.png")
--    else
--        leftImageIcon:loadTexture("items/fightIcon/000002.png")
--    end
--    if  UserData.BaseInfo.NPCId ~= nil  and  UserData.BaseInfo.NPCId ~= 0 and StaticData.Npc[UserData.BaseInfo.NPCId] ~= nil and StaticData.Npc[UserData.BaseInfo.NPCId].FightHead ~= 0 then
--        local img = StaticData.Npc[UserData.BaseInfo.NPCId].FightHead
--        rightImageIcon:loadTexture("items/fightIcon/"..img)
--    else
--        rightImageIcon:loadTexture("items/fightIcon/412007.png")
--    end

    self.downPanel = rootNode:getChildByName("Panel_down")  --Panel_top

    self.downPanel:setVisible(true)
--    local image_left =  self.downPanel:getChildByName("Image_left")
--    local image_right =  self.downPanel:getChildByName("Image_right")
--    image_left:setVisible(false)
--    image_right:setVisible(false)
    
    local Panel_left =  self.downPanel:getChildByName("Panel_Left")
    local Panel_right =  self.downPanel:getChildByName("Panel_Right")
    Panel_left:setPositionY(Panel_left:getPositionY() - (display.height - 576)/2)
    Panel_right:setPositionY(Panel_right:getPositionY() + (display.height - 576)/2)
    
    self.LoadingBar_1 = ccui.Helper:seekWidgetByName(Panel_left  ,"LoadingBar_xueliang")    -- 左边人物血条
    self.LoadingBar_2 = ccui.Helper:seekWidgetByName(Panel_right ,"LoadingBar_xueliang")    -- 右边敌人血条
--    self.left_textHp = ccui.Helper:seekWidgetByName(image_left  ,"Text_hp")
--    self.right_textHp = ccui.Helper:seekWidgetByName(image_right  ,"Text_hp")
    self.LoadingBar_1:setPercent(100)
    self.LoadingBar_2:setPercent(100)
    
    self.leftNum = ccui.Helper:seekWidgetByName(Panel_left ,"BitmapFontLabel_1")    -- 左边怒气点
--    self.rightNum = ccui.Helper:seekWidgetByName(image_right ,"Text_ep_num")    -- 右边怒气点
    self.leftNum:setString("0")
--    self.rightNum:setString("0")

    -- 蓝色条
    self.left_blueBar =  ccui.Helper:seekWidgetByName(Panel_left  ,"LoadingBar_lantiao")
    self.right_blueBar =  ccui.Helper:seekWidgetByName(Panel_right  ,"LoadingBar_lantiao")
    
    -- 名字
    local leftName = ccui.Helper:seekWidgetByName(Panel_left  ,"Text_Left_Name")
    leftName:setString(UserData.BaseInfo.userName)
    local rightName =  ccui.Helper:seekWidgetByName(Panel_right  ,"Text_Left_Name")
    if  UserData.BaseInfo.NPCId ~= nil  and  UserData.BaseInfo.NPCId ~= 0 and StaticData.Npc[UserData.BaseInfo.NPCId] ~= nil and StaticData.Npc[UserData.BaseInfo.NPCId].FightHead ~= 0 then
        local Name = StaticData.Npc[UserData.BaseInfo.NPCId].Name
         rightName:setString(Name)
    end
    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(20,1,nil,{r = 0,g = 0,b = 0,a = 255})
    outLineLable:setTexOutLine(leftName)
    outLineLable:setTtfConfig(18,1,nil,{r = 0,g = 0,b = 0,a = 255})
    outLineLable:setTexOutLine(rightName)
    
end

-- 开始出场角色
function MyFightingLayer:startGame()
    local player =  MyFlyRole:create(MyFightingConfig.ECamp.Player,UserData.BaseInfo.nFibbleId)
    local enemy =  MyFlyRole:create(MyFightingConfig.ECamp.Enemy,UserData.BaseInfo.enemyFlyID)
    player:setPosition(-1000,0)
    enemy:setPosition(3000,0)
    self:addChild(player,-1)
    self:addChild(enemy,-1)
	MyFightingCtrl.player = player
	MyFightingCtrl.enemy = enemy

end

--倒计时结束后计算谁失败或者成功
function MyFightingLayer:isWinFailure()
	local fag = 0
	local tmp = nil --返回输的那个玩家飞宝
    if MyFightingCtrl.player.hp == nil or MyFightingCtrl.enemy.hp == nil then
        return 0,tmp
	end
    if  MyFightingCtrl.player.hp > 0  and MyFightingCtrl.enemy.hp <= 0 then --赢
        fag = 1
        tmp = MyFightingCtrl.enemy
        tmp.hpBar:setPercent(0)
       -- tmp.hpText:setString(string.format("%d/%d",0, tmp.maxHp))
    elseif  MyFightingCtrl.player.hp <= 0  and MyFightingCtrl.enemy.hp > 0 then -- 输      
        fag = -1
        tmp = MyFightingCtrl.player
        tmp.hpBar:setPercent(0)
     --   tmp.hpText:setString(string.format("%d/%d",0, tmp.maxHp))
    else --平
       fag = 0
        
	end
	return fag,tmp
	
end


--显示结束页面
function MyFightingLayer:showGameOver(failRole)
	local function callback()
        local overlayer = MyFightingOver:create(MyFightingCtrl.isWin)
--        local SceneManager = require("app.views.SceneManager")
--        SceneManager:addToGameScene(overlayer, 101)
--        self:removeFromParent()
        self:addChild(overlayer, 101)
	end
    failRole:setFlyRoleBomnb(callback)
	
end


--定时器的创建和更新数据
function MyFightingLayer:updateData()
    local function update(dt)
        -- 如果不能用就直接返回 不执行下面的
        if  self.isUpDateFlag == false  then
        	return
        end
        
        if MyFightingCtrl.gameOver == true then --游戏结束
            return
        end
        if self.bg1 and self.bg2 and self.bg3 then
            -- 设置背景的滚动
            local bg1PosX = self.bg1:getPositionX()
            local bg2PosX = self.bg2:getPositionX()
            local bg3PosX = self.bg3:getPositionX()
          
            self.bg1:setPositionX(bg1PosX - self.bgSpeed)
            self.bg2:setPositionX(bg2PosX - self.bgSpeed)
            self.bg3:setPositionX(bg3PosX - self.bgSpeed)

            if bg1PosX <  (-self.bgWidth / 2) then
                self.bg1:setPositionX(self.bgWidth / 2 * 5  - 0.4)
               
            end 
            if bg2PosX < (-self.bgWidth / 2) then
                self.bg2:setPositionX(self.bgWidth / 2 * 5 - 0.4 )
            end 
            if bg3PosX < (-self.bgWidth / 2) then
                self.bg3:setPositionX(self.bgWidth / 2 * 5 - 0.4)
            end 
        end
        
   
       self.left_blueBar:setPercent(MyFightingCtrl.player.killPoint/MyFightingCtrl.player.killPointValue *100)
       self.right_blueBar:setPercent(MyFightingCtrl.enemy.killPoint/MyFightingCtrl.enemy.killPointValue *100)
    
       
        --角色更新
        MyFightingCtrl.player:update(dt)
        MyFightingCtrl.enemy:update(dt)

        --判断输赢 ---------------------------
        local isFailFlag,FailRole = self:isWinFailure()
        if isFailFlag == 1 or isFailFlag == -1 then --要么赢了，要么输了
            MyFightingCtrl.gameOver = true
            MyFightingCtrl.isWin = isFailFlag
            MyFightingCtrl:GameOverRemoveAllBullet()
            self:showGameOver(FailRole)
            return
        end
        
        -- 新手引导 出现的神将判断‘
        self:guideCountGodSkill(dt)
        
        
        --定时操作数据 碰撞检测等
        local playerBullets = MyFightingCtrl.playerBullets
        local enemyBullets = MyFightingCtrl.enemyBullets

        for key, bullet in pairs(playerBullets) do
            bullet.pause = false
        end   

        for key, bullet in pairs(enemyBullets) do
            bullet.pause = false
        end

        for key, myBullets in pairs(playerBullets) do
            for key, tempBullets in pairs(enemyBullets) do
                local flag1 = false
                local crashPos = cc.p(myBullets:getPositionX()/2 + tempBullets:getPositionX()/2 ,myBullets:getPositionY()/2 + tempBullets:getPositionY()/2)
               
                if (myBullets.skillType == 2 ) or ( tempBullets.skillType == 2) then --一个是墙
                   
                    if tempBullets.isEnableCollision == true and myBullets.isEnableCollision == true and  myBullets.type == tempBullets.type then
                        flag1 = true
                	end
                elseif  (myBullets.skillType == 4 ) or ( tempBullets.skillType == 4) then	-- 场
                    if myBullets.skillType == 4 and tempBullets.skillType ~= 4 and tempBullets:getPositionX() < (display.center.x  - 30) and tempBullets.isEnableCollision == true and myBullets.isEnableCollision == true then
                        tempBullets.crashPos = cc.p( tempBullets:getPositionX() , tempBullets:getPositionY())
                        tempBullets.pause = true
                        tempBullets.inChangFlag = true
                        tempBullets.costhp = myBullets.atk/60
                        MyFightingCtrl:setObjHaveBuff(myBullets.bufferIdTable,tempBullets)
                        MyFightingCtrl:setObjHaveBuff(tempBullets.bufferIdTable,myBullets)
                    end
                  if tempBullets.skillType == 4 and myBullets.skillType ~= 4 and myBullets:getPositionX() > (display.center.x  + 30) and tempBullets.isEnableCollision == true and myBullets.isEnableCollision == true then
                        myBullets.crashPos = cc.p(myBullets:getPositionX() ,myBullets:getPositionY())
                        myBullets.pause = true
                        myBullets.inChangFlag = true
                        myBullets.costhp = tempBullets.atk/60
                        MyFightingCtrl:setObjHaveBuff(myBullets.bufferIdTable,tempBullets)
                        MyFightingCtrl:setObjHaveBuff(tempBullets.bufferIdTable,myBullets)
                    end

                elseif (myBullets.skillType ~= 4 ) and ( tempBullets.skillType ~= 4) then 
                    if myBullets.type == tempBullets.type and tempBullets.isEnableCollision == true and myBullets.isEnableCollision == true then
                        flag1 = true
                    end
                end
                if flag1 == true then
                    local flag = false
                    if math.abs(myBullets:getPositionX() - tempBullets:getPositionX()) < 15 then
                        flag = true
                    end

                    
                    if flag  then --碰撞在一起了
                        myBullets.crashPos = crashPos
                        tempBullets.crashPos = crashPos
                        myBullets.pause = true
                        tempBullets.pause = true
                        myBullets.inChangFlag = false
                        tempBullets.inChangFlag = false
                        --cclog("1----myBullets.costhp=%d,tempBullets.costhp=%d",myBullets.costhp,tempBullets.costhp)
                        MyFightingCtrl:changObjInBullte(myBullets,tempBullets)
                        MyFightingCtrl:changObjInBullte(tempBullets,myBullets)
                       -- cclog("2----myBullets.costhp=%d,tempBullets.costhp=%d",myBullets.costhp,tempBullets.costhp)
                        MyFightingCtrl:setObjHaveBuff(myBullets.bufferIdTable,tempBullets)
                        MyFightingCtrl:setObjHaveBuff(tempBullets.bufferIdTable,myBullets)
                    end
                end
                
              
            end
            
        end

        for key, bullet in pairs(playerBullets) do
            bullet:update(dt)
        end   

        for key, bullet in pairs(enemyBullets) do
            bullet:update(dt)
        end


    end

    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0 ,false)
end

-- 出现神将的时机
function MyFightingLayer:guideCountGodSkill(dt)
 
	 if MyFightingCtrl.guideGodID == 0 then
	 	return
	 else
	    --出现 悟空
        if MyFightingCtrl.guideGodID == 411002 then --悟空的
            self.guideHouziCountTime = self.guideHouziCountTime + dt
            if  self.guideHouziCountTime >= self.guideHouziMaxTime then 
               
               if MyFightingCtrl.enemy.hp <= MyFightingCtrl.enemy.maxHp then
               
                    local flag = true
                    for key, god in pairs(MyFightingCtrl.player.myGod) do
                        if god.state == MyFightingConfig.ERoleState.Attack then
                            flag = false
                    	end
                    end
                    --如果没有神将在释放的话
                    if flag == true then
                        
                        self.isUpDateFlag = false --暂停游戏
                        
                        if UserData.NewHandLead.GuideList.FightingWithGodwill.step[2] ~= nil 
                            and UserData.NewHandLead.GuideList.FightingWithGodwill.step[2].PlotSectionID > 0 then
                            local function plotCallBack()
                                self:guideComeOutBigHead(MyFightingCtrl.enemy.maxHp*0.2)
                                self.guideHouziCountTime = 0
                                UserData.NewHandLead.GuideList.FightingWithGodwill.step[2].PlotSectionID = 0
                                
                            end
    
                            ManagerTask.SectionId = UserData.NewHandLead.GuideList.FightingWithGodwill.step[2].PlotSectionID
                            local PlotLayer = require("app.views.Plot.PlotLayer")
                            PlotLayer:initPlotEnterAntExit(0)
                            local layer = PlotLayer:create(nil, nil, plotCallBack)
                            self:addChild(layer, 31)
                        else
                            self:guideComeOutBigHead(MyFightingCtrl.enemy.maxHp*0.2)
                            self.guideHouziCountTime = 0    
                        end
                        
                    end
                end
            end
    
	     end
	 	
	 	
        if MyFightingCtrl.guideGodID == 413004 then
            if self.godSpine == nil then
                local MyGodData_Static = FightStaticData.godwill[MyFightingCtrl.guideGodID]
                local SpineJson = MyGodData_Static.spineName..".json"
                local SpineAtlas = MyGodData_Static.spineName..".atlas"

                self.godSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
                self.godSpine:setAnimation(0, "load", true)

                self.godSpine:setPosition(-50,100)
                MyFightingCtrl.player:addChild(self.godSpine,11)
                self.godSpine:setMix("load", "matk", 0.1) --过渡
                self.godSpine:setMix( "matk","load", 0.1) --过渡
            end

	 	end
	 	--出现阿三
        if MyFightingCtrl.guideGodID == 413004 and  self.isUpDateFlag ~= false then --阿三 只出现一次
            if MyFightingCtrl.enemy.hp <= MyFightingCtrl.enemy.maxHp/3 then
                self.isUpDateFlag = false --暂停游戏
                
                local function plotCallBack()
                    self:guideComeOutBigHead(MyFightingCtrl.enemy.maxHp)
                end
                
                ManagerTask.SectionId = UserData.NewHandLead.GuideList.Fighting_2.step[2].PlotSectionID
                local PlotLayer = require("app.views.Plot.PlotLayer")
                PlotLayer:initPlotEnterAntExit(0)
                local layer = PlotLayer:create(nil, nil, plotCallBack)
                self:addChild(layer, 31)
                
            end
	 	end
	 end
	
end

--新手引导用的 额外战斗神将，先出现大头像的都动画
function MyFightingLayer:guideComeOutBigHead(reduceHp)
    local godID = MyFightingCtrl.guideGodID
 
    if MyFightingCtrl.guideGodID == 411002 then
        if MyFightingCtrl.enemy.hp < 50 then
            MyFightingCtrl.guideGodID = 0
        end
    else
        MyFightingCtrl.guideGodID = 0
    end
    
    
    local releaseNode = cc.CSLoader:createNode("res/csb/god_release_layer.csb")
    MyFightingCtrl.battleLayer:addChild(releaseNode,22)
    releaseNode:setPositionY(releaseNode:getPositionY() + (display.height - 576)/2)
    local panel =  releaseNode:getChildByName("Panel")
    panel:setContentSize(cc.size(display.width, display.height))
    local pathName = "spine/releaseSkill/god_releaseSkill"
    local SpineJson = pathName..".json"
    local SpineAtlas = pathName..".atlas"
    local aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    aniSpine:setAnimation(0, "load", false)
    aniSpine:setPosition(display.center)
    panel:addChild(aniSpine)
  

    local bigGodPath = "items/bigGod/"..tonumber(godID)..".png"
    local bigGod = cc.Sprite:create(bigGodPath)

    bigGod:setPosition(display.width + 400,display.center.y)
    panel:addChild(bigGod)
    local act1 =cc.DelayTime:create(8/30)
    local act2 = cc.MoveTo:create(2/30,cc.p(display.width/4*1,display.center.y))
    local act3 = cc.MoveBy:create(40/30,cc.p( 60,0))
    local act4 = cc.MoveBy:create(5/30,cc.p(-1000,0))
    bigGod:runAction(cc.Sequence:create(act1,act2,act3,act4))

    local  function onSpineComplete(event) --完成
        if  event.animation == "load"  then

            aniSpine:stopAllActions()
            local function callback1()
                releaseNode:removeFromParent()
                MyFightingCtrl.battleLayer.isUpDateFlag = true
            end
            local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(callback1))
            aniSpine:runAction(seq)
            
            -- 出现神将
            self:guideGodRealseSkill(godID,reduceHp)
           
        end
    end

    -- 注册事件
    aniSpine:registerSpineEventHandler(onSpineComplete, 2)
end 

-- 引导出现的神将释放技能
function MyFightingLayer:guideGodRealseSkill(godId,reduceHp)
   
    local flag = false
    local MyGodData_Static = FightStaticData.godwill[godId]
   -- 如果为空，创建神将。额外的
    if self.godSpine == nil then
        flag = true
         
        local SpineJson = MyGodData_Static.spineName..".json"
        local SpineAtlas = MyGodData_Static.spineName..".atlas"

        self.godSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        self.godSpine:setAnimation(0, "load", true)

        self.godSpine:setPosition(0,30)
        MyFightingCtrl.player:addChild(self.godSpine,11)
        self.godSpine:setMix("load", "matk", 0.1) --过渡
        self.godSpine:setMix( "matk","load", 0.1) --过渡
   end

    
    local  function onSpineComplete(event)
        if  event.animation == "matk" then
            
            local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.MoveBy:create(0.5,cc.p(-50,100)))
            self.godSpine:runAction(seq)
            MyFightingCtrl.enemy:updateHp(-reduceHp)
        end
     end
    local function onSpineEvent(event)
        if event.eventData.name == "callback" and MyFightingCtrl.gameOver == nil then
        
            local skillID = MyGodData_Static.skillID                 
            local skillData  = FightStaticData.flyingObjectSkill[skillID]
            self.skillType = skillData.skillType

            if  self.skillType == 0 then -- 子弹
                
            elseif  self.skillType == 1 then -- 1直接伤害
                self:playFor_damage(MyGodData_Static)
            elseif  self.skillType == 2 then -- 2墙
               
            elseif  self.skillType == 3 then--3盾
               
            elseif  self.skillType == 4 then --4半场
                
            end
        
        end
    end
    -- 注册事件
    self.godSpine:registerSpineEventHandler(onSpineComplete, 2)
    self.godSpine:registerSpineEventHandler(onSpineEvent, 3)
    
    --等待1秒后播放神将技能动画
    local function callback()
        self.godSpine:setAnimation(0, "matk", false)
    end
    
    if flag == false then --已经创建了的
        local move = cc.MoveBy:create(0.5,cc.p(50,-100))
        self.godSpine:runAction(cc.Sequence:create(move,cc.CallFunc:create(callback)))
    else --第一次创建的时候
        self.godSpine:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(callback)))
    end
    
    
    
    
    
end



--1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
function MyFightingLayer:playFor_damage(MyGodData_Static)
    --获取对方的飞宝
    local targetRole = MyFightingCtrl:getTargetRole(MyFightingConfig.ECamp.Player) 
    local myRole = MyFightingCtrl:getRole(MyFightingConfig.ECamp.Player) 
  

    local skillID = MyGodData_Static.skillID                 
    local skillData  = FightStaticData.flyingObjectSkill[skillID]
    local smallAtkType = skillData.smallSkillType

    self.skillStaticData = skillData
    local role = targetRole
    local rolePos = cc.p(role:getPosition())

    local aniSpine = nil
    local aniParticle = nil

    local zord = myRole:getLocalZOrder()
    myRole:setLocalZOrder(zord + 1) 
    -- 是有骨骼动画的特效
    if self.skillStaticData.bombEffect ~= "0" then
        local SpineJson = self.skillStaticData.bombEffect..".json"
        local SpineAtlas = self.skillStaticData.bombEffect..".atlas"
        aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        aniSpine:setAnimation(0, "blast", false)
        aniSpine:setPosition(0,0)

    end
    --是有粒子的特效
    if self.skillStaticData.bombEffectParticle ~= "0" then
        aniParticle = cc.ParticleSystemQuad:create(self.skillStaticData.shootParticle2..".plist")
    end

    -- 获取位置
    local bombPos = cc.p(0,0)

    -- 添加到层
    local parent = self:getParent()
    if aniSpine then
        aniSpine:setPosition(bombPos)
        targetRole:addChild(aniSpine,20)
    end
    if aniParticle then
        aniParticle:setPosition(bombPos)
        targetRole:addChild(aniParticle,20)
    end

    --最后删除
    local  function onSpineComplete(event)
        myRole:setLocalZOrder(zord ) 
        if  event.animation == "blast" then
            if aniSpine then
                MyFightingCtrl:removeSpine(aniSpine)
            end
            if aniParticle then
                aniParticle:removeFromParent()
            end
        end
    end
    -- 结尾
    if aniSpine then
        aniSpine:registerSpineEventHandler(onSpineComplete, 2)
    end

   


end



return MyFightingLayer