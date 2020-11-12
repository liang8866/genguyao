//
//  WindSprite.cpp
//  GameClient
//
//  Created by apple01 on 15/9/23.
//
//

#include "WindSprite.h"

WindSprite::WindSprite()
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

WindSprite::~WindSprite()
{
    CC_SAFE_RELEASE(_texture);
    CC_SAFE_FREE(_pointState);
    CC_SAFE_FREE(_pointVertexes);
    CC_SAFE_FREE(_vertices);
    CC_SAFE_FREE(_colorPointer);
    CC_SAFE_FREE(_texCoords);
}

WindSprite* WindSprite::create(const std::string& path)
{
    WindSprite *ret = new (std::nothrow) WindSprite();
    if (ret && ret->initWithFade(path))
    {
        ret->autorelease();
        return ret;
    }
    
    CC_SAFE_DELETE(ret);
    return nullptr;
}

WindSprite* WindSprite::create(Texture2D* texture)
{
    WindSprite *ret = new (std::nothrow) WindSprite();
    if (ret && ret->initWithFade(texture))
    {
        ret->autorelease();
        return ret;
    }
    
    CC_SAFE_DELETE(ret);
    return nullptr;
}

bool WindSprite::initWithFade(const std::string& path)
{
    CCASSERT(!path.empty(), "Invalid filename");
    
    Texture2D *texture = Director::getInstance()->getTextureCache()->addImage(path);
//    texture->setTexParameters(Texture2D::TexParams{GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT});
    return initWithFade(texture);
}

bool WindSprite::initWithFade(Texture2D* texture)
{
    _pause = false;
    
    Node::setPosition(Vec2::ZERO);
    setAnchorPoint(Vec2::ZERO);
    ignoreAnchorPointForPosition(true);
    _startingPositionInitialized = false;
    
    _texHeight = texture->getPixelsHigh();
    
    _positionR = Vec2::ZERO;
    _fastMode = true;
    _minSeg = 1;
    _minSeg *= _minSeg;
    
    _stroke = texture->getPixelsWide();
    _fadeDelta = 0.2;
    
    _maxPoints = 500;
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
    scheduleUpdate();
    
    
    
    return true;
}

void WindSprite::setPosition(const Vec2& position)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR = position;
}

void WindSprite::setPosition(float x, float y)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.x = x;
    _positionR.y = y;
}

const Vec2& WindSprite::getPosition() const
{
    return _positionR;
}

void WindSprite::getPosition(float* x, float* y) const
{
    *x = _positionR.x;
    *y = _positionR.y;
}

float WindSprite::getPositionX() const
{
    return _positionR.x;
}

void WindSprite::setPositionX(float x)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.x = x;
}

float WindSprite::getPositionY() const
{
    return  _positionR.y;
}

void WindSprite::setPositionY(float y)
{
    if (!_startingPositionInitialized) {
        _startingPositionInitialized = true;
    }
    _positionR.y = y;
}

void WindSprite::tintWithColor(const Color3B& colors)
{
    setColor(colors);
    
    // Fast assignation
    for(unsigned int i = 0; i<_nuPoints*2; i++)
    {
        *((Color3B*) (_colorPointer+i*4)) = colors;
    }
}

Texture2D* WindSprite::getTexture(void) const
{
    return _texture;
}

void WindSprite::setTexture(Texture2D *texture)
{
    if (_texture != texture)
    {
        CC_SAFE_RETAIN(texture);
        CC_SAFE_RELEASE(_texture);
        _texture = texture;
    }
}

void WindSprite::setBlendFunc(const BlendFunc &blendFunc)
{
    _blendFunc = blendFunc;
}

const BlendFunc& WindSprite::getBlendFunc(void) const
{
    return _blendFunc;
}

void WindSprite::setOpacity(GLubyte opacity)
{
    CCASSERT(false, "Set opacity no supported");
}

GLubyte WindSprite::getOpacity(void) const
{
    CCASSERT(false, "Opacity no supported");
    return 0;
}

void WindSprite::setOpacityModifyRGB(bool bValue)
{
    CC_UNUSED_PARAM(bValue);
}

bool WindSprite::isOpacityModifyRGB(void) const
{
    return false;
}

void WindSprite::update(float delta)
{
    if(_pause==true) {
        
        return;
    }
    
    if (!_startingPositionInitialized)
    {
        return;
    }
    unsigned int newIdx, newIdx2, i, i2;
    unsigned int mov = 1;
    
    
    if(_nuPoints>=_maxPoints)
    {
        // Update current points
        for(i = 1; i<_nuPoints; i++)
        {
            newIdx = i-mov;
            
            // Move point
            _pointVertexes[newIdx] = _pointVertexes[i];
                
            // Move vertices
            i2 = i*2;
            newIdx2 = newIdx*2;
            _vertices[newIdx2] = _vertices[i2];
            _vertices[newIdx2+1] = _vertices[i2+1];
                
            // Move color
            i2 *= 4;
            newIdx2 *= 4;
            _colorPointer[newIdx2+0] = _colorPointer[i2+0];
            _colorPointer[newIdx2+1] = _colorPointer[i2+1];
            _colorPointer[newIdx2+2] = _colorPointer[i2+2];
            _colorPointer[newIdx2+4] = _colorPointer[i2+4];
            _colorPointer[newIdx2+5] = _colorPointer[i2+5];
            _colorPointer[newIdx2+6] = _colorPointer[i2+6];
        }
        _nuPoints-=mov;
    }
    
    // Append new point
    bool appendNewPoint = true;
    if(_nuPoints >= _maxPoints)
    {
        appendNewPoint = false;
    }
//    else if(_nuPoints>0)
//    {
//        bool a1 = _pointVertexes[_nuPoints-1].getDistanceSq(_positionR) < 2;
//        bool a2 = (_nuPoints == 1) ? false : (_pointVertexes[_nuPoints-2].getDistanceSq(_positionR)< (2 * 2.0f));
//        if(a1 || a2)
//        {
//            appendNewPoint = false;
//        }
//    }
    
    if(appendNewPoint)
    {
        _pointVertexes[_nuPoints] = _positionR;
        
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
    if( _nuPoints  && _previousNuPoints != _nuPoints ) {
//        float texDelta = 1.0f / _nuPoints;
        for(int i=_nuPoints-1; i >= 0; i-- ) {
            if(i!=(_nuPoints-1))
            {
                distance +=_pointVertexes[i].getDistance(_pointVertexes[i+1]);
            }
//            distance = _pointVertexes[i].getDistance(_positionR);
            if(distance<_texHeight)
            {
                _texCoords[i*2] = Tex2F(0, 1-distance/_texHeight);
                _texCoords[i*2+1] = Tex2F(1, 1-distance/_texHeight);
            }
        }
        
        _previousNuPoints = _nuPoints;
    }
}

void WindSprite::reset()
{
    _nuPoints = 0;
}

void WindSprite::onDraw(const Mat4 &transform, uint32_t flags)
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

void WindSprite::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
    if(_nuPoints <= 1)
        return;
    _customCommand.init(_globalZOrder, transform, flags);
    _customCommand.func = CC_CALLBACK_0(WindSprite::onDraw, this, transform, flags);
    renderer->addCommand(&_customCommand);
}
