

local EventType                     = {}

-------------------------------------------------------
--【删除busylayer的】
EventType.deleteBusyLayer           = "deleteBusyLayer"                    -- 删除busylayer

-------------------------------------------------------
--【登陆系统】
EventType.onServerLogin             = "onServerLogin"                      -- 客户端向服务器登陆
EventType.onServerRegist            = "onServerRegist"                     -- 客户端向服务器请求注册
EventType.onServerVerifyCode        = "onServerVerifyCode"                 -- 客户端向服务器请求验证码
EventType.onServerBaseInfo          = "onServerBaseInfo"                   -- 客户端向服务器请求基本信息
EventType.onRandomName              = "onRandomName"                       -- 请求随机名字

-------------------------------------------------------
--【聊天系统】
EventType.ReqWorldChatRet           = "ReqWorldChatRet"                    -- 服务端向客户端返回世界聊天
EventType.ReqNoticeWorldChat        = "ReqNoticeWorldChat"                 -- 服务端向客户端通知世界聊天
EventType.ReqPrivateChatRet         = "ReqPrivateChatRet"                  -- 服务端向客户端返回私聊

-------------------------------------------------------
--【系统时间】
EventType.OnPropertyChange          = "OnPropertyChange"                   -- 玩家基本属性变化
EventType.OnServerTime              = "OnServerTime"                       -- 服务器返回系统时间
EventType.OnBuyAction               = "OnBuyAction"                        -- 购买体力
EventType.OnGetActionBag            = "OnGetActionBag"                     -- 领取体力包


-------------------------------------------------------
--【好友通信模块】
-- 背包
EventType.OnBagItemList             = "OnBagItemList"                      -- 背包物品列表
EventType.OnBagItemChange           = "OnBagItemChange"                    -- 背包物品发生变化

-- 战斗消息
EventType.OnBattleInfo              = "OnBattleInfo"                       -- 战斗消息
EventType.OnPveBattleResult         = "OnPveBattleResult"                  -- 副本战斗消息
EventType.OnServerCleanUp           = "OnServerCleanUp"                    -- 扫荡消息
EventType.OnAreanRankList           = "OnAreanRankList"                    -- 竞技场排名列表     
EventType.OnAreanOpponentList       = "OnAreanOpponentList"                -- 竞技场对手列表
EventType.OnAreanRivalBack          = "OnAreanRivalBack"                   -- 竞技场战斗结果
EventType.OnAreanSelfInfoBack       = "OnAreanSelfInfoBack"                -- 竞技场个人信息
EventType.OnAreanRecord             = "OnAreanRecord"                      -- 竞技场记录
EventType.OnAreanBuyBack            = "OnAreanBuyBack"                     -- 竞技场购买次数返回结果

EventType.OnInquiryPlayerInfo       = "OnInquiryPlayerInfo"                -- 查询ID玩家的 
EventType.OnCommendList             = "OnCommendList"                      -- 推荐好友的列表
EventType.OnAddFriend               = "OnAddFriend"                        -- 添加好友的返回情况
EventType.OnNoticeAddFriend         = "OnNoticeAddFriend"                  -- 服务器通知玩家，某玩家的申请好友的消息
EventType.OnRefuseAddFriend         = "OnRefuseAddFriend"                  -- 服务器通知玩家，玩家好友申请拒绝回复
EventType.OnAgreeAddFriend          = "OnAgreeAddFriend"                   -- 服务器通知玩家，把玩家添加到好友列表
EventType.OnUpdateFriendOnline      = "OnUpdateFriendOnline"               -- 玩家登陆或者离线，服务器主动发给自己的好友列表
EventType.OnGiveFriendAction        = "OnGiveFriendAction"                 -- 服务端返回体力赠送结果
EventType.OnNoticeGetFriendAcion    = "OnNoticeGetFriendAcion"             -- 收到好友赠送体力通知的消息
EventType.OnGetFriendAcion          = "OnGetFriendAcion"                   -- 服务端向客户端发送接收好友赠送的体力结果
EventType.OnPullBlack               = "OnPullBlack"                        -- 服务端向客户端返回玩家拉黑请求
EventType.OnNotPullBlack            = "OnNotPullBlack"                     -- 服务端向客户端返回与玩家解除黑名单关系请求
EventType.OnNoticeBlackListChange   = "OnNoticeBlackListChange"            -- 服务端向客户端通知黑名单列表变化

-------------------------------------------------------
--【邮件】
EventType.ReqReadMail               = "ReqReadMail"                        -- 服务端向客户端返回邮件读取请求
EventType.ReqPickMail               = "ReqPickMail"                        -- 服务端向客户端返回提取邮件附件
EventType.ReqDelMail                = "ReqDelMail"                         -- 服务端向客户端返回删除邮件
EventType.ReqNoticeAddMail          = "ReqNoticeAddMail"                   -- 服务端通知客户端多了一封邮件

-------------------------------------------------------
-- 押镖系统
EventType.OnTransportList           = "OnTransportList"                    -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
EventType.OnRefreshType             = "OnRefreshType"                      -- 服务返回镖车刷新请求
EventType.OnStartTransport          = "OnStartTransport"                   -- 服务返回开始押镖请求
EventType.OnEndTransport            = "OnEndTransport"                     -- 服务返回结束押镖请求


-------------------------------------------------------
-- 【商城VIP】
EventType.ReqBuyItem                = "ReqBuyItem"                          -- 服务端向客户端返回物品购买请求
EventType.ReqNoticeVipExpChange     = "ReqNoticeVipExpChange"               -- 服务端向客户端通知VIP充值经验发生改变
EventType.ReqGetVipBag              = "ReqGetVipBag"                        -- 服务端向客户端返回获取VIP礼包请求


-------------------------------------------------------
-- 【任务】
EventType.EventOnNoticeAddTask      = "EventOnNoticeAddTask"                -- 服务端通知任务增加
EventType.EventOnUpDateTask         = "EventOnUpDateTask"                   -- 服务端通知任务状态发生改变
EventType.EventOnFinishTask         = "EventOnFinishTask"                   -- 服务端返回完成任务请求
EventType.EventOnAbandonTask        = "EventOnAbandonTask"                  -- 服务端返回放弃任务请求



-------------------------------------------------------
--  【飞宝系统】
EventType.OnGetFibbleInfo           = "OnGetFibbleInfo"                     -- 服务端返回飞宝信息
EventType.OnCreateFibble            = "OnCreateFibble"                      -- 服务端返回飞宝打造请求
EventType.OnFibbleUp                = "OnFibbleUp"                          -- 服务端返回炼造飞宝请求
EventType.OnSkillUp                 = "OnSkillUp"                           -- 服务端返回提升技能等级请求
EventType.OnChangeSkillSite         = "OnChangeSkillSite"                   -- 服务端返回技能坑位请求
EventType.OnChangeGodSite           = "OnChangeGodSite"                     -- 服务端返回神将坑位请求
EventType.OnSelectFibble            = "OnSelectFibble"                      -- 服务端返回选择飞宝
EventType.OnBuyFibbleSkillPoint     = "OnBuyFibbleSkillPoint"               -- 服务端返回技能点购买请求

-------------------------------------------------------
--  【神将系统】
EventType.OnGetGodInfo              = "OnGetGodInfo"	                    -- 服务端返回神将列表信息
EventType.OnCreateGod               = "OnCreateGod"                         -- 服务端返回合成神将信息
EventType.OnGodLevelUp              = "OnGodLevelUp"                        -- 服务端返回神将升级请求
EventType.OnGodStarUp               = "OnGodStarUp"                         -- 服务端返回神将提升星级请求

--------------------------------------------------------
--  【探索系统】
EventType.OnGetExploreInfo          = "OnGetExploreInfo"                    -- 服务端返回探索信息
EventType.OnGetCell                 = "OnGetCell"                           -- 服务端返回打开格子请求
EventType.OnRefresh                 = "OnRefresh"                           -- 服务端返回刷新大宝请求
EventType.OnExploreThrouth          = "OnExploreThrouth"                    -- 服务端返回通过探索地图

--------------------------------------------------------
--  【奖励模块】
EventType.OnGetNoticePrize          = "OnGetNoticePrize"                    -- 服务端通知获取的奖励属性
--------------------------------------------------------
--
-- 【扣除体力】
EventType.OnCostAction              = "OnCostAction"                        -- 服务端通知获取的奖励属性

--------------------------------------------------------
--【提示模块】
EventType.OnFlyPrompt               = "OnFlyPrompt"                         -- 飞宝可炼制，制造提示
EventType.OnSkillPrompt             = "OnSkillPrompt"                       -- 技能点满，有技能可升级提示


return EventType