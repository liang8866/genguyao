--local File = require("common.File")
-- File:getUserString( sKey, sDefaultValue )
-- File:setUserString( sKey, sValue )


-- string  roleStayPoint  roleStayPointID  nextOpenedTownID   openedWorldMap
-- int  roleStayWorldMapID
--保存数据
local DataManager = {}

function DataManager:getServerID()
    local ser = UserData.BaseInfo.userServAddrTable
    return ser.ServerId
end    
    
function DataManager:setIntegerForKey(sKey, iValue)
    local newKey = string.format("%d_A_%d_A_",UserData.BaseInfo.userID,self:getServerID()) .. tostring(sKey)  
    cc.UserDefault:getInstance():setIntegerForKey(newKey, iValue)
    cc.UserDefault:getInstance():flush()
end

function DataManager:getIntegerForKey(sKey, iDefaultValue)
    local newKey = string.format("%d_A_%d_A_",UserData.BaseInfo.userID,self:getServerID()) .. tostring(sKey)  
    local retInt = cc.UserDefault:getInstance():getIntegerForKey(newKey, iDefaultValue)
    return retInt
end


function DataManager:setStringForKey(sKey, sValue)
    local newKey = string.format("%d_A_%d_A_",UserData.BaseInfo.userID,self:getServerID()) .. tostring(sKey) 
    cc.UserDefault:getInstance():setStringForKey(newKey, sValue)
    cc.UserDefault:getInstance():flush()
end

function DataManager:getStringForKey(sKey, sDefaultValue)
    local newKey = string.format("%d_A_%d_A_",UserData.BaseInfo.userID,self:getServerID()) .. tostring(sKey) 
    local retString = cc.UserDefault:getInstance():getStringForKey(newKey, sDefaultValue)
    return retString
end



return DataManager