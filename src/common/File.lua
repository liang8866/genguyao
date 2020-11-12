local string = require("string")
local io = require("io")

local File = {
        writePath = nil
    }
 
function File:getWritePath() 
    if nil == File.writePath then
        File.writePath = cc.FileUtils:getInstance():getWritablePath()..'ws_game/'
    end    
    cclogDebug("write_path = %s",File.writePath ) 
    return File.writePath
end 

function File:getFullWriteFilename( filename )      
    return filename and File:getWritePath() .. filename or nil
end 

function File:getUserPath()
    return File:getWritePath()..'_user_/'
end

function File:getFullUserFilename( filename )
    return filename and File:getUserPath() .. filename or nil
end 
  
function File:exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function File:readFile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function File:writeFile(path, content, mode)
    --assert(path)
    mode = mode or "w+b"
    local ret = false 
    local file = io.open(path, mode)
    if file then
        if file:write(content) ~= nil then 
            ret =  true
        end
        io.close(file)
    end
    
    return ret ;
end
--写缓存(二进制数据)
function File:writeByte(filename,data)
    return File:writeFile(filename,data,"wb")
end
-- 获得文件内容，如文件不存在，返回nil
function File:getFileContent( filename )
    local file,err = io.open( filename )

    local content = nil
    if file then
        content = file:read( '*a' )
        file:close()
    end

    return content
end

function File:delFile( filename )
    os.remove( filename )
end

--    return {
--        dirname = dirname,
--        filename = filename,
--        basename = basename,
--        extname = extname
--    }
function File:pathInfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function File:filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end


    



function File:getUserString( sKey, sDefault )
    local gUserData = cc.UserDefault:getInstance()  
    local str = gUserData:getStringForKey( sKey )
    if str == '' then
        str = sDefault
    end
    return str
end

function File:setUserString( sKey, sValue )
    local gUserData = cc.UserDefault:getInstance()  
    local sResult = gUserData:setStringForKey( sKey, sValue )
    gUserData:flush()
    return sResult
end
        
--[[
比对文件是否失效
参数：
filename：完整文件名
second：秒
]]
--[[
function File:isFileExpires( filename, second )
    local curTime = tonumber(xymodule.get_curTime())

    local c,m,a = getFiletime( filename )

    return (curTime - a) > tonumber(second)
end 
]]--



--修改后缀名
--function File:ModifySuffix(filename,suffix)
--    local str = string.reverse(filename)
--    local index = string.find(str,'%p')
--    if not index then 
--        local i = 0
--    end
--    local str3 = string.sub(str,index + 1,string.len(str))
--    return string.reverse(str3)..suffix 
--end

--[[
--获取字符串md5
function GetMD5(str)
    return c_md5encrypt(str)
end

--获取文件md5
function GetFileMD5(file)
    return xymodule.get_filemd5(file)
end
]]--

----获取cache路径
--function File:GetCachePath()
--    local cachepath = File:getWritePath()..'cache/'
--    return cachepath
--end
--
----保存cache内容
--function File:saveCache( name, data )
--    File:writeByte( File:GetCachePath() .. name,data )
--end
--
----设置cache过期
--function File:setCacheExpires( name )
--    File:writeByte( File:GetCachePath() .. name .. '.expires', '' )
--end

--检查cache是否过期，返回true为过期，false为未过期
--[[
function isCacheExpires( name, TTL )
    if getFileContent( GetCachePath() .. name .. '.expires' ) then
        return true
    end

    if not isFileExists(GetCachePath() .. name) then
        return true
    end
    local curTime = tonumber(xymodule.get_curTime())
    local aTime = tonumber(xymodule.get_atime(GetCachePath() .. name))
    if (curTime - aTime) <= tonumber(TTL) then
        return false
    end

    return true
end
]]--

----返回cache内容，如存在返回nil
--function File:getCache( name )
--    return File:getFileContent( File:GetCachePath() .. name )
--end
--
----删除cache
--function File:delCache( name )
--    File:delFile( File:GetCachePath() .. name )
--    File:delFile( File:GetCachePath() .. name .. '.expires' )
--end
--
----获取data路径
--function File:getDataFilename( name )
--    return File:getWritePath().. 'temp/' .. name
--end

--[===[
function writeData( section, json )
    local filename = getDataFilename( section )
    writeByte( filename, table2json( json ) )
end

--[[
删除整个data文件
]]
function delData( section )
    local filename = getDataFilename( section )

    delFile( filename )
end
]===]--

--[[
设置data的key
]]
--[[
function File:setData( section, key, value )
    local filename = File:getDataFilename( section )

    local data = File:getData( section )
    if not data then 
        data = {}
    end
    data[ key ] = value

    local content = table2json(data)
    File:writeByte( filename, content )
end
]]--
--返回data(json结构)，如不存在返回nil
--[[
function File:getData( section )
    local filename = nil
    filename = File:getDataFilename( section )
    content = File:getFileContent( filename )

    return content and json.decode( content ) or nil
end
]]--



return File