
cc.FileUtils:getInstance():setPopupNotify(false)
local paths1 = cc.FileUtils:getInstance():getSearchPaths()
local writeRootPath1 = cc.FileUtils:getInstance():getWritablePath() .. "update_files" .. "/src/"
local writeRootPath2 = cc.FileUtils:getInstance():getWritablePath() .. "update_files" .. "/res/"
local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
table.insert(searchPaths,1,writeRootPath1) 
table.insert(searchPaths,2,writeRootPath2) 
cc.FileUtils:getInstance():setSearchPaths(searchPaths)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/app")
require "config"
require "cocos.init"
--打印用的CCLOG
require"common.Log"
--  全局需要用到的require


require "static_data.StaticData"
require "fight_static_data.FightStaticData"
require "user_data.UserData"  --  require "user_data.UserData" 必须在 require "net.NetMsgDispatch" 之前。因为msgFuncs的函数定义在UserData各个文件中。
require "net.NetMsgDispatch"
require "app.views.Task.ManagerTask"
require("app.views.MyFighting.MyFightingCtrl")
require("app.views.MyFighting.MyFightingConfig")

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
