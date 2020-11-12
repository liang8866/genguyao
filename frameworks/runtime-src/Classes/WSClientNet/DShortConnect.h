#ifndef _WSCLIENTNET_DSHORTCONNECT_H_
#define _WSCLIENTNET_DSHORTCONNECT_H_

#include "cocos2d.h"
USING_NS_CC;

class DBuf;
class DShortConnect
{
public:
	DShortConnect();
	~DShortConnect();

public:
	void SendDBuf(const char* szFarAddr, unsigned int unPort, const char* szMsg,int nMsgLen);		// 向远端服务器发送信息，收到应答后关闭。
	void SendAppThreadMsg(unsigned char byMsgType, const char* szMsg = nullptr, int nMsgLen = 0);
	void SocketThreadProc();                    //给消息处理线程调用
	
private:
	bool Connect(const char* szFarAddr, unsigned int unPort);
	void Close();
	int Send(const char* pSendMsg, int nMsgLen);
	int Send_N(const char* buf, int nBufLen);

private:
	int m_socket;
	std::string m_strFarAddr;
	unsigned int m_unFarPort;

	bool m_bConnected;
	char* m_pBufRecv;

	DBuf* m_pSendDBuf;
	DBuf* m_pRecvDBuf;
};

#endif