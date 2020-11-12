
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local YesCancelLayer = require("app/views/public/YesCancelLayer")

-- 以下是网线接收处理函数区 
local netMsgId = require "net.NetMsgId"
local netMsgFunc = require "net.NetMsgFuncs"
local lNet = require "net.Net"

local LevelUpLayer = require("app.views.public.LevelUpLayer")


local BaseInfo = {
    userAccount = nil,                               -- 账号
    userServAddrTable = "",                          -- 服务器地址信息，端口，等     
    userID = nil,                                    -- 角色ID  
    userName = "",                                   -- 角色名字
    userJobID = 0,                                   -- 职业ID， 0,无职业,1~4分别天王殿,归云庄,万魔窟,普陀寺
    userSex = 1,                                     -- 用户性别 0,人妖,1,男，2女
    userImageID = 11,                                -- 用户图像
    userVeriCode = 1,                                -- 用户验证码
    userLevel = 0,                                   -- 用户等级
    userExp = 0,                                     -- 用户经验
    userVip = 0,                                     -- 用户VIP
    userGold = 0,                                    -- 用户金钱
    userIngot = 0,                                   -- 用户元宝
    nReputation = 0,                                 -- 声望
    nWorldChatNum = 0,                               -- 世界聊天次数
    nAction = 0,                                     -- 体力数量
    nBuyActionNum = 0,                               -- 当日购买体力次数
    nBuyMoneyNum = 0,                                -- 当日购买游戏币次数
    sGetActionBag = '',                              -- 最新获取体力包时间
    sRecoverAction = '',                             -- 最新恢复体力时间
    bySkillPoints = 0,                               -- 技能点
    sRecoverSkillPoints = "",                        -- 最新技能点回复时间
    nFibbleId = 101001,                              -- 当前飞宝ID
    nConsumeAction = 0,                              -- 当日的体力消耗
    year = 0,                                        -- 年
    month = 0,                                       -- 月
    day = 0,                                         -- 日
    h = 0,                                           -- 时
    m = 0,                                           -- 分
    s = 0,                                           -- 秒  
    nVipExp = 0,                                     -- vip经验
    nVipBag = 0,                                     -- vip礼包 
    
    
    -- 战斗要传入的参数
    myFightTaskId = 0,                               -- 如果当前的战斗是任务的，记录任务ID，否则填0        
    NPCId = 0,                                       -- 战斗NPCId
    enemyFlyID = 101001,                             -- 敌方的飞宝ID
    myGodTable = {[1] = {411001,1},[2] = {411001,1},[3] = {411001,1},[4] = {411001,1},[5] = {411001,1}},
    enemyGodTable = {[1] = {411001,1},[2] = {411001,1},[3] = {411001,1},[4] = {411001,1},[5] = {411001,1}},
   
   
   
}

BaseInfo.EnterGameMsgList = {}

--获取一个时间表
function BaseInfo:getSeverTime()
    local temp = {}
    temp.year   = BaseInfo.year
    temp.month  = BaseInfo.month
    temp.day    = BaseInfo.day
    temp.hour   = BaseInfo.h
    temp.min    = BaseInfo.m
    temp.sec    = BaseInfo.s
    return temp
end 

-- 客户端请求登陆
function BaseInfo:sendServerLogin(account,platFormCode)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_LOGIN,"uss",10086, account, platFormCode)
end

-- 服务端返回登陆
netMsgFunc.OnLogin = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() --登陆结果 0:成功  1:平台错误  2:未创建角色？
   
    if result == 0 then--成功
        BaseInfo.userID = wsLuaFunc:readRecvInt()
        BaseInfo.userName = wsLuaFunc:readRecvString()
        -- 请求验证码，，验证码之后请求基本信息，基本信息成功后自动转主界面
        BaseInfo:sendServerVerifyCode()
    elseif result == 1 then -- 1？
        print(string.format("result = %d, 平台错误", result))
        --暂时不会做处理
    elseif result == 2 then --2未创建角色，切换到选择角色
        local SceneManager = require("app.views.SceneManager")
        SceneManager:switch(SceneManager.SceneName.SCENE_SELECTROLE)
    end
   
end

-- 客户端请求服务器时间
function BaseInfo:sendRequestServerTime()
   lNet:sendMsgToSvr(netMsgId.CL_SERVER_GET_TIME,"")
end
-- 矫正服务器时间
netMsgFunc.OnSeverTime = function ()

    local wsLuaFunc = lNet.cppFunc
    local strTime = wsLuaFunc:readRecvString()
   
    local y, month, d, h, m, s = require("common/TimeFormat.lua"):getYMDHMS(strTime)
    
    BaseInfo.year = y
    BaseInfo.month = month  
    BaseInfo.day = d    
    BaseInfo.h = h   
    BaseInfo.m = m
    BaseInfo.s = s
    
    BaseInfo:updateServerTime()
    
end

-- 刷新服务器时间
local scheduleUpdate = nil
function BaseInfo:updateServerTime()

    local isRefreshFlag = false
  
    
    if scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
    end
    local function myupdate(dt)
        BaseInfo.s = BaseInfo.s + dt
        if BaseInfo.s > 59 then --判断秒
            BaseInfo.m = BaseInfo.m + 1
            BaseInfo.s = 0
        end

        if BaseInfo.m > 59 then --判断分
            BaseInfo.h = BaseInfo.h + 1 
            BaseInfo.m = 0

        end
        if BaseInfo.h > 23 then --判断时
            BaseInfo.h = 0
        end

        if BaseInfo.s > 10 and BaseInfo.s < 11 then
            isRefreshFlag = true
        end
--        print("BaseInfo.s =%d",BaseInfo.s)
        if BaseInfo.m % 5 == 0 and BaseInfo.s  <0.12 and isRefreshFlag == true  then  -- 每隔5分钟校验一次
            isRefreshFlag = false
            UserData.BaseInfo:sendRequestServerTime()    
        end
        
        --如果有消息，则发送消息队列
        if table.nums(BaseInfo.EnterGameMsgList) > 0 then
            BaseInfo:sendEnterMsg()
        end
    end
    scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(myupdate, 0 ,false)
    
end


-- 客户端请求注册
function BaseInfo:sendServerRegist(userName,sex,imageID)
    cclog("userName =%s,sex=%d,imageID=%d",userName,sex,imageID)
    print(BaseInfo.userAccount)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_REGIST,"ussbi",10086, BaseInfo.userAccount,userName,sex,imageID)
end

-- 服务端返回注册
netMsgFunc.OnRegist = function()

    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() --注册结果  1：注册之前未请求登入,2:角色名字被占用，3职业不存在, 0成功
    print("服务端返回注册 result"..result)
    
    if result == 0 then                          -- 登陆成功
        BaseInfo.userID =  wsLuaFunc:readRecvInt()
        BaseInfo.userName =  wsLuaFunc:readRecvString()
        cclog(" 注册返回 BaseInfo.userID  = %d, BaseInfo.userName=%s",BaseInfo.userID,BaseInfo.userName)
        -- 请求验证码验证码之后请求基本信息，基本信息成功后自动转主界面
        BaseInfo:sendServerVerifyCode()
    else
        EventMgr:dispatch(EventType.onServerRegist,result) --告诉玩家那里出错了
    end
end

-- 客户端请求验证码
function BaseInfo:sendServerVerifyCode()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_VERIFYCODE,"ui", 10086,BaseInfo.userID)
end

-- 服务端返回验证码
netMsgFunc.OnVerifyCode = function()
    local wsLuaFunc = lNet.cppFunc
    BaseInfo.userVeriCode = wsLuaFunc:readRecvUint32()
    cclog("返回验证码 BaseInfo.userVeriCode = %d",BaseInfo.userVeriCode)
    
    -- 请求服务器时间 
    BaseInfo:sendRequestServerTime()
    
    --初始化进入游戏的消息队列
    BaseInfo.msgIndex = 1
    BaseInfo.EnterGameMsgList = {
        [1] = {name = UserData.BaseInfo.sendServerBaseInfo,waitReturn = false,result = false},
        [2] = {name = UserData.Bag.sendBagItemList,waitReturn = false,result = false},
        [3] = {name = UserData.Godwill.sendGetGodwillList,waitReturn = false,result = false},
        [4] = {name = UserData.Fibble.sendGetFibbleInfo,waitReturn = false,result = false},
        [5] = {name = UserData.Fibble.sendFibbleSkillInfo,waitReturn = false,result = false},
        [6] = {name = UserData.Task.sendGetTaskInfo,waitReturn = false,result = false},
    }
    
    
end

--进入游戏发送消息队列
function BaseInfo:sendEnterMsg()
    
    local curMsg = BaseInfo.EnterGameMsgList[BaseInfo.msgIndex]
    if (curMsg ~= nil ) then
        if curMsg.name ~= nil then
            if curMsg.waitReturn == false then
                curMsg.name()
                curMsg.waitReturn = true
                curMsg.result = false
            end
            if curMsg.result == true then
                BaseInfo.msgIndex = BaseInfo.msgIndex + 1
                curMsg = BaseInfo.EnterGameMsgList[BaseInfo.msgIndex]
                if curMsg == nil then
                    BaseInfo.EnterGameMsgList = {}
                    UserData.Task:enterGame()  --消息发送完毕，进入游戏
                end
            end
        else 
            -- 此处不应该进入,但为防止死循环，加入进入下一个消息
            BaseInfo.msgIndex = BaseInfo.msgIndex + 1
            curMsg = BaseInfo.EnterGameMsgList[BaseInfo.msgIndex]
            if curMsg == nil then
                BaseInfo.EnterGameMsgList = {}
                UserData.Task:enterGame()
            end
        end
    end
    
end

-- 客户端请求玩家基本信息
function BaseInfo:sendServerBaseInfo()
    
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_BASEINFO,"ui", BaseInfo.userVeriCode,BaseInfo.userID)
    cclog("角色id BaseInfo.userID = %d",BaseInfo.userID)

end
-- 服务端返回玩家基本信息
netMsgFunc.OnBaseInfo = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte()
    if result == 0 then
        BaseInfo.userID = wsLuaFunc:readRecvInt() --用户ID
        BaseInfo.userName = wsLuaFunc:readRecvString()--角色名字， 
        BaseInfo.userSex = wsLuaFunc:readRecvByte() --0,人妖,1,男，2女
        BaseInfo.userImageID =  wsLuaFunc:readRecvInt()--用户图像
        BaseInfo.userLevel = wsLuaFunc:readRecvInt()--用户等级
        BaseInfo.userExp = wsLuaFunc:readRecvDouble() --用户经验
        BaseInfo.userVip = wsLuaFunc:readRecvByte()--用户VIP
        BaseInfo.userGold = wsLuaFunc:readRecvDouble() --用户金钱
        BaseInfo.userIngot = wsLuaFunc:readRecvInt()--用户元宝
        BaseInfo.nAction = wsLuaFunc:readRecvInt() -- 体力数量
        BaseInfo.nReputation = wsLuaFunc:readRecvInt() -- 声望
        BaseInfo.nBuyActionNum = wsLuaFunc:readRecvByte() -- 当日购买体力数
        BaseInfo.sGetActionBag = wsLuaFunc:readRecvString() -- 最新获取体力包时间
        BaseInfo.sRecoverAction = wsLuaFunc:readRecvString() -- 最新恢复体力时间
        BaseInfo.bySkillPoints = wsLuaFunc:readRecvByte()           -- 技能点
        BaseInfo.sRecoverSkillPoints =  wsLuaFunc:readRecvString() -- 最新技能点回复时间
        BaseInfo.nFibbleId = wsLuaFunc:readRecvInt()  --选择的飞宝
        --dump(BaseInfo)
        print(string.format("BaseInfo.sRecoverAction is %s", BaseInfo.sRecoverAction))
        
        print(string.format("BaseInfo.bySkillPoints is %d", BaseInfo.bySkillPoints))
        print(string.format("BaseInfo.sRecoverSkillPoints is %s", BaseInfo.sRecoverSkillPoints))
        
        if BaseInfo.nFibbleId == 0 then
        	BaseInfo.nFibbleId = 101001
        end 


        
        UserData.BaseInfo.EnterGameMsgList[1].result = true   
        
        --[[
        -- 请求背包列表
        UserData.Bag:sendBagItemList()

		-- 请求神将列表
		UserData.Godwill:sendGetGodwillList()
		
		--请求飞宝及飞宝技能信息
		UserData.Fibble:sendGetFibbleInfo() 
       
        --请求邮件列表
        --lNet:sendMsgToSvr(netMsgId.CL_SERVER_EMAIL_LIST, "ui", BaseInfo.userVeriCode, BaseInfo.userID)
       
       
        -- 获取基本信息成功后 发送请求任务 (必须放最后面，这里切换场景)
        UserData.Task:sendGetTaskInfo()
        ]]
    end
end

-- 玩家基本信息改变
netMsgFunc.OnPropertyChange = function()

    local wsLuaFunc = lNet.cppFunc
    local byType = wsLuaFunc:readRecvByte()

    if byType==3  then  BaseInfo.userImageID =  wsLuaFunc:readRecvInt()                 -- 用户图像
    elseif byType==4  then  BaseInfo.userLevel = wsLuaFunc:readRecvInt()                -- 用户等级
    elseif byType==5  then  BaseInfo.userExp = wsLuaFunc:readRecvDouble()               -- 用户经验
    elseif byType==6  then  BaseInfo.userVip = wsLuaFunc:readRecvByte()                 -- 用户VIP
    elseif byType==7  then  BaseInfo.userGold = wsLuaFunc:readRecvDouble()              -- 用户金钱
    elseif byType==8  then  BaseInfo.userIngot = wsLuaFunc:readRecvInt()                -- 用户元宝  
    elseif byType==9  then  BaseInfo.nAction = wsLuaFunc:readRecvInt()                  -- 体力数量
    elseif byType==10 then  BaseInfo.nBuyActionNum = wsLuaFunc:readRecvByte()           -- 当天体力购买次数
    elseif byType==11 then  BaseInfo.bySkillPoints = wsLuaFunc:readRecvByte()  end      -- 最新技能点数
    
    EventMgr:dispatch(EventType.OnPropertyChange, byType)
    
    if byType == 4 and UserData.Task.acceptedTaskList[1][1] == "nil" then -- 用户等级
        
        local ManagerTask = require("app.views.Task.ManagerTask")
        local nextMainTaskId = ManagerTask:getNextCanAcceptedMainTask()
        if nextMainTaskId > 0 then
            UserData.Task:sendAcceptTask(nextMainTaskId,1)  
        end
    end
    if byType == 4 then
--        local scene = cc.Director:getInstance():getRunningScene()
        local layer = LevelUpLayer:create()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:addToGameScene(layer, 10)
    end
    if byType == 11 then
        EventMgr:dispatch(EventType.OnSkillPrompt)
    end
end

-- 客户端请求购买体力
function BaseInfo:sendBuyAction()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_BUY_ACTION, "ui", BaseInfo.userVeriCode, BaseInfo.userID)
end

-- 服务端返回购买体力的结果
netMsgFunc.OnGetAction = function()
    local wsLuaFunc = lNet.cppFunc
    
    BaseInfo.nBuyActionNum = wsLuaFunc:readRecvByte()
    print(string.format("BaseInfo.nBuyActionNum is %d", BaseInfo.nBuyActionNum))
    local result = wsLuaFunc:readRecvByte() -- 购买结果 0：成功，1：次数上限，2：元宝不足
    if result == 0 then
        print("体力购买成功")
    elseif result == 1 then
        print("体力购买次数已达上限")
    elseif result == 2 then
        print("元宝不足")
    end
    EventMgr:dispatch(EventType.OnBuyAction, result)
end

-- 客户端请求获取体力恢复包
function BaseInfo:sendGetActionBag()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_GET_ACTION_BAG, "ui", BaseInfo.userVeriCode, BaseInfo.userID)
end

-- 服务端返回领取体力包的结果
netMsgFunc.OnGetActionBag = function()

    local wsLuaFunc = lNet.cppFunc              
    
    BaseInfo.sGetActionBag = wsLuaFunc:readRecvString()     -- 最新获取体力的时间
    local result = wsLuaFunc:readRecvByte()                 -- 0:成功，1:已经领取过
    if result == 0 then
        print("体力包领取成功")
    elseif result == 1 then
        print("未到领取时间")
    elseif result == 2 then
        print("体力包已领取过")
    end

    EventMgr:dispatch(EventType.OnGetActionBag, result)
    
end

-- 客户端请求随机名字
function BaseInfo:sendServerRandomName(sex)

    BaseInfo.userSex = sex
    cclog("请求随机名字：sex = %d",sex)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_RANDOMNICKNAME,"ub", 10086,sex)--0,人妖,1,男，2女

end

-- 服务端返回玩家基本信息
netMsgFunc.OnRandomNickName = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() -- 0成功，否则失败
    if result == 0 then
        BaseInfo.userName =  wsLuaFunc:readRecvString()
    end
   
    EventMgr:dispatch(EventType.onRandomName,result) --分发随机名字
end

-- 客户端请求下线
function BaseInfo:sendServerOffLine()
    
    lNet:sendMsgToSvrDirect(netMsgId.CL_SERVER_OFF_LINE,"ui", BaseInfo.userVeriCode,BaseInfo.userID)
    
end

-- 服务端返回请求下线
netMsgFunc.OnOFFLine = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() -- 0成功，否则失败
end

-- 请求消耗体力
function  BaseInfo:setCostAction(costAction)
    cclog("请求消耗体力:costAction=%d",costAction)
    lNet:sendMsgToSvrDirect(netMsgId.CL_SERVER_COST_ACTION,"uii", BaseInfo.userVeriCode,BaseInfo.userID,costAction)
end

-- 服务端返回消耗体力
netMsgFunc.OnCostAction = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() -- 0:成功,1:体力不足、
    print("消耗体力结果： result:",result)
end

-- 通知账号在别处登录
netMsgFunc.onNoticeOffline = function()
    local wsLuaFunc = lNet.cppFunc
    local result = wsLuaFunc:readRecvByte() -- 1、账号异地登录   2、系统维修
    local onYes = function()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:switch(SceneManager.SceneName.SCENE_LOGIN)
    end
    if result == 1 then
        YesCancelLayer:create("您的账号在异地登录", onYes, onYes)
    elseif result == 2 then
        YesCancelLayer:create("系统维护中", onYes, onYes)
    end
    YesCancelLayer:setButtonTitle("重连","登出") 
end

return BaseInfo