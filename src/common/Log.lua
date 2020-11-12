
-------------为了方便C++网络部分也可以调用， 下面两个函数从main.lua移到了这里 ----
-- cclog
cclog = function(...)
    print(string.format(...))
end

if  __print__ == nil then
    __print__ = print ;
    print = function(...)
        __print__(...)
    end
end

--正式发布时可以为空接口。
cclogDebug = function(...)
    print(string.format(...))
end
--正式发布时可以为空接口。
printDebug = function(...)
    print(...)
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

-------------为了方便C++网络部分也可以调用， 上面两个函数从main.lua移到了这里 ----
