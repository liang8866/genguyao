local MyDragControl = require("app.views.MyFighting.MyDragControl")

local MyBullet = require("app.views.MyFighting.MyBullet")
local FlyFunction = require("app/views/FlyTechTree/FlyFunction")
local MySkillHand = class("MySkillHand", function ()
    return cc.Node:create()
end)

function MySkillHand:create(godID, battlePathNode,camp)
    local view = MySkillHand.new()
    view:init(godID, battlePathNode,camp)
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


function MySkillHand:ctor()
    self.battlePathNode = nil    --战斗路径轨迹节点
    self.Image_path = nil   --战斗路径轨道表
    self.GodId = 0         -- 记录属于那个神将的ID
end


--退出
function MySkillHand:onExit()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
end

--进入
function MySkillHand:onEnter()

end


function MySkillHand:init(godID, battlePathNode,camp)

    self.dragControl = MyDragControl:create(godID, function(sender,touch,event,type,id) self:onTouchDragSrc(sender,touch,event,type,godID) end)

    local battleSkillNode = cc.CSLoader:createNode("csb/battle_fabao_node.csb")
    battleSkillNode:setAnchorPoint(cc.p(0.5,0.5))
    local Panel_root =  battleSkillNode:getChildByName("Panel_root")

    self.dragControl:setContentSize(Panel_root:getContentSize())
    self.dragControl:addChild(battleSkillNode)
  
  


    self.camp = camp       
    self.MyGodData =FightStaticData.godwill[godID] --获取神将的数据
    self.cdTime = self.MyGodData.cdTime /10000 --冷却时间
    self.myCountTime =  self.cdTime    --计算冷却时间
	self.Light = Panel_root:getChildByName("Image_light")
	self.Light:setVisible(false)
   
    local fibbleUpData = nil
    if camp == MyFightingConfig.ECamp.Player then
        local userGodData = UserData.Godwill.godList[godID]
         fibbleUpData = FlyFunction:findFibbleUpForSameIdAndStar(godID,userGodData.star)
    else
         local userGodData = FightStaticData.godwill[godID]
         fibbleUpData = FlyFunction:findFibbleUpForSameIdAndStar(godID,userGodData.star)
    end
    local icon  = "items/godWill/412010.png"
    if fibbleUpData then
        icon = fibbleUpData.icon
    end
    local Image_skillIcon = ccui.Helper:seekWidgetByName(Panel_root,'Image_skillIcon')
    
    Image_skillIcon:loadTexture(icon)
    local text_num = ccui.Helper:seekWidgetByName(Panel_root,'Text_num')
    text_num:setString(tostring(self.MyGodData.needAngry)) --设置需要多少点怒气
    text_num:setScale(0.6)
    Image_skillIcon:setColor(cc.c3b(130,130,130))
    Image_skillIcon:setScale(0.87)
    Image_skillIcon:setLocalZOrder(-1)
    --遮罩的
    self.barIcon = cc.ProgressTimer:create(cc.Sprite:create(icon))
    self.barIcon:setColor(cc.c3b(130,130,130))
    self.barIcon:setScale(1.18)
    self.barIcon:setReverseDirection(true)
    Image_skillIcon:addChild(self.barIcon)
    local size = Image_skillIcon:getContentSize()
    self.barIcon:setPosition(size.width/2,size.height/2)
    --设置ID
    battleSkillNode:setTag(godID) 
    self:addChild(self.dragControl)
    
    local p = Image_skillIcon:getParent()
    


--    self.fadeSprite = cc.Sprite:create("spine/ui/ui_zhandoujiemian_kuang_01.png")
--    self.fadeSprite:setPosition(Image_skillIcon:getPositionX()+2,Image_skillIcon:getPositionY()-2)
--    self.fadeSprite:setAnchorPoint(cc.p(0.5,0.5))
--    p:addChild(self.fadeSprite,-11)
--    self.fadeSprite:setOpacity(150)
--    local fade1 = cc.FadeTo:create(0.3,255)
--    local fade2 = cc.FadeTo:create(0.3,150)
--    local act = cc.Sequence:create(fade1,fade2)
--    self.fadeSprite:runAction(cc.RepeatForever:create(act)) 
--    self.fadeSprite:setVisible(false)
    
 
    local pathName = "spine/ui/ui_zhandoujiemian_kuang_01"
    local SpineJson = pathName .. ".json"
    local SpineAtlas = pathName .. ".atlas"
    self.fadeSprite = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.fadeSprite:setPosition(Image_skillIcon:getPositionX(),Image_skillIcon:getPositionY())
    self.fadeSprite:setAnchorPoint(cc.p(0.5,0.5))
    self.fadeSprite:setAnimation(0, "load", true)
    p:addChild(self.fadeSprite,1)
    self.fadeSprite:setVisible(false)
   
    --定时器
    self:updateAngry(Panel_root, self.dragControl)  --更新显示定时器

    self.battlePathNode = battlePathNode

    local path_Panel_root = self.battlePathNode:getChildByName('Panel_root')

    self.Image_path = {
        path_Panel_root:getChildByName('Image_path1'),
        path_Panel_root:getChildByName('Image_path2'),
        path_Panel_root:getChildByName('Image_path3')
    }   
   
   
end


function MySkillHand:onTouchDragSrc(sender,touch,event,type,skillId)
    if type == sender.EventType.Copy then 
        self.battlePathNode:setVisible(true)

    elseif type == sender.EventType.Throw then
        local retVal = self:isInRectArea(touch)
        if retVal == 1 and self.tag ~= retVal then
            self:changePathState(1)
        elseif retVal == 2 and self.tag ~= retVal then
            self:changePathState(2)
        elseif retVal == 3 and self.tag ~= retVal then
            self:changePathState(3)
        elseif retVal == 4 and self.tag ~= retVal then
            self:changePathState(4)
        end
        self.tag = retVal 
        MyFightingCtrl.battleLayer.isUpDateFlag = false 

        self.fadeSprite:setVisible(false)

    elseif type == sender.EventType.Release then
        if self.tag < 4 then
            self.myCountTime = 0 --从新计算
            local role = MyFightingCtrl:getRole(self.camp)
            local god = role.myGod[self.godIdx] --获取一个神将
            role.angryCount = role.angryCount - god.needAngry--消耗了点怒气
            god.lineType =  self.tag -- 记录路线
            god:releaseSkill() --释放技能
            if UserData.BaseInfo.myFightTaskId == 510001 then
--                local myFlyRole = self:getParent()
                local myFightingLayer = self:getParent()
                local newLeadLayer = myFightingLayer:getChildByTag(1)
                if newLeadLayer ~= nil then
                    newLeadLayer:removeFromParent()
                    newLeadLayer = nil
                end
            end
        else
            MyFightingCtrl.battleLayer.isUpDateFlag = true 
        end  
        sender.cloneItem:removeFromParent()
        sender.cloneItem = nil
        self.battlePathNode:setVisible(false)
             
         

    elseif type == sender.EventType.Click then--点击查看
        --cclog('cxxxxxxxx== %d', skillId)
    end
end


function MySkillHand:isInRectArea(touch)
    for key, var in ipairs(self.Image_path) do
        local pos = cc.p(touch:getLocation())
        local locationInNode = var:convertToNodeSpace(pos)
        local s = var:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            return key
        end
    end
    return 4
end


function MySkillHand:changePathState(pathNum)
 
    if pathNum == 1 then
        self.Image_path[1]:loadTexture('ui/myFighting/myfighting_path2.png')
        self.Image_path[2]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[3]:loadTexture('ui/myFighting/myfighting_path1.png')
    elseif pathNum == 2 then
        self.Image_path[1]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[2]:loadTexture('ui/myFighting/myfighting_path2.png')
        self.Image_path[3]:loadTexture('ui/myFighting/myfighting_path1.png')
    elseif pathNum == 3 then
        self.Image_path[1]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[2]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[3]:loadTexture('ui/myFighting/myfighting_path2.png')
    elseif pathNum == 4 then 
        self.Image_path[1]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[2]:loadTexture('ui/myFighting/myfighting_path1.png')
        self.Image_path[3]:loadTexture('ui/myFighting/myfighting_path1.png')
    end
end


--更新需要的消耗的东东满足没有
function MySkillHand:updateAngry(root, dragItem) 
    local function update(dt)
        if MyFightingCtrl.battleLayer.isUpDateFlag == true then
            local role  = MyFightingCtrl:getRole(self.camp)
            self:showSkillAngry(root,role.angryCount ,dragItem,dt)
        end
        if MyFightingCtrl.gameOver ~= nil then --说明游戏结束了
            dragItem.isDragTouch = false
        end
    end

    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0 ,false)
end


function MySkillHand:showSkillAngry(root, angry, dragItem,dt) 
    local Image_skillIcon =  root:getChildByName("Image_skillIcon")
    Image_skillIcon:setColor(cc.c3b(255,255,255))
    
    
    self.myCountTime = self.myCountTime + dt 
    if self.myCountTime >= self.cdTime  then --如果是冷却时候到了才可以
        self.myCountTime = self.cdTime
        self.barIcon:setPercentage(0)
    else
        self.barIcon:setPercentage((1-self.myCountTime/self.cdTime)*100)
--        self.Light:setVisible(false)
        self.fadeSprite:setVisible(false)
        dragItem.isDragTouch = false

    end
    
    if angry >= self.MyGodData.needAngry then
        if self.myCountTime >= self.cdTime  then --如果是冷却时候到了才可以
            dragItem.isDragTouch = true
--            self.Light:setVisible(true)
            self.fadeSprite:setVisible(true)
           
        end
    else
--        self.Light:setVisible(false)
        self.fadeSprite:setVisible(false)
        --Image_skillIcon:setColor(cc.c3b(130,130,130))
        
        dragItem.isDragTouch = false
    end

    
    
    
--    if angry >= self.MyGodData.needAngry then
--        self.myCountTime = self.myCountTime + dt 
--        if self.myCountTime >= self.cdTime  then --如果是冷却时候到了才可以
--            self.myCountTime = self.cdTime
--            Image_skillIcon:setColor(cc.c3b(255,255,255))
--            dragItem.isDragTouch = true
--            self.barIcon:setPercentage(0)
--            self.Light:setVisible(true)
--        else
--            self.barIcon:setPercentage((1-self.myCountTime/self.cdTime)*100)
--            self.Light:setVisible(false)
--        end
--        
--        
--    else
--
--        self.Light:setVisible(false)
--        Image_skillIcon:setColor(cc.c3b(130,130,130))
--        dragItem.isDragTouch = false
--    end

end


return MySkillHand
