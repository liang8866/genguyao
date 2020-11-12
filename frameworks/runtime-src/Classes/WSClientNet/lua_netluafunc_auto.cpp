#include "lua_netluafunc_auto.h"
#include "NetLuaFunc.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <unistd.h>
#else
#include <direct.h>
#endif


int lua_NetLuaFunc_NetLuaFunc_constructor(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif



	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		cobj = new NetLuaFunc();
		cobj->autorelease();
		int ID = (int)cobj->_ID;
		int* luaID = &cobj->_luaID;
		toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj, "NetLuaFunc");
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "NetLuaFunc", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_constructor'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_create(lua_State* tolua_S)
{
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0)
	{
		if (!ok)
			return 0;
		NetLuaFunc* ret = NetLuaFunc::create();
		object_to_luaval<NetLuaFunc>(tolua_S, "NetLuaFunc", (NetLuaFunc*)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_create'.", &tolua_err);
#endif
	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_init(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_init'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		bool ret = cobj->init();
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "init", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFuncc_NetLuaFunc_init'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_readRecvByte(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvByte'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		uint16_t ret = cobj->readRecvByte();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvByte", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvByte'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_readRecvShort(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvShort'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		int32_t ret = cobj->readRecvShort();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvShort", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvShort'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_readRecvInt(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvInt'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		int ret = cobj->readRecvInt();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvInt", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvInt'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_readRecvUint32(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvUint32'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		unsigned int ret = cobj->readRecvUint32();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvUint32", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvUint32'.", &tolua_err);
#endif

	return 0;
}
int lua_NetLuaFunc_NetLuaFunc_readRecvDouble(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvDouble'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		double ret = cobj->readRecvDouble();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvDouble", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvDouble'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_readRecvString(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_readRecvString'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		std::string ret = cobj->readRecvString();
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "readRecvString", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_readRecvString'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendByte(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendByte'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		uint16_t arg0;

		ok &= luaval_to_uint16(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendByte(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendByte", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendByte'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendShort(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendShort'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		int32_t arg0;

		ok &= luaval_to_int32(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendShort(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendShort", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendShort'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendInt(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendInt'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		int arg0;

		ok &= luaval_to_int32(tolua_S, 2, (int *)&arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendInt(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendInt", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendInt'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendUint32(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendUint32'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		unsigned int arg0;

		ok &= luaval_to_uint32(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendUint32(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendUint32", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendUint32'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendDouble(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendDouble'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		double arg0;

		ok &= luaval_to_number(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendDouble(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendDouble", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendDouble'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_writeSendString(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_writeSendString'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		bool ret = cobj->writeSendString(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "writeSendString", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_writeSendString'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_beginSendBuf(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_beginSendBuf'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		unsigned int arg0;
		
		ok &= luaval_to_uint32(tolua_S, 2, &arg0);
		
		if (!ok)
			return 0;
		cobj->beginSendBuf(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "beginSendBuf", argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_beginSendBuf'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_endSendBuf(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_endSendBuf'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		cobj->endSendBuf();
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "endSendBuf", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_endSendBuf'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_sendSvrBuf(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_sendSvrBuf'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 3)
	{
		std::string arg0;
		unsigned int arg1;
        bool arg2;
				
		ok &= luaval_to_std_string(tolua_S, 2, &arg0);
		ok &= luaval_to_uint32(tolua_S, 3, &arg1);
        ok &= luaval_to_boolean(tolua_S, 4, &arg2);

		if (!ok)
			return 0;
		cobj->sendSvrBuf(arg0,arg1,arg2);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "sendSvrBuf", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_sendSvrBuf'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_downloadFile(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_downloadFile'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 3)
	{
		std::string arg0;
		std::string arg1;
		bool arg2;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0);
		ok &= luaval_to_std_string(tolua_S, 3, &arg1);
		ok &= luaval_to_boolean(tolua_S, 4, &arg2);

		if (!ok)
			return 0;
		cobj->downloadFile(arg0.c_str(), arg1.c_str(), arg2);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "downloadFile", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_downloadFile'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_getOutFile(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_getOutFile'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		std::string ret = cobj->getOutFile();
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getOutFile", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_getOutFile'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_getStrRet(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_getStrRet'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		std::string ret = cobj->getStrRet();
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getStrRet", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_getStrRet'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_endGame(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_endGame'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8) || (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
		MessageBox("You pressed the close button. Windows Store Apps do not implement a close button.", "Alert");
		return;
#endif

		Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		exit(0);
#endif

		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getStrRet", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_endGame'.", &tolua_err);
#endif

	return 0;
}

int lua_NetLuaFunc_NetLuaFunc_getCurPath(lua_State* tolua_S)
{
	int argc = 0;
	NetLuaFunc* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "NetLuaFunc", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (NetLuaFunc*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_NetLuaFunc_NetLuaFunc_getCurPath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;

		char buf[260] = { 0 };

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		getcwd(buf, sizeof(buf));
#else
		_getcwd(buf, sizeof(buf));
#endif
		std::string ret = buf;
		tolua_pushcppstring(tolua_S, ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getStrRet", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_NetLuaFunc_NetLuaFunc_getCurPath'.", &tolua_err);
#endif

	return 0;
}

static int lua_NetLuaFunc_NetLuaFunc_finalize(lua_State* tolua_S)
{
	printf("luabindings: finalizing LUA object (NetLuaFunc)");
	return 0;
}

int lua_register_NetLuaFunc_NetLuaFunc(lua_State* tolua_S)
{
	tolua_usertype(tolua_S, "NetLuaFunc");
	tolua_cclass(tolua_S, "NetLuaFunc", "NetLuaFunc", "cc.Ref", nullptr);

	tolua_beginmodule(tolua_S, "NetLuaFunc");	
	tolua_function(tolua_S, "new", lua_NetLuaFunc_NetLuaFunc_constructor);
	tolua_function(tolua_S, "create", lua_NetLuaFunc_NetLuaFunc_create);
	tolua_function(tolua_S, "init", lua_NetLuaFunc_NetLuaFunc_init);
	tolua_function(tolua_S, "readRecvByte", lua_NetLuaFunc_NetLuaFunc_readRecvByte);
	tolua_function(tolua_S, "readRecvShort", lua_NetLuaFunc_NetLuaFunc_readRecvShort);
	tolua_function(tolua_S, "readRecvInt", lua_NetLuaFunc_NetLuaFunc_readRecvInt);
	tolua_function(tolua_S, "readRecvUint32", lua_NetLuaFunc_NetLuaFunc_readRecvUint32);
	tolua_function(tolua_S, "readRecvDouble", lua_NetLuaFunc_NetLuaFunc_readRecvDouble);
	tolua_function(tolua_S, "readRecvString", lua_NetLuaFunc_NetLuaFunc_readRecvString);
	tolua_function(tolua_S, "writeSendByte", lua_NetLuaFunc_NetLuaFunc_writeSendByte);
	tolua_function(tolua_S, "writeSendShort", lua_NetLuaFunc_NetLuaFunc_writeSendShort);
	tolua_function(tolua_S, "writeSendInt", lua_NetLuaFunc_NetLuaFunc_writeSendInt);
	tolua_function(tolua_S, "writeSendUint32", lua_NetLuaFunc_NetLuaFunc_writeSendUint32);
	tolua_function(tolua_S, "writeSendDouble", lua_NetLuaFunc_NetLuaFunc_writeSendDouble);
	tolua_function(tolua_S, "writeSendString", lua_NetLuaFunc_NetLuaFunc_writeSendString);
	tolua_function(tolua_S, "beginSendBuf", lua_NetLuaFunc_NetLuaFunc_beginSendBuf);
	tolua_function(tolua_S, "endSendBuf", lua_NetLuaFunc_NetLuaFunc_endSendBuf);
	tolua_function(tolua_S, "sendSvrBuf", lua_NetLuaFunc_NetLuaFunc_sendSvrBuf);			
	tolua_function(tolua_S, "downloadFile", lua_NetLuaFunc_NetLuaFunc_downloadFile);
	tolua_function(tolua_S, "getOutFile", lua_NetLuaFunc_NetLuaFunc_getOutFile);
	tolua_function(tolua_S, "getStrRet", lua_NetLuaFunc_NetLuaFunc_getStrRet);
	tolua_function(tolua_S, "endGame", lua_NetLuaFunc_NetLuaFunc_endGame);
	tolua_function(tolua_S, "getCurPath", lua_NetLuaFunc_NetLuaFunc_getCurPath);
	tolua_endmodule(tolua_S);

	std::string typeName = typeid(NetLuaFunc).name();
	g_luaType[typeName] = "NetLuaFunc";
	g_typeCast["NetLuaFunc"] = "NetLuaFunc";
	return 1;
}

TOLUA_API int register_all_NetLuaFunc(lua_State* tolua_S)
{
	tolua_open(tolua_S);

	tolua_module(tolua_S, "NetLuaFunc", 0);
	tolua_beginmodule(tolua_S, "NetLuaFunc");

	lua_register_NetLuaFunc_NetLuaFunc(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}