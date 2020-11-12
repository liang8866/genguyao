//
//  DLongConnect.cpp
//  weishiGame
//
//  Created by apple03 on 15-9-18.
//
//

#include "DLongConnect.h"
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

DLongConnect::DLongConnect(const char* szFarAddr, unsigned int unPort)
{
    m_socket = -1;
    m_bConnected = false;
    m_pBufRecv = new char[NETIOBUFLEN];
    
    m_strFarAddr = szFarAddr;
    m_unFarPort = unPort;
    
    //创建连接线程
    std::thread threadproc = std::thread(&DLongConnect::ConnectThreadProc, this);
    threadproc.detach();
}

DLongConnect::~DLongConnect()
{
    Close();
    
    delete[]  m_pBufRecv;
    m_pBufRecv = nullptr;
}

int DLongConnect::Send(const char* pSendMsg, int nMsgLen)
{
    if (nMsgLen >= MAX_NETMSG_LEN)
    {
        CCLOG("DLongConnect::Send, message too long");
        return 1;
    }
    
    int nSendLen = Send_N(pSendMsg, nMsgLen);
    if (nSendLen != nMsgLen)
    {
        CCLOG("DLongConnect::Send, failed to send");
        SendAppThreadMsg(DBufType::eNetError);
        return 3;
    }
    
    return 0;
}

void DLongConnect::SendAppThreadMsg(unsigned char byMsgType, const char* szMsg, int nMsgLen)
{
    DBuf* pNewBuf = DBuf::TakeNewBuf();         //DNetScheduler::mainLoop()中回收
    if (pNewBuf->SetNetMsg(byMsgType, szMsg, nMsgLen))
        DNetScheduler::Instance()->PushNetBufToList(pNewBuf);
    else
        DBuf::BackBuf(&pNewBuf);
}

void DLongConnect::ConnectThreadProc()
{
    Connect();
    if (IsConnect() == false)
        SendAppThreadMsg(DBufType::eNetError);
}

void DLongConnect::RecvThreadProc()
{
    while (IsConnect())
    {
        memset(m_pBufRecv,0,NETIOBUFLEN);
        int nRecvLen = 0,nAllLen = 0;
        do
        {
            nRecvLen = recv(m_socket, m_pBufRecv + nAllLen, (NETIOBUFLEN - 1 - nAllLen), 0);
            if(nRecvLen > 0)
                nAllLen += nRecvLen;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
            int nErr = (int)GetLastError();
			if ((nErr != ERROR_SUCCESS) && (nErr != WSAEWOULDBLOCK))
#else
            int nErr = errno;
            if ((nErr != EAGAIN) && (nErr != ETIMEDOUT))
#endif
            {
                SendAppThreadMsg(DBufType::eNetError);
            }
                
            std::this_thread::sleep_for(std::chrono::milliseconds(2));	//暂定值
        }while((nRecvLen > 0) && (nAllLen < NETIOBUFLEN));
            //进行粘包处理
        if (nAllLen > 0)
            m_NetStream.DealWithSocketMsg(m_pBufRecv,nAllLen);
    }
        
    std::this_thread::sleep_for(std::chrono::milliseconds(5));	//暂定值
}

bool DLongConnect::IsConnect()
{
    bool bRet = false;
    m_mxConnect.lock();
    bRet = m_bConnected;
    m_mxConnect.unlock();
    
    return bRet;
}

bool DLongConnect::Connect()
{
    Close();
    //判断参数
    if (m_strFarAddr.length() == 0 || (m_unFarPort == 0))
        return false;
    //根据dns获取ip
    struct hostent* lphost = gethostbyname(m_strFarAddr.c_str());
    if (lphost == nullptr)
    {
        CCLOG("DLongConnect::Connect gethostbynane failed");
        return false;
    }
    if (lphost->h_length <= 0)
    {
        CCLOG("DLongConnect::Connect gethostbynane failed.h_length");
        return false;
    }
    
    //创建SOCKET
    m_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (m_socket == 0)
    {
        CCLOG("DLongConnect::Connect socket failed");
        return false;
    }
    // 设置SOCKET为非阻塞模式
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
    u_long ul = 1;
    if ( SOCKET_ERROR == ioctlsocket( m_socket, FIONBIO, &ul ) )
    {
        CCLOG("DLongConnect::Connect ioctlsocket error" );
        closesocket( m_socket );
        return false;
    }
#else
    int flags;
    flags = fcntl( m_socket, F_GETFL, 0);
    flags |= O_NONBLOCK;
    fcntl( m_socket, F_SETFL, flags );
#endif
    
    //连接
    struct sockaddr_in saServer;
    memset(&saServer, 0, sizeof(sockaddr_in));
    saServer.sin_family = AF_INET;
    saServer.sin_port = htons(m_unFarPort);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
    saServer.sin_addr.s_addr = ((LPIN_ADDR)lphost->h_addr)->s_addr;;
#else
    saServer.sin_addr.s_addr = *(unsigned int*)lphost->h_addr;
#endif
    if (-1 == connect(m_socket, (sockaddr*)&saServer, sizeof(saServer)))
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
         int nError = WSAGetLastError();
         if (nError != WSAEWOULDBLOCK)
         {
             closesocket(m_socket);
             CCLOG("DLongConnect::Connect connect failed" );
             return false;
         }
#else
         bool bconnect = false;
         int error = -1, len;
         len = sizeof(int);
         timeval tm;
         fd_set set;
         tm.tv_sec = 10;         // 超时设为10秒
         tm.tv_usec = 0;
         FD_ZERO(&set);
         FD_SET(m_socket, &set);
         if (select(m_socket + 1, NULL, &set, NULL, &tm) > 0)
         {
             getsockopt(m_socket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
             if (error == 0)
                bconnect = true;
             else
                 bconnect = false;
         }
         else
             bconnect = false;
         
         if (!bconnect)
         {
             close(m_socket);
             CCLOG("DLongConnect::Connect connect failed" );
             return false;
         }
#endif
    }
    
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    
    m_mxConnect.lock();
    m_bConnected = true;
    m_mxConnect.unlock();
    
    m_NetStream.Init(this);
    //创建接收线程
    std::thread threadproc = std::thread(&DLongConnect::RecvThreadProc, this);
    threadproc.detach();
    
    return true;
}

void DLongConnect::Close()
{
    m_mxConnect.lock();
    m_bConnected = false;
    m_mxConnect.unlock();

    if (m_socket > 0)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
        closesocket(m_socket);
#else
        close(m_socket);
#endif
    }
    m_socket = -1;
    // SLEEP段时间 ，等待RECV线程退出
    std::this_thread::sleep_for(std::chrono::milliseconds(300));
}

int DLongConnect::Send_N(const char* buf, int nBufLen)
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
