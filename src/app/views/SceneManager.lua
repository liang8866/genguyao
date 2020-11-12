
--说明: 这个类用来管理所有的场景跳转工作
--[[
将需要添加的layer加到当前层上。
local SceneManager = require("app.views.SceneManager")
SceneManager:addToGameScene(layer)
]]

local SceneManager = {
    currentLayer      = nil,  --当前的主场景下的模块层
    currentSceneIndex = nil,  --当前的主场景的索引
    changeSceneDelayTime = 0.5,
    
    isFirstLoginInApp = false, --是否首次登陆app 
    gameSceneRoot = nil,  --进入游戏地图后保存的场景节点,(进入游戏后所有Layer共用一个Scene, 选服，登陆，创建角色，开场动画有单独的Scene)
    
    gameLayerList = {}, -- 游戏Layer列表
}

SceneManager.SceneName = {
    --建议切换Scene的
    SCENE_SELECTADDRSEVER              = { name = "SCENE_SELECTADDRSEVER",             view = require("app.views.Login.SelectSerAddrLayer") },      --选服
    SCENE_LOGIN                        = { name = "SCENE_LOGIN",                       view = require("app.views.Login.LoginLayer") },              --登陆
    SCENE_SELECTROLE                   = { name = "SCENE_SELECTROLE",                  view = require("app.views.Login.SelectRoleLayer") },         --选择创建角色
    SCENE_STARTSCENE                   = { name = "SCENE_STARTSCENE",                  view = require("app.views.myStartScene") },                    --开场动画
    SCENE_ASSETS                       = { name = "SCENE_ASSETS",                      view = require("app.views.Assets.UpdateUILayer")},
        
    --建议不切换Scene的，直接添加到当前Scene上
    SCENE_STAGEMAPLAYER                = { name = "SCENE_STAGEMAPLAYER",               view = require("app.views.StageMap.StageMapLayer") },        --剧情地图
    SCENE_TOWNLAYER                    = { name = "SCENE_TOWNLAYER",                   view = require("app.views.StageMap.TownInterfaceLayer") },   --城镇界面
    SCENE_EXPLORELAYER                 = { name = "SCENE_EXPLORELAYER",                view = require("app.views.Explore.ExploreLayer") },          --探索地图
    SCENE_WORLDMAPLAYER                = { name = "SCENE_WORLDMAPLAYER",               view = require("app.views.Main.WorldMapLayer") },            --世界地图
    
    SCENE_MYFIGHTLAYER                 = { name = "SCENE_MYFIGHTLAYER",                view = require("app.views.MyFighting.MyFightingLayer")},     --新战斗界面
    SCENE_PLOT                         = { name = "SCENE_PLOT",                        view = require("app.views.Plot.PlotLayer")},                 --剧情对话界面
    SCENE_BAG                          = { name = "SCENE_BAG",                         view = require("app.views.Bag.BagLayer")},                   --背包
    
    SCENE_TASKLIST                     = { name = "SCENE_TASKLIST",                    view = require("app.views.Task.TaskDetailInfoLayer") },      --已接任务列表
    SCENE_FLYTECHTREE                  = { name = "SCENE_FLYTECHTREE",                 view = require("app.views.FlyTechTree.FlyTechTreeLayer") },  --飞宝界面
   
    SCENE_TRANSPORT                    = { name = "SCENE_TRANSPORT",                   view = require("app.views.Transport.TransportLayer")},       --运镖
    SCENE_AREAN                        = { name = "SCENE_AREAN",                       view = require("app.views.Arean.AreanLayer")},               --排行榜
   
    --不确定是否使用的
    SCENE_PVE                          = { name = "SCENE_PVE",                         view = require("app.views.Pve.CopyVolumeLayer")},            --副本章节选择
    
}


function SceneManager:switch(sceneInfo, zOrder)
    
    if sceneInfo == nil then
        return
    end
    local order = 0
    if zOrder ~= nil then
        order = zOrder
    end
    
    local layer = nil
    local pDirector = cc.Director:getInstance()
    local sceneView = sceneInfo.view
    if sceneView.create then
        layer = sceneView:create()
    else
        layer = sceneView.new()
        cclog("there is no create() function in :" .. sceneInfo.name)
    end
    
    cclog("SceneManager:switch, sceneInfo.name =" .. sceneInfo.name)
    if "SCENE_LOGIN" == sceneInfo.name or               --登陆
        "SCENE_SELECTADDRSEVER" == sceneInfo.name or    --选服
        "SCENE_SELECTROLE" == sceneInfo.name or         --选择创建角色
        "SCENE_STARTSCENE" == sceneInfo.name then         --开场动画

        local scene = cc.Scene:create()
        if scene.__cname == nil then
            scene.__cname = "current_root_scene"
        end
        scene:addChild(layer, order)
        
        if self.gameSceneRoot ~= nil then
            if self.gameSceneRoot:getParent() ~= nil then
                self.gameSceneRoot:removeFromParent()
            end
        end
        self.gameSceneRoot = nil
        pDirector:replaceScene(cc.TransitionFade:create(self.changeSceneDelayTime, scene, cc.c3b(255,255,255)))
        
    else
--        if    
--        "SCENE_STAGEMAPLAYER" == sceneInfo.name or      --剧情地图
--        "SCENE_TOWNLAYER" == sceneInfo.name or          --城镇界面
--        "SCENE_WORLDMAPLAYER" == sceneInfo.name or      --世界地图
--        "SCENE_EXPLORELAYER" == sceneInfo.name then     --探索地图

        local needReplaceScene = false
        if self.gameSceneRoot == nil then
            self.gameSceneRoot = cc.Scene:create()
            self.gameSceneRoot.__cname = "gameSceneRoot"
            needReplaceScene = true
        end
        
        if layer.__cname ~= nil and layer.__cname ~= "" then
            layer:setName(layer.__cname)
            if self.gameSceneRoot.getChildByName ~= nil and self.gameSceneRoot:getChildByName(layer.__cname) ~= nil then
                self.gameSceneRoot:removeChildByName(layer.__cname)
            end
            self.gameSceneRoot:addChild(layer, order)
        else
            cclog("layer.__cname is nil ")
            self.gameSceneRoot:addChild(layer, order)
        end
        
        self.currentLayer = layer
        if needReplaceScene then
            pDirector:replaceScene(cc.TransitionFade:create(self.changeSceneDelayTime, self.gameSceneRoot, cc.c3b(255,255,255)))
        end

    end
end

function SceneManager:getCurrentLayerName()
    return (self.currentLayer ~= nil) and self.currentLayer.__cname or "unknown"
end

function SceneManager:getGameSceneRoot()
    return self.gameSceneRoot
end

function SceneManager:getGameLayer(layerName)
    if self.gameSceneRoot == nil then
        return nil
    end
    
    if layerName ~= nil and layerName ~= "" then
        return self.gameSceneRoot:getChildByName(layerName)
    end
    return nil
end

function SceneManager:addToGameScene(layer,zOrder)
    if self.gameSceneRoot == nil then
        self.gameSceneRoot = cc.Scene:create()
        self.gameSceneRoot.__cname = "gameSceneRoot"
    end
    zOrder = zOrder == nil and 0 or zOrder
    if layer.__cname ~= nil and layer.__cname ~= "" then
        layer:setName(layer.__cname)
        if self.gameSceneRoot:getChildByName(layer.__cname) ~= nil then
            self.gameSceneRoot:removeChildByName(layer.__cname)
        end
        self.gameSceneRoot:addChild(layer, zOrder)
        
    else
        cclog("layer.__cname is nil ")
        self.gameSceneRoot:addChild(layer,zOrder)
    end
end

--删除gameSceneRoot的layerName子节点，如果reverse为true，则删除layerName以外的其他子节点
function SceneManager:removeChildLayer(layerName,reverse)
    if layerName == nil or layerName == "" then
        return
    end
    
    local goalLayerName = layerName
    local childLayer = self.gameSceneRoot:getChildren()
    for i = 1, #childLayer do
        if childLayer[i] ~= nil then
            local curLayerName = childLayer[i].__cname
            if reverse ~= nil and reverse == true then
                if curLayerName ~= goalLayerName and curLayerName ~= nil then
                    self.gameSceneRoot:removeChildByName(childLayer[i].__cname)
                end
            else
                if curLayerName == goalLayerName then
                    self.gameSceneRoot:removeChildByName(childLayer[i].__cname)
                end
            end
        end
    end
end


return SceneManager

