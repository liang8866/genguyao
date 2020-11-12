-- 副本系统

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")

local Pve = {
    
}

-- 解析剧情副本卷
-- 返回 volumeMin volumeCount
function Pve:getVolumes()

    if self.volumeCount==nil or self.volumeMin==nil then
        local count = 0
        local min = 99999999
        local copyVolumes = StaticData.CopyVolume
        for key, value in pairs(copyVolumes) do
            if key<min then
                min = key
            end    
            count = count + 1
        end
        self.volumeCount = count
        self.volumeMin = min
    end
    
    return self.volumeMin, self.volumeCount 
  
end

-- 解析精英副本卷 
-- 返回 eliteVolumeMin eliteVolumeCout
function Pve:getEliteVolumes()

    if self.eliteVolumeCount==nil or self.eliteVolumeMin==nil then
        local count = 0
        local min = 99999999
        local eliteVolumes = StaticData.EliteCopyVolume
        for key, value in pairs(eliteVolumes) do
            if key<min then
                min = key
            end
            count = count + 1
        end
        self.eliteVolumeCount = count
        self.eliteVolumeMin = min
        
    end
    return self.eliteVolumeMin, self.eliteVolumeCount

end

-- 剧情副本
-- 根据volumeId获取某卷副本列表
function Pve:getSectionsByVolumeId(volumeId)
    
    if self.sections==nil then
        local sections = {}
        self.sections = sections
    
        local min = 9999999
        local count = 0
        local copySection = StaticData.CopySection
        for key, value in pairs(copySection) do
            if key<min then
                min = key
            end
            count = count + 1
        end
        
        for i=min, min+count-1 do
            local value = copySection[i]
            if sections[value.CopyVolume] == nil then
                sections[value.CopyVolume] = {}
            end
            local tmp = sections[value.CopyVolume]
            tmp[#tmp+1] = value
        end
    end
    
    return self.sections[volumeId]
    
end

-- 精英副本
-- 根据volumeId 获取某精英卷副本列表
function Pve:getEliteSectionsByVolumeId(volumeId)

    if self.eliteSections==nil then
        local sections = {}
        self.eliteSections = sections

        local min = 9999999
        local count = 0
        local copySection = StaticData.EliteCopySection
        for key, value in pairs(copySection) do
            if key<min then
                min = key
            end
            count = count + 1
        end

        for i=min, min+count-1 do
            local value = copySection[i]
            if sections[value.CopyVolume] == nil then
                sections[value.CopyVolume] = {}
            end
            local tmp = sections[value.CopyVolume]
            tmp[#tmp+1] = value
        end
    end

    return self.eliteSections[volumeId]
end

-- 解析已开启关卡
function Pve:getOpenSections(str)
    
    if str==nil then
        str = ""
    end
    local stringEx = require("common.stringEx")
    
    if self.openSections==nil then
    
        if str=="" then
            self.openSections = {maxSection = 0, maxEliteSection = 0}
            return  self.openSections
        end
      
        local sections = {}
        self.openSections = sections
        local maxSection = 20000
        local maxEliteSection = 26000
        local strSections = stringEx:split(str, "|")
        
        for key, value in pairs(strSections) do
            local tmp = stringEx:split(value, ",")
            local id = tonumber(tmp[1])
            local star = tonumber(tmp[2])
            sections[id] = star
            
            if id>maxSection and id<26000 then
                maxSection = id
            end    
                
            if id>maxEliteSection then
                maxEliteSection = id
            end
          
        end
        
        sections.maxSection = maxSection
        sections.maxEliteSection = maxEliteSection
        
    end
    
    return self.openSections
    
end

-- 请求扫荡副本
function Pve:requestPveCleanUp(sectionId)
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_CLEANUP,"uii", baseInfo.userVeriCode, baseInfo.userID, sectionId)
end

NetMsgFuncs.OnCopyInfo = function()

    local wsLuaFunc = Net.cppFunc
    local sectionList = wsLuaFunc:readRecvString()
    print("副本列表" .. sectionList)
    
    UserData.Pve:getOpenSections(sectionList)

end

-- 扫荡结果
NetMsgFuncs.OnServerCleanUp = function()
    local wsLuaFunc = Net.cppFunc
    local result = wsLuaFunc:readRecvByte()
    local itemList = wsLuaFunc:readRecvString()
    
    local temp = {
        result = result,
        itemList = itemList
    }
    
    EventMgr:dispatch(EventType.OnServerCleanUp, temp)
    
end

return Pve