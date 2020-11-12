//
//  StreakSprite.h
//  GameClient
//
//  Created by apple01 on 15/9/14.
//
//

#ifndef __GameClient__StreakSprite__
#define __GameClient__StreakSprite__

#include "cocos2d.h"

using namespace cocos2d;

class StreakSprite : public Node, public TextureProtocol
{
public:
    /** creates and initializes a motion streak with fade in seconds, minimum segments, stroke's width, color, texture filename */
    static StreakSprite* create(float fade, float minSeg, float stroke, const Color3B& color, const std::string& path);
    /** creates and initializes a motion streak with fade in seconds, minimum segments, stroke's width, color, texture */
    static StreakSprite* create(float fade, float minSeg, float stroke, const Color3B& color, Texture2D* texture);
    
    /** color used for the tint */
    void tintWithColor(const Color3B& colors);
    
    /** Remove all living segments of the ribbon */
    void reset();
    
    /** When fast mode is enabled, new points are added faster but with lower precision */
    inline bool isFastMode() const { return _fastMode; }
    inline void setFastMode(bool bFastMode) { _fastMode = bFastMode; }
    
    inline bool isStartingPositionInitialized() const { return _startingPositionInitialized; }
    inline void setStartingPositionInitialized(bool bStartingPositionInitialized)
    {
        _startingPositionInitialized = bStartingPositionInitialized;
    }
    
    // Overrides
    virtual void setPosition(const Vec2& position) override;
    virtual void setPosition(float x, float y) override;
    virtual const Vec2& getPosition() const override;
    virtual void getPosition(float* x, float* y) const override;
    virtual void setPositionX(float x) override;
    virtual void setPositionY(float y) override;
    virtual float getPositionX(void) const override;
    virtual float getPositionY(void) const override;
    /**
     * @js NA
     * @lua NA
     */
    virtual void draw(Renderer *renderer, const Mat4 &transform, uint32_t flags) override;
    /**
     * @js NA
     * @lua NA
     */
    virtual void update(float delta) override;
    virtual Texture2D* getTexture() const override;
    virtual void setTexture(Texture2D *texture) override;
    /**
     * @js NA
     * @lua NA
     */
    virtual void setBlendFunc(const BlendFunc &blendFunc) override;
    /**
     * @js NA
     * @lua NA
     */
    virtual const BlendFunc& getBlendFunc() const override;
    virtual GLubyte getOpacity() const override;
    virtual void setOpacity(GLubyte opacity) override;
    virtual void setOpacityModifyRGB(bool value) override;
    virtual bool isOpacityModifyRGB() const override;
    
CC_CONSTRUCTOR_ACCESS:
    StreakSprite();
    virtual ~StreakSprite();
    
    /** initializes a motion streak with fade in seconds, minimum segments, stroke's width, color and texture filename */
    bool initWithFade(float fade, float minSeg, float stroke, const Color3B& color, const std::string& path);
    
    /** initializes a motion streak with fade in seconds, minimum segments, stroke's width, color and texture  */
    bool initWithFade(float fade, float minSeg, float stroke, const Color3B& color, Texture2D* texture);
    
protected:
    //renderer callback
    void onDraw(const Mat4 &transform, uint32_t flags);
    
    bool _fastMode;
    bool _startingPositionInitialized;
    
    /** texture used for the motion streak */
    Texture2D* _texture;
    BlendFunc _blendFunc;
    Vec2 _positionR;
    
    float _stroke;
    float _fadeDelta;
    float _minSeg;
    
    unsigned int _maxPoints;
    unsigned int _nuPoints;
    unsigned int _previousNuPoints;
    
    /** Pointers */
    Vec2* _pointVertexes;
    float* _pointState;
    
    // Opengl
    Vec2* _vertices;
    GLubyte* _colorPointer;
    Tex2F* _texCoords;
    
    CustomCommand _customCommand;
    
    float _texHeight;
    
private:
    CC_DISALLOW_COPY_AND_ASSIGN(StreakSprite);
};

#endif /* defined(__GameClient__StreakSprite__) */
