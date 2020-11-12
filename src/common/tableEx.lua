
local table = require("table")

local tableEx = {}

--[[
    获取table表的元素个数
param: tab为待查找的表格，bContainNil是否包含nil的值，默认不包含，不建议将table的元素设置为nil，删除使用remove
]]
function tableEx:getTableRealLength(tab,bContainNil)
    local iCount = 0
    for key ,value in pairs(tab) do
        if true == bContainNil then
            iCount = iCount + 1
        else
            if value ~= nil then
                iCount = iCount + 1
            end   
        end
    end
    return iCount
end


function tableEx:getTableKeyList(tab)
    local keyList = {}
    for key ,value in pairs(tab) do
        if key ~= nil and value ~= nil then
            table.insert(keyList,key)
        end   
    end
    return keyList
end


-- 仅支持数字和字符串做key值的查询
function tableEx:isTableHasKey(tab,keyPoint)
    for key ,value in pairs(tab) do
        if type(keyPoint) == "string" then
            return (tostring(key) == keyPoint)
        elseif type(keyPoint) == "number" then
            return (tonumber(key) == keyPoint)
        end
    end
    return false
end

function tableEx:isTableHasValue(tab,valuePoint)
    for key ,value in pairs(tab) do
        if type(valuePoint) == "string" then
            return (tostring(value) == valuePoint)
        elseif type(valuePoint) == "number" then
            return (tonumber(value) == valuePoint)
        end
    end
    return false
end


function tableEx:isTableHasValueWithKey(tab,valuePoint,keyPoint)
    if tab[keyPoint] ~= nil then
        if type(valuePoint) == "string" then
            return (tostring(tab[keyPoint]) == valuePoint)
        elseif type(valuePoint) == "number" then
            return (tonumber(tab[keyPoint]) == valuePoint)
        end
    end
    return false
end

return tableEx
