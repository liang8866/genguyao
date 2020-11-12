//
//  TestScene.cpp
//  GameClient
//
//  Created by apple01 on 15/9/21.
//
//

#include "TestScene.h"

Scene* TestScene::createScene()
{
    Scene* scene = Scene::create();
    auto layer = TestScene::create();
    scene->addChild(layer);
    return scene;
}

bool TestScene::init()
{
    if(!Layer::init())
    {
        return false;
    }
    
    _listener = EventListenerTouchOneByOne::create();
    _listener->onTouchBegan = CC_CALLBACK_2(TestScene::onTouchBegan, this);
    _listener->onTouchMoved = CC_CALLBACK_2(TestScene::onTouchMoved, this);
    _listener->onTouchEnded = CC_CALLBACK_2(TestScene::onTouchEnded, this);
    _eventDispatcher->addEventListenerWithSceneGraphPriority(_listener, this);
    
    _wind = WindSprite::create("res/effect/shoot_dazhao_5.png");
    this->addChild(_wind);
    
    Size size = Director::getInstance()->getWinSize();
    _startPos = Vec2(0, size.height/2);
    _endPos = Vec2(1024, size.height/2);
    
    _wind->setPosition(_startPos);
    _duration = 0;
    _distance = 1024;
    scheduleUpdate();
    
    return true;
}

void TestScene::update(float dt)
{
//    return;
    _duration += dt;
    float percent = _duration/3.0f;
    
    auto curPos = _wind->getPosition();
    float x = _startPos.x + _distance * percent;
    float y = _startPos.y + sinf(percent*3.1415926f) * 250;
    _wind->setPosition(Vec2(x, y));
}

bool TestScene::onTouchBegan(Touch *touch, Event *unused_event)
{
    printf("onTouchBegan");
    return true;
}

void TestScene::onTouchMoved(Touch *touch, Event *unused_event)
{
    auto pos = touch->getLocation();
    _wind->setPosition(pos);
}

void TestScene::onTouchEnded(Touch *touch, Event *unused_event)
{
    
}