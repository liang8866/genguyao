#include "base/ccConfig.h"
#ifndef _LUA_NETLUAFUNC_AUTO_H_
#define _LUA_NETLUAFUNC_AUTO_H_

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_all_NetLuaFunc(lua_State* tolua_S);

#endif