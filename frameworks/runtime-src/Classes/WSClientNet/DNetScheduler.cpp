#include "DNetScheduler.h"
#include "DBuf.h"
#include "DLongConnect.h"
#include "httpdownload.h"

DNetScheduler::DNetScheduler()
{
	CCLOG("DNetScheduler::DNetScheduler+++++++++++++++++++");

	m_pSendBuf = DBuf::TakeNewBuf();
	m_pRecvBuf = DBuf::TakeNewBuf();
	m_pConn = nullptr;
	m_L = nullptr;
    
    m_strFarAddr = "";
    m_unFarPort = 0;

	m_pHttp = nullptr;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	WSADATA wsaData;
	int n = WSAStartup(MAKEWORD(2, 2), &wsaData);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	CCLogIPAddresses();
#endif
#endif
}

DNetScheduler::~DNetScheduler()
{
	DBuf::BackBuf(&m_pRecvBuf);
	DBuf::BackBuf(&m_pSendBuf);
    if (m_pConn)
    {
        delete m_pConn;
        m_pConn = nullptr;
    }
	m_L = nullptr;
	
	if (m_pHttp)
	{
		delete m_pHttp;
		m_pHttp = nullptr;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	WSACleanup();
#else
#endif
}

DNetScheduler* DNetScheduler::Instance()
{
	static DNetScheduler s_inst;
	return &s_inst;
}

void DNetScheduler::mainLoop(float dt)
{
	VecMsgBufPtr tempVecBuf;
	// 先拷贝消息队列出来
	m_mxVecBuf.lock();
	for (int i = 0; i < m_vecBuf.size(); i++)
	{
		tempVecBuf.push_back(m_vecBuf[i]);
	}
	m_vecBuf.clear();
	m_mxVecBuf.unlock();

	unsigned char byBufType = 0;
	for (int i = 0; i < tempVecBuf.size(); i++)
	{
		DBuf* pRecvBuf = tempVecBuf[i];
		byBufType = pRecvBuf->m_byBufType;
		if (byBufType == DBufType::eNetError)                 //网络错误
		{
		    // 关闭网络
            if (m_pConn)
            {
                delete m_pConn;
                m_pConn = nullptr;
            }
			// 调用LUA 函数
			this->CallLuaOnNetError();
		}
		else if (byBufType == DBufType::eNetClientNormalMsg)
		{
			CallLuaOnNetRecvMsg(tempVecBuf[i]);
		}
		else
		{
			CCLOG("DNetScheduler::mainLoop.非法的DBufType类型");
		}
		DBuf::BackBuf(&pRecvBuf);        // 在 DLongConnect::SendAppThreadMsg TakeNewBuf
	}
    
    //把发送队列的消息发送出去
    if ((m_pConn) && (m_pConn->IsConnect()))
    {
        for (int i = 0; i < m_vecSendBuf.size(); i++)
        {
            DBuf* pSendBuf = m_vecSendBuf[i];
            m_pConn->Send(pSendBuf->GetBuf(), pSendBuf->GetLength());
            DBuf::BackBuf(&pSendBuf);   // DNetScheduler::SendBufToSvr获取
        }
        m_vecSendBuf.clear();
    }
}

void DNetScheduler::InitLua(lua_State* L)
{
	m_L = L;
}

void DNetScheduler::PushNetBufToList(DBuf* pBuf, bool bInHead)
{
	m_mxVecBuf.lock();
	if (bInHead)
		m_vecBuf.insert(m_vecBuf.begin(), pBuf);
	else
		m_vecBuf.push_back(pBuf);
	m_mxVecBuf.unlock();
}

bool DNetScheduler::CallLuaOnNetRecvMsg(DBuf* pRecvBuf)
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	p->Attach(pRecvBuf->GetBuf(), pRecvBuf->GetLength());
	lua_getglobal(m_L, "OnNetRecvMsg");
	if (lua_pcall(m_L, 0, 0, 0) != 0)
	{
		ShowCallLuaError("OnNetRecvMsg");
		return false;
	}

	return true;
}

void DNetScheduler::SendBufToSvr(const char* szFarAddr, unsigned int unPort,bool bDirect)
{
    std::string strTemp = szFarAddr;
    if ((m_strFarAddr != strTemp) || (m_unFarPort != unPort))
    {
        m_strFarAddr = strTemp;
        m_unFarPort = unPort;
        if (m_pConn)
        {
            delete m_pConn;
            m_pConn = nullptr;
        }
        m_pConn = new DLongConnect(m_strFarAddr.c_str(),m_unFarPort);
    }
    if (m_pConn == nullptr)
        m_pConn = new DLongConnect(m_strFarAddr.c_str(),m_unFarPort);
    
    if (bDirect)
    {
        if ((m_pConn) && (m_pConn->IsConnect()))
            m_pConn->Send(m_pSendBuf->GetBuf(), m_pSendBuf->GetLength());
    }
    else
    {
        DBuf* pSendBuf = DBuf::TakeNewBuf();        //DNetScheduler::mainLoop回收
        pSendBuf->WriteBuffer(m_pSendBuf->GetBuf(), m_pSendBuf->GetLength());
        m_vecSendBuf.push_back(pSendBuf);
    }
}

void DNetScheduler::DownloadFile(const char* url, const char* path, bool bFile)
{
	if (m_pHttp == NULL)
		m_pHttp = new Httpdownload();

	m_pHttp->start(url, path, bFile);
}

std::string DNetScheduler::getOutFile()
{
	if (m_pHttp)
		return m_pHttp->getOutFile();
	else
		return std::string("");
}

std::string DNetScheduler::getStrRet()
{
	if (m_pHttp)
		return m_pHttp->getStrRet();
	else
		return std::string("");
}

bool DNetScheduler::CallLuaOnNetError()
{
	lua_getglobal(m_L, "OnNetError");
	if (lua_pcall(m_L, 0, 0, 0) != 0)
	{
		ShowCallLuaError("OnNetError");
		return false;
	}

	return true;
}

bool DNetScheduler::CallLuaOnEnterBackground()
{
    lua_getglobal(m_L, "OnEnterBackground");
    if (lua_pcall(m_L, 0, 0, 0) != 0)
    {
        ShowCallLuaError("OnEnterBackground");
        return false;
    }
    
    return true;
}

bool DNetScheduler::CallLuaOnWillEnterForeground()
{
    lua_getglobal(m_L, "OnWillEnterForeground");
    if (lua_pcall(m_L, 0, 0, 0) != 0)
    {
        ShowCallLuaError("OnWillEnterForeground");
        return false;
    }
    
    return true;
}

void DNetScheduler::ShowCallLuaError(const char* szFuncName)
{
	std::string s = "c++ call lua error.function name:";
	s += szFuncName;
	s += " ";
	s += lua_tostring(m_L, -1);
	CCLOG("%s",s.c_str());
}
