--[[网络消息定义
要求服务端客户端保持一致
]]--
local NetMsgId = {

    -- 1000以下ID由系统保留,不能使用
    CL_SERVER_LOGIN = 1011,                           -- 客户端请求登陆
    SERVER_CL_LOGIN = 1012,                           -- 服务端返回登陆
    CL_SERVER_REGIST = 1013,                          -- 客户端请求注册
    SERVER_CL_REGIST = 1014,                          -- 服务端返回注册
    CL_SERVER_VERIFYCODE = 1015,                      -- 客户端请求验证码
    SERVER_CL_VERIFYCODE = 1016,                      -- 服务端返回验证码
    CL_SERVER_BASEINFO = 1017,                        -- 客户端请求玩家基本信息
    SERVER_CL_BASEINFO = 1018,                        -- 服务端返回玩家基本信息
    CL_SERVER_RANDOMNICKNAME = 1019,                  -- 客户端请求随机姓名
    SERVER_CL_RANDOMNICKNAME = 1020,                  -- 服务端返回随机姓名      
    CL_SERVER_OFF_LINE = 1021,                        -- 客户端请求下线
    SERVER_CL_OFF_LINE = 1022,                        -- 下线返回


    CL_SERVER_GET_TIME = 1026,                        -- 客户端请求服务器时间
    SERVER_CL_GET_TIME = 1027,                        -- 服务器返回时间请求
 
    --聊天消息
    CL_SERVER_WORLDCHAT = 1101,                       -- 客户端向服务端请求世界聊天
    SERVER_CL_WORLDCHAT = 1102,                       -- 服务端向客户端返回世界聊天
    SERVER_NOTICE_WORLDCHAT = 1103,                   -- 服务端向客户端通知世界聊天
    CL_SERVER_PRIVATECHAT = 1104,                     -- 客户端向服务端请求私聊
    SERVER_CL_PRIVATECHAT = 1105,                     -- 服务端向客户端返回私聊
    
    -- 补充黑名单的
    CL_SERVER_BLACKLIST = 1106,                       -- 客户端向服务端请求黑名单列表
    SERVER_CL_BLACKLIST = 1107,                       -- 服务端向客户端返回黑名单列表
    CL_SERVER_PULL_BLACK = 1108,                      -- 客户端向服务端请求将玩家拉入黑名单
    SERVER_CL_PULL_BLACK = 1109,                      -- 服务端向客户端返回玩家拉黑请求
    CL_SERVER_NOT_PULL_BLACK = 1110,                  -- 客户端向服务端请求与玩家解除黑名单关系
    SERVER_CL_NOT_PULL_BLACK = 1111,                  -- 服务端向客户端返回与玩家解除黑名单关系请求
    SERVER_CL_NOTICE_BLACKLIST_CHANGE = 1112,         -- 服务端向客户端通知黑名单列表变化
    
    --邮件
    CL_SERVER_EMAIL_LIST = 1131,                      -- 客户端向服务端请求邮件列表
    SERVER_CL_EMAIL_LIST = 1132,                      -- 服务端向客户端返回邮件列表
    CL_SERVER_READ_EMAIL = 1133,                      -- 客户端向服务端请求读取邮件内容
    SERVER_CL_READ_EMAIL = 1134,                      -- 服务端向客户端返回邮件读取请求
    CL_SERVER_PICK_ATTACH = 1135,                     -- 客户端向服务端请求提取邮件附件
    SERVER_CL_PICK_ATTACH = 1136,                     -- 服务端向客户端返回提取邮件附件
    CL_SERVER_DEL_EMAIL = 1137,                       -- 客户端向服务端请求删除邮件
    SERVER_CL_DEL_EMAIL = 1138,                       -- 服务端向客户端返回删除邮件
    SERVER_CL_NOTICE_ADD_EMAIL = 1139,                -- 服务端通知客户端多了一封邮件
    SERVER_CL_NOTICE_DEL_EMAIL = 1140,                -- 服务端通知客户端删除了一封邮件
    
    -- 体力模块消息
    CL_SERVER_BUY_ACTION = 2301,                      -- 客户端向服务端请求购买体力
    SERVER_CL_BUY_ACTION = 2302,                      -- 服务端向客户端返回体力购买请求
    CL_SERVER_GET_ACTION_BAG = 2303,                  -- 客户端向服务端请求获取体力恢复包
    SERVER_CL_GET_ACTION_BAG = 2304,                  -- 服务端向客户端返回体力恢复包请求

    -- 基本属性变化消息
    SERVER_CL_NOTICE_PROPERTY_CHANGE = 1028,          -- 服务端告诉客户端玩家基本属性变化
   
    
    -- 好友模块
    CL_SERVER_FRIEND_LIST = 1301,                     -- 客户端向服务端请求好友列表以及好友申请列表
    SERVER_CL_FRIEND_LIST = 1302,                     -- 服务端向客户端返回好友列表以及好友申请列表
    CL_SERVER_COMMEND_LIST= 1303,                     -- 客户端向服务端请求推荐好友列表
    SERVER_CL_COMMEND_LIST= 1304,                     -- 服务端向客户端返回推荐好友列表
    CL_SERVER_INQUIRY_PLAYER_INFO = 1305,             -- 客户端向服务端请求查询玩家信息
    SERVER_CL_INQUIRY_PLAYER_INFO = 1306,             -- 服务端向客户端返回查询的玩家信息
    CL_SERVER_ADD_FRIEND = 1307,                      -- 客户端向服务端添加好友
    SERVER_CL_ADD_FRIEND= 1308,                       -- 服务器返回添加好友结果
    SERVER_CL_NOTICE_ADD_FRIEND = 1309,               -- 服务器通知玩家，某玩家的申请好友的消息
    CL_SERVER_REPLY_ADD_FRIEND  = 1310,               -- 玩家回复好友申请
    SERVER_CL_NOTICE_REFUSE_ADD_FRIEND = 1311,        -- 玩家好友申请拒绝回复  
    SERVER_CL_NOTICE_AGREE_ADD_FRIEND = 1312,         -- 把玩家添加到好友列表，
    CL_SERVER_DEL_FRIEND = 1313,                      -- 客户端向服务端请删除好友
    SERVER_CL_DEL_FRIEND = 1314,                      -- 服务器向客户端发送删除好友信息(发2次，发给对方)
    SERVER_CL_NOTICE_UPDATE_FRIEND_ONLINE = 1315,     -- 玩家登陆或者离线，服务器主动发给自己的好友列表
    CL_SERVER_GIVE_FRIEND_ACTION = 1316,              -- 请求给好友体力
    SERVER_CL_GIVE_FRIEND_ACTION = 1317,              -- 服务端返回体力赠送结果
    SERVER_CL_NOTICE_GET_FRIEND_ACTION = 1318,        -- 收到好友赠送体力通知的消息
    CL_SERVER_FRIEND_ACTION = 1319,                   -- 客户端向服务端接收好友赠送的体力
    SERVER_CL_GET_FRIEND_ACTION = 1320,               -- 服务端向客户端发送接收好友赠送的体力结果
    
    --押镖系统消息
    CL_SERVER_TRANSPORT_LIST = 1351,                  -- 客户端向服务端请求押镖列表
    SERVER_CL_TRANSPORT_LIST = 1352,                  -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
    CL_SERVER_REFRESH_TYPE = 1353,                    -- 玩家请求刷新镖车类型
    SERVER_CL_REFRESH_TYPE = 1354,                    -- 服务返回镖车刷新请求
    CL_SERVER_START_TRANSPORT = 1355,                 -- 玩家请求开始押镖
    SERVER_CL_START_TRANSPORT = 1356,                 -- 服务返回开始押镖请求
    CL_SERVER_END_TRANSPORT = 1357,                   -- 玩家请求结束押镖
    SERVER_CL_END_TRANSPORT = 1358,                   -- 服务返回结束押镖请求

    
    --商城，VIP
    CL_SERVER_BUY_ITEM = 1401,                		  -- 客户端向服务端请求购买物品
    SERVER_CL_BUY_ITEM = 1402,               		  -- 服务端向客户端返回物品购买请求
    CL_SERVER_GET_VIP_BAG = 1403,                     -- 客户端向服务端请求获取VIP礼包
    SERVER_CL_GET_VIP_BAG = 1404,                     -- 服务端向客户端返回获取VIP礼包请求
    SERVER_CL_NOTICE_VIP_EXP_CHANGE = 1405,  		  -- 服务端向客户端通知VIP充值经验发生改变
    
    -- 战斗模块
    CL_SERVER_REQUEST_FIGHT = 1501,                   -- 客户端请求战斗
    SERVER_CL_FIGHT_BACK = 1502,                      -- 战斗返回
    CL_SERVER_SUBMIT_COURSE = 1503,                   -- 提交战斗记录
    SERVER_CL_SUBMIT_COURSE_BACK = 1504,              -- 返回战斗结果
    CL_SERVER_REQUEST_COPY_BATTLE = 1505,             -- 选择副本战斗  
    SERVER_CL_COPY_BATTLE_BACK = 1506,                -- 副本战斗结束
    
    SERVER_CL_COPYINFO_BACK = 1508,                   --返回用户副本信息
    CL_SERVER_REQUEST_CLEANUP = 1509,                 --请求扫荡
    SERVER_CL_REQUEST_CLEANUP_BACK = 1510,            --扫荡返回

    CL_SERVER_FIGHT_PRIZE = 2701,                     -- 客户端请求打怪奖励
    
    -- 竞技场模块
    CL_SERVER_REQUEST_ARENA_RANK_INFO = 1520,         -- 请求竞技场排行
    SERVER_CL_ARENA_RANK_INFO_BACK = 1521,            -- 服务端返回竞技场排行
    CL_SERVER_REQUEST_ARENA_OPPONENT = 1522,          -- 请求竞技场对手
    SERVER_CL_ARENA_OPPONENT_BACK = 1523,             -- 服务端返回竞技场对手
    CL_SERVER_REQUEST_ARENA_RIVAL = 1524,             -- 请求竞技场对战
    SERVER_CL_ARENA_RIVAL_BACK = 1525,                -- 返回竞技场对战结果
    CL_SERVER_REQUEST_ARENA_INFO = 1526,              -- 请求自身竞技场信息
    SERVER_CL_ARENA_SELF_INFO_BACK = 1527,            -- 返回竞技场个人信息
    CL_SERVER_REQUEST_ARENA_RECORD = 1528,            -- 请求战斗记录
    SERVER_CL_ARENA_RECORD_BACK =1529,                -- 服务端返回战斗记录
    CL_SERVER_REQUEST_ARENA_BUY = 1530,               -- 购买竞技场挑战次数
    SERVER_CL_ARENA_BUY_BACK = 1531,                  -- 服务端返回购买结果
    
    -- 任务模块信息
    CL_SERVER_TASK_INFO = 2101,                       -- 客户端请求任务信息
    SERVER_CL_TASK_INFO = 2102,                       -- 服务端返回任务信息
    CL_SERVER_GET_TASK = 2103,                        -- 客户端请求接任务
    SERVER_CL_NOTICE_TASK = 2104,                     -- 服务端通知任务增加
    CL_SERVER_UPDATE_TASK = 2105,                     -- 客户端请求更新任务状态
    SERVER_CL_UPDATE_TASK = 2106,                     -- 服务端通知任务状态发生改变
    CL_SERVER_FINISH_TASK = 2107,                     -- 客户端请求完成任务
    SERVER_CL_FINISH_TASK = 2108,                     -- 服务端返回完成任务请求
    CL_SERVER_ABANDON_TASK = 2109,                    -- 客户端请求放弃任务
    SERVER_CL_ABANDON_TASK = 2110,                    -- 服务端返回放弃任务请求
    
    -- 背包模块
    CL_SERVER_BAG_INFO = 2201,                        -- 客户端请求背包信息
    SERVER_CL_BAG_INFO = 2202,                        -- 服务端返回背包信息
    SERVER_CL_NOTEICE_ITEM_CHANGE = 2203,             -- 服务端通知背包物品发生改变

    --飞宝模块
    CL_SERVER_FIBBLE_INFO = 2401,                     -- 客户端请求飞宝信息
    SERVER_CL_FIBBLE_INFO = 2402,                     -- 服务端返回飞宝信息
    CL_SERVER_CREATE_FIBBLE = 2403,                   -- 客户端请求打造飞宝
    SERVER_CL_CREATE_FIBBLE = 2404,                   -- 服务端返回飞宝打造请求
    CL_SERVER_FIBBLE_UP = 2405,                       -- 客户端请求炼造飞宝
    SERVER_CL_FIBBLE_UP = 2406,                       -- 服务端返回炼造飞宝请求
    CL_SERVER_SKILL_UP = 2407,                        -- 客户端请求提升技能等级
    SERVER_CL_SKILL_UP = 2408,                        -- 服务端返回提升技能等级请求
    CL_SERVER_CHANGE_SKILL_SITE = 2409,               -- 客户端请求改变技能坑位
    SERVER_CL_CHANGE_SKILL_SITE = 2410,               -- 服务端返回技能坑位请求
    CL_SERVER_CHANGE_GOD_SITE = 2411,                 -- 客户端请求改变神将坑位
    SERVER_CL_CHANGE_GOD_SITE = 2412,                 -- 服务端返回神将坑位请求
    CL_SERVER_SELECT_FIBBLE = 2413,                   -- 客户端请求选择飞宝
    SERVER_CL_SELECT_FIBBLE = 2414,                   -- 服务端返回飞宝选择请求
    CL_SERVER_FIBBLE_SKILL_INFO = 2415,               -- 客户端请求飞宝技能信息
    SERVER_CL_FIBBLE_SKILL_INFO = 2416,               -- 服务端返回飞宝技能信息
    
    CL_SERVER_BUY_SKILL_POINT = 2417,                 -- 客户端请求购买技能点
    SERVER_CL_BUY_SKILL_POINT = 2418,                 -- 服务端返回技能点购买请求
    
    -- 神将模块
    CL_SERVER_GOD_INFO = 2501,                        -- 客户端请求神将信息
    SERVER_CL_GOD_INFO = 2502,                        -- 服务端返回神将信息
    CL_SERVER_CREATE_GOD = 2503,                      -- 客户端请求合成神将
    SERVER_CL_CREATE_GOD = 2504,                      -- 服务端返回神将合成请求
    CL_SERVER_GOD_UP = 2505,                          -- 客户端请求神将升级
    SERVER_CL_GOD_UP = 2506,                          -- 服务端返回神将升级请求
    CL_SERVER_GOD_STAR_UP = 2507,                     -- 客户端请求提升神将星级
    SERVER_CL_GOD_STAR_UP = 2508,                     -- 服务端返回提升神将星级请求
    
    --探索模块
    CL_SERVER_EXPLORE_INFO = 2601,                     -- 客户端请求探索信息
    SERVER_CL_EXPLORE_INFO = 2602,                     -- 服务端返回探索信息
    CL_SERVER_GET_CELL = 2603,                         -- 客户端请求打开格子
    SERVER_CL_GET_CELL = 2604,                         -- 服务端返回打开格子请求
    CL_SERVER_REFRESH = 2605,                          -- 客户端请求刷新大宝
    SERVER_CL_REFRESH = 2606,                          -- 服务端返回刷新大宝请求
    SERVER_CL_NOTICE_EXPLORE_THROUTH = 2607,           -- 服务端通知探索地图通过
    
    -- 奖励模块
    SERVER_CL_NOTICE_PRIZE = 1051,                     -- 服务端通知获取的奖励属性
    
    -- 扣除体力
    CL_SERVER_COST_ACTION = 2703,                      -- 客户端请求扣除体力
    SERVER_CL_COST_ACTION = 2704,                      -- 服务端返回体力扣除
    
    -- 被挤下线
    SERVER_CL_NOTICE_OFFLINE = 9001,                   -- 通知账号在别处登录


        
}

return NetMsgId
