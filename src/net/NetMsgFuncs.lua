local NetMsgFuncs = {
    
    -- 登陆系统
    OnLogin = nil,                         -- 服务端登陆返回
    OnRegist = nil,                        -- 服务端创建角色返回
    OnVerifyCode = nil,                    -- 服务端返回验证码
    OnBaseInfo = nil,                      -- 服务端返回玩家基本信息
    OnRandomNickName = nil,                -- 服务端返回随机名字
    OnOFFLine = nil,                       -- 服务器下线
    OnSeverTime = nil,                     -- 服务器时间
    -- 聊天系统
    OnWorldChat = nil,                     -- 服务端向客户端返回世界聊天
    OnNoticeWorldChat = nil,               -- 服务端向客户端通知世界聊天
    OnPrivateChat = nil,                   --服务端向客户端返回私聊
    
    -- 体力系统
    OnGetAction = nil,                     -- 服务端返回体力请求
    OnGetActionBag = nil,                  -- 服务端返回体力恢复包请求
    
    -- 基本属性变化
    OnPropertyChange = nil,                -- 玩家基本属性变化
    
    -- 好友模块
    OnFriendList = nil,                    -- 服务端向客户端返回好友列表以及好友申请列表
    OnCommendList = nil,                   -- 服务端向客户端返回推荐好友列表
    OnInquiryPlayerInfo = nil,             -- 服务端向客户端返回查询的玩家信息
    OnAddFriend = nil,                     -- 服务器返回添加好友结果
    OnNoticeAddFriend = nil,               -- 服务器通知玩家，某玩家的申请好友的消息 
    OnRefuseAddFriend = nil,               -- 玩家好友申请拒绝回复  
    OnAgreeAddFriend = nil,                -- 把玩家添加到好友列表，
    OnDeleteFriend = nil,                  -- 服务器向客户端发送删除好友信息(发2次，发给对方)
    OnUpdateFriendOnline = nil,            -- 玩家登陆或者离线，服务器主动发给自己的好友列表
    OnGiveFriendAction = nil,              -- 服务端返回体力赠送结果
    OnNoticeGetFriendAcion = nil,          -- 收到好友赠送体力通知的消息
    OnGetFriendAcion = nil,                -- 服务端向客户端发送接收好友赠送的体力结果
    -- 补充黑名单   
    OnBlackList = nil,                     -- 服务端向客户端返回黑名单列表
    OnPullBlack = nil,                     -- 服务端向客户端返回玩家拉黑请求
    OnNotPullBlack = nil,                  -- 服务端向客户端返回与玩家解除黑名单关系请求
    OnNoticeBlackListChange = nil,         -- 服务端向客户端通知黑名单列表变化
    
    -- 背包
    OnBagItemList = nil,                   -- 背包列表
    OnBagItemChange = nil,                 -- 物品数量发生改变 
    
    -- 战斗模块
    OnBattleInfo = nil,                    -- 战斗日志返回
    OnPveBattleResult = nil,               -- 副本战斗结果
    OnCopyInfo = nil,                      -- 已开启副本列表
    OnServerCleanUp = nil,                 -- 扫荡返回
    OnFightPrize = nil,                    -- 客户端请求打怪奖励
    
    -- 竞技场模块
    OnAreanRankList = nil,                 -- 竞技场排名
    OnAreanOpponentList = nil,             -- 竞技场对手列表
    OnAreanRivalBack = nil,                -- 竞技场战斗结果
    OnAreanSelfInfoBack = nil,             -- 竞技场个人信息
    OnAreanRecord = nil,                   -- 竞技场挑战记录
    OnAreanBuyBack = nil,                  -- 竞技场购买结果
    
    -- 邮件
    OnMailList = nil,                      -- 服务端向客户端返回邮件列表
    OnReadMail = nil,                      -- 服务端向客户端返回邮件读取请求
    OnPickAttack = nil,                    -- 服务端向客户端返回提取邮件附件
    OnDelMail = nil,                       -- 服务端向客户端返回删除邮件
    OnNoticeAddMail = nil,                 -- 服务端通知客户端多了一封邮件
    OnNoticeDelMail = nil,                 -- 服务端通知客户端删除了一封邮件
    
    -- 押镖系统
    OnTransportList = nil,                 -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
    OnRefreshType = nil,                   -- 服务返回镖车刷新请求
    OnStartTransport = nil,                -- 服务返回开始押镖请求
    OnEndTransport = nil,                  -- 服务返回结束押镖请求
    
    --商城，VIP
    OnBuyItem = nil,                       -- 服务端向客户端返回物品购买请求
    OnNoticeVipExpChange = nil,            -- 服务端向客户端通知VIP充值经验发生改变
    OnGetVipBag = nil,                     -- 服务端向客户端返回获取VIP礼包请求
    
    
    -- 任务模块
    OnGetTaskInfo = nil,                   -- 服务端返回任务信息
    OnNoticeAddTask = nil,                 -- 服务端通知任务增加
    OnUpDateTask = nil,                    -- 服务端通知任务状态发生改变
    OnFinishTask = nil,                    -- 客户端请求完成任务
    OnAbandonTask = nil,                   -- 放弃任务
    
    
    -- 飞宝系统模块
    OnGetFibbleInfo = nil,                 -- 服务端返回飞宝信息
    OnCreateFibble = nil,                  -- 服务端返回飞宝打造请求
    OnFibbleUp = nil,                      -- 服务端返回炼造飞宝请求
    OnSkillUp = nil,                       -- 服务端返回提升技能等级请求
    OnChangeSkillSite = nil,               -- 服务端返回技能坑位请求
    OnChangeGodSite = nil,                 -- 服务端返回神将坑位请求
    OnSelectFibble = nil,                  -- 服务器返回选择飞宝
    OnGetFibbleSkillInfo = nil,            -- 返回技能信息
    OnBuyFibbleSkillPoint = nil,           -- 服务端返回技能点购买请求
    
    -- 神将系统模块
    OnGetGodInfo = nil,                    -- 服务端返回神将信息
    OnCreateGod = nil,                     -- 服务端返回神将合成请求
    OnGodLevelUp = nil,                    -- 服务端返回神将升级请求
    OnGodStarUp = nil,                     -- 服务端返回提升神将星级请求

    -- 探索模块
    OnGetExploreInfo = nil,                -- 服务端返回探索信息
    OnGetCell = nil,                       -- 服务端返回打开格子请求
    OnRefresh = nil,                       -- 服务端返回刷新打包请求
    OnExploreThrouth = nil,                -- 服务端通知探索地图通过
    
    -- 奖励模块
    OnGetNoticePrize = nil,               -- 服务端通知获取的奖励属性
    
    --扣除体力
    OnCostAction = nil ,                  -- 服务端通知扣除体力
    
    --被挤下线
    onNoticeOffline = nil,                 -- 通知账号在别处登录
}

return NetMsgFuncs
 
