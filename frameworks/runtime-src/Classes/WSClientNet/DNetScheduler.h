#ifndef _WSCLIENTNET_DNETSCHEDULER_H_
#define _WSCLIENTNET_DNETSCHEDULER_H_

#include "cocos2d.h"
USING_NS_CC;

extern "C" {
#include "lua.h"
}

class DBuf;
class DLongConnect;
class Httpdownload;
class DNetScheduler : public Ref
{
public:
	typedef std::vector<DBuf*> VecMsgBufPtr;
private:
	DNetScheduler();
	~DNetScheduler();
public:
	static DNetScheduler* Instance();

	void mainLoop(float dt);
	void InitLua(lua_State* L);
	void PushNetBufToList(DBuf* pBuf, bool bInHead = false);
	DBuf* GetRecvDBuf(){ return m_pRecvBuf; };
	DBuf* GetSendDBuf(){ return m_pSendBuf; };
	void SendBufToSvr(const char* szFarAddr,unsigned int unPort,bool bDirect);  // 第三个参数是表示是否不经过队列，直接发送
	void DownloadFile(const char* url, const char* path, bool bFile = true);
	std::string getOutFile();
	std::string getStrRet();

public:
	bool CallLuaOnNetRecvMsg(DBuf* pRecvBuf);
	bool CallLuaOnNetError();
    bool CallLuaOnEnterBackground();
    bool CallLuaOnWillEnterForeground();
	void ShowCallLuaError(const char* szFuncName);

private:
	VecMsgBufPtr m_vecBuf;
	std::mutex m_mxVecBuf;
    VecMsgBufPtr m_vecSendBuf;          // 发送DBuf池，来自LUA，单线程，不加锁
	DBuf* m_pRecvBuf;
	DBuf* m_pSendBuf;
	DLongConnect* m_pConn;
	lua_State* m_L;
    
    std::string m_strFarAddr;
    unsigned int m_unFarPort;

	Httpdownload* m_pHttp;
};

#endif