local StaticData = require("static_data.StaticData")

local lNet = require ("net.Net")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local SelectSerAddrLayer = class("SelectSerAddrLayer", require("app.views.View"))

function SelectSerAddrLayer:onEnter()
    -- 定时器
    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) self:update(dt) end, 0.016 ,false)
end

function SelectSerAddrLayer:onExit()
    if self.scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
    end
    self.scheduleUpdate = nil
end

-- 获取所有的大区
function SelectSerAddrLayer:getAllAddrInfo()
   local bigZone = {}
   local count = #StaticData.ConnectAddr
   for i=1, count do
       local data = StaticData.ConnectAddr[i]
       if bigZone[data.BigZone]==nil then
          bigZone[data.BigZone] = {}
       end
       table.insert(bigZone[data.BigZone], data)
   end
   return bigZone
end

--初始化
function SelectSerAddrLayer:onCreate()

    self.bigInfo = self:getAllAddrInfo()
    self.leftPanel = nil
    self.leftCells = {}
    self.cellHeight = 50
    self.cellOffset = 40
    self.midCells = {}

    self.visibleSize = cc.Director:getInstance():getVisibleSize()

    self.mylayer = self:createResoueceNode("csb/SelectServerScene.csb")
    local root =  self.mylayer:getChildByName("Panel")
    self.leftPanel = root:getChildByName("leftContainer"):getChildByName("leftPanel")
    self.Title = root:getChildByName("Title"):getChildByName("value")

    root:setPosition(self.visibleSize.width/2,self.visibleSize.height/2)

    self:initTopMenu()
    self:initLeftMenu()
    self:initMidMenu()
    self:attachEvent()
    self:refreshLeftMenu(-1)

end

-- 初始化顶部菜单
function SelectSerAddrLayer:initTopMenu()
    local root =  self.mylayer:getChildByName("Panel")
    local topPanel = root:getChildByName("topPanel")
    local addrLabel = topPanel:getChildByName("value")
    local stateLabel = topPanel:getChildByName("state")

    local id = cc.UserDefault:getInstance():getIntegerForKey("lastLoginAddr",-1)
    if id == -1 then
        addrLabel:setString("")
        stateLabel:setString("")
    else
        local addrData = StaticData.ConnectAddr[id]
        addrLabel:setString(addrData.ZoneName)
        stateLabel:setString(addrData.Status)
        if addrData.Status == "爆满" then
            stateLabel:setColor(cc.c3b(248,0,10))
        else
            stateLabel:setColor(cc.c3b(31,162,101))
        end
    end

    local function onBtnClick(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            local addrData = StaticData.ConnectAddr[id]

            if addrData == nil then
                return
            end
            UserData.BaseInfo.userServAddrTable = addrData
            self:login()
        end
    end
    topPanel:getChildByName("btn"):addTouchEventListener(onBtnClick)

end

-- 初始化中间菜单
function SelectSerAddrLayer:initMidMenu()
    local function onBtnClick(sender, eventType)
         if eventType == cc.EventCode.ENDED then
            local tag = sender:getTag()
            local bigArea = self.bigInfo[self.curBigAddr]
            local addrData = bigArea[tag]
            UserData.BaseInfo.userServAddrTable = addrData
            self:login()
         end
    end

    local root =  self.mylayer:getChildByName("Panel")
    local selectPanel = root:getChildByName("selectPanel")
    local cell = selectPanel:getChildByName("1")
    cell:getChildByName("cellbg"):setTag(1)
    cell:getChildByName("cellbg"):addTouchEventListener(onBtnClick)
    self.midCells[1] = cell
    for i=2, 10 do
        local clone = cell:clone()
        local col = math.fmod(i-1,2)
        local line = math.floor((i-1)/2)
        clone:setPosition(cc.p(col*330, (4-line)*70))
        clone:setParent(nil)
        clone:getChildByName("cellbg"):addTouchEventListener(onBtnClick)
        selectPanel:addChild(clone)
        self.midCells[i] = clone
        clone:getChildByName("cellbg"):setTag(i)
    end
end

-- 初始化左边菜单
function SelectSerAddrLayer:initLeftMenu()
    for key, value in pairs(self.bigInfo) do
        local text = ccui.Text:create(key,"Arial",20)
        text.data = key
        text:setAnchorPoint(cc.p(0, 0.5))
        self.leftPanel:addChild(text)
        self.leftCells[#self.leftCells+1] = text
    end

    for i=1, #self.leftCells do
        local cell = self.leftCells[i]
        cell:setPosition(cc.p(-self.cellOffset*(i-1), -(i-1)*self.cellHeight))
    end
end

function SelectSerAddrLayer:update(dt)
    self:rePosition()
end

-- 重置位置
function SelectSerAddrLayer:rePosition()
    local offsetY = self.leftPanel:getPositionY()
    for i=1, #self.leftCells do
        local cell = self.leftCells[i]
        local curPosY = offsetY + cell:getPositionY()
        if math.abs(curPosY) > 3 * self.cellHeight then
            cell:setVisible(false)
        else
            cell:setVisible(true)
            if math.abs(curPosY) < self.cellHeight then
                self:refreshMidMenu(cell.data)
                cell:setColor(cc.c3b(255,255,255))
            else
                cell:setColor(cc.c3b(128,128,128))
            end
        end
        cell:setScale(1.3-0.3/(3*self.cellHeight)*math.abs(curPosY))
        cell:setPositionX(-math.abs(curPosY)/self.cellHeight * self.cellOffset)
    end
end

-- 刷新中间菜单
function SelectSerAddrLayer:refreshMidMenu(addr)
    if self.curBigAddr and self.curBigAddr == addr then
        return
    end

    self.curBigAddr = addr
    local data = self.bigInfo[addr]
    if data == nil then
       return
    end

    self.Title:setString(data[1].BigZone)

    local nCount = #data
    for i=1, 10 do
        local cell = self.midCells[i]
        if i<=nCount then
            cell:getChildByName("name"):setString(data[i].ZoneName)
            cell:getChildByName("state"):setString(data[i].Status)
            if data[i].Status == "爆满" then
                cell:getChildByName("state"):setColor(cc.c3b(248,0,10))
            else
                cell:getChildByName("state"):setColor(cc.c3b(31,162,101))
            end
            cell:setVisible(true)
        else
            cell:setVisible(false)
        end
    end
end 

-- 触摸事件处理
function SelectSerAddrLayer:attachEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    local halfWidth = cc.Director:getInstance():getVisibleSize().width/2

    -- 开始
    listener:registerScriptHandler(function(touch, event)
     if touch:getLocation().x > halfWidth then
         return false
     end
        self.startPos = cc.p(touch:getLocation())
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )

    -- 移动
    listener:registerScriptHandler(function(touch, event)
        self:handleMove(touch)
    end,cc.Handler.EVENT_TOUCH_MOVED )

    -- 结束
    listener:registerScriptHandler(function(touch, event)
        self:handeEnded(touch)
    end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) 
end

function SelectSerAddrLayer:handleMove(touch)
    local deltaY =  touch:getDelta().y
    local curPosY = self.leftPanel:getPositionY()+deltaY
    self.leftPanel:setPositionY(curPosY)
    self:refreshLeftMenu(deltaY)
    --self:rePosition()
end

-- 滚动左边菜单
function SelectSerAddrLayer:refreshLeftMenu(deltaY)
    if deltaY < 0 then
        local offset = self.leftPanel:getPositionY()
        local tmp = {}
        for i=#self.leftCells, 1, -1 do
            local cell = self.leftCells[i]
            if cell:getPositionY()+ offset < -3 * self.cellHeight then
                tmp[#tmp+1] = cell
                self.leftCells[i] = nil
            end
        end

        local posy = self.leftCells[1]:getPositionY()
        for i=1, #tmp do
            table.insert(self.leftCells, 1, tmp[i])
            tmp[i]:setPositionY(i*self.cellHeight + posy)
        end
    end

    if deltaY > 0 then
        local offset = self.leftPanel:getPositionY()
        local tmp = {}
        local tb = {}
        for i=1, #self.leftCells do
            local cell = self.leftCells[i]
            if cell:getPositionY() + offset > 3 * self.cellHeight then
                tmp[#tmp+1] = cell
            else
                tb[#tb+1] = cell
            end
        end

        self.leftCells = tb
        local posy = self.leftCells[#self.leftCells]:getPositionY()
        for i=1, #tmp do
            self.leftCells[#self.leftCells+1] = tmp[i]
            tmp[i]:setPositionY(-i*self.cellHeight + posy)
        end
    end
end

function SelectSerAddrLayer:handeEnded(touch)
    local offset = self.leftPanel:getPositionY()
    local i,j = math.modf(offset/self.cellHeight)

    local offsetY = cc.p(touch:getLocation()).y - cc.p(touch:getStartLocation()).y
    self:refreshLeftMenu(offsetY)

    if offsetY > 5 then
        i = i + math.ceil(j)
    elseif offsetY < -5 then
        i = i + math.floor(j)
    end
    self:ScrollTo(i)
end

function SelectSerAddrLayer:ScrollTo(index)
    local offset = index * self.cellHeight
    local moveto = cc.MoveTo:create(0.15, cc.p(0, offset))
    self.leftPanel:runAction(moveto)
end

-- 登录
function SelectSerAddrLayer:login()
    local ser = UserData.BaseInfo.userServAddrTable 
    lNet:init(ser["NetAddr"],ser["NetPort"]) 
    UserData.BaseInfo:sendServerRandomName(1)--请求随机名字，开始进来默认是男的，用在创建角色那边  
    local SceneManager = require("app.views.SceneManager")
    SceneManager:switch(SceneManager.SceneName.SCENE_LOGIN)
end

function SelectSerAddrLayer:NextScene(event)
--    cc.UserDefault:getInstance():setIntegerForKey("lastLoginAddr", UserData.BaseInfo.servAddrTable["id"])
--    self:removeChildByTag(1000,true)
--    local SceneManager = require("view.SceneManager")
--    SceneManager:switch(SceneManager.SceneName.SCENE_NAME_LOGIN)
end

return SelectSerAddrLayer
