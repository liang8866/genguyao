//
//  StreakSprite.cpp
//  GameClient
//
//  Created by apple01 on 15/9/14.
//
//

#include "StreakSprite.h"

StreakSprite::StreakSprite()
: _fastMode(false)
, _startingPositionInitialized(false)
, _texture(nullptr)
, _blendFunc(BlendFunc::ALPHA_NON_PREMULTIPLIED)
, _positionR(Vec2::ZERO)
, _stroke(0.0f)
, _fadeDelta(0.0f)
, _minSeg(0.0f)
, _maxPoints(0)
, _nuPoints(0)
, _previousNuPoints(0)
, _pointVertexes(nullptr)
, _pointState(nullptr)
, _vertices(nullptr)
, _colorPointer(nullptr)
, _texCoords(nullptr)
{
}

StreakSprite::~StreakSprite()
{
    CC_SAFE_RELEASE(_texture);
    CC_SAFE_FREE(_pointState);
    CC_SAFE_FREE(_pointVertexes);
    CC_SAFE_FREE(_vertices);
    CC_SAFE_FREE(_colorPointer);
    CC_SAFE_FREE(_texCoords);
}

StreakSprite* StreakSprite::create(float fade, float minSeg, float stroke, const Color3B& color, const std::string& path)
{
    StreakSprite *ret = new (std::nothrow) StreakSprite();
    if (ret && ret->initWithFade(fade, minSeg, stroke, color, path))
    {
        ret->autorelease();
        return ret;
    }
    
    CC_SAFE_DELETE(ret);
    return nullptr;
}

StreakSprite* StreakSprite::create(float fade, float minSeg, float stroke, const Color3B& color, Texture2D* texture)
{
    StreakSprite *ret = new (std::nothrow) StreakSprite();
    if (ret && ret->initWithFade(fade, minSeg, stroke, color, texture))
    {
        ret->autorelease();
        return ret;
    }
    
    CC_SAFE_DELETE(ret);
    return nullptr;
}

bool StreakSprite::initWithFade(float fade, float minSeg, float stroke, const Color3B& color, const std::string& path)
{
    CCASSERT(!path.empty(), "Invalid filename");
    
    Texture2D *texture = Director::getInstance()->getTextureCache()->addImage(path);
    texture->setTexParameters(Texture2D::TexParams{GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT});
    return initWithFade(fade, minSeg, stroke, color, texture);
}

bool StreakSprite::initWithFade(float fade, float minSeg, float stroke, const Color3B& color, Texture2D* texture)
{
    Node::setPosition(Vec2::ZERO);
    setAnchorPoint(Vec2::ZERO);
    ignoreAnchorPointForPosition(true);
    _startingPositionInitialized = false;
    
    _positionR = Vec2::ZERO;
    _fastMode = true;
    _minSeg = (minSeg == -1.0f) ? stroke/5.0f : minSeg;
    _minSeg *= _minSeg;
    
    _stroke = stroke;
    _fadeDelta = 1.0f/fade;
    
    _maxPoints = (int)(fade*60.0f)+2;
    _nuPoints = 0;
    _pointState = (float *)malloc(sizeof(float) * _maxPoints);
    _pointVertexes = (Vec2*)malloc(sizeof(Vec2) * _maxPoints);
    
    _vertices = (Vec2*)malloc(sizeof(Vec2) * _maxPoints * 2);
    _texCoords = (Tex2F*)malloc(sizeof(Tex2F) * _maxPoints * 2);
    _colorPointer =  (GLubyte*)malloc(sizeof(GLubyte) * _maxPoints * 2 * 4);
    
    // Set blend mode
    _blendFunc = BlendFunc::ALPHA_NON_PREMULTIPLIED;
    
    // shader state
    setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR));
    
    setTexture(texture);
    setColor(color);
    scheduleUpdate();
    
    _texHeight = texture->getPixelsHigh();
    
    return true;
}

void StreakSprite::setPosition(const Vec2& position)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR = position;
}

void StreakSprite::setPosition(float x, float y)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.x = x;
    _positionR.y = y;
}

const Vec2& StreakSprite::getPosition() const
{
    return _positionR;
}

void StreakSprite::getPosition(float* x, float* y) const
{
    *x = _positionR.x;
    *y = _positionR.y;
}

float StreakSprite::getPositionX() const
{
    return _positionR.x;
}

void StreakSprite::setPositionX(float x)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.x = x;
}

float StreakSprite::getPositionY() const
{
    return  _positionR.y;
}

void StreakSprite::setPositionY(float y)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.y = y;
}

void StreakSprite::tintWithColor(const Color3B& colors)
{
    setColor(colors);
    
    // Fast assignation
    for(unsigned int i = 0; i<_nuPoints*2; i++)
    {
        *((Color3B*) (_colorPointer+i*4)) = colors;
    }
}

Texture2D* StreakSprite::getTexture(void) const
{
    return _texture;
}

void StreakSprite::setTexture(Texture2D *texture)
{
    if (_texture != texture)
    {
        CC_SAFE_RETAIN(texture);
        CC_SAFE_RELEASE(_texture);
        _texture = texture;
    }
}

void StreakSprite::setBlendFunc(const BlendFunc &blendFunc)
{
    _blendFunc = blendFunc;
}

const BlendFunc& StreakSprite::getBlendFunc(void) const
{
    return _blendFunc;
}

void StreakSprite::setOpacity(GLubyte opacity)
{
    CCASSERT(false, "Set opacity no supported");
}

GLubyte StreakSprite::getOpacity(void) const
{
    CCASSERT(false, "Opacity no supported");
    return 0;
}

void StreakSprite::setOpacityModifyRGB(bool bValue)
{
    CC_UNUSED_PARAM(bValue);
}

bool StreakSprite::isOpacityModifyRGB(void) const
{
    return false;
}

void StreakSprite::update(float delta)
{
    if (!_startingPositionInitialized)
    {
        return;
    }
    
    delta *= _fadeDelta;
    
    unsigned int newIdx, newIdx2, i;
    // Update current points
    for(i = 0; i<_nuPoints; i++)
    {
        _pointState[i] -= delta;
        
        if(_pointState[i] > 0)
        {
            newIdx = i;
            newIdx2 = newIdx*8;
            
            const GLubyte op = (GLubyte)(_pointState[newIdx] * 255.0f);
            _colorPointer[newIdx2+3] = op;
            _colorPointer[newIdx2+7] = op;
        }
    }
    
    // Append new point
    bool appendNewPoint = true;
    if(_nuPoints >= _maxPoints)
    {
        appendNewPoint = false;
    }
    
    else if(_nuPoints>0)
    {
        bool a1 = _pointVertexes[_nuPoints-1].getDistanceSq(_positionR) < _minSeg;
        bool a2 = (_nuPoints == 1) ? false : (_pointVertexes[_nuPoints-2].getDistanceSq(_positionR)< (_minSeg * 2.0f));
        if(a1 || a2)
        {
            appendNewPoint = false;
        }
    }
    
    if(appendNewPoint)
    {
        _pointVertexes[_nuPoints] = _positionR;
        _pointState[_nuPoints] = 1.0f;
        
        // Color assignment
        const unsigned int offset = _nuPoints*8;
        *((Color3B*)(_colorPointer + offset)) = _displayedColor;
        *((Color3B*)(_colorPointer + offset+4)) = _displayedColor;
        
        // Opacity
        _colorPointer[offset+3] = 255;
        _colorPointer[offset+7] = 255;
        
        // Generate polygon
        if(_nuPoints > 0 && _fastMode )
        {
            if(_nuPoints > 1)
            {
                ccVertexLineToPolygon(_pointVertexes, _stroke, _vertices, _nuPoints, 1);
            }
            else
            {
                ccVertexLineToPolygon(_pointVertexes, _stroke, _vertices, 0, 2);
            }
        }
        
        _nuPoints ++;
    }
    
    if( ! _fastMode )
    {
        ccVertexLineToPolygon(_pointVertexes, _stroke, _vertices, 0, _nuPoints);
    }
    
    
    // Updated Tex Coords only if they are different than previous step
    float distance = 0;
    float lastDistance = 0;
    if( _nuPoints  && _previousNuPoints != _nuPoints ) {
//        float texDelta = 1.0f / _nuPoints;
        for( i=0; i < _nuPoints; i++ ) {
            if(i==0)
            {
                lastDistance = 0;
            }
            else
            {
                lastDistance = _pointVertexes[i].getDistance(_pointVertexes[i-1])/_texHeight;
            }
            
            distance += lastDistance;
            
            _texCoords[i*2] = Tex2F(0, distance);
            _texCoords[i*2+1] = Tex2F(1, distance);
        }
        
        _previousNuPoints = _nuPoints;
    }
}

void StreakSprite::reset()
{
    _nuPoints = 0;
}

void StreakSprite::onDraw(const Mat4 &transform, uint32_t flags)
{
    getGLProgram()->use();
    getGLProgram()->setUniformsForBuiltins(transform);
    
    GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX );
    GL::blendFunc( _blendFunc.src, _blendFunc.dst );
    
    GL::bindTexture2D( _texture->getName() );
    
#ifdef EMSCRIPTEN
    // Size calculations from ::initWithFade
    setGLBufferData(_vertices, (sizeof(Vec2) * _maxPoints * 2), 0);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    setGLBufferData(_texCoords, (sizeof(Tex2F) * _maxPoints * 2), 1);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    setGLBufferData(_colorPointer, (sizeof(GLubyte) * _maxPoints * 2 * 4), 2);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, 0);
#else
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, _vertices);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, 0, _texCoords);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, _colorPointer);
#endif // EMSCRIPTEN
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nuPoints*2);
    CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, _nuPoints*2);
}

void StreakSprite::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
    if(_nuPoints <= 1)
        return;
    _customCommand.init(_globalZOrder, transform, flags);
    _customCommand.func = CC_CALLBACK_0(StreakSprite::onDraw, this, transform, flags);
    renderer->addCommand(&_customCommand);
}
