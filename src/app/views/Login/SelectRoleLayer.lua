local SelectRoleLayer = class("SelectRoleLayer", require("app.views.View"))

local stringEx =  require("common.stringEx")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

function SelectRoleLayer:onCreate()
    local SceneManager = require("app.views.SceneManager")
    SceneManager.isFirstLoginInApp = true
    self.index = 0
    
    EventMgr:registListener(EventType.onRandomName, self, self.onRandomName)

    self.rootNode = self:createResoueceNode("csb/selectRoleLayer.csb") --获取根目录
--    self.rootNode:setPositionY( self.rootNode:getPositionY() + (display.height - 576)/2)
    local Panel1 = self.rootNode:getChildByName("Panel_1")--获取panel1
    Panel1:setPosition(display.center)--放到位中心去
    local Image_inputbg = self.rootNode:getChildByName("Image_inputbg")
    self.input_TextField = Image_inputbg:getChildByName("input_TextField")          --你输入的名字的框
    self.input_TextField:setTextHorizontalAlignment(1)
    self.input_TextField:setString(UserData.BaseInfo.userName)
    self.rand_name_btn = Image_inputbg:getChildByName("rand_name_btn")
    
    Image_inputbg:setPositionY(Image_inputbg:getPositionY() + (display.height - 576)/2)
    local Text_Select_role =  self.rootNode:getChildByName("Text_Select_role")
    Text_Select_role:setPositionY(Text_Select_role:getPositionY() + (display.height - 576)/2)
    
    self.Image_cloud_left = self.rootNode:getChildByName("Image_cloud_left")
    self.Button_left_role = self.Image_cloud_left:getChildByName("Button_left_role")
    self.Image_cloud_right = self.rootNode:getChildByName("Image_cloud_right")
    self.Button_right_role = self.Image_cloud_right:getChildByName("Button_right_role")
    
    local function onEventTouchButton(sender,eventType)
        if sender == self.Button_left_role and eventType == cc.EventCode.ENDED then
            self.index = 1
            self.Image_cloud_left:setColor(cc.c3b(255,255,255))
            self.Image_cloud_left:setScale(1)
            self.Image_cloud_right:setColor(cc.c3b(100,100,100))
            self.Image_cloud_right:setScale(0.7)
            UserData.BaseInfo:sendServerRandomName(1)
        elseif sender == self.Button_right_role and eventType == cc.EventCode.ENDED then
            self.index = 2
            self.Image_cloud_left:setColor(cc.c3b(100,100,100))
            self.Image_cloud_left:setScale(0.7)       
            self.Image_cloud_right:setColor(cc.c3b(255,255,255))
            self.Image_cloud_right:setScale(1)
            UserData.BaseInfo:sendServerRandomName(2) 
        end
    end
    
    self.Button_left_role:addTouchEventListener(onEventTouchButton)
    self.Button_right_role:addTouchEventListener(onEventTouchButton)

    self:showComfirm(Panel1)
    self.index = 1
    self.Image_cloud_left:setColor(cc.c3b(255,255,255))
    self.Image_cloud_left:setScale(1)
    self.Image_cloud_right:setColor(cc.c3b(100,100,100))
    self.Image_cloud_right:setScale(0.7)    
    self:getRandomName(Panel1)     
    
end
--进入
function SelectRoleLayer:onEnter()
    print("SelectRoleLayer:onEnter")
end

--退出
function SelectRoleLayer:onExit()
    print("SelectRoleLayer:onExit")
    EventMgr:unregistListener(EventType.onRandomName, self, self.onRandomName)
end

-- 检测输入的名字是否符合规则 返回 1 表示字符串太短  返回 2表示 带有不合法字符
function SelectRoleLayer:checkInputNameIsCorrect(inputname)
    local indexFlag = 0
    if inputname == nil or inputname == "" or string.len(inputname) < 6 then --字符串太短
        indexFlag = 1
    elseif stringEx:isincludespecialchar(inputname) == true then
        indexFlag = 2
    end
    return indexFlag
end



--返回或者确认按钮
function SelectRoleLayer:showComfirm(panel1)
    local btn_comfirm = ccui.Helper:seekWidgetByName(panel1,"confirm_btn")
    local btn_back = ccui.Helper:seekWidgetByName(panel1,"back_btn")
    local function onEventTouchButton(sender,eventType)
        if sender == btn_back and eventType == cc.EventCode.ENDED then -- 返回按钮的
--            local SceneManager = require("app.views.SceneManager")
--            SceneManager:switch(SceneManager.SceneName.SCENE_SELECTADDRSEVER)
        end
        if sender == btn_comfirm and eventType == cc.EventCode.ENDED then -- 判断点击OK按钮的
            local  inputNameStr = self.input_TextField:getString()  --获取你输入的名字
            local indexflag = self:checkInputNameIsCorrect(inputNameStr)
            if indexflag == 0 then --符合规则的情况下  
                local index = self:getCurIndex() 
                local JobTbale = {1,1,2,2,3,3,4,4}
                local JobID = JobTbale[index]
                
                local sex = 1
                local imageID = index + 10 -- ICON表格中11~12是地图人物头像，21，22是UI上的人物头像
                if index%2 == 0 then
                    sex = 2
                end
                
                
                UserData.BaseInfo:sendServerRegist(inputNameStr,sex,imageID) --请求注册
                
            elseif  indexflag == 1 then --1 表示字符串太短  返回 2表示 带有不合法
                PublicTipLayer:setTextAction("你输出人名字太短")
            elseif  indexflag == 2 then   --1 表示字符串太短  返回 2表示 带有不合法
                PublicTipLayer:setTextAction("您输入的名字不合法")
            end
        end

 
    end --onEventTouchButton 函数的结束

    --为按钮添加触摸回调函数
    btn_comfirm:addTouchEventListener(onEventTouchButton)
    btn_comfirm:setPressedActionEnabled(true)
    btn_back:addTouchEventListener(onEventTouchButton)
    btn_back:setPressedActionEnabled(true)
    
    -- 对字体进行描边
    local Text_comfirm = btn_comfirm:getChildByName("Text_1")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_comfirm)  
    

end

--点击随机名名字按钮获取随机名字
function SelectRoleLayer:getRandomName(root)
--    local btn_random = ccui.Helper:seekWidgetByName(root ,"rand_name_btn")
    local function onEventTouchButton(sender,eventType)
       
        if sender == self.rand_name_btn and eventType == cc.EventCode.ENDED then
            -- 这里发送服务器获取名字
            UserData.BaseInfo:sendServerRandomName(UserData.BaseInfo.userSex)
           
        end
    end
    self.rand_name_btn:addTouchEventListener(onEventTouchButton)
    self.rand_name_btn:setPressedActionEnabled(true)
end


function SelectRoleLayer:createCircle()
    self.islandsTable = {}
    self.beautyIdTable = StaticData.SelectRoleData --获取对应的数据
    self.center = display.center
    for i = 1 ,#self.beautyIdTable do
        local nd = cc.CSLoader:createNode("csb/selectRoleNode.csb")
        nd.Id = i
        self.islandsTable[i] = nd
        nd:setTag(i)
        local itemData = self.beautyIdTable[i]

        local Image_icon = nd:getChildByName("Image_icon")
        Image_icon:loadTexture(itemData.image) --设置对应的人物
        
        local Text_school =  Image_icon:getChildByName("Text_school") --职业
        local school = itemData.name..i
        Text_school:setString(school)
        local panel = Image_icon:getChildByName("Panel_des")-- 描述panel
        local Text_des = panel:getChildByName("Text_des") -- 描述
        Text_des:setString(itemData.decs)
       
        self:addChild(nd)
    end


    local PI2 = 6.2831
    local centerPos = cc.p( self.center.x , self.center.y  )
    local r = 180 + 20* #self.beautyIdTable--半径 
    local xScale = 1.37 --X轴缩放 1.8 1.2
    local yScale = 0.1 --Y轴缩放

    local degree = 0 --角度
    local targetDegree = degree  --目标角度
    local nIslandNum = #self.beautyIdTable
    local curIsland = nil 

    local function getPosFromDegree(degree)
        -- 圆形方程
        local x = r * math.cos(degree)
        local y = r * math.sin(degree)
        x = x * xScale + centerPos.x
        y = y * yScale + centerPos.y 
        return cc.p(x,y)
    end

    local function compare(cell1, cell2)
        return cell1:getPositionY() > cell2:getPositionY()
    end
    local temp = nil
    local dAngle = 0.5 + nIslandNum *0.25 
    local startAlpha = 0.66
    local function refreshPosition()
        if self.islandsTable == nil then    
            return
        end
        for i=1, #self.islandsTable do
          
            local pos = getPosFromDegree(( i -dAngle)*PI2/nIslandNum -  PI2/(nIslandNum*2) + degree)
            self.islandsTable[i]:setPosition(pos)
        end

        if temp == nil then
            temp = {}
            for i=1, #self.islandsTable do
                temp[i] = self.islandsTable[i]
            end
        end
        table.sort(temp,compare)
        curIsland = temp[#temp]

        for i=1, #temp do
            if temp[i]:getPositionY() > centerPos.y then
                temp[i]:setLocalZOrder(1+i)
            else
                temp[i]:setLocalZOrder(11+i)
            end
            local ymin = centerPos.y - r * yScale
            local y = temp[i]:getPositionY() 
            
            local alpha = (1-(y-ymin)/(r*yScale*2))
            
--            if alpha <= 0 or y >(centerPos.y) then
--                alpha = 0
--            end
--            local myAlpha =  (1-(y-ymin)/(r*yScale))
--            if  math.abs(centerPos.y - y) < 1 then
--                myAlpha = 0.2
--            end
         
            local Image_icon =  temp[i]:getChildByName("Image_icon")
            
            Image_icon:setOpacity(  alpha * 255)
           
            temp[i]:setScale(0.2 + 0.6*alpha*alpha)
            
            --选择的对象
            self:mSelectBulgeNode(self:getCurIndex())
        end
    end
    refreshPosition()

    local oldTarget = 0
    local startPos = cc.p(0,0)
    local delta = PI2/nIslandNum
   
    local startDegree = 0
    local deltaDegree = 0
    local eachPi = 3.14 / 4
    self.isPauseUpdate = false --是否暂停更新
    local function onTouchBegan(touch , event)
        if self.isTouchFlag == true then
            startPos = touch:getLocation()
            startDegree = degree
            deltaDegree = 0
            
            self.isPauseUpdate = true --是否暂停更新
        end
        return self.isTouchFlag
    end
    local function onTouchMoved(touch , event)
        local location = cc.p(touch:getLocation())
        deltaDegree = (location.x - startPos.x)/180
        degree = startDegree + deltaDegree
        targetDegree = degree
        
        refreshPosition()  
    end
    local function onTouchEnded(touch, event)
        local location = cc.p(touch:getLocation())
        local offset = location.x - cc.p(touch:getStartLocation()).x

        local k,sub = math.modf(deltaDegree/delta)
        if sub > 0.1 then
            k = k + 1
        elseif sub < -0.1 then
            k = k - 1
        end
        targetDegree = startDegree + k * delta
        
       
--        local i = targetDegree/delta
--        local index = i
--        if i< 0 then
--            index = (nIslandNum - i)%nIslandNum + 1
--        else      
--            index = math.abs(i )%(nIslandNum)+1 
--        end      
--        cclog("-----i=%d----  index = %d  idx",i,index)
        

        

        if  math.abs(offset) < 10  then
            for j=1, nIslandNum do
                local Image_icon =  self.islandsTable[j]:getChildByName("Image_icon")
                local contentSize = Image_icon:getContentSize() 
                local viewPos = self:convertToNodeSpace(location)
                local opa = Image_icon:getOpacity()
                if opa > 80 then
                    local sca = self.islandsTable[j]:getScale()  
                    local value1 = math.abs(viewPos.x - self.islandsTable[j]:getPositionX()) 
                    local value2 = math.abs(viewPos.y - self.islandsTable[j]:getPositionY()) 
                    if value1 < (sca*contentSize.width/2 )  and value2 < (sca*contentSize.height/2  ) then
                        local index = self:getCurIndex()
                        local xiangcha = index - j
                        if xiangcha == 6 then
                            xiangcha = -2
                        elseif xiangcha == -6 then
                            xiangcha = 2   
                        elseif xiangcha == 7 then
                            xiangcha = 1  
                        elseif xiangcha == -7 then
                            xiangcha = -1  
                        end 
                        local mydelta = xiangcha *(delta)
                        targetDegree = mydelta + targetDegree
                       
                        self.isTouchFlag = false
                       
                    end
                end
            end
        end
  
        --用于最后偏离纠正的，肯定是必须是整数的
        local num = math.floor(targetDegree / eachPi + 0.5)
        targetDegree = num * eachPi
       
        self.isPauseUpdate = false --是否暂停更新
       
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)

--    --默认转到第五个
--    local delta = PI2/nIslandNum
--    local mydelta = -4 * delta
--    targetDegree = mydelta + degree


    local function update(dt)
    
        if self.isPauseUpdate == true  then--是否暂停更新
            return
        end
        
        if degree == targetDegree then
        
            self.isTouchFlag = true
            return
        end
        --self.isTouchFlag = false
        degree = degree * (1-dt*nIslandNum/2) + targetDegree * dt*nIslandNum/2
        local sub = targetDegree - degree 
        
        if math.abs(sub) < 0.005 then
            degree = targetDegree

            local CurIdx =self:getCurIndex()
            local sex = 1
            if CurIdx%2 == 0 then
            	sex = 2
            end
         
            UserData.BaseInfo:sendServerRandomName(sex)--单数是男，双数是女
        end
        refreshPosition()
    end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.016, false) 


end

--获取当前的index
function SelectRoleLayer:getCurIndex()
    return self.index
end

function SelectRoleLayer:mSelectBulgeNode(index)
  -- cclog("选择%d",index)
end

--通知随机名字
function SelectRoleLayer:onRandomName(event)
    local result = event._usedata
    if result == 0 then --表示成功
--        local Panel1 = self.rootNode:getChildByName("Panel_1")--获取panel1
--        local inputWdg = ccui.Helper:seekWidgetByName(Panel1, "input_TextField")       --你输入的名字的框
        self.input_TextField:setString(UserData.BaseInfo.userName)
    else  -- 失败
        PublicTipLayer:setTextAction("请求随机名字失败！") 
    end
    
end




return SelectRoleLayer