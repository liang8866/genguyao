-- 卷选择界面
local CopySectionLayer = require("app.views.Pve.CopySectionLayer")
local CopyVolumeLayer = class("CopyVolumeLayer", require("app.views.View"))

function CopyVolumeLayer:onCreate()

    local csb = self:createResoueceNode("csb/CopyVolumeLayer.csb")--创建CSB
    local root = csb:getChildByName("root")
    root:setPosition(display.center)
    self.list = root:getChildByName("list")
    self.model = root:getChildByName("item")
    self.list:setItemModel(self.model)
    self.jqbtn = root:getChildByName("jqbtn")
    self.jyfbbtn = root:getChildByName("jyfbbtn")
    self.title = root:getChildByName("title")
    local closebtn = root:getChildByName("closebtn")
    
    local function onListEvent(sender, eventType)
        if eventType==1 then
            local index = self.list:getCurSelectedIndex()
            local item = self.list:getItem(index)        
            if item.close==true then
                return
            end
            local sectionLayer = CopySectionLayer:create(self.tab, item.id)
            self:addChild(sectionLayer)
        end
    end
    self.list:addEventListener(onListEvent)
    
    local function onButtonEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            if sender==self.jqbtn then
                self:switchTab(1)
            elseif sender==self.jyfbbtn then
                self:switchTab(2)
            elseif sender==closebtn then
                self:removeFromParent()
            end
        end
    end
    
    closebtn:addTouchEventListener(onButtonEvent)
    self.jqbtn:addTouchEventListener(onButtonEvent)
    self.jyfbbtn:addTouchEventListener(onButtonEvent)

    self.tab = -1    
    self:switchTab(1)
    
end

function CopyVolumeLayer:switchTab(tab)

    self.tab = tab
    if tab==1 then
        self.jqbtn:setHighlighted(true)
        self.jyfbbtn:setHighlighted(false)
        self.jqbtn:getChildByName("title"):setColor(cc.c3b(146,17,27))
        self.jyfbbtn:getChildByName("title"):setColor(cc.c3b(255,255,255))
        self.title:setString("剧情副本")
    else 
        self.jqbtn:setHighlighted(false)
        self.jyfbbtn:setHighlighted(true)
        self.jqbtn:getChildByName("title"):setColor(cc.c3b(255,255,255))
        self.jyfbbtn:getChildByName("title"):setColor(cc.c3b(146,17,27))
        self.title:setString("精英副本")
    end

    self:refreshList()

end

--进入
function CopyVolumeLayer:onEnter()
    
end

--退出
function CopyVolumeLayer:onExit()

end

function CopyVolumeLayer:refreshList()

    self.list:removeAllItems()
    
    local sections = UserData.Pve:getOpenSections()
      
    local min, count = 0, 0
    local copyValume = nil
    local openId = 0 
    if self.tab==1 then
        min, count = UserData.Pve:getVolumes()
        copyValume = StaticData.CopyVolume
        local tmp = StaticData.CopySection[sections.maxSection+1]
        if tmp then
            openId = tmp.CopyVolume
        elseif sections.maxSection>0 then
            openId = StaticData.CopySection[sections.maxSection].CopyVolume
        else
            openId = 20001
        end 
    else
        min, count = UserData.Pve:getEliteVolumes()
        copyValume = StaticData.EliteCopyVolume
        local tmp = StaticData.EliteCopySection[sections.maxEliteSection]
        if tmp then
            openId = tmp.CopyVolume
        elseif sections.maxSection>=21001 then
            openId = 25001
        end
    end
    
    local index = 0    
    for id=min, min+count-1 do
        index = index + 1
        self.list:pushBackDefaultItem()
        
        local item = self.list:getItem(index-1)
        if id>openId then
            item:getChildByName("image"):setColor(cc.c3b(128,128,128))
            item.close = true
        else
            local cur, max = self:getStarInfo(id)
            local percent = cur/max
            local bottompanel = item:getChildByName("bottompanel")    
            bottompanel:getChildByName("curlabel"):setString(tostring(cur))
            bottompanel:getChildByName("maxlabel"):setString("/" .. tostring(max))
            bottompanel:getChildByName("loadingbar"):setPercent(cur/max*100)
            for i=1, 4 do
                local box = bottompanel:getChildByName("box" .. tostring(i))
                if percent>=i*0.25 then
                    box:loadTexture("ui/pve/pve_box_highlight.png")
                end
            end
        end
        item.id = id
        item:setVisible(true)
        item:getChildByName("title"):getChildByName("titlelabel"):setString(string.format("第%d章", index))
        item:getChildByName("name"):getChildByName("namelabel"):setString(copyValume[id].VolumeName)
    end
   
end

-- 获取星级信息
function CopyVolumeLayer:getStarInfo(volumeId)
    
    local cur, max = 0, 0
    
    local sections = UserData.Pve:getOpenSections()
    local allsections = nil

    if self.tab==1 then
        allsections = UserData.Pve:getSectionsByVolumeId(volumeId)
    elseif self.tab==2 then
        allsections = UserData.Pve:getEliteSectionsByVolumeId(volumeId)
    end 

    if allsections then
        max = #allsections * 3
    end

    for key, value in pairs(allsections) do
        local id = value.SectionId
        if sections[id] then
            cur = cur + sections[id]
        end
    end

    return cur, max

end

return CopyVolumeLayer