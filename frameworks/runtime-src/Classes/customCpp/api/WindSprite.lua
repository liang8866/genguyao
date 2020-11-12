
--------------------------------
-- @module WindSprite
-- @extend Sprite,TextureProtocol
-- @parent_module cus

--------------------------------
--  Remove all living segments of the ribbon 
-- @function [parent=#WindSprite] reset 
-- @param self
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
--  color used for the tint 
-- @function [parent=#WindSprite] tintWithColor 
-- @param self
-- @param #color3b_table colors
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setPause 
-- @param self
-- @param #bool pause
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setStartingPositionInitialized 
-- @param self
-- @param #bool bStartingPositionInitialized
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] isStartingPositionInitialized 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
--  When fast mode is enabled, new points are added faster but with lower precision 
-- @function [parent=#WindSprite] isFastMode 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setFastMode 
-- @param self
-- @param #bool bFastMode
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- @overload self, cc.Texture2D         
-- @overload self, string         
-- @function [parent=#WindSprite] create
-- @param self
-- @param #string path
-- @return WindSprite#WindSprite ret (return value: WindSprite)

--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#WindSprite] draw 
-- @param self
-- @param #cc.Renderer renderer
-- @param #mat4_table transform
-- @param #unsigned int flags
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setTexture 
-- @param self
-- @param #cc.Texture2D texture
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] isOpacityModifyRGB 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setPositionY 
-- @param self
-- @param #float y
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setPositionX 
-- @param self
-- @param #float x
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] getTexture 
-- @param self
-- @return Texture2D#Texture2D ret (return value: cc.Texture2D)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] getPositionY 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] getPositionX 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#WindSprite] update 
-- @param self
-- @param #float delta
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setOpacity 
-- @param self
-- @param #unsigned char opacity
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#WindSprite] getBlendFunc 
-- @param self
-- @return BlendFunc#BlendFunc ret (return value: cc.BlendFunc)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] setOpacityModifyRGB 
-- @param self
-- @param #bool value
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- 
-- @function [parent=#WindSprite] getOpacity 
-- @param self
-- @return unsigned char#unsigned char ret (return value: unsigned char)
        
--------------------------------
-- @overload self, float, float         
-- @overload self, vec2_table         
-- @function [parent=#WindSprite] setPosition
-- @param self
-- @param #float x
-- @param #float y
-- @return WindSprite#WindSprite self (return value: WindSprite)

--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#WindSprite] setBlendFunc 
-- @param self
-- @param #cc.BlendFunc blendFunc
-- @return WindSprite#WindSprite self (return value: WindSprite)
        
--------------------------------
-- @overload self, float, float         
-- @overload self         
-- @function [parent=#WindSprite] getPosition
-- @param self
-- @param #float x
-- @param #float y
-- @return WindSprite#WindSprite self (return value: WindSprite)

return nil
