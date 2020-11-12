
local MyDragControl = class("MyDragControl", function()
    return ccui.Layout:create()
end)


--id：控件ID，callBackSrc：源对象外部回调函数   
--外部必须以id来设置对象的Tag
function MyDragControl:create(id, callbackSrc)
    local view = MyDragControl.new()
    view:init(id, callbackSrc)
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


function MyDragControl:ctor()
    --事件类型
    self.EventType = {
        None    = 0,    --初始化状态
        Began   = 1,    --按下
        Copy    = 2,    --创建副本
        Throw   = 3,    --拖拽移动
        Release = 4,    --拖拽释放
        Click   = 5,    --点击事件
    }

    self.status = self.EventType.None --拖拽状态事件
    self.isDragTouch = true    --是否开启拖拽控件
    self.srcItem = nil   --原对象
    self.cloneItem = nil --副本对象
    self.callbackSrc = nil   --原本外部回调函数
    self.id = nil     --对象ID
    self.listener = nil    --原本监听
end


function MyDragControl:onEnter()

end


function MyDragControl:onExit()
    self:closeTouchEvent()
end


function MyDragControl:init(id, callbackSrc)
    self.callbackSrc = callbackSrc
    self.id = id 

    self:openTouchEvent()
end


--开启触摸事件
function MyDragControl:openTouchEvent()
    if self.listener ~= nil then
        return
    end

    local beganPos = nil
    local function onTouchBegan(touch , event)
        if self.isDragTouch == false then
            return false
        end

        local pos = cc.p(touch:getLocation())
        beganPos = pos
        local locationInNode = self:convertToNodeSpace(pos)
        local s = self:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self.status = self.EventType.Began
            --self:srcItemEvent(touch, event) 
            return true 
        end 
        return false
    end

    local function onTouchMoved(touch , event)
        local location = cc.p(touch:getLocation())    
        if self.status ~= self.EventType.Throw then
            local valueX = math.abs(location.x - beganPos.x)
            local valueY = math.abs(location.y - beganPos.y) 
            if valueX > 7 or valueY > 7 then--创建副本
                self.status = self.EventType.Copy
                self:srcItemEvent(touch, event)
            else
                return
            end  
            self.status = self.EventType.Throw
        end
        self:srcItemEvent(touch, event)
    end

    local function onTouchEnded(touch , event)
        if self.status == self.EventType.Began then
            self.status = self.EventType.Click
        elseif self.status == self.EventType.Throw then 
            self.status = self.EventType.Release 
        else

        end
        self:srcItemEvent(touch, event) 
    end

    self.listener = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(true)
    self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)  
end


--关闭触摸事件
function MyDragControl:closeTouchEvent()
    if self.listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end


--原本对象的外部回调
function MyDragControl:noticeEventSrc(touch,event)
    if self.callbackSrc then
        self.callbackSrc(self,touch,event,self.status, self.id)
    end
end


--原本对象的触摸操作
function MyDragControl:srcItemEvent(touch, event)
    if self.status == self.EventType.None then--none


    elseif self.status == self.EventType.Began then--按下 


    elseif self.status == self.EventType.Copy then--创建副本
        self.srcItem = self:getChildByTag(self.id):getChildByName("Panel_root"):getChildByName("Image_skillIcon")    --外部必须以id来设置对象的Tag
        
        self.cloneItem = self.srcItem:clone()
        local z = self:getLocalZOrder()

        self:getParent():addChild(self.cloneItem,z+1)
        local lacation = cc.p(touch:getLocation())
        local pos = cc.p(self:getParent():convertToNodeSpace(lacation))
       -- self.cloneItem:setPosition(cc.p(pos.x - self.cloneItem:getContentSize().width,pos.y - self.cloneItem:getContentSize().height)) 
        self.cloneItem:setPosition(pos)
        self:noticeEventSrc(touch,event)


    elseif self.status == self.EventType.Throw then--拖拽移动
        local lacation = cc.p(touch:getLocation())
        local pos = cc.p(self:getParent():convertToNodeSpace(lacation)) 

        self.cloneItem:setPosition(pos)

        self:noticeEventSrc(touch,event)


    elseif self.status == self.EventType.Release then--拖拽释放
        local pos = cc.p(touch:getLocation())
        self:noticeEventSrc(touch,event)


    elseif self.status == self.EventType.Click then--点击查看
        self:noticeEventSrc(touch,event)


    else

    end

end


return MyDragControl


