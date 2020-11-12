//
//  DLongConnect.h
//  weishiGame
//
//  Created by apple03 on 15-9-18.
//
//

#ifndef weishiGame_DLongConnect_h
#define weishiGame_DLongConnect_h

#include "cocos2d.h"
USING_NS_CC;

#include "DNetStream.h"

class DLongConnect
{
public:
    DLongConnect(const char* szFarAddr, unsigned int unPort);
    ~DLongConnect();
    
public:
    int Send(const char* pSendMsg, int nMsgLen);	// 向远端服务器发送信息，如果没有建立连接，先建立连接
    void SendAppThreadMsg(unsigned char byMsgType, const char* szMsg = nullptr, int nMsgLen = 0);
    void ConnectThreadProc();                   //Connect线程
    void RecvThreadProc();                    //recv线程
    bool IsConnect();
    
private:
    bool Connect();
    void Close();
    int Send_N(const char* buf, int nBufLen);
    
private:
    int m_socket;
    std::string m_strFarAddr;
    unsigned int m_unFarPort;
    
    bool m_bConnected;
    std::mutex m_mxConnect;
    char* m_pBufRecv;

    DNetStream	m_NetStream;			//粘包处理的结构体
};

#endif
