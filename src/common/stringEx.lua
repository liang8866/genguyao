--local string = require("string") 

local StaticData = require("static_data.StaticData")
local stringEx = {}
local warining1 = require "static_data.StaticData_warining1"

stringEx._htmlspecialchars_set = {}
 stringEx._htmlspecialchars_set["&"] = "&amp;"
stringEx._htmlspecialchars_set["\""] = "&quot;"
stringEx._htmlspecialchars_set["'"] = "&#039;"
stringEx._htmlspecialchars_set["<"] = "&lt;"
stringEx._htmlspecialchars_set[">"] = "&gt;"

stringEx._unuse_specialchars_set = {
 "!",
 "@",
 "#",
 "$",
 "~",
 "^",
 "&",
 "*",
 "(",
 ")",
 "-",
 "_",
 "+",
 "=",
 "[",
 "]",
 "\"",
 "|",
 "<",
 ">",
 "'",
 "\\",
 "`",
 ".",
 ",",
 "?",
 " ",
 "  "
}
--复制一个表格
function stringEx:copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTab(v)
        end
    end
    return tab
end
--[-----------------------------------------------------------------]
-- 判断是否含有特殊字符，有得话返回ture,没有的话返回false
function stringEx:isincludespecialchar(str)
    local flg = false
    local len = string.len(str)
    for i = 1 ,#stringEx._unuse_specialchars_set do
        for j = 1,len do
            local s = string.sub(str,j,j)
           -- cclog("%s,%s",s,)
            if s == stringEx._unuse_specialchars_set[i] then
                flg = true
                 break  
            end
        end
    end
    return flg   
end
-- 检测输入的名字是否符合规则 返回 0 表示正确的  1 表示字符串太短  返回 2表示 带有不合法字符 
function stringEx:checkInputIsCorrect(inputname)
    local indexFlag = 0
    if inputname == nil or inputname == "" or string.len(inputname) <= 6 then --字符串太短
        indexFlag = 1
    elseif stringEx:isincludespecialchar(inputname) == true then
        indexFlag = 2
    end
    return indexFlag
end
--print(utf8len("hi中国"))  ->   [LUA-print] 4
function stringEx:utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--把每一个字符分割成一个table保存起来
function stringEx:utf8lenTable(str)
    local len  = #str
    local left = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
      
    end
   -- local endTime = os.clock();
   -- local useTime = endTime - startTime;
   -- print("消耗时间：" .. useTime .. "s");
   -- local result = table.concat(t);
   -- print(result)
   return t
end

--根据文件名读取文本并分割成各个段落
function stringEx:mySplitStr(filename)
    local str =  stringEx:read_files(filename)
    local strTable = stringEx:split(str,"////")
    return strTable
end
--读取文本配置文件解析 1-9|2-11|3-8|4-8|5-8|6-9//1-9|2-11|3-8|4-8|5-8|6-9//1-9|2-11|3-8|4-8|5-8|6-9//1-9|2-11|3-8|4-8|5-8|6-9//1-9|2-11|3-8|4-8|5-8|6-9
function stringEx:myGetHeadTxt(filename)
    local str =  stringEx:read_files(filename)
    local juanTable = stringEx:split(str,"//")--先分割出来有多少卷
    local myTable = {}
    for i = 1,#juanTable do
        local zhangTable =  stringEx:split(juanTable[i],"|")--分割出对应的章
        myTable[i] = {}
        for j =1, #zhangTable do
            local t = stringEx:split(zhangTable[j],'-')
            myTable[i][j] = t[2]
            
--            print(i.."  "..j.."  "..t[2])
    	end
    end
    
    return myTable
end

--切割字符串
--debugEx:printDump(split("how==are==you!","==")) 
--[LUA-print] {
--[1] = "how",
--[2] = "are",
--[3] = "you!",
--}  
function stringEx:split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

--道具字符串解析
--"15001-1|15002-2"
--返回 tableItem = { [1] = {id = 15001 , count = 1} , [2] = {id = 15002 ,count = 2}}
function stringEx:itemResolveFromString(strContent,tableItem)
    local tbl1 = self:split(strContent,'|')
    for k,v in pairs(tbl1) do
        local tbl2 = self:split(v,'-')
        local item = {}
        item.id = tonumber(tbl2[1])
        item.count = tonumber(tbl2[2])
        item.probability = tonumber(tbl2[3])
        tableItem[#tableItem+1] = item
    end
end

--在那个种植园那里才会用到
function stringEx:mSplitString(nStr)
    local nArr = self:split(nStr,"|")
    local nMyStr = nil
    local nStart,nEnd = string.find(nStr,'%b||')
    if nStart then
        nMyStr = string.sub(nStr, nStart + 1, nEnd - 1)
    end
    return nArr,nMyStr  
end

--神农岛自然灾害字符分解
--所触发过的灾害(nil:表示还未触发过灾害，形式(1-0|2-0|3-1)前面的数字表示灾难的名称，后面的数字0表示已处理，1表示未处理（0：催熟，1：除草，2：浇水，3：捉虫，4：施肥）
function stringEx:DisasterResolveFromString(strContent)
	local nTable = {}
    if strContent ~= 'nil'  then
        local tbl1 = self:split(strContent,'|')
        local i = 1
        for k,v in pairs(tbl1) do
            local tbl2 = self:split(v,'-')
            local item = {} 
            item.idx = tonumber(tbl2[1])
            item.handle = tonumber(tbl2[2])
            nTable[i] = item
            i = i + 1
        end
	end
   return nTable
end


-- print stringEx:formatNumberThousands( 123456789 )  -->  123,456,789  
function stringEx:formatNumberThousands(num)
    local formatted = tostring(Sundry:tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--检测名字是否含有敏感词
function stringEx:checkIsWarning(str)

    local  isFlag = false
    -- 第一个敏感词库表
    for i = 1 ,#warining1 do
        if string.find(str,warining1[i]["name"]) ~= nil then
            isFlag = true
            return isFlag
        end
    end
    -- 第2个敏感词库表
    for i = 1 ,#StaticData.warining2 do
        if string.find(str,StaticData.warining2[i]["name"]) ~= nil then
            isFlag = true
            return isFlag
        end
    end
    return isFlag
end

--替换敏感字。。。
function stringEx:WariningStringGsub(str)
    -- 系统敏感词库表
    for i = 1 ,6575 do
        local isNil = string.find(str, warining1[i]["name"])
        if isNil then
            local replaceStr = string.rep("*", self:utf8len(warining1[i]["name"]))
            str = string.gsub(str,warining1[i]["name"],replaceStr)
        end
    end
    -- 自定义敏感词库表
    for i = 1 ,#StaticData.warining2 do
        local isNil = string.find(str, StaticData.warining2[i]["name"])
        if isNil then
            local replaceStr = string.rep("*", self:utf8len(StaticData.warining2[i]["name"]))
            str = string.gsub(str,StaticData.warining2[i]["name"],replaceStr)
        end
    end
      
    return str
end


--读取文本内容
function stringEx:read_files( fileName )
   -- local pathFile = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    return cc.FileUtils:getInstance():getStringFromFile(fileName)
--    local f = assert(io.open(pathFile,'r'))
--    local content = f:read("*all") 
--    f:close()
   
   --return content
end  

function stringEx:getFileStr(fileName)
    local strContent =  self:read_files(fileName)
	local strTable = self:split(strContent,'==')
    cclog("1 %s,%d",strTable[1],self:utf8len(strTable[1]))
    cclog("2 %s,%d",strTable[2],self:utf8len(strTable[2]))
    cclog("3 %s,%d",strTable[3],self:utf8len(strTable[3]))
    
    return strTable
end


--
--function stringEx:charLen(str)
--    local _, len = string.gsub(str, "[^\128-\193]", "")
--    return len
--end
--
--function stringEx:plainFormat(str)
--    return string.gsub(str, "(#%[%w+%])", "")
--end
--
--function stringEx:htmlspecialchars(input)
--    for k, v in pairs(stringEx._htmlspecialchars_set) do
--        input = string.gsub(input, k, v)
--    end
--    return input
--end
--            
--function stringEx:htmlspecialcharsDecode(input)
--    for k, v in pairs(stringEx._htmlspecialchars_set) do
--        input = string.gsub(input, v, k)
--    end
--    return input
--end

--function stringEx:nl2br(input)
--    return string.gsub(input, "\n", "<br />")
--end
--
--function stringEx:text2html(input)
--    input = string.gsub(input, "\t", "    ")
--    input = stringEx:htmlspecialchars(input)
--    input = string.gsub(input, " ", "&nbsp;")
--    input = stringEx:nl2br(input)
--    return input
--end
--

function stringEx:ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function stringEx:rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function stringEx:trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function stringEx:ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end
--
--local function urlencodeChar(c)
--    return "%" .. string.format("%02X", string.byte(c))
--end

--function stringEx:urlencode(str)
--    -- convert line endings
--    str = string.gsub(tostring(str), "\n", "\r\n")
--    -- escape all characters but alphanumeric, '.' and '-'
--    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
--    -- convert spaces to "+" symbols
--    return string.gsub(str, " ", "+")
--end
--
--function stringEx:urldecode(str)
--    str = string.gsub (str, "+", " ")
--    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(Sundry:tonum(h,16)) end)
--    str = string.gsub (str, "\r\n", "\n")
--    return str
--end



--任务描述以及聊天文字的字符串解析
--local multiStr1 = "[text=测试 fontColor=ff7f00测试 fontName=ArialRoundedMTBold fontSize=30 [/text][image=wsk1.png scale=1.3 [/image]"
function stringEx:splitClumpText(str)
    local tabTemp = {}
    local index = 0
    for w in string.gfind(str,'%[(.-)%]') do
        index = index + 1
        tabTemp[index]={}
        tabTemp[index]["textAll"] = w

        for k, v in string.gfind(w, "(%S+)=(%S+)" ) do
            tabTemp[index][k] = v
        end
    end
    if #tabTemp < 1 then
        index = index + 1
        tabTemp[index]={}
        tabTemp[index].text = str
    end 
    return tabTemp
end

--解析奖励的物品字符串  --如:711001-2|712001-3 , (带掉落几率)如:711001-2-10000|712001-3-8000
function stringEx:splitPrizeItemsStr(itemsStr)
    local tabTemp = {}
    local tabTemp2 = stringEx:split(itemsStr,"|") --先解析有多少种类型的NPC
    for i=1, #tabTemp2 do
        local tabTemp3 = stringEx:split(tabTemp2[i],"-")
        tabTemp[i] = tabTemp3
    end
    return tabTemp
end

--stringEx = stringEx        
return stringEx
