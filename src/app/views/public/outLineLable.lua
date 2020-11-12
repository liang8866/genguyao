local outLineLable = {


}

function outLineLable:setTtfConfig(fontSize,outLineSize,fontColor,outLineColor)
	self.ttfConfig = {}
    self.ttfConfig.fontFilePath = "font/FangZhengJianYuan.ttf"
    self.ttfConfig.fontSize = fontSize
    self.ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    self.ttfConfig.customGlyphs = nil
    self.ttfConfig.distanceFieldEnabled = true
    self.ttfConfig.outlineSize = outLineSize
    self.fontColor = fontColor
    self.outLineColor = outLineColor 
end

function outLineLable:setTexOutLine(text)
   
    local fontColor,outLineColor
    if self.fontColor ~= nil then
    	fontColor = cc.c4b(self.fontColor.r,self.fontColor.g,self.fontColor.b,self.fontColor.a)
    else
        fontColor =  cc.c4b(255, 255, 255, 255)
    end 
    if self.outLineColor ~= nil then
        outLineColor = cc.c4b(self.outLineColor.r,self.outLineColor.g,self.outLineColor.b,self.outLineColor.a)
    else
        outLineColor =  cc.c4b(38,41,100,255)
    end     
    text:setVisible(false)
    local textParent = text:getParent()
    local label1 = cc.Label:createWithTTF(self.ttfConfig,text:getString(),cc.TEXT_ALIGNMENT_CENTER,120)
    label1:setPosition(cc.p(text:getPosition()))
    label1:setTextColor( fontColor)
    label1:setAnchorPoint(text:getAnchorPoint())
    label1:enableOutline(outLineColor)
    textParent:addChild(label1)
    
    return label1
end


return outLineLable