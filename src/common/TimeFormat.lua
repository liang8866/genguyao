local TimeFormat = {}

--获取当前时间与strTime的时间差，格式错误默认返回为0
function TimeFormat:getSecondsInter(strTime)
    if strTime == "" or strTime == nil then
    	return 0
    end
    local temp = {}
    temp.year   = string.sub(strTime,1,4)
    temp.month  = string.sub(strTime,6,7)
    temp.day    = string.sub(strTime,9,10)
    temp.hour   = string.sub(strTime,12,13)
    temp.min    = string.sub(strTime,15,16)
    temp.sec    = string.sub(strTime,18,19)

    if temp.year == '0000' or temp.year == "" or temp.month == "" or temp.day == "" or temp.hour == "" or temp.min == "" or temp.sec == "" then
        return 0
    end
    local ti = os.time(temp)
    local serverTime = UserData.BaseInfo:getSeverTime()
    local nowSec = os.time(serverTime)
    if nowSec==nil then
        return 0
    end
    return (nowSec - ti)
end

-- 根据字符串获取 年月日 时分秒
function TimeFormat:getYMDHMS(strTime)
    
    local year   = tonumber(string.sub(strTime,1,4))
    local month  = tonumber(string.sub(strTime,6,7))
    local day    = tonumber(string.sub(strTime,9,10))
    local hour   = tonumber(string.sub(strTime,12,13))
    local min    = tonumber(string.sub(strTime,15,16))
    local sec    = tonumber(string.sub(strTime,18,19))
    
    return year, month, day, hour, min, sec

end

-- 获取时分秒(传入总秒数,返回时，分，秒)
function TimeFormat:getHMS(s)
    local h = math.modf(s/60/60)
    s = s - h * 60 * 60
    local m = math.modf(s/60)
    s = s - m * 60 

    return h, m, s
end

--➢   例如:
--➢   上线时显示：正在游戏中……
--➢   下线时显示：离线**分钟（离线时间少于1个小时）
--            离线*小时（离线时间大于1个小时少于1天）
--            离线*天（离线时间大于1天，少于一个月）
--            离线*个月（离线时间大于一个月）

--获取当前时间间隔多少 分钟 、 小时 、 天 、 月 、年
function TimeFormat:getSecondsInterFromMark(strTime)
    local min   = 60
    local hour  = 3600     -- 60 * 60
    local day   = 86400    --24*60*60 一天的秒数
    local month = 2592000  --30 * day 一个月的秒数
    local year =  31104000  --12 * month 一年的秒数
    local secondes = self:getSecondsInter(strTime)
    if secondes >= year then
        local num = secondes/year
        return 5,secondes/month,string.format("%d年",num)
    elseif secondes >= month then
        local num = secondes/month
        return 4,secondes/month,string.format("%d月",num)
    elseif secondes >= day then
        local num = secondes/day
        return 3,secondes/month,string.format("%d天",num)
    elseif secondes >= hour then 
        local num = secondes/hour
        return 2,secondes/month,string.format("%d小时",num) 
    elseif secondes > 0 then
        local num = secondes/min
        if num < 1 then
        	num = 1
        end
        return 1,secondes/month,string.format("%d分钟",num)
    else
        return 0,0,"1分钟"
    end
end

--判断时间是不是当天
function TimeFormat:isToday(srcTime)
    local time = srcTime
    if time == nil or time == "" then
    	return false
    end
    if type(time) == "number"  then
        --秒
        time = os.date("*t", time)
    elseif type(time) == "string" then
        --"2015/01/14 14:08:44"
        local strTime = time
        time = {}
        time.year   = tonumber(string.sub(strTime,1,4))
        time.month  = tonumber(string.sub(strTime,6,7))
        time.day    = tonumber(string.sub(strTime,9,10))
        time.hour   = tonumber(string.sub(strTime,12,13))
        time.min    = tonumber(string.sub(strTime,15,16))
        time.sec    = tonumber(string.sub(strTime,18,19))
    elseif type(time) ~= "table" then
        return false 	
    end
    local serverTime = UserData.BaseInfo:getSeverTime()
    if serverTime.year and time.year and serverTime.year == time.year and serverTime.month and time.month and serverTime.month == time.month and serverTime.day and time.day and serverTime.day == time.day then
        return true
    end
    
    return false
end

return TimeFormat