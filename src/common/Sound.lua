local File = require("common.File")

local Sound = {}

-- 播放背景音乐
function Sound:playBGMusic( file, ms )
    file = File:getResFilename( file )

    local function stopMp3()
        SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
    end
    if File:isFileExists(file) == true then
        if File:getUserString( 'sound','1' ) ~= '0' then 
            --SimpleAudioEngine:sharedEngine():playBackgroundMusic( file)
            SimpleAudioEngine:sharedEngine():playBackgroundMusic( file, true)       
        end
    end
end

function Sound:preLoadBGMusic( file )
    --if CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid then
    file = File:getResFilename( file )   
    if File:isFileExists(file) == true then
        if File:getUserString( 'sound','1' ) ~= '0' then     
            SimpleAudioEngine:sharedEngine():preloadBackgroundMusic( file)  
        end 
    end
end

-- 播放音效
function Sound:playEffect( file, ms )
    file = File:getResFilename( file )

    local effectID = nil
    local function stopWav()
        SimpleAudioEngine:sharedEngine():stopEffect(effectID)
    end
    if File:isFileExists(file) == true then
        if File:getUserString( 'sound','1' ) ~= '0' then 
            effectID = SimpleAudioEngine:sharedEngine():playEffect( file )      
        end
    end
    return effectID
end
        
function Sound:preLoadEffect(file)
    file = File:getResFilename( file )
    if File:isFileExists(file) == true then  
        if File:getUserString( 'sound','1' ) ~= '0' then 
            SimpleAudioEngine:sharedEngine():preloadEffect( file )      
        end 
    end     
end

return Sound