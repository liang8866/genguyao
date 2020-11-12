local View = class("View", cc.Node)

function View:ctor()
    
   local function onEvent(event)
        if event == "enter" then
            if self.onEnter then
                self:onEnter()
            end
        elseif event == "exit" then
            if self.onExit then
                self:onExit()
            end
        end
   end 
    
   if self.onEnter or self.onExit then
        self:registerScriptHandler(onEvent)
   end
    
   if self.onCreate then self:onCreate() end 

end

function View:createResoueceNode(resourceFilename)
    
    local resourceNode = cc.CSLoader:createNode(resourceFilename)
    assert(resourceNode, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(resourceNode)
    return resourceNode
    
end


function View:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    
    local resourceNode = self.resourceNode_
    
    for nodeName, nodeBinding in pairs(binding) do
        local node = resourceNode:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

return View