local StaticData = require("static_data.StaticData")
local TimeFormat = require("common.TimeFormat")

local StrengthTips = class("StrengthTips", require("app.views.View"))

function acTionUpperBound(level)    --计算体力上限
    local acTion = UserData.BaseInfo.userLevel * 2 + StaticData.SystemParam['BaseAction'].IntValue
    return acTion
end

function StrengthTips:onCreate()

    self.csb = self:createResoueceNode("csb/strength_tips.csb")

    self.text  = self.csb:getChildByName("text")      -- 当前时间
    self.bg = self.csb:getChildByName("bg")     -- 购买次数
    
    -- 自上次领取体力后经过的秒数
    local duration = TimeFormat:getSecondsInter(UserData.BaseInfo.sRecoverAction)

    -- 恢复全部体力所需要的秒数
    self.allRemain = (acTionUpperBound(UserData.BaseInfo.userLevel) - UserData.BaseInfo.nAction) * 60 * 6 - duration

    -- 恢复下一点体力所需要的秒数
    self.nextRemain = 6*60 - duration
    if self.nextRemain<=0 or self.nextRemain>6*60 then  
        self.nextRemain = 6*60
    end
    
end

function StrengthTips:onEnter()

    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        self:updateUI(dt)
    end, 0 ,false)
    
end


function StrengthTips:onExit()

    if self.scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end

end

function StrengthTips:updateUI(dt)
    
    local baseInfo = UserData.BaseInfo
    self.allRemain = self.allRemain - dt
    self.nextRemain = self.nextRemain - dt
    if self.nextRemain<0 then
        self.nextRemain = self.allRemain % 360
    end
    
--    local vip = StaticData.vip[baseInfo.userVip]
    local nDayBuyNums = 5  -- 今日可购买的总次数；
    local size = self.bg:getContentSize()
    if self.allRemain <= 0 or baseInfo.nAction >= acTionUpperBound(baseInfo.userLevel) then
        self.text:setString(string.format("已购买体力次数：%d/%d\n体力已回满",
            baseInfo.nBuyActionNum, nDayBuyNums))
            self.bg:setContentSize(cc.size(size.width, 63))
    else
        local nh, nm, ns = self:getHMS(math.floor(self.nextRemain))
        local ah, am, as = self:getHMS(math.floor(self.allRemain))
    
        self.text:setString(string.format("已购买体力次数：%d/%d\n下点体力恢复：%02d:%02d:%02d\n恢复全部体力：%02d:%02d:%02d\n恢复时间间隔：6分钟",
            baseInfo.nBuyActionNum, nDayBuyNums,
            nh, nm, ns,
            ah, am, as))
            self.bg:setContentSize(cc.size(size.width, 115))
    end
    
end

-- 获取时分秒
function StrengthTips:getHMS(s)

    local h = math.modf(s/60/60)
    s = s - h * 60 * 60
    local m = math.modf(s/60)
    s = s - m * 60 
    
    return h, m, s
    
end


return StrengthTips