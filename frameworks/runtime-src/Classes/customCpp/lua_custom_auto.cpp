#include "lua_custom_auto.hpp"
#include "StreakSprite.h"
#include "WindSprite.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_custom_StreakSprite_reset(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_reset'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_reset'", nullptr);
            return 0;
        }
        cobj->reset();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:reset",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_reset'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_setTexture(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_setTexture'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Texture2D* arg0;

        ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_setTexture'", nullptr);
            return 0;
        }
        cobj->setTexture(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:setTexture",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_setTexture'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_getTexture(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_getTexture'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_getTexture'", nullptr);
            return 0;
        }
        cocos2d::Texture2D* ret = cobj->getTexture();
        object_to_luaval<cocos2d::Texture2D>(tolua_S, "cc.Texture2D",(cocos2d::Texture2D*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:getTexture",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_getTexture'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_tintWithColor(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_tintWithColor'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Color3B arg0;

        ok &= luaval_to_color3b(tolua_S, 2, &arg0, "StreakSprite:tintWithColor");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_tintWithColor'", nullptr);
            return 0;
        }
        cobj->tintWithColor(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:tintWithColor",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_tintWithColor'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_setBlendFunc(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_setBlendFunc'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::BlendFunc arg0;

        ok &= luaval_to_blendfunc(tolua_S, 2, &arg0, "StreakSprite:setBlendFunc");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_setBlendFunc'", nullptr);
            return 0;
        }
        cobj->setBlendFunc(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:setBlendFunc",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_setBlendFunc'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_setStartingPositionInitialized(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_setStartingPositionInitialized'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "StreakSprite:setStartingPositionInitialized");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_setStartingPositionInitialized'", nullptr);
            return 0;
        }
        cobj->setStartingPositionInitialized(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:setStartingPositionInitialized",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_setStartingPositionInitialized'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_getBlendFunc(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_getBlendFunc'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_getBlendFunc'", nullptr);
            return 0;
        }
        const cocos2d::BlendFunc& ret = cobj->getBlendFunc();
        blendfunc_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:getBlendFunc",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_getBlendFunc'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_isStartingPositionInitialized(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_isStartingPositionInitialized'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_isStartingPositionInitialized'", nullptr);
            return 0;
        }
        bool ret = cobj->isStartingPositionInitialized();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:isStartingPositionInitialized",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_isStartingPositionInitialized'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_isFastMode(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_isFastMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_isFastMode'", nullptr);
            return 0;
        }
        bool ret = cobj->isFastMode();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:isFastMode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_isFastMode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_setFastMode(lua_State* tolua_S)
{
    int argc = 0;
    StreakSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (StreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_StreakSprite_setFastMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "StreakSprite:setFastMode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_StreakSprite_setFastMode'", nullptr);
            return 0;
        }
        cobj->setFastMode(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "StreakSprite:setFastMode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_setFastMode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_StreakSprite_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"StreakSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 5)
        {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0, "StreakSprite:create");
            if (!ok) { break; }
            double arg1;
            ok &= luaval_to_number(tolua_S, 3,&arg1, "StreakSprite:create");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4,&arg2, "StreakSprite:create");
            if (!ok) { break; }
            cocos2d::Color3B arg3;
            ok &= luaval_to_color3b(tolua_S, 5, &arg3, "StreakSprite:create");
            if (!ok) { break; }
            cocos2d::Texture2D* arg4;
            ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 6, "cc.Texture2D",&arg4);
            if (!ok) { break; }
            StreakSprite* ret = StreakSprite::create(arg0, arg1, arg2, arg3, arg4);
            object_to_luaval<StreakSprite>(tolua_S, "StreakSprite",(StreakSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 5)
        {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0, "StreakSprite:create");
            if (!ok) { break; }
            double arg1;
            ok &= luaval_to_number(tolua_S, 3,&arg1, "StreakSprite:create");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4,&arg2, "StreakSprite:create");
            if (!ok) { break; }
            cocos2d::Color3B arg3;
            ok &= luaval_to_color3b(tolua_S, 5, &arg3, "StreakSprite:create");
            if (!ok) { break; }
            std::string arg4;
            ok &= luaval_to_std_string(tolua_S, 6,&arg4, "StreakSprite:create");
            if (!ok) { break; }
            StreakSprite* ret = StreakSprite::create(arg0, arg1, arg2, arg3, arg4);
            object_to_luaval<StreakSprite>(tolua_S, "StreakSprite",(StreakSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "StreakSprite:create",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_StreakSprite_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_custom_StreakSprite_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (StreakSprite)");
    return 0;
}

int lua_register_custom_StreakSprite(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"StreakSprite");
    tolua_cclass(tolua_S,"StreakSprite","StreakSprite","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"StreakSprite");
        tolua_function(tolua_S,"reset",lua_custom_StreakSprite_reset);
        tolua_function(tolua_S,"setTexture",lua_custom_StreakSprite_setTexture);
        tolua_function(tolua_S,"getTexture",lua_custom_StreakSprite_getTexture);
        tolua_function(tolua_S,"tintWithColor",lua_custom_StreakSprite_tintWithColor);
        tolua_function(tolua_S,"setBlendFunc",lua_custom_StreakSprite_setBlendFunc);
        tolua_function(tolua_S,"setStartingPositionInitialized",lua_custom_StreakSprite_setStartingPositionInitialized);
        tolua_function(tolua_S,"getBlendFunc",lua_custom_StreakSprite_getBlendFunc);
        tolua_function(tolua_S,"isStartingPositionInitialized",lua_custom_StreakSprite_isStartingPositionInitialized);
        tolua_function(tolua_S,"isFastMode",lua_custom_StreakSprite_isFastMode);
        tolua_function(tolua_S,"setFastMode",lua_custom_StreakSprite_setFastMode);
        tolua_function(tolua_S,"create", lua_custom_StreakSprite_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(StreakSprite).name();
    g_luaType[typeName] = "StreakSprite";
    g_typeCast["StreakSprite"] = "StreakSprite";
    return 1;
}

int lua_custom_WindSprite_reset(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_reset'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_reset'", nullptr);
            return 0;
        }
        cobj->reset();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:reset",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_reset'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_tintWithColor(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_tintWithColor'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Color3B arg0;

        ok &= luaval_to_color3b(tolua_S, 2, &arg0, "WindSprite:tintWithColor");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_tintWithColor'", nullptr);
            return 0;
        }
        cobj->tintWithColor(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:tintWithColor",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_tintWithColor'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_setPause(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_setPause'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "WindSprite:setPause");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_setPause'", nullptr);
            return 0;
        }
        cobj->setPause(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:setPause",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_setPause'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_setStartingPositionInitialized(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_setStartingPositionInitialized'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "WindSprite:setStartingPositionInitialized");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_setStartingPositionInitialized'", nullptr);
            return 0;
        }
        cobj->setStartingPositionInitialized(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:setStartingPositionInitialized",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_setStartingPositionInitialized'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_isStartingPositionInitialized(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_isStartingPositionInitialized'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_isStartingPositionInitialized'", nullptr);
            return 0;
        }
        bool ret = cobj->isStartingPositionInitialized();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:isStartingPositionInitialized",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_isStartingPositionInitialized'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_isFastMode(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_isFastMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_isFastMode'", nullptr);
            return 0;
        }
        bool ret = cobj->isFastMode();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:isFastMode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_isFastMode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_setFastMode(lua_State* tolua_S)
{
    int argc = 0;
    WindSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (WindSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_WindSprite_setFastMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "WindSprite:setFastMode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_WindSprite_setFastMode'", nullptr);
            return 0;
        }
        cobj->setFastMode(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "WindSprite:setFastMode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_setFastMode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_WindSprite_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"WindSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 1)
        {
            cocos2d::Texture2D* arg0;
            ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0);
            if (!ok) { break; }
            WindSprite* ret = WindSprite::create(arg0);
            object_to_luaval<WindSprite>(tolua_S, "WindSprite",(WindSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 1)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "WindSprite:create");
            if (!ok) { break; }
            WindSprite* ret = WindSprite::create(arg0);
            object_to_luaval<WindSprite>(tolua_S, "WindSprite",(WindSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "WindSprite:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_WindSprite_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_custom_WindSprite_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (WindSprite)");
    return 0;
}

int lua_register_custom_WindSprite(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"WindSprite");
    tolua_cclass(tolua_S,"WindSprite","WindSprite","cc.Sprite",nullptr);

    tolua_beginmodule(tolua_S,"WindSprite");
        tolua_function(tolua_S,"reset",lua_custom_WindSprite_reset);
        tolua_function(tolua_S,"tintWithColor",lua_custom_WindSprite_tintWithColor);
        tolua_function(tolua_S,"setPause",lua_custom_WindSprite_setPause);
        tolua_function(tolua_S,"setStartingPositionInitialized",lua_custom_WindSprite_setStartingPositionInitialized);
        tolua_function(tolua_S,"isStartingPositionInitialized",lua_custom_WindSprite_isStartingPositionInitialized);
        tolua_function(tolua_S,"isFastMode",lua_custom_WindSprite_isFastMode);
        tolua_function(tolua_S,"setFastMode",lua_custom_WindSprite_setFastMode);
        tolua_function(tolua_S,"create", lua_custom_WindSprite_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(WindSprite).name();
    g_luaType[typeName] = "WindSprite";
    g_typeCast["WindSprite"] = "WindSprite";
    return 1;
}
TOLUA_API int register_all_custom(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"cus",0);
	tolua_beginmodule(tolua_S,"cus");

	lua_register_custom_StreakSprite(tolua_S);
	lua_register_custom_WindSprite(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

