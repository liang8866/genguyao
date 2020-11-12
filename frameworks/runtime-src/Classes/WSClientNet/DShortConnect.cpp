#include "DShortConnect.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <io.h>
#include <WS2tcpip.h>
#include <Winsock2.h>
#else
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#endif
#include "DNetMsgBase.h"
#include "DBuf.h"
#include "DNetScheduler.h"

DShortConnect::DShortConnect()
{
	m_socket = -1;
	m_bConnected = false;
	m_pBufRecv = new char[NETIOBUFLEN];

	m_strFarAddr = "";
	m_unFarPort = 0;

	m_pSendDBuf = DBuf::TakeNewBuf();
	m_pRecvDBuf = DBuf::TakeNewBuf();
}

DShortConnect::~DShortConnect()
{
	Close();

	delete[]  m_pBufRecv;
	m_pBufRecv = nullptr;

	DBuf::BackBuf(&m_pSendDBuf);
	DBuf::BackBuf(&m_pRecvDBuf);
}

void DShortConnect::SendDBuf(const char* szFarAddr, unsigned int unPort, const char* szMsg, int nMsgLen)
{
	if (m_bConnected)
		return;

	if ((!szFarAddr) || (unPort == 0))
		return;

	m_strFarAddr = szFarAddr;
	m_unFarPort = unPort;

	m_pSendDBuf->FreeBuf();
	m_pSendDBuf->WriteBuffer(szMsg, nMsgLen);

	//创建接收线程
	std::thread threadproc = std::thread(&DShortConnect::SocketThreadProc, this);
	threadproc.detach();
}

void DShortConnect::SendAppThreadMsg(unsigned char byMsgType, const char* szMsg, int nMsgLen)
{
	DBuf* pNewBuf = DBuf::TakeNewBuf();         //DNetScheduler::mainLoop()中回收
	if (pNewBuf->SetNetMsg(byMsgType, szMsg, nMsgLen))
		DNetScheduler::Instance()->PushNetBufToList(pNewBuf);
	else
		DBuf::BackBuf(&pNewBuf);
}

void DShortConnect::SocketThreadProc()
{
	int nRecvLen = 0, nMsgLen = 0;
	unsigned int utRead = 0;
	if (Connect(m_strFarAddr.c_str(), m_unFarPort) == false)
		goto errhandle;

	// 发送消息
	if (Send(m_pSendDBuf->GetBuf(), m_pSendDBuf->GetLength()) != 0)
		goto errhandle;

	// 接收消息
	m_pRecvDBuf->FreeBuf();
	memset(m_pBufRecv, 0, NETIOBUFLEN);
	nRecvLen = recv(m_socket, m_pBufRecv, NETMSG_HEADER_LEN, 0);		// 读取包头
	if (nRecvLen != NETMSG_HEADER_LEN)
	{
		CCLOG("DShortConnect::SendDBuf,接收到的消息包头错误");
		goto errhandle;
	}
	m_pRecvDBuf->Attach(m_pBufRecv, nRecvLen);
	if (m_pRecvDBuf->ReadUint32(utRead))
	{
		if (utRead != NET_MSG_TAG)
		{
			CCLOG("DShortConnect::SendDBuf,接收到的消息包头错误");
			goto errhandle;
		}
		m_pRecvDBuf->ReadUint32(utRead);
		if ((utRead >= MAX_NETMSG_LEN) || (utRead < NETMSG_HEADER_LEN))
		{
			CCLOG("DShortConnect::SendDBuf,接收到的消息长度不对");
			goto errhandle;
		}
		nMsgLen = utRead;
		// 继续把消息接收完
		int nRecvLen2 = (nMsgLen - NETMSG_HEADER_LEN);
		if (nRecvLen2 > 0)
		{
			nRecvLen = recv(m_socket, m_pBufRecv + NETMSG_HEADER_LEN, nRecvLen2, 0);
			if (nRecvLen != nRecvLen2)
			{
				CCLOG("DShortConnect::SendDBuf,接收到的消息长度不对2");
				goto errhandle;
			}
		}
		m_pRecvDBuf->FreeBuf();
		m_pRecvDBuf->WriteBuffer(m_pBufRecv, nMsgLen);

		SendAppThreadMsg(DBufType::eNetClientNormalMsg, m_pRecvDBuf->GetBuf(), m_pRecvDBuf->GetLength());

		Close();		//接到消息后就关闭
		return;
	}
	else
		goto errhandle;

errhandle:
	Close();
	SendAppThreadMsg(DBufType::eNetError, nullptr, 0);
}

bool DShortConnect::Connect(const char* szFarAddr, unsigned int unPort)
{
	Close();
	//判断参数
	if (!szFarAddr || (unPort == 0))
		return false;
	//根据dns获取ip
	struct hostent* lphost = gethostbyname(szFarAddr);
	if (lphost == nullptr)
	{
		CCLOG("DShortConnect::Connect gethostbynane failed");
		return false;
	}
	if (lphost->h_length <= 0)
	{
		CCLOG("DShortConnect::Connect gethostbynane failed.h_length");
		return false;
	}

	//创建SOCKET
	m_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (m_socket == 0)
    {
        CCLOG("DLongConnect::Connect socket failed");
        return false;
    }
	// 设置发送接收超时.5秒
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	int nNetTimeout = 5000;
	setsockopt(m_socket, SOL_SOCKET, SO_SNDTIMEO, (char*)&nNetTimeout, sizeof(int));
	setsockopt(m_socket, SOL_SOCKET, SO_RCVTIMEO, (char*)&nNetTimeout, sizeof(int));
#else
	struct timeval ti;   
	ti.tv_sec = 5;
	ti.tv_usec = 0;
	setsockopt(m_socket, SOL_SOCKET, SO_SNDTIMEO, &ti, sizeof(ti));
	setsockopt(m_socket, SOL_SOCKET, SO_RCVTIMEO, &ti, sizeof(ti));
#endif

	//连接
	struct sockaddr_in saServer;
	memset(&saServer, 0, sizeof(sockaddr_in));
	saServer.sin_family = AF_INET;
	saServer.sin_port = htons(unPort);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	saServer.sin_addr.s_addr = ((LPIN_ADDR)lphost->h_addr)->s_addr;;
#else
	saServer.sin_addr.s_addr = *(unsigned int*)lphost->h_addr;
#endif
	if (-1 == connect(m_socket, (sockaddr*)&saServer, sizeof(saServer)))
	{
		return false;
    }

	std::this_thread::sleep_for(std::chrono::milliseconds(10));

	m_bConnected = true;		//表示已经连接上

	return true;
}

void DShortConnect::Close()
{
	if (!m_bConnected)
		return;

	m_bConnected = false;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	closesocket(m_socket);
#else
	close(m_socket);
#endif
	m_socket = -1;
}

int DShortConnect::Send(const char* pSendMsg, int nMsgLen)
{
	// 连接被关闭
	if (!m_bConnected)
		return 1;
	//首先进行消息合法判断
	if (nMsgLen >= MAX_NETMSG_LEN)
	{
		CCLOG("DShortConnect::Send,发送的网络消息大于最大消息长度");
		return 2;
	}

	//每次只发送NETIOBUFLEN定义的长度-1
	int nSendBufLen = 0;
	while (nSendBufLen < nMsgLen)
	{
		int nLeftLen = nMsgLen - nSendBufLen;
		int nNeedSendLen = nLeftLen >(NETIOBUFLEN - 1) ? (NETIOBUFLEN - 1) : nLeftLen;
		Send_N(pSendMsg + nSendBufLen, nNeedSendLen);
		nSendBufLen += nNeedSendLen;
	}

	return 0;
}

int DShortConnect::Send_N(const char* buf, int nBufLen)
{
	if ((!buf) || (nBufLen < 1))
		return -1;

	for (int s = 0, t = 0;;)
	{
		t = send(m_socket, buf + s, nBufLen - s, 0);
		if (t < 1)
			return -1;
		s += t;
		if (nBufLen == s)
			return s;

		std::this_thread::sleep_for(std::chrono::milliseconds(2));	//暂定值
	}

	return -1;
}