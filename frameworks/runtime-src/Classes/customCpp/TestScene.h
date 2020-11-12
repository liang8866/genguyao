//
//  TestScene.h
//  GameClient
//
//  Created by apple01 on 15/9/21.
//
//

#ifndef __GameClient__TestScene__
#define __GameClient__TestScene__

#include "cocos2d.h"
#include "WindSprite.h"

using namespace cocos2d;

class TestScene : public Layer
{
public:
    static Scene* createScene();
    CREATE_FUNC(TestScene);
    
    virtual bool init();
    
    virtual bool onTouchBegan(Touch *touch, Event *unused_event);
    virtual void onTouchMoved(Touch *touch, Event *unused_event);
    virtual void onTouchEnded(Touch *touch, Event *unused_event);
    
    void update(float dt);
    
private:
    EventListenerTouchOneByOne* _listener;
    WindSprite* _wind;
    Vec2 _startPos;
    Vec2 _endPos;
    float _duration;
    float _distance;
};

#endif /* defined(__GameClient__TestScene__) */
