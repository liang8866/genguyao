
local stringEx =  require("common.stringEx")


local FlyFunction = {
    tempMySkillIdTable = {},
    tempMyGodIdTable = {},
}

function FlyFunction:getFlyGodIdTable(nFibbleId)
    FlyFunction.tempMyGodIdTable = {}
    local  data = UserData.Fibble.fibbleTable[nFibbleId]
 
    FlyFunction.tempMyGodIdTable = {data[1].nGodId1,data[1].nGodId2,data[1].nGodId3,data[1].nGodId4,data[1].nGodId5}
   
end

--设置按钮灰色
function FlyFunction:setButtonGray(btn)
    btn:setTouchEnabled(false)
    local image_type = btn:getChildByName("image_type") -- 那个类别的，仙，人，妖
    local Image_flyicon = btn:getChildByName("Image_flyicon") --飞宝图标
    local Text_name = btn:getChildByName("Text_name") -- 飞宝名字
    image_type:setColor(cc.c3b(130,130,130))
    Image_flyicon:setColor(cc.c3b(130,130,130))
    Text_name:setColor(cc.c3b(130,130,130))
end
--设置按钮正常
function FlyFunction:setButtonNarmal(btn)
    btn:setTouchEnabled(true)
    local image_type = btn:getChildByName("image_type") -- 那个类别的，仙，人，妖
    local Image_flyicon = btn:getChildByName("Image_flyicon") --飞宝图标
    local Text_name = btn:getChildByName("Text_name") -- 飞宝名字
    image_type:setColor(cc.c3b(255,255,255))
    Image_flyicon:setColor(cc.c3b(255,255,255))
    Text_name:setColor(cc.c3b(255,255,255))
    
end



-- 参数：传人一个表
-- 功能：根据ID从小到大排序
function FlyFunction:sortTableById(t)
    table.sort(t,function(a,b) 
        return a.id < b.id
    end)
    return t
end

-- 参数：传人飞宝Id
-- 功能：检查飞宝是否已经创建出来了
function FlyFunction:checkFibbleIsHave(nFibbleId)
    local flag = false
    for key, var in pairs(UserData.Fibble.fibbleTable) do
        if key == nFibbleId then
			flag = true
		 	break
		end
	end
	return flag
end

-- 参数：传人法宝ID
-- 功能：检查飞宝是否可以点亮 需要检查等级，前置条件等级和开启的飞宝
function FlyFunction:checkFibbleEnable(nFibbleId)
    local flag = true -- 默认是可以点亮 
    local fibbleUpData = self:findFibbleUpForSameIdAndStar(nFibbleId,0) -- 可以创建的只需要显示的是一星的就行了
    if UserData.BaseInfo.userLevel >= fibbleUpData.preLv  and fibbleUpData.preFlyID ~= "0" then
        local tempTable = stringEx:split(fibbleUpData.preFlyID,"|")
        for key, var in pairs(tempTable) do
            local f = self:checkFibbleIsHave(tonumber(var))
        	if f == false then -- 如果有一个条件不符合 就不能点亮
                flag = false
                break
        	end
        end
    elseif UserData.BaseInfo.userLevel < fibbleUpData.preLv then -- 如果等级低于的话也不能点亮
         flag = false
    end 
    
    
    return flag
    
end


-- 参数：传入飞宝ID
-- 功能：检查飞宝是否可以创建 需要检查飞宝的材料是否足够和前置条件是否符合

function FlyFunction:checkFibbleCreate(nFibbleId)
    local flag =  true
   
    local fibbleUpData = self:findFibbleUpForSameIdAndStar(nFibbleId,0) -- 可以创建的只需要显示的是一星的就行了
    local f1 = self:checkFibbleEnable(nFibbleId) -- 先检查是否点亮了
    local f2 = self:checkFibbleIsHave(nFibbleId) -- 已经拥有了的就不创建  
    if f1 == true and f2 == false then  -- 要点亮才行
        local materialTable = self:splitNeedMaterial(fibbleUpData.cID)
        for key, var in pairs(materialTable) do
            if self:checkFibbleCaiLiaoIsOk(var) == false then --如果材料有一个不满足的话，没有用
                flag = false
        	end
        end
    else               -- 否则不行
        flag = false
    end
  
    return flag
end

-- 参数：飞宝ID，飞宝星级
-- 功能：检查飞宝是否可以强化，这个情况下 肯定是创建了的
function FlyFunction:checkFibbleStreng(nFibbleId,star)
    local flag =  true
   
    
    local fibbleUpData = self:findFibbleUpForSameIdAndStar(nFibbleId,star)
    local materialTable = self:splitNeedMaterial(fibbleUpData.cID)
    for key, var in pairs(materialTable) do
        if self:checkFibbleCaiLiaoIsOk(var) == false then --如果材料有一个不满足的话，没有用
            flag = false
        end
    end
    return flag
end



-- 参数：飞宝ID
-- 功能：返回飞宝的前置飞宝ID
function FlyFunction:getStartPreFlyID(nFibbleId)
    local fibbleUpData = self:findFibbleUpForSameIdAndStar(nFibbleId,0)
    local tempTable = stringEx:split(fibbleUpData.preFlyID,"|")
  
    return tempTable
end


-- 参数:传入材料字符串
-- 功能：解析出字符串 返回个table
function FlyFunction:splitNeedMaterial(str)
    local needTable = {}
    local tempTable = stringEx:split(str,"|")
    for var=1, #tempTable do
        local t = stringEx:split(tempTable[var],"-")
        local item = {}
        item.id = tonumber(t[1]) 
        item.num = tonumber(t[2])
        needTable[var] = item 
    end
    return needTable
end


-- 参数：传入的是材料ID
-- 功能：检查材料是否满足，返回false 或者true
function FlyFunction:checkFibbleCaiLiaoIsOk(item)
    local flag = false
    local num = UserData.Bag.items[item.id]
    if num then
        if num >= item.num then
            flag = true
        end
    end
    return flag 
end


-- 参数：ID，星级
-- 功能: 查找当前法宝所需的数据，返回一个对应的一个表
function FlyFunction:findFibbleUpForSameIdAndStar(nFibbleId,star)
    local t = nil
    
    for key, var in pairs(FightStaticData.FibbleUP) do
        if var.id == nFibbleId  and star == var.star then
			t = var
			break
		end
	end
	return t
end

-- 参数：飞宝ID ，星级
-- 功能：返回对应的所需材料表
function FlyFunction:finFibbleNeedMaterial(nFibbleId,star)
	local myData = self:findFibbleUpForSameIdAndStar(nFibbleId,star)
    return self:splitNeedMaterial(myData.cID)
end


-- 参数：传人飞宝ID
-- 功能：查询某一个ID的所有数据
function FlyFunction:FibbleUpForSameId(nFibbleId)
    local t = {}
    for key, var in pairs(FightStaticData.FibbleUP) do
        if var.id == nFibbleId  then
            table.insert(t,var)
        end
    end
   local temp = self:sortTableById(t)
    return temp
end


-- 参数：传入节点
-- 功能：设置没选中状态

function FlyFunction:setSkillSelect(btn)

    local skillNodePanel = btn:getParent()
    local skillBtn = btn
    skillBtn:setTouchEnabled(false)
    local selectSkill = skillNodePanel:getChildByName("selectSkill")
    local selectNoSkill = skillNodePanel:getChildByName("normalSkill")
    
    selectSkill:setVisible(true)
    selectNoSkill:setVisible(false)
    skillBtn:setColor(cc.c3b(130,130,130))
end

-- 参数：传入一个按钮
-- 功能：设置没选中状态

function FlyFunction:setSkillNoSelect(btn)

    local skillNodePanel = btn:getParent()
    local skillBtn = btn
    skillBtn:setTouchEnabled(true)
    local selectSkill = skillNodePanel:getChildByName("selectSkill")
    local selectNoSkill = skillNodePanel:getChildByName("normalSkill")

    selectSkill:setVisible(false)
    selectNoSkill:setVisible(true)
    skillBtn:setColor(cc.c3b(255,255,255))
end

--删除表
function FlyFunction:tableRemoveForId(t,id)
    for key, var in pairs(t) do
        if var == id then
            table.remove(t,key)
        end
    end
end


-- 参数：传入神将的一个按钮 
-- 功能：设置神将节点为选中状态

function FlyFunction:setGodSelect(godBtn)
    godBtn:setTouchEnabled(false)
    local nodePanel = godBtn:getParent()
    nodePanel:setColor(cc.c3b(130,130,130))
end

-- 参数：传入神将的一个按钮 
-- 功能：设置神将节点为不选中状态

function FlyFunction:setGodNoSelect(godBtn)
    godBtn:setTouchEnabled(true)
    local nodePanel = godBtn:getParent()
    nodePanel:setColor(cc.c3b(255,255,255))
end


return FlyFunction