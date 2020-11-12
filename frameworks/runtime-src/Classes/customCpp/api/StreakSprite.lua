
--------------------------------
-- @module StreakSprite
-- @extend Node,TextureProtocol
-- @parent_module cus

--------------------------------
--  Remove all living segments of the ribbon 
-- @function [parent=#StreakSprite] reset 
-- @param self
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setTexture 
-- @param self
-- @param #cc.Texture2D texture
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] getTexture 
-- @param self
-- @return Texture2D#Texture2D ret (return value: cc.Texture2D)
        
--------------------------------
--  color used for the tint 
-- @function [parent=#StreakSprite] tintWithColor 
-- @param self
-- @param #color3b_table colors
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#StreakSprite] setBlendFunc 
-- @param self
-- @param #cc.BlendFunc blendFunc
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setStartingPositionInitialized 
-- @param self
-- @param #bool bStartingPositionInitialized
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#StreakSprite] getBlendFunc 
-- @param self
-- @return BlendFunc#BlendFunc ret (return value: cc.BlendFunc)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] isStartingPositionInitialized 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
--  When fast mode is enabled, new points are added faster but with lower precision 
-- @function [parent=#StreakSprite] isFastMode 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setFastMode 
-- @param self
-- @param #bool bFastMode
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- @overload self, float, float, float, color3b_table, cc.Texture2D         
-- @overload self, float, float, float, color3b_table, string         
-- @function [parent=#StreakSprite] create
-- @param self
-- @param #float fade
-- @param #float minSeg
-- @param #float stroke
-- @param #color3b_table color
-- @param #string path
-- @return StreakSprite#StreakSprite ret (return value: StreakSprite)

--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#StreakSprite] draw 
-- @param self
-- @param #cc.Renderer renderer
-- @param #mat4_table transform
-- @param #unsigned int flags
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] isOpacityModifyRGB 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setPositionY 
-- @param self
-- @param #float y
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setPositionX 
-- @param self
-- @param #float x
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] getPositionY 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] getPositionX 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- js NA<br>
-- lua NA
-- @function [parent=#StreakSprite] update 
-- @param self
-- @param #float delta
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setOpacity 
-- @param self
-- @param #unsigned char opacity
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] setOpacityModifyRGB 
-- @param self
-- @param #bool value
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)
        
--------------------------------
-- 
-- @function [parent=#StreakSprite] getOpacity 
-- @param self
-- @return unsigned char#unsigned char ret (return value: unsigned char)
        
--------------------------------
-- @overload self, float, float         
-- @overload self, vec2_table         
-- @function [parent=#StreakSprite] setPosition
-- @param self
-- @param #float x
-- @param #float y
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)

--------------------------------
-- @overload self, float, float         
-- @overload self         
-- @function [parent=#StreakSprite] getPosition
-- @param self
-- @param #float x
-- @param #float y
-- @return StreakSprite#StreakSprite self (return value: StreakSprite)

return nil
