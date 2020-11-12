--公共模块，技能的Tips

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local wnd_list = {}

local SkillTipsNode = class("SkillTipsNode", function()
    return cc.Node:create()
end)

function SkillTipsNode:create()
    local node = SkillTipsNode.new()
    node:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            node:onEnter() 
        elseif eventType == "exit" then
            node:onExit() 
        end  
    end  
    node:registerScriptHandler(onEventHandler)
    return node
end

function SkillTipsNode:ctor()

end

function SkillTipsNode:onEnter()

end

function SkillTipsNode:onExit()

end

function SkillTipsNode:init()
    
    local node =  cc.CSLoader:createNode("csb/SkillTips.csb")
    self:addChild(node)

    local Panel_skillTip = node:getChildByName("Panel_skillTip")
    
    --self.Panel_skillTip:setPosition(100,500)

    
    wnd_list.Panel_skillTip = Panel_skillTip
    wnd_list.Sprite_Bg = Panel_skillTip:getChildByName("Sprite_Bg")
    wnd_list.Image_skill_icon = Panel_skillTip:getChildByName("Image_skill_icon")
    wnd_list.Image_1 = Panel_skillTip:getChildByName("Image_1")
    wnd_list.Image_1:setVisible(false)
    wnd_list.Text_skill_name = Panel_skillTip:getChildByName("Text_skill_name")
    wnd_list.Text_skill_level = Panel_skillTip:getChildByName("Text_skill_level")
    wnd_list.Text_skill_fight = Panel_skillTip:getChildByName("Text_skill_fight")
    wnd_list.Text_skill_effect_title = Panel_skillTip:getChildByName("Text_skill_effect_title")
    wnd_list.Text_skill_effect = Panel_skillTip:getChildByName("Text_skill_effect")
    wnd_list.Text_skill_desp_title = Panel_skillTip:getChildByName("Text_skill_desp_title")
    wnd_list.Text_skill_desp = Panel_skillTip:getChildByName("Text_skill_desp")
    
end

function SkillTipsNode:showSkillTips(skillID)
    
    cclog("showSkillTips skillID = " .. skillID)
    local skillInfo = UserData.Fibble:getSkillInfo(skillID)
    local skill_staticData = FightStaticData.flyingObjectSkill[skillID]
    if skillInfo == nil or skill_staticData == nil then
        return
    end
    
    wnd_list.Image_skill_icon:loadTexture(skill_staticData.icon)
    --wnd_list.Image_1 = Panel_skillTip:getChildByName("Image_1")
    --wnd_list.Image_1:setVisible(false)
    wnd_list.Text_skill_name:setString(skillInfo.name)
    wnd_list.Text_skill_level:setString("Lv." .. tostring(skillInfo.level))
    wnd_list.Text_skill_fight:setString("战力:" .. tostring(skillInfo.fight))
    wnd_list.Text_skill_desp:setString(skill_staticData.des)
    if string.len(skill_staticData.buffID) == 0 then
        wnd_list.Text_skill_effect:setString("")
        return
    end
    local buffIDList = string.split(skill_staticData.buffID,"|")
    local effectText = ""
    for i=1, table.nums(buffIDList) do
        local buffID = tonumber(buffIDList[i])
        local buffStaticInfo = FightStaticData.buffer[buffID]
        if buffStaticInfo ~= nil then
            effectText = effectText .. buffStaticInfo.name
        end
        if i < table.nums(buffIDList) then
            effectText = effectText .. ","
        end
    end
        
    wnd_list.Text_skill_effect:setString(effectText)
    
        --    wnd_list.Text_skill_effect_title = Panel_skillTip:getChildByName("Text_skill_effect_title")
        --    wnd_list.Text_skill_desp_title = Panel_skillTip:getChildByName("Text_skill_desp_title")
    

end

return SkillTipsNode