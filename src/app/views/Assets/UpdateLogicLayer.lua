
require('common.json')
local lNet = require ("net.Net")
local UpdateLogicLayer = class("UpdateLogicLayer", cc.Node)

--local updateAddr = "http://192.168.0.12:9006/"           -- http更新地址
local updateAddr = "http://192.168.0.155:81/"           -- http更新地址

function UpdateLogicLayer:create()
    local view = UpdateLogicLayer.new()
    local function onNodeEvent(eventType)
        if eventType == "enter" then
            view:onEnter()
        elseif eventType == "exit" then
            view:onExit()
        end
    end
    view:registerScriptHandler(onNodeEvent)
    return view
end

function UpdateLogicLayer:ctor()
    self.writeRootPath = nil                -- 更新目录
    self.resVerServerFile = nil             -- 服务器资源版本号文件名
    self.resVerServer = nil                 -- 服务器资源版本号文件内容
    self.resVerClientFile = nil             -- 客户端资源版本号文件名
    self.resVerClient = nil                 -- 客户端资源版本号文件内容
    self.fileListServerFile = nil           -- 服务器资源列表文件名
    self.fileListServer = nil               -- 服务器资源列表文件内容
    self.fileListClientFile = nil           -- 客户端资源列表文件名
    self.fileListClient = nil               -- 客户端资源列表文件内容
    
    self.updateFile = nil                   -- 当前更新文件名
    self.updatePath = nil                   -- 当前更新路径
    self.updateResTable = nil               -- 需要更新资源列表
    self.updateProgress = 1                 -- 资源更新进度

    self.EventType = {
        None = 0,                           -- 初始化状态
        StartGame = 1,                      -- 开始游戏
        StartUpdate = 2,                    -- 开始更新
        Progress = 3,                       -- 更新中
        Finish = 4,                         -- 更新完成
    }
    self.callback = nil                     -- 外部回调
    self.status = self.EventType.None 
end


function UpdateLogicLayer:onEnter()
    
end


function UpdateLogicLayer:onExit()
    if self.myScheduleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
    end
end

function UpdateLogicLayer:init(callback)
    self.callback = callback    
    self:readResVersion()

    if not self.resVerServer then
        return
    else    
        if not self.resVerClient or self.resVerServer[1].version ~= self.resVerClient[1].version then
            self.status = self.EventType.StartUpdate
            self:noticeEvent()
        else 
            self.status = self.EventType.StartGame
            self:noticeEvent()        
        end     
    end
end

function UpdateLogicLayer:readResVersion()
    if self.writeRootPath == nil then
        self.writeRootPath = cc.FileUtils:getInstance():getWritablePath() .. "update_files"        
        cc.FileUtils:getInstance():addSearchPath(self.writeRootPath, true)
        local searchPath = cc.FileUtils:getInstance():getSearchPaths()              -- 不知道为什么这里没有加进去
        dump(searchPath)
    end
    
    -- 读client版本号文件
    self.resVerClientFile = self.writeRootPath .. "/" .. "resVersion_client.json"
    local fp = io.open(self.resVerClientFile, 'r')
    if fp then
        local js = fp:read('*a')
        io.close(fp)
        self.resVerClient = json.decode(js)
        print(self.resVerClient[1].version)
    --else
        --print("resVersion_client.json read error")
    end

    -- 下载server上版本号文件
    local wsLuaFunc = lNet.cppFunc
    wsLuaFunc:downloadFile(updateAddr .. "resVersion_server.json", "update_files", true)
    self.resVerServerFile = wsLuaFunc:getOutFile()    

    local path = wsLuaFunc:getCurPath()
    
    -- 读server版本号文件
    local fp = io.open(self.resVerServerFile, 'r')
    if fp then
        local js = fp:read('*a')
        io.close(fp)
        self.resVerServer = json.decode(js)
        print(self.resVerServer[1].version)
    else
        print("resVersion_server.json read error")
    end    
end

function UpdateLogicLayer:readFileList()
    if self.writeRootPath == nil then 
        self.writeRootPath = cc.FileUtils:getInstance():getWritablePath() .. "update_files"
    end
    
    -- 读client列表文件
    self.fileListClientFile = self.writeRootPath .. "/" .. "fileList_client.json"
    local fp = io.open(self.fileListClientFile, 'r')
    if fp then
        local js = fp:read('*a')
        io.close(fp)
        self.fileListClient = json.decode(js)
    --else
        --print("fileList_client.json read error")
    end

    -- 下载server上列表文件
    local wsLuaFunc = lNet.cppFunc
    wsLuaFunc:downloadFile(updateAddr .. "fileList_server.json", "update_files", true)
    self.fileListServerFile = wsLuaFunc:getOutFile();
    
    -- 读server列表文件
    local fp = io.open(self.fileListServerFile, 'r')
    if fp then
        local js = fp:read('*a')
        io.close(fp)
        self.fileListServer = json.decode(js)
    else
        print("fileList_server.json read error")
    end 
end

function UpdateLogicLayer:writeResVersion()
    local fp = io.open(self.resVerClientFile, 'w')
    if fp then
        local js = json.encode(self.resVerServer)
        fp:write(js)
        io.close(fp)
    end    
end

function UpdateLogicLayer:writeFileList()
    local fp = io.open(self.fileListClientFile, 'w')
    if fp then
        local js = json.encode(self.fileListServer)
        fp:write(js)
        io.close(fp)
    end
end

function UpdateLogicLayer:findUpdateFile()
    local restab = {}
    local isUpdate = true
    if self.fileListServer then
        if self.fileListClient then
            for k1, v1 in ipairs(self.fileListServer) do
                isUpdate = true
                for k2, v2 in ipairs(self.fileListClient) do
                    if v1.file == v2.file then
                        if v1.md5 == v2.md5 then
                            isUpdate = false
                        end
                        break
                    end    
                end
                if isUpdate == true then
                    table.insert(restab, v1.file)
                end
            end
        else    
            for k1, v1 in ipairs(self.fileListServer) do
                table.insert(restab, v1.file)
            end    
        end     
    else
        print("fileListServer error")
    end
    return restab
end

function UpdateLogicLayer:downloadRes()
    local filename = self.updateResTable[self.updateProgress]
    if filename then
        local wsLuaFunc = lNet.cppFunc
        --local urlbase = "http://127.0.0.1:81/"
        local url = updateAddr .. filename 
        wsLuaFunc:downloadFile(url, "update_files", true)
        self.updateFile = wsLuaFunc:getOutFile()
        
        self.updateProgress = self.updateProgress + 1
    end    
end

function UpdateLogicLayer:updateRes()
    self:readFileList()
    self.updateResTable = self:findUpdateFile()

    self.myScheduleUpdateId = nil  
    -- 定义一个定时器
    self.updateProgress = 0
    local all = #self.updateResTable
    
    local function myupdate(dt)
        self.updateProgress = self.updateProgress + 1
        if self.updateProgress >= all then
            self.updateProgress = all
            if self.myScheduleUpdateId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
                self.myScheduleUpdateId = nil
                
                self:writeFileList()
                self:writeResVersion()

                self.status = self.EventType.Finish
                self:noticeEvent() 
                self.status = self.EventType.StartGame
                self:noticeEvent()  
            end
        end
        
        self.status = self.EventType.Progress
        self:noticeEvent()
        self:downloadRes()
    end   
    self.myScheduleUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(myupdate, 0 ,false)  
end

function UpdateLogicLayer:noticeEvent()
    if self.callback then
        self.callback(self,self.status)
    else
        print('callback is nil')
    end
end

return UpdateLogicLayer

