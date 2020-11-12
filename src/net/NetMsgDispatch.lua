
local msgId = require "net.NetMsgId"
local msgFuncs = require "net.NetMsgFuncs"
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMsgDispatch = {
 
    --登陆系统
    [msgId.SERVER_CL_LOGIN] = msgFuncs.OnLogin,
    [msgId.SERVER_CL_REGIST] = msgFuncs.OnRegist,
    [msgId.SERVER_CL_BASEINFO] = msgFuncs.OnBaseInfo,
    [msgId.SERVER_CL_VERIFYCODE] = msgFuncs.OnVerifyCode,
    [msgId.SERVER_CL_RANDOMNICKNAME] = msgFuncs.OnRandomNickName,
    [msgId.SERVER_CL_OFF_LINE] = msgFuncs.OnOFFLine,
   
    [msgId.SERVER_CL_GET_TIME] = msgFuncs.OnSeverTime,                               -- 服务端发送回时间

    --聊天系统
    [msgId.SERVER_CL_WORLDCHAT] = msgFuncs.OnWorldChat,
    [msgId.SERVER_NOTICE_WORLDCHAT] = msgFuncs.OnNoticeWorldChat, 
    [msgId.SERVER_CL_PRIVATECHAT] = msgFuncs.OnPrivateChat, 
 
    -- 体力系统
    [msgId.SERVER_CL_BUY_ACTION] = msgFuncs.OnGetAction,
    [msgId.SERVER_CL_GET_ACTION_BAG] = msgFuncs.OnGetActionBag,
    
    [msgId.SERVER_CL_NOTICE_PROPERTY_CHANGE] = msgFuncs.OnPropertyChange,             -- 服务器通知玩家属性发生改变
        
      --好友模块 
    [msgId.SERVER_CL_FRIEND_LIST] = msgFuncs.OnFriendList,                            -- 服务端向客户端返回好友列表以及好友申请列表
    [msgId.SERVER_CL_COMMEND_LIST] = msgFuncs.OnCommendList ,                         -- 服务端向客户端返回推荐好友列表
    [msgId.SERVER_CL_INQUIRY_PLAYER_INFO] = msgFuncs.OnInquiryPlayerInfo,             -- 服务端向客户端返回查询的玩家信息
    [msgId.SERVER_CL_ADD_FRIEND] = msgFuncs.OnAddFriend ,                             -- 服务器返回添加好友结果
    [msgId.SERVER_CL_NOTICE_ADD_FRIEND] = msgFuncs.OnNoticeAddFriend ,                -- 服务器通知玩家，某玩家的申请好友的消息
    [msgId.SERVER_CL_NOTICE_REFUSE_ADD_FRIEND] = msgFuncs.OnRefuseAddFriend ,         -- 玩家好友申请拒绝回复  
    [msgId.SERVER_CL_NOTICE_AGREE_ADD_FRIEND] = msgFuncs.OnAgreeAddFriend ,           -- 把玩家添加到好友列表，
    [msgId.SERVER_CL_DEL_FRIEND] = msgFuncs.OnDeleteFriend ,                          -- 服务器向客户端发送删除好友信息(发2次，发给对方)
    [msgId.SERVER_CL_NOTICE_UPDATE_FRIEND_ONLINE] = msgFuncs.OnUpdateFriendOnline ,   -- 玩家登陆或者离线，服务器主动发给自己的好友列表
    [msgId.SERVER_CL_GIVE_FRIEND_ACTION] = msgFuncs.OnGiveFriendAction ,              -- 服务端返回体力赠送结果
    [msgId.SERVER_CL_NOTICE_GET_FRIEND_ACTION] = msgFuncs.OnNoticeGetFriendAcion ,    -- 收到好友赠送体力通知的消息
    [msgId.SERVER_CL_GET_FRIEND_ACTION] = msgFuncs.OnGetFriendAcion ,                 -- 服务端向客户端发送接收好友赠送的体力结果
    -- 补充黑名单的
    [msgId.SERVER_CL_BLACKLIST] = msgFuncs.OnBlackList ,                              -- 服务端向客户端返回黑名单列表
    [msgId.SERVER_CL_PULL_BLACK] = msgFuncs.OnPullBlack ,                             -- 服务端向客户端返回玩家拉黑请求
    [msgId.SERVER_CL_NOT_PULL_BLACK] = msgFuncs.OnNotPullBlack ,                      -- 服务端向客户端返回与玩家解除黑名单关系请求
    [msgId.SERVER_CL_NOTICE_BLACKLIST_CHANGE] = msgFuncs.OnNoticeBlackListChange ,    -- 服务端向客户端通知黑名单列表变化

    -- 背包消息
    [msgId.SERVER_CL_NOTEICE_ITEM_CHANGE] = msgFuncs.OnBagItemChange ,                -- 服务端通知玩家物品数量发生改变 
    [msgId.SERVER_CL_BAG_INFO] = msgFuncs.OnBagItemList ,                             -- 服务端向客户端返回背包信息
    
    -- 战斗消息
    [msgId.SERVER_CL_FIGHT_BACK] = msgFuncs.OnBattleInfo,                             -- 战斗日志返回
    [msgId.SERVER_CL_COPY_BATTLE_BACK] = msgFuncs.OnPveBattleResult,                  -- 副本战斗结果
    [msgId.SERVER_CL_COPY_BATTLE_BACK] = msgFuncs.OnPveBattleResult,                  -- 副本战斗结果
    [msgId.SERVER_CL_COPYINFO_BACK] = msgFuncs.OnCopyInfo,                            -- 副本列表信息
    [msgId.SERVER_CL_REQUEST_CLEANUP_BACK] = msgFuncs.OnServerCleanUp,                -- 扫荡副本
    [msgId.CL_SERVER_FIGHT_PRIZE] = msgFuncs.OnFightPrize,                            -- 客户端请求打怪奖励

    -- 竞技场消息
    [msgId.SERVER_CL_ARENA_RANK_INFO_BACK] = msgFuncs.OnAreanRankList,                -- 竞技场排名
    [msgId.SERVER_CL_ARENA_OPPONENT_BACK] = msgFuncs.OnAreanOpponentList,             -- 竞技场对手列表
    [msgId.SERVER_CL_ARENA_RIVAL_BACK] = msgFuncs.OnAreanRivalBack,                   -- 竞技场战斗结果
    [msgId.SERVER_CL_ARENA_SELF_INFO_BACK] = msgFuncs.OnAreanSelfInfoBack,            -- 竞技场个人信息
    [msgId.SERVER_CL_ARENA_RECORD_BACK] = msgFuncs.OnAreanRecord,                     -- 竞技场个人信息
    [msgId.SERVER_CL_ARENA_BUY_BACK] = msgFuncs.OnAreanBuyBack,                       -- 竞技场购买结果
    
    -- 邮件
    [msgId.SERVER_CL_EMAIL_LIST] = msgFuncs.OnMailList ,                             -- 服务端向客户端返回邮件列表
    [msgId.SERVER_CL_READ_EMAIL] = msgFuncs.OnReadMail ,                             -- 服务端向客户端返回邮件读取请求
    [msgId.SERVER_CL_PICK_ATTACH] = msgFuncs.OnPickAttack ,                          -- 服务端向客户端返回提取邮件附件
    [msgId.SERVER_CL_DEL_EMAIL] = msgFuncs.OnDelMail ,                               -- 服务端向客户端返回删除邮件
    [msgId.SERVER_CL_NOTICE_ADD_EMAIL] = msgFuncs.OnNoticeAddMail ,                  -- 服务端通知客户端多了一封邮件
    [msgId.SERVER_CL_NOTICE_DEL_EMAIL] = msgFuncs.OnNoticeDelMail ,                  -- 服务端通知客户端删除了一封邮件
    
    -- 押镖系统
    [msgId.SERVER_CL_TRANSPORT_LIST] = msgFuncs.OnTransportList,                     -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
    [msgId.SERVER_CL_REFRESH_TYPE] = msgFuncs.OnRefreshType,                         -- 服务返回镖车刷新请求
    [msgId.SERVER_CL_START_TRANSPORT] = msgFuncs.OnStartTransport,                   -- 服务返回开始押镖请求
    [msgId.SERVER_CL_END_TRANSPORT] = msgFuncs.OnEndTransport,                       -- 服务返回结束押镖请求
    
    --商城，VIP
    [msgId.SERVER_CL_BUY_ITEM] = msgFuncs.OnBuyItem,                                 -- 服务端向客户端返回物品购买请求
    [msgId.SERVER_CL_NOTICE_VIP_EXP_CHANGE] = msgFuncs.OnNoticeVipExpChange,         -- 服务端向客户端通知VIP充值经验发生改变
    [msgId.SERVER_CL_GET_VIP_BAG] = msgFuncs.OnGetVipBag,                            -- 服务端向客户端返回获取VIP礼包请求
    
    -- 任务模块
    [msgId.SERVER_CL_TASK_INFO] = msgFuncs.OnGetTaskInfo,                            -- 服务端返回任务信息
    [msgId.SERVER_CL_NOTICE_TASK] = msgFuncs.OnNoticeAddTask,                        -- 服务端通知任务增加
    [msgId.SERVER_CL_UPDATE_TASK] = msgFuncs.OnUpDateTask,                           -- 服务端通知任务状态发生改变
    [msgId.SERVER_CL_FINISH_TASK] = msgFuncs.OnFinishTask,                           -- 服务端请求完成任务
    [msgId.SERVER_CL_ABANDON_TASK] = msgFuncs.OnAbandonTask,                         -- 服务端请求放弃任务
    
    
    -- 飞宝系统模块
    [msgId.SERVER_CL_FIBBLE_INFO] = msgFuncs.OnGetFibbleInfo ,                       -- 服务端返回飞宝信息
    [msgId.SERVER_CL_CREATE_FIBBLE] = msgFuncs.OnCreateFibble ,                      -- 服务端返回飞宝打造请求
    [msgId.SERVER_CL_FIBBLE_UP] = msgFuncs.OnFibbleUp ,                              -- 服务端返回炼造飞宝请求
    [msgId.SERVER_CL_SKILL_UP] = msgFuncs.OnSkillUp ,                                -- 服务端返回提升技能等级请求
    [msgId.SERVER_CL_CHANGE_SKILL_SITE] = msgFuncs.OnChangeSkillSite ,               -- 服务端返回技能坑位请求
    [msgId.SERVER_CL_CHANGE_GOD_SITE] =  msgFuncs.OnChangeGodSite ,                  -- 服务端返回神将坑位请求
    
    [msgId.SERVER_CL_SELECT_FIBBLE] =  msgFuncs.OnSelectFibble,                      -- 服务端返回神将坑位请求
    [msgId.SERVER_CL_FIBBLE_SKILL_INFO] =  msgFuncs.OnGetFibbleSkillInfo,            -- 服务端返回飞宝技能信息
    [msgId.SERVER_CL_BUY_SKILL_POINT] = msgFuncs.OnBuyFibbleSkillPoint,              -- 服务端返回技能点购买请求
    
    -- 神将系统模块
    [msgId.SERVER_CL_GOD_INFO] = msgFuncs.OnGetGodInfo,                              -- 服务端返回神将信息
    [msgId.SERVER_CL_CREATE_GOD] = msgFuncs.OnCreateGod,                             -- 服务端返回神将合成请求
    [msgId.SERVER_CL_GOD_UP] = msgFuncs.OnGodLevelUp,                                -- 服务端返回神将升级请求
    [msgId.SERVER_CL_GOD_STAR_UP] = msgFuncs.OnGodStarUp,                            -- 服务端返回提升神将星级请求
    
    -- 探索模块
    [msgId.SERVER_CL_EXPLORE_INFO] = msgFuncs.OnGetExploreInfo,                      -- 服务端返回探索信息
    [msgId.SERVER_CL_GET_CELL] = msgFuncs.OnGetCell,                                 -- 服务端返回打开格子请求
    [msgId.SERVER_CL_REFRESH] = msgFuncs.OnRefresh,                                  -- 客户端返回刷新大宝
    [msgId.SERVER_CL_NOTICE_EXPLORE_THROUTH] = msgFuncs.OnExploreThrouth,            -- 服务端通知探索地图通过
    
    -- 奖励模块
    [msgId.SERVER_CL_NOTICE_PRIZE] = msgFuncs.OnGetNoticePrize,                      -- 服务端返回探索信息
    
    --消耗体力
    [msgId.SERVER_CL_COST_ACTION] = msgFuncs.OnCostAction,                           -- 服务端返回探索信息
    
    -- 被挤下线
    [msgId.SERVER_CL_NOTICE_OFFLINE] = msgFuncs.onNoticeOffline                      -- 通知账号在别处登录]
    
}

-- C++调用,进入后台
function OnEnterBackground()
   
    local SceneManager = require("app.views.SceneManager")
    SceneManager:switch(SceneManager.SceneName.SCENE_SELECTADDRSEVER)
    UserData.BaseInfo:sendServerOffLine()--发送请求退出   
    
end
-- C++调用,进入游戏
function OnWillEnterForeground()
    
end

-- C++调用,网络出错
function OnNetError()
    local lnet = require "net.Net"
    EventMgr:dispatch(EventType.deleteBusyLayer)
    --在此关闭网络连接转圈动画    
    cclog('OnNetError')
    
    local function onEventEixtGame()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:switch(SceneManager.SceneName.SCENE_LOGIN)
    end
   
    local YesCancelLayer = require("app/views/public/YesCancelLayer")
    local yeslayer = YesCancelLayer:create("网络异常，请确认网络正常后重试！",nil,onEventEixtGame)
    yeslayer:setButtonTitle("重连","登出") 
    
end

-- C++调用,收到消息
function OnNetRecvMsg()
    local lnet = require "net.Net"
   
    --在此关闭网络连接转圈动画   
    EventMgr:dispatch(EventType.deleteBusyLayer)
  
    local wsLuaFunc = lnet.cppFunc
    local unTag = wsLuaFunc:readRecvUint32()
    local unLen = wsLuaFunc:readRecvUint32()
    local unUserId = wsLuaFunc:readRecvUint32()
    local unMsgId = wsLuaFunc:readRecvUint32()

    local func = NetMsgDispatch[unMsgId]
    if (func ~= nil) then
        xpcall(function() func() end,__G__TRACKBACK__) 
    else
        cclog("msg not have dispatch function:%d",unMsgId)   
    end
end
