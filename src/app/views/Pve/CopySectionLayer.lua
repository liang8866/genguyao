-- 副本选择界面
local CopySectionLayer = class("CopySectionLayer", require("app.views.View"))

-- sectionId 副本id
-- type 副本类型
function CopySectionLayer:create(type, volumeId)
    
    local copySection = CopySectionLayer:new()
    copySection:init(type, volumeId)
    return copySection
    
end

function CopySectionLayer:init(type, volumeId)

    local csb = self:createResoueceNode("csb/CopySectionLayer.csb")--创建CSB
    local root = csb:getChildByName("root")
    root:setPosition(display.center)
    self.list = root:getChildByName("list")
    local model = root:getChildByName("item")
    self.list:setItemModel(model)
    local droppanel = root:getChildByName("droppanel")
    self.droppanel1 = droppanel:getChildByName("droppanel1")
    self.droppanel2 = droppanel:getChildByName("droppanel2")
    self.detail = root:getChildByName("detail")

    local closebtn = root:getChildByName("closebtn")
    local zhandoubtn = root:getChildByName("zhandoubtn")
    self.saodangbtn = root:getChildByName("saodangbtn")
    
    self.type = type            -- 卷类型  
    self.volumeId = volumeId    -- 卷id
    self.curSectionId = -1      -- 当前选中副本id
    self.curSelectItem = nil    -- 当前选中节点

    -- 显示卷名称
    local volumeData = nil
    if volumeId<25000 then
        volumeData = StaticData.CopyVolume
    else
        volumeData = StaticData.EliteCopyVolume
    end
    root:getChildByName("title"):setString(volumeData[volumeId].VolumeName)
    
    -- 刷新章节列表
    self:refreshList()

    local function onListEvent(sender, eventType)
        if eventType==1 then
            local index = self.list:getCurSelectedIndex()
            local item = self.list:getItem(index)
            if item.close==true then
                return
            end
            
            local value = item.value
            self:selectSection(value)
            self:selectItem(item)
        end
    end
    self.list:addEventListener(onListEvent)

    local function onButtonEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            if sender==closebtn then
                self:removeFromParent()
            elseif sender==zhandoubtn then
                if self.curSectionId~=-1 then
                    local copySections = nil
                    if self.curSectionId>=26001 then
                        copySections = StaticData.EliteCopySection
                    else
                        copySections = StaticData.CopySection
                    end
                    
                    if copySections[self.curSectionId].CostAction > UserData.BaseInfo.nAction then
                        print("体力不够")
                        return
                    end
                
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:switch(SceneManager.SceneName.SCENE_MYFIGHTLAYER)
                    --SceneManager.currentLayer:pve(self.curSectionId)
                end
            elseif sender==self.saodangbtn then
                local CleanupLayer = require("app.views.Pve.PveCleanupLayer")
                local layer = CleanupLayer:create(self.curSectionId)
                self:addChild(layer)
            end
        end
    end
    
    closebtn:addTouchEventListener(onButtonEvent)
    zhandoubtn:addTouchEventListener(onButtonEvent)
    self.saodangbtn:addTouchEventListener(onButtonEvent)
end

--进入
function CopySectionLayer:onEnter()

end

--退出
function CopySectionLayer:onExit()

end

-- 选择副本
function CopySectionLayer:selectSection(value)

    self.curSectionId = value.SectionId 

    local openSections = UserData.Pve:getOpenSections()
    if openSections[value.SectionId] then
        self.saodangbtn:setEnabled(true)
        self.saodangbtn:setColor(cc.c3b(255,255,255))
    else
        self.saodangbtn:setEnabled(false)
        self.saodangbtn:setColor(cc.c3b(128,128,128))
    end

    local prizeId = value.PrizeId
    local prize = StaticData.Prize[prizeId]
    if prize then
        self.droppanel2:getChildByName("gold"):setString(tostring(prize.Gold))
        self.droppanel2:getChildByName("exp"):setString(tostring(prize.Exp))
    end
    
    self.detail:setString(value.SectionStory)

    local stringEx = require("common.stringEx")
    local items = stringEx:split(prize.Items, "|")
    if items then
        for i=1, 3 do
            local cell = self.droppanel1:getChildByName("icon" .. tostring(i))
            if i<#items then
                cell:setVisible(true)
                local tmp = stringEx:split(items[i], "#")
                local itemId = tonumber(tmp[1])
                local item = StaticData.Item[itemId]
                if item then
                    cell:getChildByName("icon"):setTexture(item.ItemIcon)
                end
            else
                cell:setVisible(false)
            end
        end
    end
end

--刷新副本列表
function CopySectionLayer:refreshList()

    local sections = nil
    local Pve = UserData.Pve
    local openSections = Pve:getOpenSections()
    local maxOpenSectionId = 0
    if self.type==1 then
        sections = Pve:getSectionsByVolumeId(self.volumeId)
        maxOpenSectionId = openSections.maxSection
    else
        sections = Pve:getEliteSectionsByVolumeId(self.volumeId)
        maxOpenSectionId = openSections.maxEliteSection
    end
    
    if sections==nil then
        return
    end

    local i = 0
    local maxItem = nil
    local maxIndex = 0
    for key, value in ipairs(sections) do
        i = i + 1
        
        self.list:pushBackDefaultItem()
        local item = self.list:getItem(i-1)
        item.value = value
        item:setVisible(true)
        item.close = false
        item:getChildByName("name"):setString(value.SectionName)
        local star = 0
        if openSections[value.SectionId] then 
            star = openSections[value.SectionId]
        elseif self.type==1 and (key==1 or openSections[sections[key-1].SectionId]) then   -- 如果是普通副本 第一关默认开启
        elseif self.type==2 and (openSections[sections[key].SectionId-5000]) 
        and (key==1 or ((key~=1) and  openSections[sections[key-1].SectionId])) then    
        else
            self:setGray(item)
        end

        -- 显示星级
        for i=1, 3 do
            local tmpStar = item:getChildByName("star"..tostring(i))
            if i<=star then
                tmpStar:loadTexture("ui/pve/pve_check_starnormal.png")
            end
        end
        
        -- 显示体力
        item:getChildByName("action"):getChildByName("actionlabel"):setString(value.CostAction)
        
        if item.close==false then
            maxItem = item
            maxIndex = i
        end
    end
    
    if maxItem then
        self:selectItem(maxItem)
        self:selectSection(maxItem.value)
    end
    
    if i~=0 then
        self.list:forceDoLayout() 
        self.list:jumpToPercentHorizontal((maxIndex-1)/(i-1) * 100)
    end
--    self.list:doLayout()

end

function CopySectionLayer:selectItem(item)
    if self.curSelectItem then
        self.curSelectItem:getChildByName("select"):setVisible(false)
    end
    self.curSelectItem = item
    item:getChildByName("select"):setVisible(true)
end
-- chenxfhjfddf
function CopySectionLayer:setGray(item)
    
    if item==nil then
        return
    end
    
    local color = cc.c3b(128, 128, 128)
    
    item:getChildByName("iconBg"):setColor(color)
    item:getChildByName("icon"):setColor(color)
    item:getChildByName("action"):setColor(color)
    item:getChildByName("action"):getChildByName("actionlabel"):setColor(color)
    item:getChildByName("img"):setColor(color)
    item:getChildByName("name"):setColor(color)
    item:getChildByName("lock"):setVisible(true)
    item.close = true
end

return CopySectionLayer